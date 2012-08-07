
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
    ec_null_fatal( Barrier2::create() )
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

int alternative_2(alt_ptr g1, alt_ptr g2)
{
    Altable *arr[2] = {};
    arr[0] = static_cast<Altable *>(g1);
    arr[1] = static_cast<Altable *>(g2);

    Alternative *p = NULL;
    ec_null_fatal( Alternative::create(arr, 2) )

    return p->select();
}






























