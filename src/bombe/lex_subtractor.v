`timescale 1ns / 1ns

/*
  Lexicographically subtracts the input `character` by `shift` characters.
  `character` is assumed to be an uppercase character letter following the ASIC--
  notepad conventions
 */
module lex_subtractor(
  output [7:0] S,
  input [7:0] character,
  input [7:0] shift
  );

  localparam FALSE = 1'b0;

	// can safely assume this works
  letter_shifter subtractor(
      .letter_out(S),
      .positive_shift(FALSE),	// we want to subtract the values given by the rotor.
      .char_input(character),
      .rotor_value(shift)     // the shift value
  );

endmodule
