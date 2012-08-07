
staload "contrib/cspats/SATS/atscsp.sats"





absviewtype Int (int)
viewtypedef Int = [x: int] Int x
extern fun eq_Int_int {x, y: int} (x: !Int x, y: int y): bool (x == y)
extern fun release_Int (x: Int): void

absviewtype req (int, int)
viewtypedef req = [cl: nat] [blk: nat] req (cl, blk)
extern fun create_req {cl,blk: nat} (cl: int cl, blk: int blk): req (cl, blk)
extern fun release_req (req: req): void
extern fun req_x {x,y: int} (req: !req (x, y)): Int x
extern fun req_y {x,y: int} (req: !req (x, y)): Int y

extern fun CELL (left: chin (req)(*{1..2}.{0..3}*), shift: event, right: chout (req)): void


// CSP: CELL = left?x.y -> shift -> right!x.y -> CELL
implement CELL (left, shift, right) = let
  val req = read (left)
  val () = sync (shift)
  val () = write (right, req)
in
  CELL (left, shift, right)
end

fun CELL_proc (left: chin (req), shift: event, right: chout (req)): process = lam () =<lin, cloptr1>
  CELL (left, shift, right)

extern fun BUFF (left: chin (req), shift: event, right: chout (req)): void

// CSP: BUFF = ((CELL[[right<-comm]]) [|{|comm|}|] (CELL[[left<-comm]])) \ {|comm|}
implement BUFF (left, shift, right) = let
  val comm = create_one_one_channel {req} ()
  val+~ Pair (comm_in, comm_out) = comm

  val shift2 = copy_event (shift)
  val p1 = CELL_proc (left, shift, comm_out)
  val p2 = CELL_proc (comm_in, shift2, right)

  val p = par_process (p1, p2)
in
  run p
end

fun BUFF_proc (left: chin (req), shift: event, right: chout (req)): process =
  lam () =<lin, cloptr1> BUFF (left, shift, right)
 

// CSP: DQ(2) = deq -> shift -> X(2)
fun DQ_2 (enq: chin (req),
                 deq: event, 
                 shift: event,
                 empty: event,
                 left: chout (req),
                 right: chin (req),
                 next: chout (req)
                 ): void = let
  val () = sync (deq)
  val () = sync (shift)
in
  X_i (2, enq, deq, shift, empty, left, right, next)
end


// CSP: DQ(i) = enq?x.y -> ( left!x.y -> shift-> DQ(i+1) )
//   [] deq -> ( 	if (i==0) then empty -> DQ(0) 
//			else X(i)
//		    )
and DQ_i {i: nat | i < 2} (i: int i,
                 enq: chin (req),
                 deq: event, 
                 shift: event,
                 empty: event,
                 left: chout (req),
                 right: chin (req),
                 next: chout (req)
                 ): void = let
  val (res_enq | ()) = ch2guard (enq)
  val (res_deq | ()) = event2guard (deq)

  val [z: int] (pf_sel | ret) = guard_select2 (enq, deq)
in
  if guard_match (enq, ret) then let
    val req = guard_read (pf_sel, res_enq | enq)
    val () = guard2event (res_deq | deq)

    val () = write (left, req)
    val () = sync (shift)
  in
    if i = 0 then DQ_i (1, enq, deq, shift, empty, left, right, next)
    else DQ_2 (enq, deq, shift, empty, left, right, next)
  end else let
    val () = guard_sync (pf_sel, res_deq | deq)
    val () = guard2ch (res_enq | enq) 
  in
    if i = 0 then let
      val () = sync (empty)
    in
      DQ_i (0, enq, deq, shift, empty, left, right, next)
    end else
      X_i (i, enq, deq, shift, empty, left, right, next)
  end
end
  
// CSP: X(i) = right?y.z -> ( next!y.z -> DQ(i-1) )
//     [] shift -> X(i)
and X_i {i: pos | i <= 2} (i: int i,
                 enq: chin (req),
                 deq: event, 
                 shift: event,
                 empty: event,
                 left: chout (req),
                 right: chin (req),
                 next: chout (req)
                 ): void = let
  val (res_right | ()) = ch2guard (right)
  val (res_shift | ()) = event2guard (shift)
  val (pf_sel | ret) = guard_select2 (right, shift)
