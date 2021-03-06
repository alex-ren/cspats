/*
    Error-checking support functions
    AUP2, Sec. 1.04.2

    Copyright 2003 by Marc J. Rochkind. All rights reserved.
    May be copied only for purposes and under conditions described
    on the Web page www.basepath.com/aup/copyright.htm.

    The Example Files are provided "as is," without any warranty;
    without even the implied warranty of merchantability or fitness
    for a particular purpose. The author and his publisher are not
    responsible for any damages, direct or incidental, resulting
    from the use or non-use of these Example Files.

    The Example Files may contain defects, and some contain deliberate
    coding mistakes that were included for educational reasons.
    You are responsible for determining if and how the Example Files
    are to be used.

*/
// #include "defs.h"
//

#include "headers.h"
#include "ec.h"

#include <pthread.h>

// rzq: simplily print the error information to the screen
static void ec_mutex(bool lock)
{
    static pthread_mutex_t ec_mtx = PTHREAD_MUTEX_INITIALIZER;
    int errnum;
    char *msg;

    if (lock) {
        if ((errnum = pthread_mutex_lock(&ec_mtx)) == 0)
            return;
    }
    else {
        if ((errnum = pthread_mutex_unlock(&ec_mtx)) == 0)
            return;
    }
    if ((msg = strerror(errnum)) == NULL)
        fprintf(stderr, "Mutex error in ec_* function: %d\n", errnum);
    else
        fprintf(stderr, "Mutex error in ec_* function: %s\n", msg);
    exit(EXIT_FAILURE);
}

/*[ec_atexit_fcn]*/
static void ec_atexit_fcn(void)
{
    ec_print();
}
/*[ec_node]*/
static struct ec_node {
    struct ec_node *ec_next;
    int ec_errno;
    EC_ERRTYPE ec_type;
    char *ec_context;  // rzq: the location of error (file, line, and etc.
} *ec_head, ec_node_emergency;
static char ec_s_emergency[100];

const bool ec_in_cleanup = false;
/*[ec_push]*/

#define SEP1 " ["
#define SEP2 ":"
#define SEP3 "] "

void ec_push(const char *fcn, const char *file, int line,
  const char *str, int errno_arg, EC_ERRTYPE type)
{
    struct ec_node node, *p;
    size_t len;
    static bool attexit_called = false;

    ec_mutex(true);
    node.ec_errno = errno_arg;
    node.ec_type = type;
    if (str == NULL)
        str = "";
    len = strlen(fcn) + strlen(SEP1) + strlen(file) + strlen(SEP2) +
      6 + strlen(SEP3) + strlen(str) + 1;
    node.ec_context = (char *)calloc(1, len);
    if (node.ec_context == NULL) {
        if (ec_s_emergency[0] == '\0')
            node.ec_context = ec_s_emergency;
        else
            // rzq: why? Seems to be a bug.
            node.ec_context = "?";
        len = sizeof(ec_s_emergency);
    }
    if (node.ec_context != NULL)
        snprintf(node.ec_context, len, "%s%s%s%s%d%s%s", fcn, SEP1,
          file, SEP2, line, SEP3, str);
    p = (struct ec_node *)calloc(1, sizeof(struct ec_node));
    // rzq: When it fails for the second, no error msg would be recorded.
    if (p == NULL && ec_node_emergency.ec_context == NULL)
        p = &ec_node_emergency; /* use just once */
    if (p != NULL) {
        node.ec_next = ec_head;
        ec_head = p;
        *ec_head = node;
    }
    if (!attexit_called) {
        attexit_called = true;
        ec_mutex(false);
        if (atexit(ec_atexit_fcn) != 0) {
            ec_push(fcn, file, line, "atexit failed", errno, EC_ERRNO);
            ec_print(); /* so at least the error gets shown */
        }
    }
    else
        ec_mutex(false);
}
/*[ec_print]*/
void ec_print(void)
{
    struct ec_node *e;
    int level = 0;

    ec_mutex(true);
    for (e = ec_head; e != NULL; e = e->ec_next, level++) {
        char buf[300], buf2[25 + sizeof(buf)];

        if (e == &ec_node_emergency)
            fprintf(stderr, "\t*** Trace may be incomplete ***\n");
        syserrmsgtype(buf, sizeof(buf), e->ec_context,
          /* rzq: Only the innermost errno is meaningful. */
          /* 0 means no error at all, no matter what ec_type is */
          e->ec_next == NULL ? e->ec_errno : 0, e->ec_type);
        snprintf(buf2, sizeof(buf2), "%s\t%d: %s",
          // rzq: (level == 0? "ERROR:" : ""), level, buf);
           (e->ec_errno != 0? "ERROR:" : "TRACE:"), level, buf);
        fprintf(stderr, "%s\n", buf2);
        logfmt(buf2);
    }
    ec_mutex(false);
}
/*[ec_reinit]*/
void ec_reinit(void)
{
    struct ec_node *e, *e_next;

    ec_mutex(true);
    for (e = ec_head; e != NULL; e = e_next) {
        e_next = e->ec_next;
        if (e->ec_context != ec_s_emergency)
            free(e->ec_context);
        if (e != &ec_node_emergency)
            free(e);
    }
    ec_head = NULL;
    memset(&ec_node_emergency, 0, sizeof(ec_node_emergency));
    memset(&ec_s_emergency, 0, sizeof(ec_s_emergency));
    ec_mutex(false);
}
/*[ec_warn]*/
void ec_warn(void)
{
    fprintf(stderr, "***WARNING: Control flowed into EC_CLEANUP_BGN\n");
}
/*[]*/

