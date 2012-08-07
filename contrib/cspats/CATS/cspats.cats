/***********************************************************************/
/*                                                                     */
/*                         Applied Type System                         */
/*                                                                     */
/*                              Hongwei Xi                             */
/*                                                                     */
/***********************************************************************/

/*
** ATS - Unleashing the Potential of Types!
**
** Copyright (C) 2002-2010 Hongwei Xi, Boston University
**
** All rights reserved
**
** ATS is free software;  you can  redistribute it and/or modify it under
** the terms of the GNU LESSER GENERAL PUBLIC LICENSE as published by the
** Free Software Foundation; either version 2.1, or (at your option)  any
** later version.
** 
** ATS is distributed in the hope that it will be useful, but WITHOUT ANY
** WARRANTY; without  even  the  implied  warranty  of MERCHANTABILITY or
** FITNESS FOR A PARTICULAR PURPOSE.  See the  GNU General Public License
** for more details.
** 
** You  should  have  received  a  copy of the GNU General Public License
** along  with  ATS;  see the  file COPYING.  If not, please write to the
** Free Software Foundation,  51 Franklin Street, Fifth Floor, Boston, MA
** 02110-1301, USA.
*/

/* ****** ****** */

/*
**
** Contributed by Zhiqiang Ren (aren AT cs DOT bu DOT edu)
** Start Time: July, 2012
**
*/

/* ****** ****** */


#ifndef ATSLIB_CSPATS_CATS
#define ATSLIB_CSPATS_CATS


#include "contrib/cspats/LIB/cspats.h"

ATSinline()
ats_void_type
atslib_cspats_one2one_chan_in_destroy(ats_ptr_type pch)
{
    one2one_chan_unref((one2one_chan_ptr)pch);
    return;
}
    

ATSinline()
ats_void_type
atslib_cspats_one2one_chan_out_destroy(ats_ptr_type pch)
{
    one2one_chan_unref((one2one_chan_ptr)pch);
    return;
}

ATSinline()
ats_void_type
atslib_cspats_one2one_chan_in_read_tsz(
    ats_ptr_type pch,
    ats_ref_type buff,
    ats_size_type tsz)
{
    return one2one_chan_read(pch, buff, tsz);
}

ATSinline()
ats_void_type
atslib_cspats_one2one_chan_out_write(
    ats_ptr_type pch,
    ats_ptr_type buff)
{
    return one2one_chan_write(pch, buff);
}

/* *************** ***************** */

ATSinline()
ats_void_type
atslib_cspats_many2one_chan_in_destroy(ats_ptr_type pch)
{
    many2one_chan_unref((many2one_chan_ptr)pch);
    return;
}
    

ATSinline()
ats_void_type
atslib_cspats_many2one_chan_out_destroy(ats_ptr_type pch)
{
    many2one_chan_unref((many2one_chan_ptr)pch);
    return;
}

ATSinline()
ats_void_type
atslib_cspats_many2one_chan_in_read_tsz(
    ats_ptr_type pch,
    ats_ref_type buff,
    ats_size_type tsz)
{
    return many2one_chan_read(pch, buff, tsz);
}

ATSinline()
ats_void_type
atslib_cspats_many2one_chan_out_write(
    ats_ptr_type pch,
    ats_ptr_type buff)
{
    return many2one_chan_write(pch, buff);
}

ATSinline()
ats_ptr_type
atslib_cspats_barrier2_create()
{
    return barrier2_create();
}

ATSinline()
ats_int_type
atslib_cspats_barrier2_create_err(ats_ref_type ppbar)
{
    barrier2_ptr pbar = barrier2_create_err();
    if (NULL == pbar)
    {
        return -1;
    }
    else
    {
        *((barrier2_ptr *)ppbar) = pbar;
        return 0;
    }
}

ATSinline()
ats_ptr_type
atslib_cspats_barrier2_ref(ats_ptr_type pbar)
{
    return barrier2_ref((barrier2_ptr)pbar);
}

ATSinline()
ats_void_type
atslib_cspats_barrier2_unref(ats_ptr_type pbar)
{
    return barrier2_unref((barrier2_ptr)pbar);
}

ATSinline()
ats_void_type
atslib_cspats_barrier2_sync(ats_ptr_type pbar)
{
    return barrier2_sync((barrier2_ptr)pbar);
}

ATSinline()
ats_int_type
atslib_cspats_alternative_2(ats_ptr_type g1, ats_ptr_type g2)
{
    return alternative_2((alt_ptr)g1, (alt_ptr)g2);
}

ATSinline()
ats_void_type
atslib_cspats_alt_one2one_chan_in_read_tsz(
    ats_ptr_type g,
    ats_ref_type buf,
    ats_size_type tsz)
{
    one2one_chan_ptr pch = (one2one_chan_ptr)g;
    return one2one_chan_read(pch, buf, tsz);
}

ATSinline()
ats_void_type
atslib_cspats_alt_many2one_chan_in_read_tsz(
    ats_ptr_type g,
    ats_ref_type buf,
    ats_size_type tsz)
{
    many2one_chan_ptr pch = (many2one_chan_ptr)g;
    return many2one_chan_read(pch, buf, tsz);
}

    
ATSinline()
ats_void_type
atslib_cspats_alt_barrier2_sync(ats_ptr_type g)
{
    return barrier2_sync((barrier2_ptr)g);
}
    



#endif  // end of [#ifndef ATSLIB_CSPATS_CATS]









