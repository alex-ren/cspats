#ifndef _LOGF_H_
#define _LOGF_H_

#ifdef __cplusplus
extern "C" {
#endif

#include "headers.h"

void logfmt_setpath(const char *path);
void logfmt(const char *format, ...);
void logfmt_args(int argc, char *argv[]);
/*
 * Once set to false, logfmt will not write log into file.
 */
void logfmt_enable(bool enable);



#ifdef __cplusplus
} /* extern "C" */
#endif

#endif /* _LOGF_H_ */




