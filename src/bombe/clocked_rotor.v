`timescale 1ns / 1ns

/**
  The same rotor as rotor_0_25, but with a clock.
  This rotor is positive-edge triggered.
*/

/**
TODO: Write an FSM for this - off/on for clocked_increment and load.

*/
module clocked_rotor_0_25(
  output [7:0] rotor_out,   // 8-bit representation. note -always non-negative
  input increment,
  input load,                       // async set
  input [4:0] rotor_init_state,     // 5-bit state
  input clk	                        // clock
  );

  wire key_released;
  wire reset_state;

  clocked_rotor_FSM fsm(
    .key_release(key_released),
    .reset_state(reset_state),
    .clk(clk),
    .reset(load)
  );

  clocked_rotor_datapath datapath(
    .rotor_out(rotor_out),
    .key_release(key_release),
    .reset_state(reset_state),
    .rotor_init_state(rotor_init_state)
  );

endmodule // clocked_rotor_0_25

/*
  The finite state machine for the clocked rotor.
 */
module clocked_rotor_FSM(
  output reg key_release,             // tells the datapath to reset the increment bit
  output reg reset_state,             // tells the datapath to reset the state of the rotor.
  input clk,                          // clock of clocked rotor.
  input reset);

  // possible states
  localparam  SAVE_VALUE = 3'b000;
  localparam  CHECK_VALUE = 3'b100;
  localparam  RESET_ROTOR = 3'b001;

  // convenience parameters
  localparam  ON = 1'b1;
  localparam  OFF = 1'b0;

  reg [2:0] current_state;  // 3-bit state register
  //reg next_state;

  always @( posedge clk or posedge reset ) begin: state_table
    case(current_state) // always go to reset if it is on, otherwise, just bounce
      SAVE_VALUE:       current_state = reset ? RESET_ROTOR : CHECK_VALUE;
      CHECK_VALUE:      current_state = reset ? RESET_ROTOR : SAVE_VALUE;
      RESET_ROTOR:      current_state = reset ? RESET_ROTOR : SAVE_VALUE;  // if we have just reset, save the value for safety
      default:          current_state = SAVE_VALUE;                        // default to save value. Ensures that we always have a valid state.
    endcase
  end // state_table

  // querying the current state
  always @ ( posedge clk or posedge reset ) begin: query_state
    key_release = OFF;
    reset_state = OFF;

    case(current_state)
      SAVE_VALUE:       key_release = ON;   // release the key
      CHECK_VALUE:      key_release = OFF;  // press the key
      RESET_ROTOR:      reset_state = ON;   // async reset.
    endcase
  end // query_state

endmodule

/*
The datapath for the clocked rotor.
*/
module clocked_rotor_datapath(
  output [7:0] rotor_out,
  input key_release,
  input reset_state,
  input [4:0] rotor_init_state
);

  wire key_press = ~key_release; // if key_release is 0, then we want to increment the rotor.

  // since the rotor's increment is sensitive to keypress changes, and
  //  load_init_state is async, we should just be able to pass everything in.
  rotor_0_25 rotor(
    .rotor_out(rotor_out),
    .user_increment(key_press),
    .load_init_state(reset_state),
    .rotor_init_state(rotor_init_state)	 // whether or not we switch here is predicated on reset_state.
  );

endmodule
