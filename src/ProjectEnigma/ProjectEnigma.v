`timescale 1ns / 1ns

/*
NOTE: KEY SYNTAX

input [n:m] KEY
...
KEY[j]


HEX SYNTAX

output [6:0]HEXN

...

... = HEXN

*/

module main(
		output [7:0] LEDG,
		output [6:0] HEX0,
		output [6:0] HEX2,
		output [6:0] HEX3,
		input [17:0]SW,
		input [0:3] KEY,
		input CLOCK_50
		);

	localparam ONE = 1'b1;
	wire key_pressed = 1'b1 - KEY[2]; // not(key[2])
	wire [3:0] state;
	wire [7:0] rotor_out;

	// rotor
	rotor_0_25 rotor(
		.rotor_out(rotor_out),
		.user_increment(KEY[2]),
		.load_init_state(SW[16]),
		.rotor_init_state(SW[4:0])
	);

	assign LEDG[7] = key_pressed;
	assign LEDG[6:0] = rotor_out;

	// TEMP - seeing state
	hex_display state_display(
		.IN(state),
		.OUT(HEX0)
	);

/**
	// TEMP: seeing rotor value
	hex_display rotor_val_low(
		.IN(rotor_out[3:0]),
		.OUT(HEX2)
	);
*/

	hex_display rotor_val_high(
		.IN({1'b0, rotor_out[6:4]}),
		.OUT(HEX3)
	);


endmodule
