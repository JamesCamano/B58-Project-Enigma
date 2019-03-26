`timescale 1ns / 1ns

/*
An eight-bit value checker.
R = 1 iff alpha is equal to beta.

 */
module ascii_equality_checker (
  output R,
  input [7:0] alpha,
  input [7:0] beta
  );

  // equality check
  assign R = alpha == beta;

endmodule // ascii_equality_checker
