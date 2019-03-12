`timescale 1ns / 1ns

module main(
		output [17:0] LEDR,
		input [17:0]SW
		);


	// rotor
	rotor_0_25 rotor(
		.rotor_out(LEDR[6:0]),
		.clk(SW[17]),
		.load_init_state(SW[16]),
		.rotor_init_state(SW[4:0])
	);
	
endmodule
