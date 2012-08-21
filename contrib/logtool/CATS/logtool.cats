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
** Start Time: August, 2012
**
*/

/* ****** ****** */


#ifndef ATSLIB_LOGTOOL_CATS
#define ATSLIB_LOGTOOL_CATS


#include "contrib/cspats/LIB/common/inc_all.h"

ATSinline()
ats_void_type atslib_logtool_buffered_trace(
    ats_ptr_type fcn,
    ats_ptr_type file,
    ats_int_type line,
    ats_ptr_type fmt,
    ...)
{
    va_list ap;
    va_start(ap, fmt);
    buffered_trace_v(fcn, file, line, fmt, ap);
    va_end(ap);
}

ATSinline()
ats_void_type atslib_logtool_instant_trace(
    ats_ptr_type fcn,
    ats_ptr_type file,
    ats_int_type line,
    ats_ptr_type fmt,
    ...)
{
    va_list ap;
    va_start(ap, fmt);
    buffered_trace_v(fcn, file, line, fmt, ap);
    va_end(ap);
    EC_FLUSH("STRING here has no effect")
}

ATSinline()
ats_void_type atslib_logtool_flush()
{
    EC_FLUSH("STRING here has no effect")
}

#endif



