`timescale 1ns / 1ns
/*
  A 0.25 Hz clock.
*/
module rate_divider (
  output clk;
  input CLOCK_50;
  );

  /*
  Note: (5 * 10^7) / 4 = 1.25 * 10^6
  lg(1.25*10^6) ~= 23.6 ~= 24
  */
  // 24-bit register - should be initialized to 0 by default.
  localparam START_VAL = 24'd0;

  reg [23:0] counter = START_VAL;
  always @ (posedge CLOCK_50) begin
    counter = counter + 1'b1;
  end

  assign clk = counter == START_VAL;
endmodule //rate_divider
