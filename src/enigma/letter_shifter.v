`timescale 1ns / 1ns

/*
A module to represent the letter shifter circuit block for Enigma.

  - char_input represents the 7-bit representation of an uppercase
    english character as defined in the ASIC Notepad-- project.

   - rotor_value is the 7-bit representation of a integer in the range
     0...25.

    - encrypt represents the mode of the enigma machine.
*/
module letter_shifter(
  output [7:0] letter_out, // eight-bit letter out
  input encrypt,
  input [7:0] char_input,
  input [7:0] rotor_value // Rotor_Out in diagram
  );

  wire [7:0] unwrapped_char_sum;
  wire wrap;
  wire wrapped_sum; // output of 2nd level adder-subtractor

  // the reshifting value for character overflow.
  localparam ALPHA_WRAP = 7'd26;

  // first 7-bit adder -> shifting the letter rotor_value places.
  adder_eight_bit unwrapped_shift(
      .sum(unwrapped_char_sum),
      .A(char_input),
      .B(rotor_value),
      .add(encrypt)
  );

  letter_overflow_comparator overflow (
      .success(wrap),
      .NTCV(unwrapped_char_sum),
      .Gr(enable)
  );

  // 2nd level adder -> wrapping the previously un-shifted value.
  adder_eight_bit wrapper_shift(
      .sum(wrapped_sum),
      .A(unwrapped_char_sum),
      .B(ALPHA_WRAP), // does this work?
      .add(encrypt) // either adds or subtracts the ALPHA_WRAP value
  );

  // mux that picks the correct encryption value
  mux2to1 encrypted_letter_mux(
    .x(unwrapped_char_sum), // selected when s = wrap = 0
    .y(wrapped_sum),        // selected when s = wrap = 1
    .s(wrap),               // tells us whether we need to wrap letter value
    .m(letter_out));

endmodule
