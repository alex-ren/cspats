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
** Start Time: July, 2012
**
*)

(* ****** ****** *)

%{#
#include "contrib/cspats/CATS/cspats.cats"
%} // end of [%{#]

(* ****** ****** *)

#define ATS_STAFLAGLOAD 0  // no static loading at run-time

(* ****** ****** *)

sortdef vtp = viewtype
sortdef vt0p = viewt@ype

(* ****** ****** *)

absviewtype // viewt@ype: invariant
  one2one_chan_in_vt0ype_int (a:viewt@ype, tag:int)

stadef one2one_chan_in = one2one_chan_in_vt0ype_int

viewtypedef one2one_chan_in (a: vt0p) = [tag:int] one2one_chan_in (a, tag)

(* ****** ****** *)

absviewtype // viewt@ype: invariant
  one2one_chan_out_vt0ype_int (a:viewt@ype, tag:int)

stadef one2one_chan_out = one2one_chan_out_vt0ype_int

viewtypedef one2one_chan_out (a: vt0p) = [tag:int] one2one_chan_out (a, tag)

(* ****** ****** *)

dataviewtype // viewt@ype: invariant
  one2one_chan_vt0ype_int (a:viewt@ype, int) = 
| {tag:int} one2one_pair (a, tag) of (
  one2one_chan_in (a, tag), one2one_chan_out (a, tag))
// end of [one2one_chan_vt0ype_int]

stadef one2one_chan = one2one_chan_vt0ype_int

viewtypedef one2one_chan (a: viewt@ype) = 
  [tag:int] one2one_chan (a, tag)

(* ****** ****** *)

(*
** Name: one2one_chan_create
** Note: No error is returned. If error occurrs, the program terminates.
*)
fun one2one_chan_create {a:vt0p} (): one2one_chan a

(*
** Name one2one_chan_create_err
*)
fun one2one_chan_create_err {a:vt0p} (
  ch: &one2one_chan (a)? >> opt (one2one_chan (a), e == 0) ): #[e: int] int e

fun one2one_chan_in_destroy {a:vt0p} (ch: one2one_chan_in a): void =
  "mac#atslib_cspats_one2one_chan_in_destroy"

fun one2one_chan_out_destroy {a:vt0p} (ch: one2one_chan_out a): void =
  "mac#atslib_cspats_one2one_chan_out_destroy"

(* ****** ****** *)

fun {a:vt0p} one2one_chan_in_read (
  ch: !one2one_chan_in a,
  buf: &a? >> a): void

fun one2one_chan_in_read_tsz {a:vt0p} (
  ch: !one2one_chan_in a,
  buf: &a? >> a,
  tsz: sizeof_t a
  ): void = "mac#atslib_cspats_one2one_chan_in_read_tsz"

// todo:
// Is the following function really necessary?
// fun {a:viewt@ype} one2one_chan_in_read_opt (
//   ch: !one2one_chan_in a,
//   data: &a? >> opt (a, ret <> 0)): #[ret:int] int ret

// overload >> with one2one_chan_in_read

// overload >> with one2one_chan_in_read_opt

(* ****** ****** *)

fun one2one_chan_out_write{a:vt0p} (
  ch: !one2one_chan_out a,
  data: &a >> a?): void =
"atslib_cspats_one2one_chan_out_write"

// overload << with one2one_chan_out_write

(* ****** ****** *)

absviewtype // viewt@ype: invariant
  many2one_chan_in_vt0ype_int (a:viewt@ype, tag:int)

stadef many2one_chan_in = many2one_chan_in_vt0ype_int

viewtypedef many2one_chan_in (a: viewt@ype) = [tag:int] many2one_chan_in (a, tag)

(* ****** ****** *)

absviewtype // viewt@ype: invariant
  many2one_chan_out_vt0ype_int (a:viewt@ype, tag:int)

stadef many2one_chan_out = many2one_chan_out_vt0ype_int

viewtypedef many2one_chan_out (a: vt0p) = [tag:int] many2one_chan_out (a, tag)

(* ****** ****** *)

dataviewtype // viewt@ype: invariant
  many2one_chan_vt0ype_int (a:viewt@ype, int) = 
| {tag:int} many2one_pair (a, tag) of (
  many2one_chan_in (a, tag), many2one_chan_out (a, tag))
// end of [many2one_chan_vt0ype_int]

stadef many2one_chan = many2one_chan_vt0ype_int

viewtypedef many2one_chan (a: vt0p) = 
  [tag:int] many2one_chan (a, tag)

