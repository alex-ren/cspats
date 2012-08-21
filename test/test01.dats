staload "cspats/SATS/cspats.sats"
staload _ = "cspats/DATS/cspats.dats"

implement main () = let
  val+~ one2one_pair (ack_in, ack_out) = one2one_chan_create {int} ()
  val bar = barrier2_create ()

  val (res_ack | ack_alt) = one2one_chan_in_2_alt (ack_in)
  val (res_bar | bar_alt) = barrier2_2_alt (bar)

  val (pf_sel | ret) = alternative_2 (ack_alt, bar_alt)
in
  if ret = 0 then let
    var ack: int?
    val ack_in = alt_one2one_chan_in_read (pf_sel, res_ack | ack_alt, ack)
    val bar = alt_2_barrier2 (res_bar | bar_alt)

    val () = one2one_chan_in_destroy (ack_in)
    val () = one2one_chan_out_destroy (ack_out)
    val () = barrier2_unref (bar)
  in end else let
    val bar = alt_barrier2_sync (pf_sel, res_bar | bar_alt)
    val ack_in = alt_2_one2one_chan_in (res_ack | ack_alt)

    val () = one2one_chan_in_destroy (ack_in)
    val () = one2one_chan_out_destroy (ack_out)
    val () = barrier2_unref (bar)
  in end
end


  
  
