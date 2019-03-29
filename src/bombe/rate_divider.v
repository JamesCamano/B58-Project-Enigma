`timescale 1ns / 1ns
/*
  A 0.25 Hz clock., given that clk_in is CLOCK_50.
	TODO: reset?
*/
module rate_divider_quarter_second (
	output clk_out,
	input clk_in);
  /*
  Note: (5 * 10^7) / 4 = 1.25 * 10^6
  lg(1.25*10^6) ~= 23.6 ~= 24
  */
  // 24-bit register - should be initialized to 0 by default.

  localparam START_VAL = 1'd0;

  reg [24:0] counter;

  always @ (posedge clk_in) begin
    counter = counter + 1'b1;
  end

  assign clk_out = counter[24] == START_VAL;

endmodule //rate_divider
