

/*
 * We only condider the executing environment with shared memory. Therefore 
 * message is linear.
 *
 */


/* =======================================
 * one-to-one channel has two ends, by which we can have a very simple semantics
 * corresponding to the channel concept in CSP.
 * 
 * Note:
 *   Many can wait to read, but only one will succeed in reading, others shall block
 *   Only one can wait to write, simultaneous write is eliminated by linear type.
 */
// absviewtype chin (viewtype)
absviewtype chin (int, viewtype) // use int to mark the channel
viewtypedef chin (a: viewtype) = [x: int] chin (x, a)

absviewtype chout (int, viewtype)
viewtypedef chout (a: viewtype) = [x: int] chout (x, a)

dataviewtype channel (int, viewtype) = 
| {x:int} {a:viewtype} Pair (x, a) of (chin (x, a), chout (x, a))

fun create_one_one_channel {a:viewtype} (): [x: int] channel (x, a)

fun read {a: viewtype} (cin: !chin a): a
fun read_guard {a: viewtype} (cin: !chin a, f: (!a) -> bool): a

fun write {a: viewtype} (cout: !chout a, v: a): void

fun copy {a: viewtype} {x: int} (cin: !chin (x,a)): chin (x,a)
fun chin_destroy {a: viewtype} (cin: chin a): void
fun chout_destroy {a: viewtype} (cout: chout a): void


/* =======================================
 * event: barrier of 2
 *
 */
absviewtype event (int)
viewtypedef event = [x: int] event x
fun create_event (): event
fun copy_event (e: !event): event
fun sync (e: !event): void

/* =======================================
 *
 *
 */
viewtypedef process = (() -<lin,cloptr1> void)

fun run (p: process): void
fun par_process (p1: process, p2: process): process

/* =======================================
 * guard: only for chin and event
 *
 */
absviewtype guard (int)
absview ch_res (int, viewtype)
absview e_res (int)

absview selector (int)

fun ch2guard {a: viewtype} {x:int} (cin: !chin (x, a) >> guard x): (ch_res (x, a) | void)
fun event2guard {x:int} (e: !event x >> guard x): (e_res x | void)

fun guard_select2 {x,y: int} (g1: !guard x, g2: !guard y): 
  [z: int | z == x || z == y] (selector z | int z)

// fun guard_select2 {x,y: int} (g1: !guard x, g2: !guard y): 
//   [z: int] (selector z | int z)

fun guard_match {x,y: int} (g: !guard x, y: int y): bool (x == y)

fun guard_read {a: viewtype} {x: int} (
  pf_s: selector x, 
  pf_res: ch_res (x, a)
  | g: !guard x >> chin (x, a)
  ): a

fun guard_sync {a: viewtype} {x: int} (
  pf_s: selector x, 
  pf_res: e_res x
  | g: !guard x >> event x
  ): void

// fun guard_error_check {z: int} (pf_sel: selector z | ret: int z): void

fun guard2ch {a: viewtype} {x: int} (
  pf_res: ch_res (x, a)
  | g: !guard x >> chin (x, a)
  ): void

fun guard2event {x: int} (
  pf_res: e_res x
  | g: !guard x >> event x
  ): void