(* ****** ****** *)

(*
** Name: many2one_chan_create
** Note: No error is returned. If error occurrs, the program terminates.
*)
fun many2one_chan_create {a:vt0p} (): many2one_chan (a)

(*
** Name many2one_chan_create_err
*)
fun many2one_chan_create_err {a:vt0p} (
  ch: &many2one_chan (a)? >> opt (many2one_chan (a), e == 0) ): #[e: int] int e

fun many2one_chan_in_destroy {a:vt0p} (ch: many2one_chan_in a): void =
  "mac#atslib_cspats_many2one_chan_in_destroy"

fun many2one_chan_out_ref {a:vt0p}{tag:int} (
  ch: !many2one_chan_out (a, tag)): many2one_chan_out (a, tag) =
  "mac#atslib_cspats_many2one_chan_out_ref"

fun many2one_chan_out_unref {a:vt0p} (ch: many2one_chan_out a): void =
  "mac#atslib_cspats_many2one_chan_out_unref"


(* ****** ****** *)

fun {a:vt0p} many2one_chan_in_read (
  ch: !many2one_chan_in a,
  buf: &a? >> a): void

(*
** Name: many2one_chan_in_cond_read
** Note: Conditional read. This function returns only when the
** content read satisfies the condition.
*)
fun {a:vt0p} many2one_chan_in_cond_read 
  {vt0:vt0p} {f:eff} (
  ch: !many2one_chan_in a,
  buf: &a? >> a,
  f: (&a, &vt0>>vt0) -<fun,f> bool,
  env: &vt0>>vt0) : void

fun many2one_chan_in_read_tsz {a:vt0p} (
  ch: !many2one_chan_in a,
  buf: &a? >> a,
  tsz: sizeof_t a
  ): void = "mac#atslib_cspats_many2one_chan_in_read_tsz"

(*
** Name: many2one_chan_in_cond_read_tsz
** Note: Conditional read. This function returns only when the
** content read satisfies the condition.
*)
fun many2one_chan_in_cond_read_tsz {a:vt0p}{vt0:vt0p}{f:eff} (
  ch: !many2one_chan_in a,
  buf: &a? >> a,
  tsz: sizeof_t a,
  f: (&a, &vt0>>vt0) -<fun,f> bool,
  env: &vt0>>vt0) : void = "atslib_cspats_many2one_chan_in_cond_read_tsz"

// todo:
// Is the following function really necessary?
// fun {a:viewt@ype} many2one_chan_in_read_opt (
//   ch: !many2one_chan_in a,
//   data: &a? >> opt (a, ret <> 0)): #[ret:int] int ret

// overload >> with many2one_chan_in_read

// overload >> with many2one_chan_in_read_opt

(* ****** ****** *)

fun many2one_chan_out_write {a:vt0p} (
  ch: !many2one_chan_out a,
  data: &a >> a?): void =
"mac#atslib_cspats_many2one_chan_out_write"

// overload << with many2one_chan_out_write

(* ****** ****** *)

absviewtype barrier2_int (tag:int)

stadef barrier2 = barrier2_int

viewtypedef barrier2 = [tag:int] barrier2 (tag)

(* ****** ****** *)

(*
** Name: barrier2_create
** Note: No error is returned. If error occurrs, the program terminates.
*)
fun barrier2_create (): barrier2 =
  "mac#atslib_cspats_barrier2_create"

(*
** Name barrier2_create_err
*)
fun barrier2_create_err (
  bar: &barrier2? >> opt (barrier2, e == 0) ): #[e: int] int e =
  "mac#atslib_cspats_barrier2_create_err"

fun barrier2_ref {tag:int} (
  bar: !barrier2 (tag)): barrier2 tag =
  "mac#atslib_cspats_barrier2_ref"

fun barrier2_unref (bar: barrier2): void =
  "mac#atslib_cspats_barrier2_unref"

(* ****** ****** *)

fun barrier2_sync (bar: !barrier2): void =
  "mac#atslib_cspats_barrier2_sync"

(* ****** ****** *)

absviewtype alt_int (tag: int)
stadef alt = alt_int
viewtypedef alt = [tag:int] alt (tag)

(* ****** ****** *)

absview
  one2one_chan_res_vt0yp_int (a: viewt@ype, tag: int)
stadef one2one_chan_in_res = one2one_chan_res_vt0yp_int

fun one2one_chan_in_2_alt {a:vt0p}{tag:int} (
  ch: one2one_chan_in (a, tag)
  ): (one2one_chan_in_res (a, tag) | alt (tag)) = "mac#atslib_cspats_one2one_chan_in_2_alt"

