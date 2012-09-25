staload "cspats/SATS/cspats.sats"
staload _ = "cspats/DATS/cspats.dats"

implement main () = ()

// Parameter for environment
#define g_cons_max_thread 4


typedef conn_id = int // {-1, 0, 1, 2}
typedef thread_id = int  // {1, 2, 3, 4}

typedef response = int  // {0: ok, 1: error, 2: full}

sortdef vtp = viewtype
sortdef vt0p = viewt@ype

absviewtype // viewt@ype: invariant
  one2one_chan_in_array_vt0ype_int (a:viewt@ype, tag: int, len: int)

stadef one2one_chan_in_arr = one2one_chan_in_array_vt0ype_int


absview linked

// viewtypedef link_response  = (linked | response)


// @decl_channel_array
// @name: create_t
// @num: g_cons_max_thread
// @type: one2one_chan (conn_id)
extern fun get_chan_create_t_in {n: pos | n <= g_cons_max_thread} 
  (n: int n): one2one_chan_in (conn_id)

extern fun get_chan_create_t_out {n: pos | n <= g_cons_max_thread} 
  (n: int n): one2one_chan_out (conn_id)

////


(*
threads = {all the threads}
*)

(*
channel link_end_result_in: threads  
channel link_end_result_out: threads.response

link_end_result (thr) = link_end_result_in.thr -> (link_end_result_out.thr!0 -> SKIP
                       |~| link_end_result_out.thr!1 -> SKIP)
*)
extern fun link_end_result (): response
implement link_end_result () = 0

(*
thread_id = {1, 2, 3, 4}

// Channels of this group consist of the following.
Channel create, close: threads
channel start_link: thead_id
channel end_link: {ok, error}
-- {0: ok, 1: error}

Connection () = create -> Active ()

Active () = close -> Connection ()
         [] start_link?t -> Linking ()

Linking () = link_end_result_in.thr -> link_end_result_out.thr?r 
               -> end_link!? -> Active ()
*)
fun Connection (create: many2one_chan_out ,
                       close:  barrier2,
                       start_link: one2one_chan_in (thread_id),
                       end_link:   one2one_chan_out (response)
                      ): void = let
  val () = barrier2_sync (create)
in
  Active (create, close, start_link, end_link)
end

and Active (create: barrier2,
            close:  barrier2,
            start_link: one2one_chan_in (thread_id),
            end_link:   one2one_chan_out (response)
            ): void = let
  val (res_close | close_alt) = barrier2_2_alt (close)
  val (res_start_link | start_link_alt) = one2one_chan_in_2_alt (start_link)

  val (pf_sel | ret) = alternative_2 (close_alt, start_link_alt)
in
  if ret = 0 then let
    val close = alt_barrier2_sync (pf_sel, res_close | close_alt)
    val start_link = alt_2_one2one_chan_in (res_start_link | start_link_alt)
  in
    Connection(create, close, start_link, end_link)
  end else let
    var t: thread_id?
    val start_link = alt_one2one_chan_in_read (
                       pf_sel, res_start_link | start_link_alt, t)
    val close = alt_2_barrier2 (res_close | close_alt)
  in
    Linking (create, close, start_link, end_link)
  end
end

and Linking (create: barrier2,
            close:  barrier2,
            start_link: one2one_chan_in (thread_id),
            end_link:   one2one_chan_out (response)
            ): void = let
  var r: response?
  // somehow get the r
  val () = r := link_end_result ()

  val () = one2one_chan_out_write (end_link, r)
in
  Active (create, close, start_link, end_link)
end

fun Connection_proc (create: barrier2,
            close:  barrier2,
            start_link: one2one_chan_in (thread_id),
            end_link:   one2one_chan_out (response)
            ): process =
  lam () =<lin, cloptr1> Connection (create, close, start_link, end_link)

////
ConnMgr = create?t -> conn_create?c -> 
    thread_create_sync.t!c -> (todo let thread do this) conn_create_sync.c!t -> ConnMgr

  












