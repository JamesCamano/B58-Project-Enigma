`timescale 1ns / 1ns

/*
Represents the Enigma Machine.
*/
module enigma(
  output [7:0] letter_out,
  input encrypt,
  input [7:0] char_input,			// ASCII
  input char_pressed,
  input [4:0] rotor_init_state,
  input load_init_state);

  wire [7:0] rotor_out;

  // first rotor
  rotor_0_25 rotor_1(
    .rotor_out(rotor_out),
    .clk(char_pressed),
    .load_init_state(load_init_state),
    .rotor_init_state(rotor_init_state)
    );

  // letter shifter
  letter_shifter shifter(
    .letter_out(letter_out),
    .encrypt(encrypt),
    .char_input(char_input),
    .rotor_value(rotor_out)
  );

endmodule
