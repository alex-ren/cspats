
#include "cspats.h"
#include "cspats_lib.h"

#include "common/headers.h"
#include "common/ec.h"

one2one_chan_ptr one2one_chan_create()
{
    One2OneChannel *p = NULL;
    ec_null_fatal( p = One2OneChannel::create() )

    return static_cast<one2one_chan_ptr>(p);
}

one2one_chan_ptr one2one_chan_create_err()
{
    One2OneChannel *p = NULL;
    p = One2OneChannel::create();
    return static_cast<one2one_chan_ptr>(p);
}

one2one_chan_ptr one2one_chan_ref(one2one_chan_ptr pch)
{
    One2OneChannel *p = static_cast<One2OneChannel *>(pch);
    p->ref();
    return pch;
}

void one2one_chan_unref(one2one_chan_ptr pch)
{
    One2OneChannel *p = static_cast<One2OneChannel *>(pch);
    p->unref();
}

void one2one_chan_read(one2one_chan_ptr pch, unsigned char *buffer, size_t len)
{
    One2OneChannel *p = static_cast<One2OneChannel *>(pch);
    p->read(buffer, len);

}

void one2one_chan_write(one2one_chan_ptr pch, unsigned char *buffer)
{
    One2OneChannel *p = static_cast<One2OneChannel *>(pch);
    p->write(buffer);

}

/* ************** *************** */

many2one_chan_ptr many2one_chan_create()
{
    Many2OneChannel *p = NULL;
    ec_null_fatal( p = Many2OneChannel::create() )

    return static_cast<many2one_chan_ptr>(p);
}

many2one_chan_ptr many2one_chan_create_err()
{
    Many2OneChannel *p = NULL;
    p = Many2OneChannel::create();
    return static_cast<many2one_chan_ptr>(p);
}

many2one_chan_ptr many2one_chan_ref(many2one_chan_ptr pch)
{
    Many2OneChannel *p = static_cast<Many2OneChannel *>(pch);
    p->ref();
    return pch;
}

void many2one_chan_unref(many2one_chan_ptr pch)
{
    Many2OneChannel *p = static_cast<Many2OneChannel *>(pch);
    p->unref();
}

void many2one_chan_read(many2one_chan_ptr pch, unsigned char *buffer, size_t len)
{
    Many2OneChannel *p = static_cast<Many2OneChannel *>(pch);
    p->read(buffer, len);

}

void many2one_chan_cond_read(many2one_chan_ptr pch, 
                             unsigned char *buffer, 
                             size_t len,
                             bool (*f)(unsigned char *, void *),
                             void *env
                             )
{
    Many2OneChannel *p = static_cast<Many2OneChannel *>(pch);
    p->cond_read(buffer, len, f, env);

}

void many2one_chan_write(many2one_chan_ptr pch, unsigned char *buffer)
{
    Many2OneChannel *p = static_cast<Many2OneChannel *>(pch);
    p->write(buffer);

}


/*
 * Name: barrier2_create
 * Return: Pointer to the barrier
 * Note: No error is returned. If error occurrs, the program terminates.
 */
barrier2_ptr barrier2_create()
{
    Barrier2 *p = NULL;
    ec_null_fatal( p = Barrier2::create() )
    return static_cast<barrier2_ptr>(p);
}

/*
 * Name: barrier2_create_err
 * Return:
 *    success: Pointer to the barrier
 *    failure: NULL
 */
barrier2_ptr barrier2_create_err()
{
    Barrier2 *p = NULL;
    p = Barrier2::create();
    return static_cast<barrier2_ptr>(p);
}
    
barrier2_ptr barrier2_ref(barrier2_ptr pbar)
{
    Barrier2 *p = static_cast<Barrier2 *>(pbar);
    p->ref();
    // INSTANT_TRACE("barrier2_ref 000000000002\n")
    return pbar;
}

void barrier2_unref(barrier2_ptr pbar)
{
    Barrier2 *p = static_cast<Barrier2 *>(pbar);
    p->unref();
}

void barrier2_sync(barrier2_ptr pbar)
{
    Barrier2 *p = static_cast<Barrier2 *>(pbar);
    p->sync();
}

void barrier2_sync_sem(barrier2_ptr pbar)
{
    Barrier2 *p = static_cast<Barrier2 *>(pbar);
    p->sync_sem();
}
/* *************** **************** */

alt_ptr one2one_chan_in_2_alt(one2one_chan_ptr pch)
{
    // void * ==> One2OneChannel *
    One2OneChannel *p = static_cast<One2OneChannel *>(pch);
    // One2OneChannel * ==> Altable *
    return static_cast<Altable *>(p);
    // Altable * ==> void *
}

one2one_chan_ptr alt_2_one2one_chan_in(alt_ptr palt)
{
    // void * ==> Altable *
    Altable *p = static_cast<Altable *>(palt);
    // Altable * ==> One2OneChannel *
    return dynamic_cast<One2OneChannel *>(p);
    // One2OneChannel * ==> void *
}

/* *************** **************** */

alt_ptr many2one_chan_in_2_alt(many2one_chan_ptr pch)
{
    // void * ==> Many2OneChannel *
    Many2OneChannel *p = static_cast<Many2OneChannel *>(pch);
    // Many2OneChannel * ==> Altable *
    return static_cast<Altable *>(p);
    // Altable * ==> void *
}

many2one_chan_ptr alt_2_many2one_chan_in(alt_ptr palt)
{
    // void * ==> Altable *
    Altable *p = static_cast<Altable *>(palt);
    // Altable * ==> Many2OneChannel *
    return dynamic_cast<Many2OneChannel *>(p);
    // Many2OneChannel * ==> void *
}

/* *************** **************** */

alt_ptr barrier2_2_alt(barrier2_ptr pba)
{
    // void * ==> Barrier2 *
    Barrier2 *p = static_cast<Barrier2 *>(pba);
    // Barrier2 * ==> Altable *
    return static_cast<Altable *>(p);
    // Altable * ==> void *
}

barrier2_ptr alt_2_barrier2(alt_ptr palt)
{
    // void * ==> Altable *
    Altable *p = static_cast<Altable *>(palt);
    // Altable * ==> Barrier2 *
    return dynamic_cast<Barrier2 *>(p);
    // Barrier2 * ==> void *
}

/* *************** **************** */

int alternative_2(alt_ptr g1, alt_ptr g2)
{
    Altable *arr[2] = {};
    arr[0] = static_cast<Altable *>(g1);
    arr[1] = static_cast<Altable *>(g2);

    Alternative *p = NULL;
    ec_null_fatal( p = Alternative::create(arr, 2) )

    return p->select();
}

/* *************** ********************* */

void run_proc(pthread_t * pid, void *(*start_routine)(void *), void *arg)
{
    int ret = 0;
    ec_rv_fatal( ret = run_proc_error(pid, start_routine, arg) )
    return;
}

int run_proc_error(pthread_t * pid, void *(*start_routine)(void *), void *arg)
{
    return pthread_create(pid, NULL, start_routine, arg);
}
    
void wait_proc(pthread_t pid, void **retval)
{
    int ret = 0;
    ec_rv_fatal( ret = wait_proc_error(pid, retval) )
    return;
}

int wait_proc_error(pthread_t pid, void **retval)
{
    return pthread_join(pid, retval);
}


































