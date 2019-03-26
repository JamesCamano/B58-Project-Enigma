`timescale 1ns / 1ns

/*
High-level module of the Bombe machine.

Sequentially takes in 3 `flag` characters that might be encrypted by the Enigma machine,
and outputs the unique setting that produces these 3 characters in sequence.

The bombe machine has an asychronous reset.

NOTE: These flag characters <S0, S1, S2> are assumed to be the encrypted result
 of the sequence <A, B, C>.

*/
module bombe (
  output [7:0] bombe_out,
  input [7:0] char_in,
  input reset);



endmodule // bombe

/* Control module of the bombe.
   The control portion of this module is thought of to be in 4 stages:
    - 1. Input (with 3 sub stages),
    - 2. Equality check
    - 3. Rotor increment
    - 4. Success/Failure.
 */
module bombe_control ();

endmodule //bombe_control

module bombe_datapath ();

endmodule //bombe_datapath
