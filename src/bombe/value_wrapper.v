`timescale 1ns / 1ns

/*
  A module that computes val mod 26.
*/
module value_wrapper_0_25(
  output [7:0] wrapped_val,
  input [7:0] val
  );
  localparam  TWENTY_SIX = 8'd26;
  assign wrapped_val = val % TWENTY_SIX;
endmodule
