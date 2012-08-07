(***********************************************************************)
(*                                                                     *)
(*                         Applied Type System                         *)
(*                                                                     *)
(*                              Hongwei Xi                             *)
(*                                                                     *)
(***********************************************************************)

(*
** ATS - Unleashing the Potential of Types!
** Copyright (C) 2002-2010 Hongwei Xi, Boston University
** All rights reserved
**
** ATS is free software;  you can  redistribute it and/or modify it under
** the  terms of the  GNU General Public License as published by the Free
** Software Foundation; either version 2.1, or (at your option) any later
** version.
** 
** ATS is distributed in the hope that it will be useful, but WITHOUT ANY
** WARRANTY; without  even  the  implied  warranty  of MERCHANTABILITY or
** FITNESS FOR A PARTICULAR PURPOSE.  See the  GNU General Public License
** for more details.
** 
** You  should  have  received  a  copy of the GNU General Public License
** along  with  ATS;  see  the  file  COPYING.  If not, write to the Free
** Software Foundation, 51  Franklin  Street,  Fifth  Floor,  Boston,  MA
** 02110-1301, USA.
*)

(* ****** ****** *)

(*
**
** Contributed by Zhiqiang Ren (aren AT cs DOT bu DOT edu)
** Time: July, 2012
**
*)

(* ****** ****** *)

#define ATS_DYNLOADFLAG 0  // no need for dynamic loading

staload "contrib/cspats/SATS/cspats.sats"

%{^  // Embedded in the beginning of the generated file.

ATSinline()
ats_ptr_type 
atslib_cspats_one2one_chan_io_create()
{
    return one2one_chan_create();
}

ATSinline()
ats_int_type atslib_cspats_one2one_chan_io_create_err(ats_ref_type ppch)
{
    one2one_chan_ptr pch = one2one_chan_create_err();
    if (NULL == pch)
    {
        return -1;
    }
    else
    {
        *((one2one_chan_ptr *)ppch) = pch;
        return 0;
    }
}

ATSinline()
ats_ptr_type 
atslib_cspats_one2one_chan_io_ref(ats_ptr_type pch)
{
    return one2one_chan_ref(pch);
}

ATSinline()
ats_void_type 
atslib_cspats_one2one_chan_io_unref(ats_ptr_type pch)
{
    return one2one_chan_unref(pch);
}

/* ******************* **********************/

ATSinline()
ats_ptr_type 
atslib_cspats_many2one_chan_io_create()
{
    return many2one_chan_create();
}

ATSinline()
ats_int_type atslib_cspats_many2one_chan_io_create_err(ats_ref_type ppch)
{
    many2one_chan_ptr pch = many2one_chan_create_err();
    if (NULL == pch)
    {
        return -1;
    }
    else
    {
        *((one2one_chan_ptr *)ppch) = pch;
        return 0;
    }
}

ATSinline()
ats_ptr_type 
atslib_cspats_many2one_chan_io_ref(ats_ptr_type pch)
{
    return many2one_chan_ref(pch);
}

ATSinline()
ats_void_type 
atslib_cspats_many2one_chan_io_unref(ats_ptr_type pch)
{
    return many2one_chan_unref(pch);
}


%}  // end of [%{^]

absviewtype one2one_chan_io (viewt@ype+, int)
viewtypedef one2one_chan_io (a:vt0p) = [tag:int] one2one_chan_io (a, tag)

extern castfn one2one_chan_io_2_in {a:vt0p}{tag:int} (
  ch: one2one_chan_io (a, tag)): one2one_chan_in (a, tag)

extern castfn one2one_chan_io_2_out {a:vt0p}{tag:int} (
  ch: one2one_chan_io (a, tag)): one2one_chan_out (a, tag)

extern castfn one2one_chan_in_2_io {a:vt0p}{tag:int} (
  ch: one2one_chan_in (a, tag)): one2one_chan_io (a, tag)

extern castfn one2one_chan_out_2_io {a:vt0p}{tag:int} (
  ch: one2one_chan_out (a, tag)): one2one_chan_io (a, tag)

(*
** Name: one2one_chan_io_create
** Note:
**    No error is returned. But the program may be terminated.
*)
extern fun one2one_chan_io_create {a:vt0p} (): one2one_chan_io a
  = "mac#atslib_cspats_one2one_chan_io_create"

extern fun one2one_chan_io_create_err {a:vt0p} (
  ch: &one2one_chan_io (a)? >> opt (one2one_chan_io (a), e == 0)): #[e: int] int e
  = "mac#atslib_cspats_one2one_chan_io_create_err"

extern fun one2one_chan_io_ref {a:vt0p}{tag:int} (
  ch: !one2one_chan_io(a,tag)): one2one_chan_io (a, tag)
  = "mac#atslib_cspats_one2one_chan_io_ref"

extern fun one2one_chan_io_unref {a:vt0p} (
  ch: one2one_chan_io a): void
  = "mac#atslib_cspats_one2one_chan_io_unref"


(*
** Proto:
**   fun one2one_chan_create {a:vt0p} (): one2one_chan a
*)
implement one2one_chan_create {a:vt0p} () = let
  val ch_in = one2one_chan_io_create {a} ()
  val ch_out = one2one_chan_io_ref (ch_in)

  val ch_in = one2one_chan_io_2_in (ch_in)
  val ch_out = one2one_chan_io_2_out (ch_out)
in
  one2one_pair (ch_in, ch_out)
end
  
