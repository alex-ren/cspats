staload "cspats/SATS/cspats.sats"
staload _ = "cspats/DATS/cspats.dats"

// fun read_int_chan (chin: !one2one_chan_in int): void = let
//   var x: int?
//   val () = one2one_chan_in_read<int> (chin, x)
//   val () = printf ("read an int: %d\n", @(x))
// in end
// 
// 
// fun read_int_chan_tsz (chin: !one2one_chan_in int): void = let
//   var x: int?
//   val () = one2one_chan_in_read_tsz (chin, x, sizeof<int>)
//   val () = printf ("read an int: %d\n", @(x))
// in end
// 
// 
// fun write_int_chan (chout: !one2one_chan_out int): void = let
//   var x: int = 0
//   val () = printf ("write an int: %d\n", @(x))
//   val () = one2one_chan_out_write (chout, x)
// in end

// implement main () = let
//   var ch: one2one_chan (int) ?
//   val ret = one2one_chan_create_err {int} (ch)
// in
//   if ret = 0 then let
//     (* Channel is created successfully. *)
//     prval () = opt_unsome ch
//     val+ ~one2one_pair (ch_in, ch_out) = ch
// 
//     (* Destroy the channel before the program exits. *)
//     val () = read_int_chan_tsz (ch_in)
//     val () = one2one_chan_in_destroy (ch_in)
// 
//     val () = write_int_chan (ch_out)
//     val () = one2one_chan_out_destroy (ch_out)
//   in end else let
//     prval () = opt_unnone ch
//   in end
// end

// ==================================
fun read_int_chan (chin: !many2one_chan_in int): void = let
  var x: int?
  val () = many2one_chan_in_read<int> (chin, x)
  val () = printf ("read an int: %d\n", @(x))
in end


fun read_int_chan_tsz (chin: !many2one_chan_in int): void = let
  var x: int?
  val () = many2one_chan_in_read_tsz (chin, x, sizeof<int>)
  val () = printf ("read an int: %d\n", @(x))
in end


fun write_int_chan (chout: !many2one_chan_out int): void = let
  var x: int = 0
  val () = printf ("write an int: %d\n", @(x))
  val () = many2one_chan_out_write (chout, x)
in end

implement main (): void = let
  var ch: many2one_chan (int) ?
  val ret = many2one_chan_create_err {int} (ch)
in
  if ret = 0 then let
    (* Channel is created successfully. *)
    prval () = opt_unsome ch
    val+ ~many2one_pair (ch_in, ch_out) = ch
  
    (* Destroy the channel before the program exits. *)
    val () = read_int_chan_tsz (ch_in)
    val () = many2one_chan_in_destroy (ch_in)

    val () = write_int_chan (ch_out)
    val () = many2one_chan_out_unref (ch_out)
  in end else let
    prval () = opt_unnone ch
  in end
end
  
////
  
    val () = read_int_chan_tsz (ch_in)
    val () = write_int_chan (ch_out)
