`timescale 1ns / 1ns

/*
High-level module of the Bombe machine.

Sequentially takes in 3 `flag` characters that might be encrypted by the Enigma machine,
and outputs the unique setting that produces these 3 characters in sequence.

The bombe machine has an asychronous reset.

NOTE: These flag characters <S0, S1, S2> are assumed to be the encrypted result
 of the sequence <A, B, C>.

*/
module bombe (
  output [7:0] bombe_out,
  input [7:0] char_in,
  input reset);



endmodule // bombe

/* Control module of the bombe.
   The control portion of this module is thought of to be in 4 stages:
    - 1. Input (with 3 sub stages),
    - 2. Equality check
    - 3. Rotor increment
    - 4. Success/Failure.
 */
module bombe_control (
  output reset_to_beginning,            // reset to start
  output load_s1,                       // load first ascii reg.
  output load_s2,                       // '' second ''
  output load_s3,                       // '' third ''
  output rotor_enable,                  // enabler for rotor increment.
  input reset,                          // async reset
  input key_press,                      // indicator bit for user pressing bit.
  input go,                             // indicator bit for user starting bombe.
  input arithmetic_end                  // indicator bit for deduction success/failure.
  );

  /* STATES:
    - 1. load reg s1
    - 2. load reg s2
    - 3. load reg s3

    - 4. deduction (start + continue) - effectively the same state

    - 5. end (success/failure state)

    - 6. RESET -> load reg s1

    ceil(log_2(6)) = log_2(8) = 3
  */

  // STATE REGISTERS
  reg [2:0] current_state;
  reg [2:0] next_state;

  // STATES
  // load
  localparam LOAD_S1        = 4'd0;
  localparam LOAD_S1_WAIT   = 4'd1;   // intermediate state for waiting until key_press goes low. same for similarly-named states.

  localparam LOAD_S2        = 4'd2;
  localparam LOAD_S2_WAIT   = 4'd3;

  localparam LOAD_S3        = 4'd4;
  localparam LOAD_S3_WAIT   = 4'd5;

  // process start / continue
  localparam DEDUCT         = 4'd6;   // main functionality state.

  // end/reset
  localparam PROCESS_END    = 4'd7;   // success/failure state.
  localparam RESET          = 4'd8;   //
  localparam RESET_WAIT     = 4'd9;   // intermediate state for waiting until reset goes low.

  // QUERY CURRENT STATE AND CHOOSE NEXT STATE
  // TODO: reset stages for load.
  always @ ( * ) begin: state_table                                         // when ANYTHING changes, check the state table.
    case (current_state)
        LOAD_S1:        next_state = key_press ? LOAD_S1_WAIT : LOAD_S1;    // loop in LOAD_S1 until key_press is high.
        LOAD_S1_WAIT:   next_state = key_press ? LOAD_S1_WAIT : LOAD_S2;    // loop in waiting stage, until the key is released.
        LOAD_S2:        next_state = key_press ? LOAD_S2_WAIT : LOAD_S2;
        LOAD_S2_WAIT    next_state = key_press ? LOAD_S2_WAIT : LOAD_S3;
        LOAD_S3:        next_state = key_press ? LOAD_S3_WAIT : LOAD_S3;
        LOAD_S3_WAIT    next_state = key_press ? LOAD_S3_WAIT : DEDUCT;     // Begin deducing after this key press goes low.
        DEDUCT          next_state = arithmetic_end ? PROCESS_END: DEDUCT;  // Until we get the arithmetic_end flag, keep on deducing.
        PROCESS_END     next_state = reset ? RESET : PROCESS_END;           // stay in process end state until user explicitly wants to reset.
        RESET:          next_state = RESET_WAIT;
        RESET_WAIT:     next_state = reset ? RESET_WAIT : LOAD_S1;          // loop in reset_wait state until reset is low.
      default: next_state = RESET;
    endcase
  end // state_table


  // QUERY CURRENT STATE TO DEFINE CONTROL BITS

  // SWITCH TO NEXT STATE

endmodule //bombe_control

module bombe_datapath (
  output [7:0] bombe_out,
  output arithmetic_end,
  input [7:0] ascii_val,
  input load_s1,
  input load_s2,
  input load_s3,
  input reset,
  input rotor_enable,
  input clk);



endmodule //bombe_datapath