in
  if guard_match (right, ret) then let
    val req = guard_read (pf_sel, res_right | right)
    val () = guard2event (res_shift | shift)

    val () = write (next, req)
  in
    DQ_i (i - 1, enq, deq, shift, empty, left, right, next)
  end else let
    val () = guard_sync (pf_sel, res_shift | shift)
    val () = guard2ch (res_right | right)
  in
    X_i (i, enq, deq, shift, empty, left, right, next)
  end
end

fun DQ_0_proc (
                 enq: chin (req),
                 deq: event, 
                 shift: event,
                 empty: event,
                 left: chout (req),
                 right: chin (req),
                 next: chout (req)
                 ): process =
  lam () =<lin, cloptr1> DQ_i (0, enq, deq, shift, empty, left, right, next)

// CSP: DQueue = (DQ(0) [|{|left, right, shift|}|] BUFF) \ {|left, right, shift|}
fun DQueue (enq: chin (req),
                 deq: event, 
                 empty: event,
                 next: chout (req)
                 ): void = let
  val left = create_one_one_channel {req} ()
  val+~ Pair (left_in, left_out) = left

  val right = create_one_one_channel {req} ()
  val+~ Pair (right_in, right_out) = right

  val shift1 = create_event ()
  val shift2 = copy_event (shift1)

  val PROC_DQ_0 = DQ_0_proc (enq, deq, shift1, empty, left_out, right_in, next)
  val PROC_BUFF = BUFF_proc (left_in, shift2, right_out)

  val p = par_process (PROC_DQ_0, PROC_BUFF)
in
  run p
end

fun DQueue_proc (enq: chin (req),
                 deq: event, 
                 empty: event,
                 next: chout (req)
                 ): process = 
  lam () =<lin, cloptr1> DQueue (enq, deq, empty, next)

// CSP: DCtrl = dci?i.blk -> dio!blk -> dint -> dco!i.blk -> DCtrl
extern fun DCtrl (dci: chin (req), 
                  dio: chout (Int), 
                  dint: event,
                  dco: chout (req)
                  ): void

implement DCtrl (dci, dio, dint, dco) = let
  val req = read (dci)
  val blk = req_y (req)
  val () = write (dio, blk)
  val () = sync (dint)
  val () = write (dco, req)
in
  DCtrl (dci, dio, dint, dco)
end

fun DCtrl_proc (dci: chin (req), 
                  dio: chout (Int), 
                  dint: event,
                  dco: chout (req)
                  ): process =
  lam () =<lin, cloptr1> DCtrl (dci, dio, dint, dco)

// CSP: Disk =  dio?blk -> dint -> Disk
extern fun Disk (dio: chin (Int), dint: event): void
implement Disk (dio, dint) = let
  val blk = read (dio)
  val () = release_Int (blk)
  val () = sync (dint)
in
  Disk (dio, dint)
end

fun Disk_proc (dio: chin (Int), dint: event): process =
  lam () =<lin, cloptr1> Disk (dio, dint)

// CSP: DS_idle = ds?cl.blk -> dci!cl.blk -> DS_busy
fun DS_idle (ds: chin (req), 
             dci: chout (req),
             dco: chin req, 
             ack: chout Int,
             enq: chout req,
             deq: event,
             empty: event,
             next: chin (req)
            ): void = let
  val req = read (ds)
  val () = write (dci, req)
in
  DS_busy (ds, dci, dco, ack, enq, deq, empty, next)
end

// CSP: DS_busy = dco?cl.blk -> ( ack.cl -> DS_check )
//	    [] ds?cl.blk -> enq!cl.blk -> DS_busy
and DS_busy (ds: chin req,
             dci: chout (req),
             dco: chin req, 
             ack: chout Int,
             enq: chout req,
             deq: event,
             empty: event,
             next: chin (req)
             ): void = let
  val (res_dco | ()) = ch2guard (dco)
  val (res_ds | ()) = ch2guard (ds)
  val (pf_sel | ret) = guard_select2 (dco, ds)