fun alt_2_one2one_chan_in {a:vt0p}{tag:int} (
  pf_res: one2one_chan_in_res (a, tag)
  | g: alt (tag)
  ): one2one_chan_in (a, tag) = "mac#atslib_cspats_alt_2_one2one_chan_in"

(* ****** ****** *)

absview
  many2one_chan_res_vt0yp_int (a: viewt@ype, tag: int)
stadef many2one_chan_in_res = many2one_chan_res_vt0yp_int

fun many2one_chan_in_2_alt {a:vt0p}{tag:int} (
  ch: many2one_chan_in (a, tag)
  ): (many2one_chan_in_res (a, tag) | alt(tag))
  = "mac#atslib_cspats_many2one_chan_in_2_alt"

fun alt_2_many2one_chan_in {a:vt0p}{tag:int} (
  pf_res: many2one_chan_in_res (a, tag)
  | g: alt (tag)
  ): many2one_chan_in (a, tag)
  = "mac#atslib_cspats_alt_2_many2one_chan_in"

(* ****** ****** *)

absview
  barrier2_res_int (tag: int)
stadef barrier2_res = barrier2_res_int

fun barrier2_2_alt {tag:int} (
  bar: barrier2 (tag)
  ): (barrier2_res (tag) | alt (tag))
  = "mac#atslib_cspats_barrier2_2_alt"

fun alt_2_barrier2 {tag:int} (
  pf_res: barrier2_res (tag)
  | g: alt (tag)
  ): barrier2 (tag)
  = "mac#atslib_cspats_alt_2_barrier2"

(* ****** ****** *)

(*
** Note: The following style is too rigid so that
**       too difficult to use.
absview selector2 (t1:int, t2: int, n: int)
absview selector (tag: int)

praxi select2_1_selector {t1,t2:int}
  (s: selector2 (t1, t2, 1)): selector t1

praxi select2_2_selector {t1,t2:int}
  (s: selector2 (t1, t2, 2)): selector t2
*)

(*
** Name: alternative_2
** Note: No error is returned.
*)

absview selector

(*
** Name: alternative_2
** Note: It's the uses' responsiblity to read/sync on the
**       appropriate channel/barrier. It's only forced
**       that one read/sync must be done.
** Note: No error is returned. If error occurrs, the program terminates.
*)
fun alternative_2 {t1,t2:int} (g1: !alt t1, g2: !alt t2):<fun1> 
   (selector | intBtwe (0,1)) =
  "mac#atslib_cspats_alternative_2"
 

fun {a:vt0p} alt_one2one_chan_in_read {tag:int} (
  pf_s: selector, 
  pf_res: one2one_chan_in_res (a, tag)
  | g: alt (tag),
    buf: &a? >> a): one2one_chan_in (a, tag)

fun alt_one2one_chan_in_read_tsz {a:vt0p} {tag:int} (
  pf_s: selector, 
  pf_res: one2one_chan_in_res (a, tag)
  | g: alt (tag),
    buf: &a? >> a,
    tsz: sizeof_t a): one2one_chan_in (a, tag) =
  "mac#atslib_cspats_alt_one2one_chan_in_read_tsz"

fun {a:vt0p} alt_many2one_chan_in_read {tag:int} (
  pf_s: selector, 
  pf_res: many2one_chan_in_res (a, tag)
  | g: alt (tag),
    buf: &a? >> a): many2one_chan_in (a, tag)

fun alt_many2one_chan_in_read_tsz {a:vt0p} {tag:int} (
  pf_s: selector, 
  pf_res: many2one_chan_in_res (a, tag)
  | g: alt (tag),
    buf: &a? >> a,
    tsz: sizeof_t a): many2one_chan_in (a, tag) =
  "mac#atslib_cspats_alt_many2one_chan_in_read_tsz"

fun alt_barrier2_sync {tag:int} (
  pf_s: selector, 
  pf_res: barrier2_res (tag)
  | g: alt (tag)
  ): barrier2 (tag) =
  "mac#atslib_cspats_alt_barrier2_sync"


viewtypedef process = (() -<lin,cloptr1> void)

fun para_run2 (p1: process, p2: process):<fun1> void
fun para_run3 (p1: process, p2: process, p3: process):<fun1> void
fun para_run4 (p1: process, p2: process, p3: process, p4: process):<fun1> void


abst@ype pid = $extype"pthread_t"














