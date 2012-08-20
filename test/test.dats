staload "cspats.sats"
staload _ = "cspats.dats"

implement main () = let
  val+~ one2one_chan_pair (ack_in, ack_out) = many2one_chan_create {int} ()
  val bar = barrier2_create ()

  prval (res_ack | ()) = one2one_chan_in_2_alt (ack_in)
  prval (res_bar | ()) = barrier2_2_alt (bar)

  val (pf_sel | ret) = alternative_2 (ack_in, bar)
in
  if ret = 0 then let
    var ack: int?
    val () = alt_one2one_chan_in_read (pf_sel, res_ack | ack_in, ack)
    prval () = alt_2_barrier2 (res_bar | bar)

    val () = one2one_chan_in_destroy (ack_in)
    val () = one2one_chan_out_destroy (ack_out)
    val () = barrier2_destroy (bar)
  in end else let
    val () = alt_barrier2_sync (pf_sel, res_bar | bar)
    prval () = alt_2_one2one_chan_in (res_ack | ack_in)

    val () = one2one_chan_in_destroy (ack_in)
    val () = one2one_chan_out_destroy (ack_out)
    val () = barrier2_destroy (bar)
  in end
end


  
  
