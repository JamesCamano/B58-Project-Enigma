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
module bombe_control (
  output reset_to_beginning,            // reset to start
  output load_s1,                       // load first ascii reg.
  output load_s2,                       // '' second ''
  output load_s3,                       // '' third ''
  output rotor_enable,                  // enabler for rotor increment.
  input reset,                          // async reset
  input key_press,                      // indicator bit for user pressing bit.
  input go,                             // indicator bit for user starting bombe.
  input arithmetic_end                  // indicator bit for deduction success/failure.
  );

endmodule //bombe_control

module bombe_datapath (
  output [7:0] bombe_out,
  output arithmetic_end,
  input [7:0] ascii_val,
  input load_s1,
  input load_s2,
  input load_s3,
  input reset,
  input rotor_enable,
  input clk);

endmodule //bombe_datapath
