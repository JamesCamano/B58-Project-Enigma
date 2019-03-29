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

module Enigma(
		output [7:0] LEDG,
		output [17:0] LEDR,
		output [6:0] HEX0,
		output [6:0] HEX1,
		output [6:0] HEX2,
		output [6:0] HEX3,
		output [6:0] HEX4,
		output [6:0] HEX5,
		output [6:0] HEX6,
		output [6:0] HEX7,
		input [17:0]SW,
		input [0:3] KEY,
		input CLOCK_50
		);

	localparam ONE = 1'b1;
	wire key_pressed = ~KEY[3]; // not(key[2])
/*
	wire [3:0] state;
	wire [7:0] rotor_out;

	// rotor
	rotor_0_25 rotor(
		.rotor_out(rotor_out),
		.user_increment(KEY[2]),
		.load_init_state(SW[16]),
		.rotor_init_state(SW[4:0])
	);

	//assign LEDG[7] = key_pressed;
	assign LEDG[7:0] = rotor_out;

	// TEMP - seeing state
	hex_display state_display(
		.IN(state),
		.OUT(HEX0)
	);


	// TEMP: seeing rotor value
	hex_display rotor_val_low(
		.IN(rotor_out[3:0]),
		.OUT(HEX2)
	);


	hex_display rotor_val_high(
		.IN({1'b0, rotor_out[7:4]}),
		.OUT(HEX3)
	);

*/

/* ENIGMA testing
	wire [7:0] enigma_out;
	wire [7:0] rotor_out;
	wire TEMP_WRAP;

	wire [7:0] NTCS;

	hex_display input_val_low(
		.IN(SW[3:0]),
		.OUT(HEX4)
	);

		hex_display input_val_high(
		.IN(SW[7:4]),
		.OUT(HEX5)
	);


	hex_display output_val_low(
		.IN(NTCS[3:0]),
		.OUT(HEX6)
	);

	hex_display output_val_high(
		.IN(NTCS[7:4]),
		.OUT(HEX7)
	);

	hex_display rotor_out_low(
		.IN(rotor_out[3:0]),
		.OUT(HEX0)
	);

	hex_display rotor_out_high(
		.IN(rotor_out[7:4]),
		.OUT(HEX1)
	);

	enigma eni(
		.letter_out(enigma_out),
		.TEMP_WRAP(TEMP_WRAP),
		.TEMP_NTCS(NTCS),
		.TEMP_ROTOR(rotor_out),
		.encrypt(SW[17]),
		.char_input(SW[7:0]),
		.char_pressed(key_pressed),
		.rotor_init_state(SW[15:11]),
		.load_init_state(SW[10])
	);

	assign LEDG[0] = TEMP_WRAP;
	assign LEDR = NTCS;
	*/


	wire [7:0] bombe_out;
	wire [7:0] char_in = SW[7:0];
	wire key_down = key_pressed;	 // active low
	wire start_deduct = ~KEY[0];
	wire global_clk = CLOCK_50;
	wire reset = SW[17];

	bombe bom(
		.bombe_out(bombe_out),
		.char_in(char_in),
		.state_out(LEDR[4:0]),
		.rotor_clk_out(LEDR[17]),
		.key_press(key_down),
		.go(start_deduct),
		.clk(CLOCK_50),
		.reset(reset)
	);

	// output
	hex_display bombe_out_low(
		.IN(bombe_out[3:0]),
		.OUT(HEX0)
	);

	hex_display bombe_out_high(
		.IN(bombe_out[7:4]),
		.OUT(HEX1)
	);


	hex_display input_val_low(
		.IN(char_in[3:0]),
		.OUT(HEX4)
	);

		hex_display input_val_high(
		.IN(char_in[7:4]),
		.OUT(HEX5)
	);
	
	
	/*
	assign LEDR[17] = ~KEY[0];
	assign increment = SW[17];
	assign load = SW[16];
	assign init_state = SW[4:0];
	
	clocked_rotor_0_25 r(
		.rotor_out(LEDR[7:0]),
		.current_state(LEDG[2:0]),
		.increment(increment),
		.load(load),
		.rotor_init_state(init_state),
		.clk(~KEY[0])
	);
	*/

endmodule
