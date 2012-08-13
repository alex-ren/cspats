// staload "contrib/cspats/SATS/cspats.sats"
staload "cspats/SATS/cspats.sats"

// staload _(*template*) = "contrib/cspats/DATS/cspats.dats"
staload _(*template*) = "cspats/DATS/cspats.dats"




(*
absviewtype Int (int)
viewtypedef Int = [x: int] Int x
extern fun eq_Int_int {x, y: int} (x: !Int x, y: int y): bool (x == y)
extern fun release_Int (x: Int): void
*)

(* ************ ************** *)

absviewt@ype req (int, int) = int
viewtypedef req = [cl: nat] [blk: nat] req (cl, blk)

viewtypedef req_t = req
extern fun create_req {cl,blk: nat} (cl: int cl, blk: int blk): req (cl, blk)
extern fun release_req (req: req): void
extern fun req_x {x,y: int} (req: !req (x, y)): int x
extern fun req_y {x,y: int} (req: !req (x, y)): int y

extern fun CELL (
  left: one2one_chan_in (req)(*{1..2}.{0..3}*),
  shift: barrier2,
  right: one2one_chan_out (req)
  ): void


// CSP: CELL = left?x.y -> shift -> right!x.y -> CELL
implement CELL (left, shift, right) = let
  var req: req?
  val () = one2one_chan_in_read (left, req)
  val () = barrier2_sync (shift)
  val () = one2one_chan_out_write<req_t> (right, req)
in
  CELL (left, shift, right)
end

fun CELL_proc (
  left: one2one_chan_in (req),
  shift: barrier2,
  right: one2one_chan_out (req)): process =
  lam () =<lin, cloptr1> CELL (left, shift, right)

(* ************ ************** *)

extern fun BUFF (
  left: one2one_chan_in (req),
  shift: barrier2,
  right: one2one_chan_out (req)): void

// CSP: BUFF = ((CELL[[right<-comm]]) [|{|comm|}|] (CELL[[left<-comm]])) \ {|comm|}
implement BUFF (left, shift, right) = let
  val comm = one2one_chan_create {req} ()
  val+~ one2one_pair (comm_in, comm_out) = comm

  val shift2 = barrier2_ref (shift)
  val p1 = CELL_proc (left, shift, comm_out)
  val p2 = CELL_proc (comm_in, shift2, right)

  val () = para_run2 (p1, p2)
in
  ()
end

fun BUFF_proc (
  left: one2one_chan_in (req),
  shift: barrier2, right:
  one2one_chan_out (req)): process =
  lam () =<lin, cloptr1> BUFF (left, shift, right)

(* ************ ************** *)

// CSP: DQ(2) = deq -> shift -> X(2)
fun DQ_2 (enq: one2one_chan_in (req),
                 deq: barrier2,
                 shift: barrier2,
                 empty: barrier2,
                 left: one2one_chan_out (req),
                 right: one2one_chan_in (req),
                 next: one2one_chan_out (req)
                 ): void = let
  val () = barrier2_sync (deq)
  val () = barrier2_sync (shift)
in
  X_i (2, enq, deq, shift, empty, left, right, next)
end

// CSP: DQ(i) = enq?x.y -> ( left!x.y -> shift-> DQ(i+1) )
//   [] deq -> (        if (i==0) then empty -> DQ(0)
//                      else X(i)
//                  )
and DQ_i {i: nat | i < 2} (i: int i,
                 enq: one2one_chan_in (req),
                 deq: barrier2,
                 shift: barrier2,
                 empty: barrier2,
                 left: one2one_chan_out (req),
                 right: one2one_chan_in (req),
                 next: one2one_chan_out (req)
                 ): void = let
  prval (res_enq | ()) = one2one_chan_in_2_alt (enq)
  prval (res_deq | ()) = barrier2_2_alt (deq)
  val (pf_sel | ret) = alternative_2 (enq, deq)
