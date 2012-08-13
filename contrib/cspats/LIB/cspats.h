#ifndef CSPATS_H
#define CSPATS_H

#ifdef __cplusplus
extern "C" {
#endif

#include <stddef.h>

#include <pthread.h>

typedef void * one2one_chan_ptr;

/*
 * Name: one2one_chan_create
 * Return: Pointer to the channel
 * Note: No error is returned. If error occurrs, the program terminates.
 */
one2one_chan_ptr one2one_chan_create();

/*
 * Name: one2one_chan_create_err
 * Return:
 *    success: Pointer to the channel
 *    failure: NULL
 */
one2one_chan_ptr one2one_chan_create_err();

one2one_chan_ptr one2one_chan_ref(one2one_chan_ptr pch);
void one2one_chan_unref(one2one_chan_ptr pch);

void one2one_chan_read(one2one_chan_ptr pch, unsigned char *buffer, size_t len);
void one2one_chan_write(one2one_chan_ptr pch, unsigned char *buffer);

/* ************** *************** */

typedef void * many2one_chan_ptr;

/*
 * Name: many2one_chan_create
 * Return: Pointer to the channel
 * Note: No error is returned. If error occurrs, the program terminates.
 */
many2one_chan_ptr many2one_chan_create();

/*
 * Name: many2one_chan_create_err
 * Return:
 *    success: Pointer to the channel
 *    failure: NULL
 */
many2one_chan_ptr many2one_chan_create_err();

many2one_chan_ptr many2one_chan_ref(many2one_chan_ptr pch);
void many2one_chan_unref(many2one_chan_ptr pch);

void many2one_chan_read(many2one_chan_ptr pch, unsigned char *buffer, size_t len);
void many2one_chan_write(many2one_chan_ptr pch, unsigned char *buffer);

/* ************** ******************* */

typedef void * barrier2_ptr;

/*
 * Name: barrier2_create
 * Return: Pointer to the barrier
 * Note: No error is returned. If error occurrs, the program terminates.
 */
barrier2_ptr barrier2_create();

/*
 * Name: barrier2_create_err
 * Return:
 *    success: Pointer to the barrier
 *    failure: NULL
 */
barrier2_ptr barrier2_create_err();

barrier2_ptr barrier2_ref(barrier2_ptr pbar);

void barrier2_unref(barrier2_ptr pbar);

void barrier2_sync(barrier2_ptr pbar);

/* ************** ******************* */

typedef void * alt_ptr;

int alternative_2(alt_ptr g1, alt_ptr g2);

/* ************** ******************* */
void run_proc(pthread_t *pid, void *(*start_routine)(void *), void *arg);
int run_proc_error(pthread_t *pid, void *(*start_routine)(void *), void *arg);

void wait_proc(pthread_t pid, void **retval);
int wait_proc_error(pthread_t pid, void **retval);





#ifdef __cplusplus
} /* extern "C" */
#endif

#endif // end of [CSPATS_H]





