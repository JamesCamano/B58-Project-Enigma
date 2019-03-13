`timescale 1ns / 1ns

/*
  A register that cycles through the values
  0-25, based on a initial state.

  This register returns its current value
  as a 7-bit value.


  NOTE: valid values of rotor_init_state
        are from 5'b0 (5'd0) to 5'b01101 (4'd25)

        If rotor_init_state is not within
        these values, then default will be
        0.

  NOTE: load_init_state is asychronous.
  The incrementation of the rotor is
  based on clk.
*/
module rotor_0_25(
  output reg [6:0] rotor_out,   // 7-bit representation. note -always non-negative
  output reg [3:0] TEMP_STATE,   // a temporary output to see state
  input clk,                    // sync incrementer
  input user_increment,
  input load_init_state,        // async set
  input [4:0] rotor_init_state
  );
  // 25 = 16 + 8 + 
  localparam TWO_BIT_SIGN_EXT = 2'b00;
  localparam DEFAULT_VALUE = 7'd0;
  localparam BEGINNING_VALUE = 7'd0, END_VALUE = 7'b0011001;
  localparam ONE = 7'b0_000_001;
  localparam ON = 1'b1;

  /* Starting, rotor does not have a value - default to zero.
	  If the rotor has a value, then increment
	  If the user wants to set the value, check if bad value, and 'assign' accordingly.
  */

  
  // STATES
  localparam NULL_VAL = 2'd0, VAL = 2'd1, USER_SET = 2'd2;

	
  // STATE REGISTER
  reg [1:0] current_state;
  reg [6:0] untrimmed_rotor_value;
  
  reg [25:0] rate_divider;

  always@(*)
  begin: state_table
		case(current_state)
			NULL_VAL: current_state = VAL; 												// cannot escape null value state, if have null value?
			VAL: current_state = load_init_state ? USER_SET: VAL;					// assume always in a valid valued state
			USER_SET: current_state = load_init_state ? USER_SET : VAL; 		// handle invalid value, and then go to valid value state
		default: current_state = NULL_VAL;
		endcase
  end // state_table
  
  always@(posedge clk) begin: big_begin // always on clock tick
	  case(current_state)
			NULL_VAL: 
				begin: initialize_rotors
					rotor_out <= DEFAULT_VALUE;
					rate_divider <= DEFAULT_VALUE;
				end // initialize_rotors 
			
			VAL: 
				begin: increment
					rate_divider <= rate_divider + ONE;									// increment rate divider-how about delay when pressing?
					if (rate_divider == 25'd0) begin: and_condition
						if (user_increment == ON) begin: overflow 					// WHAT
							if (rotor_out >= END_VALUE)
								rotor_out <= DEFAULT_VALUE;
							else
								rotor_out <= rotor_out + ONE;
						end // overflow
					end  // and_condition
				end // increment
				
			USER_SET:
				begin: user_load
					if (rotor_init_state > END_VALUE)
						rotor_out <= DEFAULT_VALUE;
					else
						rotor_out <= {TWO_BIT_SIGN_EXT, rotor_init_state}; // buffer user's input
				end // user_load
			
			default: 
				begin: constant
					rotor_out <= rotor_out; // don't do anything
				end // constant
	  endcase
	  
	  TEMP_STATE = {TWO_BIT_SIGN_EXT, current_state};
  end // big_begin
  
endmodule
