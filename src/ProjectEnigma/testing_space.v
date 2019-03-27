`timescale 1ns / 1ns

/* A module for testing purposes. */


module testing_space(
		output	[7:0] LEDG,
		input 	[7:0] SW,
		input 	[1:0] KEY,
		input		CLOCK_50 // WE MUST HAVE THIS FOR CLOCK RATE_DIVIDER FUNCTIONALITY.
	);

	wire clk;
	wire [7:0] rotor_out;

	rate_divider_quarter_second rate_div(
		.clk_out(clk),
		.clk_in(CLOCK_50)
	);

  clocked_rotor_0_25(
	  .rotor_out(rotor_out),   // 8-bit representation. note -always non-negative
	  .increment(SW[7]),
	  .load(SW[6]),                       // async set
	  .rotor_init_state(SW[3:0]),     // 5-bit state
	  .clk(clk)	                        // clock
  );


	assign LEDG = rotor_out;

endmodule
