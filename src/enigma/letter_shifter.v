`timescale 1ns / 1ns

/*
A module to represent the letter shifter circuit block for Enigma.

  - char_input represents the 7-bit representation of an uppercase
    english character as defined in the ASIC Notepad-- project.

   - rotor_value is the 7-bit representation of a integer in the range
     0...25.

    - positive_shift represents the mode of the adder - whether to
      lexicographically add or subtract.
*/
module letter_shifter(
  output [7:0] letter_out, // eight-bit letter out
  output [7:0] TEMP_NTCS,
  output TEMP_WRAP,
  input positive_shift,
  input [7:0] char_input,
  input [7:0] rotor_value // Rotor_Out in diagram
  );

  wire [7:0] unwrapped_char_sum;
  wire wrap;
  wire [7:0] wrapped_sum; // output of 2nd level adder-subtractor

  // the reshifting value for character overflow.
  localparam ALPHA_WRAP = 8'd26;

  // first 7-bit adder -> shifting the letter rotor_value places.
  adder_eight_bit unwrapped_shift(
      .sum(unwrapped_char_sum),
      .A(char_input),
      .B(rotor_value),
      .add(positive_shift)
  );


  letter_overflow_comparator overflow (
      .success(wrap),
      .NTCV(unwrapped_char_sum),
      .Gr(positive_shift)
  );

  assign TEMP_WRAP = wrap;
  assign TEMP_NTCS = letter_out;

  // 2nd level adder -> wrapping the previously un-shifted value.
  adder_eight_bit wrapper_shift(
      .sum(wrapped_sum),
      .A(unwrapped_char_sum),
      .B(ALPHA_WRAP),
      .add(~positive_shift) // either adds or subtracts the ALPHA_WRAP value. Note that we want to shift in the *opposite direction* of
  );

  // mux that picks the correct encryption value
  mux2to1_eight_bit encrypted_letter_mux (
    .m(letter_out),
    .x(unwrapped_char_sum), // selected when s = wrap = 0
    .y(wrapped_sum),        // selected when s = wrap = 1
    .s(wrap)               // tells us whether we need to wrap letter value
  );

endmodule
