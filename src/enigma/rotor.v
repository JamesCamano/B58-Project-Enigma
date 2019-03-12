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
  input clk,                    // sync incrementer
  input load_init_state,        // async set
  input [4:0] rotor_init_state
  );
  
  localparam TWO_BIT_SIGN_EXT = 2'b00;
  localparam DEFAULT_VALUE = 7'd0;
  localparam BEGINNING_VALUE = 7'd0, END_VALUE = 7'd25;
  localparam ONE = 7'd1;

  /* Starting, rotor does not have a value - default to zero.
	  If the rotor has a value, then increment
	  If the user wants to set the value, check if bad value, and 'assign' accordingly.
  */
	
  // STATES
  localparam NULL_VAL = 2'd0, VAL = 2'd1, USER_SET = 2'd2;
	
  // STATE REGISTER
  reg [1:0] current_state;
  reg [6:0] untrimmed_rotor_value;
  
  always@(*)
  begin: state_table
		case(current_state)
			NULL_VAL: current_state = VAL; // cannot escape null value state, if have null value?
			VAL: current_state = VAL;				// assume always in a valid valued state
			USER_SET: current_state = VAL; 		// handle invalid value, and then go to valid value state
		default: current_state = NULL_VAL;
		endcase
  end // state_table
  
  always@(*) begin: big_begin
	  case(current_state)
			NULL_VAL: 
				begin: initialize_rotors
					rotor_out <= DEFAULT_VALUE;
					untrimmed_rotor_value <= DEFAULT_VALUE;
				end // initialize_rotors 
			
			VAL: 
				begin: increment
					if (clk == 1'b0) 
						begin: overflow
							if (rotor_out == END_VALUE)
								rotor_out <= DEFAULT_VALUE;
							else
								rotor_out <= rotor_out + ONE;
						end // overflow
				end // increment
				
			USER_SET:
				begin: user_load
					if (rotor_init_state > END_VALUE)
						rotor_out <= DEFAULT_VALUE;
					else
						rotor_out <= rotor_init_state;
				end // user_load
			
			default: 
				begin: constant
					rotor_out <= rotor_out; // don't do anything
				end // constant
	  endcase
  end // big_begin
  
endmodule