void buffered_trace(const char *fcn, const char *file, int line,
  const char *format, ...)
{
    va_list ap;
    va_start(ap, format);
    buffered_trace_v(fcn, file, line, format, ap);
    va_end(ap);
    return;
}


void buffered_trace_v(const char *fcn, const char *file, int line,
  const char *format, va_list ap)
{
    struct ec_node node, *p;
    size_t len = 0;
    static bool attexit_called = false;

    ec_mutex(true);

#define BUFFER_SZ 300
    static char buffer[BUFFER_SZ] = {};

    len = snprintf(buffer, BUFFER_SZ, "%s [%s:%d] [tid:%6u] ", 
                   fcn, file, line, pthread_self());
    len += vsnprintf(buffer + len, BUFFER_SZ - len, format, ap);

    len += 1;  // add the trailing '\n'

    node.ec_errno = 0;  // rzq: indicating this is not error
                        // hence no query for errno at all
    node.ec_type = EC_NONE;  // rzq: any value would suffice

    node.ec_context = (char *)calloc(1, len);
    if (node.ec_context == NULL) {
        if (ec_s_emergency[0] == '\0')
            node.ec_context = ec_s_emergency;
        else
            // rzq: why? Seems to be a bug.
            node.ec_context = "?";
        len = len < sizeof(ec_s_emergency)? len: sizeof(ec_s_emergency);
    }
    if (node.ec_context != NULL)
    {
        memcpy(node.ec_context, buffer, len);
    }
    p = (struct ec_node *)calloc(1, sizeof(struct ec_node));
    // rzq: When it fails for the second, no error msg would be recorded.
    if (p == NULL && ec_node_emergency.ec_context == NULL)
        p = &ec_node_emergency; /* use just once */
    if (p != NULL) {
        node.ec_next = ec_head;
        ec_head = p;
        *ec_head = node;  // rzq: copy the node from stack to heap
    }
    if (!attexit_called) {
        attexit_called = true;
        ec_mutex(false);
        if (atexit(ec_atexit_fcn) != 0) {
            ec_push(fcn, file, line, "atexit failed", errno, EC_ERRNO);
            ec_print(); /* so at least the error gets shown */
        }
    }
    else
        ec_mutex(false);
}




