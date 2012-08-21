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
** Start Time: August, 2012
**
*)

(* ****** ****** *)

%{#
#include "contrib/logtool/CATS/logtool.cats"
%} // end of [%{#]

(* ****** ****** *)

#define ATS_STAFLAGLOAD 0  // no static loading at run-time

fun buffered_trace {ts:types} 
  (fcn: string, file: string, line: Pos, 
  fmt: printf_c ts, args: ts): void =
  "mac#atslib_logtool_buffered_trace"

fun flush (): void = "mac#atslib_logtool_flush"

fun instant_trace {ts:types} 
  (fcn: string, file: string, line: Pos, 
  fmt: printf_c ts, args: ts): void =
  "mac#atslib_logtool_instant_trace"

// macdef INSTANT_TRACE (fcn, file, line, fmt, args) = let
//   val () = instant_trace (,(fcn), ,(file), ,(line), ,(fmt), ,(args))
// in
//   flush ()
// end

// macrodef INSTANT_TRACE (fcn, file, line, fmt, args) = `(let
//   val () = instant_trace (,(fcn), ,(file), ,(line), ,(fmt), ,(args))
// in
//   flush ()
// end
// )




