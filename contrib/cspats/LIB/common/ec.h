#ifndef _EC_H_
#define _EC_H_

#ifdef __cplusplus
extern "C" {
#endif

/*
    It might be nice to code functions or macros to replace the system calls or libraryfunctions (e.g., close_e()), but there's no way to execute a goto from an expression. So, ec_neg1(), etc., must be statements. Two alternatives:
        1. Exit instead of goto, which is allowed in a function called within an expression.
        2. In C++, use throw inside a function.
    #1 doesn't allow error recovery, and #2 doesn't work in C.
*/
/*[basic]*/
extern const bool ec_in_cleanup;

typedef enum {/*errno*/
              EC_ERRNO = 0, 
              /*networking*/
              EC_EAI = 1, 
              EC_GETDATE = 2, 
              EC_NONE = 3
              } EC_ERRTYPE;

#define EC_CLEANUP_BGN\
    ec_warn();\
    ec_cleanup_bgn:\
    {\
        bool ec_in_cleanup;\
        ec_in_cleanup = true;

#define EC_CLEANUP_END\
    }

// rzq: get the system errno
#define ec_cmp(var, errrtn)\
    {\
        assert(!ec_in_cleanup);\
        if ((intptr_t)(var) == (intptr_t)(errrtn)) {\
            ec_push(__func__, __FILE__, __LINE__, #var, errno, EC_ERRNO);\
            goto ec_cleanup_bgn;\
        }\
    }

// rzq: use var (the return value of the function) as the errno
// when var is not 0, it is the error number
#define ec_rv(var)\
    {\
        int errrtn;\
        assert(!ec_in_cleanup);\
        if ((errrtn = (var)) != 0) {\
            ec_push(__func__, __FILE__, __LINE__, #var, errrtn, EC_ERRNO);\
            goto ec_cleanup_bgn;\
        }\
    }

// rzq: EC_EAI, has nothing to do with errno
#define ec_ai(var)\
    {\
        int errrtn;\
        assert(!ec_in_cleanup);\
        if ((errrtn = (var)) != 0) {\
            ec_push(__func__, __FILE__, __LINE__, #var, errrtn, EC_EAI);\
            goto ec_cleanup_bgn;\
        }\
    }

// rzq: the following 7 macros are all based on
// ec_cmp therefore using system errno
#define ec_neg1(x) ec_cmp(x, -1)
/*
    Not in book: 0 used instead of NULL to avoid warning from C++ compilers.
*/
#define ec_null(x) ec_cmp(x, 0)
#define ec_zero(x) ec_null(x) /* not in book */
#define ec_false(x) ec_cmp(x, false)
#define ec_eof(x) ec_cmp(x, EOF)
#define ec_nzero(x)\
    {\
        if ((x) != 0)\
            EC_FAIL\
    }

#define EC_FAIL ec_cmp(0, 0)

#define EC_CLEANUP goto ec_cleanup_bgn;

// flush the chain of records and reinitialize it
#define EC_FLUSH(str)\
    {\
        ec_print();\
        ec_reinit();\
    } 
// end of [the following 7]

/*[]*/
#define EC_EINTERNAL INT_MAX

/* **************************************************** */
// rzq: recording the error in the chain
// if errno_arg is set to 0 then type doesn't matter any
// more
void ec_push(const char *fcn, const char *file, int line,
  const char *str, int errno_arg, EC_ERRTYPE type);

// rzq: Print and log (if necessary) all the records in the
// chain. May query the information according to the errno
// stored in the element of chain.
void ec_print(void);
// rzq: reinitialize the chain, restart the counting
void ec_reinit(void);
// rzq: output a special warning msg
void ec_warn(void);

/* **************************************************** */

/* **************************************************** */
// rzq: Similar to ec_push.
// Just record the message with errno set to 0, which
// indicates no error at all.
void buffered_trace(const char*fcn, const char *file, int line,
  const char *str);

/*
 * rzq:
 * Just record the "str" in the chain
 */
#define BUFFERED_TRACE(str) \
    buffered_trace(__func__, __FILE__, __LINE__, str); 

// rzq: record the "str" in the chain and flush the chain
#define INSTANT_TRACE(str) \
    buffered_trace(__func__, __FILE__, __LINE__, str); \
    EC_FLUSH("")

// rzq: no error information at all
#define ec_extra_cmp(var, errrtn)\
    {\
        assert(!ec_in_cleanup);\
        if ((intptr_t)(var) == (intptr_t)(errrtn)) {\
            buffered_trace(__func__, __FILE__, __LINE__, #var); \
            goto ec_cleanup_bgn;\
        }\
    }

// rzq: the following 7 macros are all based on
// ec_cmp therefore using system errno
#define ec_extra_neg1(x) ec_extra_cmp(x, -1)
/*
    Not in book: 0 used instead of NULL to avoid warning from C++ compilers.
*/
#define ec_extra_null(x) ec_extra_cmp(x, 0)
#define ec_extra_zero(x) ec_null_extra(x) /* not in book */
#define ec_extra_false(x) ec_extra_cmp(x, false)
#define ec_extra_eof(x) ec_extra_cmp(x, EOF)
#define ec_extra_nzero(x)\
    {\
        if ((x) != 0)\
            EC_FAIL_EXTRA\
    }

#define EC_FAIL_EXTRA ec_extra_cmp(0, 0)


/*
 * rzq:
 * Record the errno and then exit.
 */
#define ec_cmp_fatal(var, errrtn)\
    {\
        if ((intptr_t)(var) == (intptr_t)(errrtn)) {\
            ec_push(__func__, __FILE__, __LINE__, #var, errno, EC_ERRNO);\
            exit(EXIT_FAILURE);\
        }\
    }

// rzq: use var (the return value of the function) as the errno
#define ec_rv_fatal(var)\
    {\
        int errrtn;\
        if ((errrtn = (var)) != 0) {\
            ec_push(__func__, __FILE__, __LINE__, #var, errrtn, EC_ERRNO);\
            exit(EXIT_FAILURE);\
        }\
    }

// rzq: the following 7 macros are all based on
// ec_cmp_fatal therefore using system errno
#define ec_neg1_fatal(x) ec_cmp_fatal(x, -1)
/*
    Not in book: 0 used instead of NULL to avoid warning from C++ compilers.
*/
// rzq: the following 6 macros are all based on
// ec_cmp therefore using system errno
#define ec_null_fatal(x) ec_cmp_fatal(x, 0)
#define ec_zero_fatal(x) ec_null_fatal(x) /* not in book */
#define ec_false_fatal(x) ec_cmp_fatal(x, false)
#define ec_eof_fatal(x) ec_cmp_fatal(x, EOF)
#define ec_nzero_fatal_fatal(x)\
    {\
        if ((x) != 0)\
            EC_FAIL_FATAL\
    }

#define EC_FAIL_FATAL ec_cmp_fatal(0, 0)
// end of [the following 7]





#ifdef __cplusplus
} /* extern "C" */
#endif

#endif /* _EC_H_ */