in
  if ret = 0 then let
    var req: req?
    val () = alt_one2one_chan_in_read (pf_sel, res_enq | enq, req)
    prval () = alt_2_barrier2 (res_deq | deq)

    val () = one2one_chan_out_write<req_t> (left, req)
    val () = barrier2_sync (shift)
  in
    if i = 0 then DQ_i (1, enq, deq, shift, empty, left, right, next)
    else DQ_2 (enq, deq, shift, empty, left, right, next)
  end else let
    val () = alt_barrier2_sync (pf_sel, res_deq | deq)
    prval () = alt_2_one2one_chan_in (res_enq | enq)
  in
    if i = 0 then let
      val () = barrier2_sync (empty)
    in
      DQ_i (0, enq, deq, shift, empty, left, right, next)
    end else
      X_i (i, enq, deq, shift, empty, left, right, next)
  end
end

// CSP: X(i) = right?y.z -> ( next!y.z -> DQ(i-1) )
//     [] shift -> X(i)
and X_i {i: pos | i <= 2} (i: int i,
                 enq: one2one_chan_in (req),
                 deq: barrier2,
                 shift: barrier2,
                 empty: barrier2,
                 left: one2one_chan_out (req),
                 right: one2one_chan_in (req),
                 next: one2one_chan_out (req)
                 ): void = let
  val (res_right | ()) = one2one_chan_in_2_alt (right)
  val (res_shift | ()) = barrier2_2_alt (shift)
  val (pf_sel | ret) = alternative_2 (right, shift)
in
  if ret = 0 then let
    var req: req?
    val () = alt_one2one_chan_in_read (pf_sel, res_right | right, req)
    val () = alt_2_barrier2 (res_shift | shift)

    val () = one2one_chan_out_write<req_t> (next, req)
  in
    DQ_i (i - 1, enq, deq, shift, empty, left, right, next)
  end else let
    val () = alt_barrier2_sync (pf_sel, res_shift | shift)
    prval () = alt_2_one2one_chan_in (res_right | right)
  in
    X_i (i, enq, deq, shift, empty, left, right, next)
  end
end

fun DQ_0_proc (
                 enq: one2one_chan_in (req),
                 deq: barrier2,
                 shift: barrier2,
                 empty: barrier2,
                 left: one2one_chan_out (req),
                 right: one2one_chan_in (req),
                 next: one2one_chan_out (req)
                 ): process =
  lam () =<lin, cloptr1> DQ_i (0, enq, deq, shift, empty, left, right, next)

(* ************ ************** *)

// CSP: DQueue = (DQ(0) [|{|left, right, shift|}|] BUFF) \ {|left, right, shift|}
fun DQueue (enq: one2one_chan_in (req),
                 deq: barrier2,
                 empty: barrier2,
                 next: one2one_chan_out (req)
                 ): void = let
  val left = one2one_chan_create {req} ()
  val+~ one2one_pair (left_in, left_out) = left

  val right = one2one_chan_create {req} ()
  val+~ one2one_pair (right_in, right_out) = right

  val shift1 = barrier2_create ()
  val shift2 = barrier2_ref (shift1)

  val PROC_DQ_0 = DQ_0_proc (enq, deq, shift1, empty, left_out, right_in, next)
  val PROC_BUFF = BUFF_proc (left_in, shift2, right_out)

  val () = para_run2 (PROC_DQ_0, PROC_BUFF)
in
end

fun DQueue_proc (enq: one2one_chan_in (req),
                 deq: barrier2,
                 empty: barrier2,
                 next: one2one_chan_out (req)
                 ): process =
  lam () =<lin, cloptr1> DQueue (enq, deq, empty, next)

(* ************ ************** *)

// CSP: DCtrl = dci?i.blk -> dio!blk -> dint -> dco!i.blk -> DCtrl
extern fun DCtrl (dci: one2one_chan_in (req),
                  dio: one2one_chan_out (int),
                  dint: barrier2,
                  dco: one2one_chan_out (req)
                  ): void