(*
** Proto:
** fun one2one_chan_create_err {a:vt0p} (
**   ch: &one2one_chan? >> opt (one2one_chan (a), e == 0) ): #[e: int] int e
*)
(*  todo
implement one2one_chan_create_err {a} (ch) = let
  var ch_in: one2one_chan_io (a) ?
  val e = one2one_chan_io_create_err {a} (ch_in)
in
  if e = 0 then let
    prval () = opt_unsome {one2one_chan_io (a)} (ch_in)
    val ch_out = one2one_chan_io_ref (ch_in)
    val ch_in = one2one_chan_io_2_in (ch_in)
    val ch_out = one2one_chan_io_2_o (ch_out)

    val () = ch := one2one_pair (ch_in, ch_out)
    prval () = opt_some {one2one_chan (a)} (ch)
  in
    e
  end else let
    prval () = opt_none {one2one_chan (a)} (ch)
  in
    e
  end
end
*)

(* ****************** ******************** *)

(*
** Proto
fun {a:vt0p} one2one_chan_in_read (
  ch: !one2one_chan_in a,
  buf: &a? >> a): void
**
*)
implement{a} one2one_chan_in_read (ch, buf) =
  one2one_chan_in_read_tsz (ch, buf, sizeof<a>)


(* ****************** ******************** *)

absviewtype many2one_chan_io (viewt@ype+, int)
viewtypedef many2one_chan_io (a:vt0p) = [tag:int] many2one_chan_io (a, tag)

extern castfn many2one_chan_io_2_in {a:vt0p}{tag:int} (
  ch: many2one_chan_io (a, tag)): many2one_chan_in (a, tag)

extern castfn many2one_chan_io_2_out {a:vt0p}{tag:int} (
  ch: many2one_chan_io (a, tag)): many2one_chan_out (a, tag)

extern castfn many2one_chan_in_2_io {a:vt0p}{tag:int} (
  ch: many2one_chan_in (a, tag)): many2one_chan_io (a, tag)

extern castfn many2one_chan_out_2_io {a:vt0p}{tag:int} (
  ch: many2one_chan_out (a, tag)): many2one_chan_io (a, tag)

(*
** Name: many2one_chan_io_create
** Note:
**    No error is returned. But the program may be terminated.
*)
extern fun many2one_chan_io_create {a:vt0p} (): many2one_chan_io a
  = "mac#atslib_cspats_many2one_chan_io_create"

extern fun many2one_chan_io_create_err {a:vt0p} (
  ch: &many2one_chan_io (a)? >> opt (many2one_chan_io (a), e == 0)): #[e: int] int e
  = "mac#atslib_cspats_many2one_chan_io_create_err"

extern fun many2one_chan_io_ref {a:vt0p}{tag:int} (
  ch: !many2one_chan_io(a,tag)): many2one_chan_io (a, tag)
  = "mac#atslib_cspats_many2one_chan_io_ref"

extern fun many2one_chan_io_unref {a:vt0p} (
  ch: many2one_chan_io a): void
  = "mac#atslib_cspats_many2one_chan_io_unref"


(*
** Proto:
**   fun many2one_chan_create {a:vt0p} (): many2one_chan a
*)
implement many2one_chan_create {a:vt0p} () = let
  val ch_in = many2one_chan_io_create {a} ()
  val ch_out = many2one_chan_io_ref (ch_in)

  val ch_in = many2one_chan_io_2_in (ch_in)
  val ch_out = many2one_chan_io_2_out (ch_out)
in
  many2one_pair (ch_in, ch_out)
end
  
(*
** Proto:
** fun many2one_chan_create_err {a:vt0p} (
**   ch: &many2one_chan? >> opt (many2one_chan (a), e == 0) ): #[e: int] int e
*)
(*  todo
implement many2one_chan_create_err {a} (ch) = let
  var ch_in: many2one_chan_io (a) ?
  val e = many2one_chan_io_create_err {a} (ch_in)
in
  if e = 0 then let
    prval () = opt_unsome {many2one_chan_io (a)} (ch_in)
    val ch_out = many2one_chan_io_ref (ch_in)
    val ch_in = many2one_chan_io_2_in (ch_in)
    val ch_out = many2one_chan_io_2_o (ch_out)

    val () = ch := many2one_pair (ch_in, ch_out)
    prval () = opt_some {many2one_chan (a)} (ch)
  in
    e
  end else let
    prval () = opt_none {many2one_chan (a)} (ch)
  in
    e
  end
end
*)

(* ****************** ******************** *)

(*
** Proto
fun {a:vt0p} many2one_chan_in_read (
  ch: !many2one_chan_in a,
  buf: &a? >> a): void
**
*)
implement{a} many2one_chan_in_read (ch, buf) =
  many2one_chan_in_read_tsz (ch, buf, sizeof<a>)

(*
** Proto
fun {a:vt0p} alt_one2one_chan_in_read {tag:int} (
  pf_s: selector, 
  pf_res: one2one_chan_in_res (a, tag)
  | g: !alt (tag)  >> one2one_chan_in (a, tag),
    buf: &a? >> a): void
**
*)
implement {a} alt_one2one_chan_in_read {tag} (
  pf_s, pf_res | g, buf) =
  alt_one2one_chan_in_read_tsz (pf_s, pf_res | g, buf, sizeof<a>)


(*
** Proto
fun {a:vt0p} alt_many2one_chan_in_read {tag:int} (
  pf_s: selector, 
  pf_res: many2one_chan_in_res (a, tag)
  | g: !alt (tag)  >> many2one_chan_in (a, tag),
    buf: &a? >> a): void
**
*)
implement {a} alt_many2one_chan_in_read {tag} (
  pf_s, pf_res | g, buf) =
  alt_many2one_chan_in_read_tsz (pf_s, pf_res | g, buf, sizeof<a>)




