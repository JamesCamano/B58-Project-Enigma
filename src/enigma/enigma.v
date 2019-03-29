`timescale 1ns / 1ns

/*
Represents the Enigma Machine.
*/
module enigma_circuit(
  output [7:0] letter_out,
  output [7:0] TEMP_NTCS,			// Debugging
  output TEMP_WRAP,					// Debugging
  output [7:0] TEMP_ROTOR,
  output unwrapped_char_sum,
  input encrypt,
  input [7:0] char_input,			// ASCII
  input char_pressed,
  input [4:0] rotor_init_state,
  input load_init_state);

  wire [7:0] rotor_out;

  // first rotor
  rotor_0_25 rotor_1(
    .rotor_out(rotor_out),
    .user_increment(char_pressed),
    .load_init_state(load_init_state),
    .rotor_init_state(rotor_init_state)
    );
	 
  assign TEMP_ROTOR = rotor_out;

  // letter shifter
  letter_shifter shifter(
    .letter_out(letter_out),
	 .TEMP_NTCS(TEMP_NTCS),
	 .TEMP_WRAP(TEMP_WRAP),
    .positive_shift(encrypt),
    .char_input(char_input),
    .rotor_value(rotor_out)
  );

  
endmodule
