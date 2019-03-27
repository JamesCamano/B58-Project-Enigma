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

  localparam SAVE_VALUE = 1'b0;
  localparam ON = 1'b1;
  // note that the rotor _maintains_ state when:
  //    - clocked_increment == 0
  //    - clocked_load == 0
  //    - clocked_rotor_init_state = X

  reg [7:0] rotor_val;
  reg clocked_increment;		// having these being the problem, rotor insensitive to clocked_increment being higher
  reg clocked_load;

  // s = clk = 0 -> m = x = default
  // s = clk = 1 -> m = y = input value
	
  always@(posedge clk)
  begin: clocked_rotor
	// set wires to default values
	clocked_increment = 1'b0;
	clocked_load =  1'b0;
	
	// the fact that the clock is positive here means that we perform whatever we need to do here
	if (load == ON)
		clocked_load = ON; // trigger the async load functinality
	else if (increment == ON)
		clocked_increment = ON; 
		
  end // clocked_rotor
  
  rotor_0_25 rotor(
    .rotor_out(rotor_out),
    .user_increment(clocked_increment),
    .load_init_state(clocked_load),
    .rotor_init_state(rotor_init_state)	 // whether or not we switch here is predicated on clocked_load.
  );

endmodule // clocked_rotor_0_25


module clocked_rotor_FSM();

endmodule

module clocked_rotor_datapath();