implement DCtrl (dci, dio, dint, dco) = let
  var req: req?
  val () = one2one_chan_in_read (dci, req)
  val blk = req_y (req)
  val () = one2one_chan_out_write<int> (dio, blk)
  val () = barrier2_sync (dint)
  val () = one2one_chan_out_write<req_t> (dco, req)
in
  DCtrl (dci, dio, dint, dco)
end

fun DCtrl_proc (dci: one2one_chan_in (req),
                  dio: one2one_chan_out (int),
                  dint: barrier2,
                  dco: one2one_chan_out (req)
                  ): process =
  lam () =<lin, cloptr1> DCtrl (dci, dio, dint, dco)

(* ************ ************** *)

// CSP: Disk =  dio?blk -> dint -> Disk
extern fun Disk (dio: one2one_chan_in (int), dint: barrier2): void
implement Disk (dio, dint) = let
  var blk: int?
  val () = one2one_chan_in_read (dio, blk)
  val () = barrier2_sync (dint)
in
  Disk (dio, dint)
end

fun Disk_proc (dio: one2one_chan_in (int), dint: barrier2): process =
  lam () =<lin, cloptr1> Disk (dio, dint)

(* ************ ************** *)

// CSP: DS_idle = ds?cl.blk -> dci!cl.blk -> DS_busy
fun DS_idle (ds: one2one_chan_in (req),
             dci: one2one_chan_out (req),
             dco: one2one_chan_in req,
             ack: one2one_chan_out int,
             enq: one2one_chan_out req,
             deq: barrier2,
             empty: barrier2,
             next: one2one_chan_in (req)
            ): void = let
  var req: req?
  val () = one2one_chan_in_read (ds, req)
  val () = one2one_chan_out_write<req_t> (dci, req)
in
  DS_busy (ds, dci, dco, ack, enq, deq, empty, next)
end

// CSP: DS_busy = dco?cl.blk -> ( ack.cl -> DS_check )
//          [] ds?cl.blk -> enq!cl.blk -> DS_busy
and DS_busy (ds: one2one_chan_in req,
             dci: one2one_chan_out (req),
             dco: one2one_chan_in req,
             ack: one2one_chan_out int,
             enq: one2one_chan_out req,
             deq: barrier2,
             empty: barrier2,
             next: one2one_chan_in (req)
             ): void = let
  val (res_dco | ()) = one2one_chan_in_2_alt (dco)
  val (res_ds | ()) = one2one_chan_in_2_alt (ds)
  val (pf_sel | ret) = alternative_2 (dco, ds)
  var req: req?
in
  if ret = 0 then let
    val () = alt_one2one_chan_in_read (pf_sel, res_dco | dco, req)
    val () = alt_2_one2one_chan_in (res_ds | ds)
    val cl = req_x (req)
    val () = release_req (req)
    val () = one2one_chan_out_write<int> (ack, cl)
  in
    DS_check (ds, dci, dco, ack, enq, deq, empty, next)
  end else let
    val () = alt_one2one_chan_in_read (pf_sel, res_ds | ds, req)
    val () = alt_2_one2one_chan_in (res_dco | dco)
    val () = one2one_chan_out_write<req_t> (enq, req)
  in
    DS_busy (ds, dci, dco, ack, enq, deq, empty, next)
  end
end

// CSP: DS_check = deq -> ( empty -> DS_idle
//                   [] next?cl.blk -> dci!cl.blk -> DS_busy )
and DS_check (ds: one2one_chan_in req,
             dci: one2one_chan_out (req),
             dco: one2one_chan_in req,
             ack: one2one_chan_out int,
             enq: one2one_chan_out req,
             deq: barrier2,
             empty: barrier2,
             next: one2one_chan_in (req)
             ): void = let
  val () = barrier2_sync (deq)
  val (res_empty | ()) = barrier2_2_alt (empty)
  val (res_next | ()) = one2one_chan_in_2_alt (next)
  val (pf_sel | ret) = alternative_2 (empty, next)
