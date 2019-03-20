`timescale 1ns / 1ns

/* Represents a seven_bit unsigned adder-subtractor.
    This module performs the following arithmetic and returns in Sum:
      A + B, if Add = 1.
      A - B, if Add = 0.

      TODO: Carryout C_Out if needed.
 */
module adder_eight_bit(
  output [7:0] sum,
  input  [7:0] A,
  input  [7:0] B,
  input        add);

  reg [7:0] result;
  // convenient constants
  localparam ADD_ENABLE = 1'b1;
  /* check which operation we need to do, and proceed accordingly.
  */
  always@(*)
  begin: operation_check
    if(add == ADD_ENABLE) // add only if ADD_ENABLE is logic-1.
      result <= A+B; // A+B
    else
      result <= A-B; // A-B
  end // operation_check

  // output
  assign sum = result;
endmodule