in
  if guard_match (dco, ret) then let
    val req = guard_read (pf_sel, res_dco | dco)
    val () = guard2ch (res_ds | ds)
    val cl = req_x (req)
    val () = release_req (req)
    val () = write (ack, cl)
  in
    DS_check (ds, dci, dco, ack, enq, deq, empty, next)
  end else let
    val req = guard_read (pf_sel, res_ds | ds)
    val () = guard2ch (res_dco | dco)
    val () = write (enq, req)
  in
    DS_busy (ds, dci, dco, ack, enq, deq, empty, next)
  end
end

// CSP: DS_check = deq -> ( empty -> DS_idle
//		     [] next?cl.blk -> dci!cl.blk -> DS_busy )
and DS_check (ds: chin req,
             dci: chout (req),
             dco: chin req, 
             ack: chout Int,
             enq: chout req,
             deq: event,
             empty: event,
             next: chin (req)
             ): void = let
  val () = sync (deq)
  val (res_empty | ()) = event2guard (empty)
  val (res_next | ()) = ch2guard (next)
  val (pf_sel | ret) = guard_select2 (empty, next)
in
  if guard_match (empty, ret) then let
    val () = guard_sync (pf_sel, res_empty | empty)
    val () = guard2ch (res_next | next)
  in
    DS_idle (ds, dci, dco, ack, enq, deq, empty, next)
  end else let
    val req = guard_read (pf_sel, res_next | next)
    val () = guard2event (res_empty | empty)
    val () = write (dci, req)
  in
    DS_busy (ds, dci, dco, ack, enq, deq, empty, next)
  end
end
    
// CSP: DSched = DS_idle
val DSched = DS_idle
fun DSched_proc (ds: chin req,
             dci: chout (req),
             dco: chin req, 
             ack: chout Int,
             enq: chout req,
             deq: event,
             empty: event,
             next: chin (req)
             ): process =
  lam () =<lin, cloptr1> DSched (ds, dci, dco, ack, enq, deq, empty, next)

// CSP: DSS = (DSched [|{|enq,deq,next,empty|}|] DQueue)
// 	[|{|dci,dco|}|]
//       (DCtrl [|{|dio,dint|}|] Disk)
extern fun DSS (ds: chin req,
                ack: chout Int
               ): void

fun DSS_proc (ds: chin req,
                ack: chout Int
               ): process =
  lam () =<lin, cloptr1> DSS (ds, ack)

implement DSS (ds, ack) = let
  val+~ Pair(enq_in, enq_out) = create_one_one_channel {req} ()

  val deq1 = create_event ()
  val deq2 = copy_event (deq1)

  val+~ Pair(next_in, next_out) = create_one_one_channel {req} ()
  
  val empty1 = create_event ()
  val empty2 = copy_event (empty1)
  
  val+~ Pair(dci_in, dci_out) = create_one_one_channel {req} ()
  val+~ Pair(dco_in, dco_out) = create_one_one_channel {req} ()

  val+~ Pair(dio_in, dio_out) = create_one_one_channel {Int} ()

  val dint1 = create_event ()
  val dint2 = copy_event (dint1)

  val p1 = DSched_proc (ds, dci_out, dco_in, ack, enq_out, deq2, empty1, next_in)
  val p2 = DQueue_proc (enq_in, deq1, empty2, next_out)
  val p3 = DCtrl_proc (dci_in, dio_out, dint1, dco_out)
  val p4 = Disk_proc (dio_in, dint2)

  val p12 = par_process (p1, p2)
  val p34 = par_process (p3, p4)

  val p = par_process (p12, p34)
in
  run p
end


// CSP: C(i) = ds!i.1 -> moreone -> ack.i->SKIP
extern fun C_i {i: nat} (i: int i,
                  ds: chout req,
                  ack: chin Int
                  ): void

implement C_i {i} (i, ds, ack) = let
  val req = create_req (i, 2)
  val () = write (ds, req)

  // something like moreone
  val () = printf ("This is C_%d\n", @(i))

  fun cmp (n: !Int): bool = eq_Int_int (n, i)
  val cl_no = read_guard {Int} (ack, cmp)

  val () = release_Int (cl_no)
  val () = chout_destroy (ds)
  val () = chin_destroy (ack)
in end


////
// CSP: SYS = DSS [|{|ds,ack|}|] (C(1)|||C(2)) 

--============================
-- Demo
--============================

C(1) = ds!1.2 -> moreone -> ack.1->SKIP

C(2) = ds!2.3 -> moretwo -> ack.2->SKIP