in
  if ret = 0 then let
    val () = alt_barrier2_sync (pf_sel, res_empty | empty)
    val () = alt_2_one2one_chan_in (res_next | next)
  in
    DS_idle (ds, dci, dco, ack, enq, deq, empty, next)
  end else let
    var req: req?
    val () = alt_one2one_chan_in_read (pf_sel, res_next | next, req)
    val () = alt_2_barrier2 (res_empty | empty)
    val () = one2one_chan_out_write<req_t> (dci, req)
  in
    DS_busy (ds, dci, dco, ack, enq, deq, empty, next)
  end
end

(* ************ ************** *)

// CSP: DSched = DS_idle
val DSched = DS_idle
fun DSched_proc (ds: one2one_chan_in req,
             dci: one2one_chan_out (req),
             dco: one2one_chan_in req,
             ack: one2one_chan_out int,
             enq: one2one_chan_out req,
             deq: barrier2,
             empty: barrier2,
             next: one2one_chan_in (req)
             ): process =
  lam () =<lin, cloptr1> DSched (ds, dci, dco, ack, enq, deq, empty, next)

(* ************ ************** *)

// CSP: DSS = (DSched [|{|enq,deq,next,empty|}|] DQueue)
//      [|{|dci,dco|}|]
//       (DCtrl [|{|dio,dint|}|] Disk)
extern fun DSS (ds: one2one_chan_in req,
                ack: one2one_chan_out int
               ): void

fun DSS_proc (ds: one2one_chan_in req,
                ack: one2one_chan_out int
               ): process =
  lam () =<lin, cloptr1> DSS (ds, ack)

implement DSS (ds, ack) = let
  val+~ one2one_pair (enq_in, enq_out) = one2one_chan_create {req} ()

  val deq1 = barrier2_create ()
  val deq2 = barrier2_ref (deq1)

  val+~ one2one_pair (next_in, next_out) = one2one_chan_create {req} ()

  val empty1 = barrier2_create ()
  val empty2 = barrier2_ref (empty1)

  val+~ one2one_pair (dci_in, dci_out) = one2one_chan_create {req} ()
  val+~ one2one_pair (dco_in, dco_out) = one2one_chan_create {req} ()

  val+~ one2one_pair (dio_in, dio_out) = one2one_chan_create {int} ()

  val dint1 = barrier2_create ()
  val dint2 = barrier2_ref (dint1)

  val p1 = DSched_proc (ds, dci_out, dco_in, ack, enq_out, deq2, empty1, next_in)
  val p2 = DQueue_proc (enq_in, deq1, empty2, next_out)
  val p3 = DCtrl_proc (dci_in, dio_out, dint1, dco_out)
  val p4 = Disk_proc (dio_in, dint2)

  val () = para_run4 (p1, p2, p3, p4)
in
end

////
(* ************ ************** *)

// CSP: C(i) = ds!i.1 -> moreone -> ack.i->SKIP
extern fun C_i {i: nat} (i: int i,
                  ds: one2one_chan_out req,
                  ack: one2one_chan_in int
                  ): void

implement C_i {i} (i, ds, ack) = let
  var req = create_req (i, 2)
  val () = one2one_chan_out_write<req_t> (ds, req)

  // something like moreone
  val () = printf ("This is C_%d\n", @(i))

  // fun cmp (n: !int): bool = eq_Int_int (n, i)
  // val cl_no = one2one_chan_in_read_guard {int} (ack, cmp)

  // val () = release_Int (cl_no)
  val () = one2one_chan_out_destroy (ds)
  val () = one2one_chan_in_destroy (ack)
in end


////
// CSP: SYS = DSS [|{|ds,ack|}|] (C(1)|||C(2))

--============================
-- Demo
--============================

C(1) = ds!1.2 -> moreone -> ack.1->SKIP

C(2) = ds!2.3 -> moretwo -> ack.2->SKIP
