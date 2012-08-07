#ifndef _SYSERR_
#define _SYSERR_

#ifdef __cplusplus
extern "C" {
#endif

#include "ec.h"

void syserr(const char *msg);
char *syserrmsgtype(char *buf, size_t buf_max, const char *msg,
  int s_errno, EC_ERRTYPE type);
char *syserrmsgline(char *buf, size_t buf_max,
  int s_errno, EC_ERRTYPE type);
const char *getdate_strerror(int e);
const char *errsymbol(int errno_arg);
void syserr_print(const char *msg);


#ifdef __cplusplus
} /* extern "C" */
#endif

#endif /* _SYSERR_ */



