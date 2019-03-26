`timescale 1ns / 1ns

/**
  The same rotor as rotor_0_25, but with a clock.
  This rotor is positive-edge triggered.
*/
module clocked_rotor_0_25(
  output [7:0] rotor_out,   // 8-bit representation. note -always non-negative
  input increment,
  input load,                       // async set
  input [4:0] rotor_init_state      // 5-bit state
  input clk;                        // clock
  );

  localparam SAVE_VALUE = 0'b0;
  // note that the rotor _maintains_ state when:
  //    - clocked_increment == 0
  //    - clocked_load == 0
  //    - clocked_rotor_init_state = X

  wire clocked_increment;
  wire clocked_load;

  // s = clk = 0 -> m = x = default
  // s = clk = 1 -> m = y = input value

  mux2to1 clk_load(
    .x(SAVE_VALUE),
    .y(load),
    .s(clk),
    .m(clocked_load)
  );

  mux2to1 clk_increment(
    .x(SAVE_VALUE),
    .y(increment),
    .s(clk),
    .m(clocked_increment)
  );

  rotor_0_25 rotor(
    .rotor_out(rotor_out);
    .user_increment(clocked_increment);
    .load_init_state(clocked_load);
    .rotor_init_state(rotor_init_state); // whether or not we switch here is predicated on clocked_load.
  );

endmodule // clocked_rotor
