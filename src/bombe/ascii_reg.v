`timescale 1ns / 1ns

/*
A 8-bit register, designed to hold a ascii value.
Contains a load bit, dictating whether this register is to hold the value.
Contains an asynchronous reset. Defaults to "A" (where the value is represented
as 8d'41)

Note that both load and reset are active-high.
*/
module ascii_reg (
  output reg [7:0] S,
  input load,
  input reset,
  input [7:0] letter
  );

  localparam CHAR_A = 8'h41; // see ascii decoder for ASIC-- notepad.
  localparam ON = 1'b1;

  always @ (posedge reset or posedge load)
  begin: load_reset
    // check if reset
    if (reset == ON)
      S = CHAR_A;
    else
      S = letter; // load must have triggered this.
  end // load_reset
  
endmodule //ascii_reg
