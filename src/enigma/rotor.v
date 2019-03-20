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
module rotor_0_25( // split to debug
  output reg [7:0] rotor_out,       // 8-bit representation. note -always non-negative
//  output reg [3:0] TEMP_STATE,    // a temporary output to see state
  input user_increment,
  input load_init_state,            // async set
  input [4:0] rotor_init_state      // 5-bit state
  );
  // 25 = 16 + 8 +
  localparam THREE_BIT_SIGN_EXT = 2'b00;
  localparam DEFAULT_VALUE = 8'd0;
  localparam BEGINNING_VALUE = 8'd0, END_VALUE = 7'b0011001;
  localparam ONE = 8'b0000_0001;
  localparam ON = 1'b1;

  // control wires
  wire reset_rotor;
  wire increment_rotor;

  // a wire that dictates whether the user has interacted with the machine or not
  wire user_interacted;
  assign user_interacted = user_increment | load_init_state;

  rotor_0_25_control rotor_control(
      .increment(increment_rotor),
      .reset(reset_rotor),
      .user_increment(user_increment),
      .load_init_state(load_init_state)
  );

  rotor_0_25_datapath rotor_0_25_datapath(
      .rotor_out(rotor_out),
      .user_input(user_interacted),
      .increment(increment_rotor),
      .reset(reset_rotor),
      .rotor_state(rotor_init_state)
  );

endmodule

/* The control module for the rotor circuit.
   The FSM for this cicruit changes on the positive edge of the keypress.

   The control circuit is sensitive to:
    - key(board) presses, and
    - an active reset switch.

   This control circuit has outputs:
    - increment: tells the datapath to increment the current register value.
                 this value will be logic-0 if the user has reset states.

    - reset:     tells the datapath to reset the current state of Enigma.
                 this bit will take precedence over increment.
 */
module rotor_0_25_control(
    output reg increment,
    output reg reset,
    input user_increment,
    input load_init_state);

    // state register
    reg current_state;                    // single-bit state reg

    // convenience constants
    localparam  OFF = 1'b0,
                ON  = 1'b1;

    // state table
    localparam  ROTOR_STANDARD = 1'b0,   // when in increment mode
                ROTOR_RESET = 1'b1;      // when user has pressed reset.

    // activate whenever user has sent the user_increment flag up, or pressed
    //  the reset button
    // NOTE: This saves us a state, since we will implicitly be in the same state -> only input will potentially change our state.
    always@(posedge user_increment or posedge load_init_state)
    begin: state_table
      case(current_state):
        ROTOR_STANDARD:   current_state = load_init_state ? ROTOR_RESET : ROTOR_STANDARD;    // if we are in standard mode, we want to be sensitive of reset.
        ROTOR_RESET:      current_state = load_init_state ? ROTOR_RESET : ROTOR_STANDARD;    // ''
        default:          current_state = ROTOR_RESET;  // we will hit this value iff current_state has no value. Default to rotor reset to 0, and we assume that DATAPATH will take care of the rest.
      endcase
    end // state_table


    // query the current state, in the same 'line' as the above block.
    always@(posedge user_increment or posedge load_init_state)
    begin: enable_signals
      // make all our output signals zero. hence we need not a default value.
      increment = OFF;
      reset = OFF;

      case(current_state):
        ROTOR_STANDARD: increment = ON; // reset is already off for us.
        ROTOR_RESET:    reset = ON;     // increment is already off for us.
      endcase
    end // enable_signals

    // by the end of this module, we should either have a 10 or 01 for <increment, reset>.
endmodule

/* The datapath of the 0 -> 25 numero-lexicographical rotor.
  Contains:
    - A 5-bit counter whose values cycle from 0-25 in increasing order..

  Takes in as input:
    - user_input        - to tell the circuit whether or not we should start the datapath. The nature of this input should be so that it is on when the user has interacted with the circuit in some way.
    - increment bit     - dictates whether to increment the value in the rotor.
    - reset bit         - dictates whether to reset the value of the ROTOR_RESET
    - 5-bit rotor_state - the desired starting state of the enigma machine.*

    * if rotor_state > 5'd25, then the circuit will set the value to the default of 5'd0.
 */
module rotor_0_25_datapath(
  output reg [7:0] rotor_out,   // output value of rotor.
  input user_input,             // a button press - triggere
  input increment,
  input reset,
  input [4:0] rotor_state);

  // convenient constants.
  localparam TWO_BIT_SIGN_EXT = 2'b00;

  localparam MIN_VALUE = 8'd0, MAX_VALUE = 8'b0001_1001;
  localparam DEFAULT_VALUE = 8'd0;
  localparam ONE = 8'b0000_0001;

  localparam  OFF = 1'b0,
              ON  = 1'b1;

  reg [7:0] bit_extended_rotor_state;
  // we will be sensitive to reset first. Check if its on.
  always@(posedge user_input)
  begin: datapath_functionality
    bit_extended_rotor_state <= {TWO_BIT_SIGN_EXT, rotor_state};

    if (reset == ON) // as of currently, reset is activated every time user presses reset, or at start of circuit.
      begin: reset_functionality
          if (bit_extended_rotor_state >= MAX_VALUE) // if the user has inputted too large a value
            rotor_out = DEFAULT_VALUE;               // reset the value of the rotor
          else
            rotor_out = bit_extended_rotor_state
      end // reset_functionality
    else // the fact that user_input is high means that we want to increment
      begin: increment_functionality
        rotor_out = rotor_out + ONE;
        if (rotor_out >= MAX_VALUE)
          rotor_out = DEFAULT_VALUE;
      end // increment_functionality
  end // datapath_functionality
endmodule
