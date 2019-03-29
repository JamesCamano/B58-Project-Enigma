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
  input  [7:0] char_in,
  input  key_press;     // HOW
  input  go;            // start deduction
  input clk;            // assume CLOCK_50
  input reset);

  wire circuit_reset;
  wire [2:0] load_reg;
  wire rotor_en;
  wire arithmetic_end;
  wire rotor_clk;
  wire inhibited_clk; // used to toggle clk_50

  bombe_control fsm(
    .reset_to_beginning(circuit_reset),
    .load_s0(load_reg[0]),
    .load_s1(load_reg[1]),
    .load_s2(load_reg[2]),
    .rotor_enable(rotor_en),
    .reset(reset),
    .key_press(key_press),
    .go(go),
    .arithmetic_end(arithmetic_end),
    .control_clk(clk)
    );

  and(inhibited_clk, rotor_en, CLOCK_50);

  rate_divider_quarter_second divider(
    .clk_out(rotor_clk),
    .clk_in(inhibited_clk)
  );

  bombe_datapath bombe_datapath(
    .bombe_out(bombe_out),
    .arithmetic_end(arithmetic_end),
    .char(char_in),
    .load_s0(load_reg[0]),
    .load_s1(load_reg[1]),
    .load_s2(load_reg[2]),
    .reset(circuit_reset),
    .rotor_enable(rotor_en),
    .rotor_clk(rotor_clk)
  );

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
  output load_s0,                       // load first ascii reg.
  output load_s1,                       // '' second ''
  output load_s2,                       // '' third ''
  output rotor_enable,                  // enabler for rotor increment.
  input reset,                          // async reset
  input key_press,                      // indicator bit for user pressing bit.
  input go,                             // indicator bit for user starting bombe.
  input arithmetic_end,                 // indicator bit for deduction success/failure.
  input control_clk;                    // clock for control circuit.
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
  reg [3:0] current_state;
  reg [3:0] next_state;

  // convenient parameters
  localparam  ON = 1'b1;
  localparam  OFF = 1'b0;

  // STATES
  // load
  localparam LOAD_S0        = 4'd0;
  localparam LOAD_S0_WAIT   = 4'd1;   // intermediate state for waiting until key_press goes low. same for similarly-named states.

  localparam LOAD_S1        = 4'd2;
  localparam LOAD_S1_WAIT   = 4'd3;

  localparam LOAD_S2        = 4'd4;
  localparam LOAD_S2_WAIT   = 4'd5;

  // process start / continue
  localparam DECUCT_WAIT    = 4'd10;
  localparam DEDUCT         = 4'd6;   // main functionality state.

  // end/reset
  localparam PROCESS_END    = 4'd7;   // success/failure state.
  localparam RESET          = 4'd8;   //
  localparam RESET_WAIT     = 4'd9;   // intermediate state for waiting until reset goes low.

  // QUERY CURRENT STATE AND CHOOSE NEXT STATE
  // TODO: reset stages for load.
  // Note, we can do begin/end statements within cases - see poly_function.v line 157.
  always @ ( * ) begin: state_table                                         // when ANYTHING changes, check the state table.
    case (current_state)
        LOAD_S0:        next_state = key_press ? LOAD_S0_WAIT : LOAD_S0;    // loop in LOAD_S0 until key_press is high.
        LOAD_S0_WAIT:   next_state = key_press ? LOAD_S0_WAIT : LOAD_S1;    // loop in waiting stage, until the key is released.
        LOAD_S1:        next_state = key_press ? LOAD_S1_WAIT : LOAD_S1;
        LOAD_S1_WAIT    next_state = key_press ? LOAD_S1_WAIT : LOAD_S2;
        LOAD_S2:        next_state = key_press ? LOAD_S2_WAIT : LOAD_S2;
        LOAD_S2_WAIT    next_state = key_press ? LOAD_S2_WAIT : DEDUCT_WAIT;// Begin deducing after this key press goes low.
        DEDUCT_WAIT     next_state = go        ? DEDUCT: DEDUCT_WAIT;
        DEDUCT          next_state = arithmetic_end ? PROCESS_END: DEDUCT;  // Until we get the arithmetic_end flag, keep on deducing.
        PROCESS_END     next_state = reset ? RESET : PROCESS_END;           // stay in process end state until user explicitly wants to reset.
        RESET:          next_state = RESET_WAIT;
        RESET_WAIT:     next_state = reset ? RESET_WAIT : LOAD_S0;          // loop in reset_wait state until reset is low.
      default: next_state = RESET;                                          // default to reset so that we can assure that everything has correct starting values.
    endcase
  end // state_table


  // QUERY CURRENT STATE TO DEFINE CONTROL BITS
  always @ ( * ) begin: enable_signals
    // note: setting every bit to off assumes preserving state.
    reset_to_beginning = OFF;
    load_s0 = OFF;
    load_s1 = OFF;
    load_s2 = OFF;
    rotor_enable = OFF;

    case (current_state)
      LOAD_S0:    load_s0 = ON;
      LOAD_S1:    load_s1 = ON;
      LOAD_S2:    load_s2 = ON;
      DEDUCT:     rotor_enable = ON;        // enable the rotor so that we may deduce values.
      RESET:      reset_to_beginning = ON;
      RESET_WAIT: reset_to_beginning = ON; // keep the reset on for safety.
      //default: ;                         // default means that we just preserve state. This will be in all wait states.
    endcase
  end // enable_signals

  // SWITCH TO NEXT STATE
  always @ ( posedge clk ) begin: state_transition
    // check for reset here for async reset?
    current_state <= next_state;
  end
endmodule //bombe_control

module bombe_datapath (
  output [7:0] bombe_out,
  output arithmetic_end,
  input [7:0] char,
  input load_s0,
  input load_s1,
  input load_s2,
  input reset,
  input rotor_enable,
  input rotor_clk       // clock for rotor.
  );

  // convenience variables
  localparam ROTOR_ZERO = 5'd0;
  localparam  ONE = 2'd1,
              TWO = 2'd2,
              ZERO = 2'd0;

  localparam ROTOR_MAX = 8'd25;

  localparam ERROR_VAL = 8'b1111_1111;

  // could be represented by an 8-bit * 3 wire
  wire [7:0] enc_s0;
  wire [7:0] enc_s1;
  wire [7:0] enc_s2;

  // `decrypted` s1, s2 and s3.
  wire [7:0] dec_s0;
  wire [7:0] dec_s1;
  wire [7:0] dec_s2;

  // shifted rotor values
  wire [7:0] x_0;
  wire [7:0] x_1;
  wire [7:0] x_2;

  // wire equality results
  wire [2:0] R;

  // result mux select
  wire result_mux_select;

  // connecting combinatorial wires
  wire matched_sequence;

  // rotor values
  wire [7:0] rotor_out;
  wire rotor_end;       // flag that rotor has reached max value

  // LOAD
  // registers
  ascii_reg s1(
    .S(enc_s0),
    .load(load_s0),
    .reset(reset),
    .letter(char)
  );

  ascii_reg s2(
    .S(enc_s1),
    .load(load_s1),
    .reset(reset),
    .letter(char)
  );

  ascii_reg s3(
    .S(enc_s2),
    .load(load_s2),
    .reset(reset),
    .letter(char)
  );


  // DEDUCT
  // clocked rotor
  clocked_rotor_0_25(
    .rotor_out(rotor_out),
    .increment(rotor_enable),       // see NANDed portion in diagram
    .load(reset),                   // note connection to total reset
    .rotor_init_state(ROTOR_ZERO),
    .clk(rotor_clk)
    );

  // because we have a rotor x_0 is guaranteed to be 0->25
  // values
  assign x_0 = rotor_out; //+ ZERO;

  value_wrapper_0_25(
      .wrapped_val(x_1),
      .val(rotor_out + ONE)
  );

  value_wrapper_0_25(
      .wrapped_val(x_2),
      .val(rotor_out + TWO)
  );

  // lexicographic subtractors
  lex_subtractor l_s0(
    .S(dec_s0),
    .character(enc_s0),
    .shift(x_0)
  );

  lex_subtractor l_s1(
    .S(dec_s1),
    .character(enc_s1),
    .shift(x_1)
  );

  lex_subtractor l_s2(
    .S(dec_s2),
    .character(enc_s2),
    .shift(x_2)
  );

  // SUCCESS / FAILURE.
  // Equality
  localparam  ORD_A = 8'd65,
              ORD_B = 8'd66,
              ORD_C = 8'd67;

  ascii_equality_checker c_0(
    .R(R[0]),
    .alpha(dec_s0),
    .beta(ORD_A)
  );

  ascii_equality_checker c_1(
    .R(R[1]),
    .alpha(dec_s1),
    .beta(ORD_B)
  );

  ascii_equality_checker c_2(
    .R(R[2]),
    .alpha(dec_s2),
    .beta(ORD_C)
  );

  // we have matched the sequence iff equality passes.
  assign matched_sequence = &R;
  assign rotor_end = rotor_value == ROTOR_MAX;
  and(result_mux_select, rotor_end, ~matched_sequence);

  mux2to1(
    .x(rotor_out),
    .y(ERROR_VAL),
    .s(result_mux_select),
    .m(bombe_out)
  );

  // OUTPUT ASSIGNMENTS
  // end flag
  or(arithmetic_end, matched_sequence, rotor_end);

endmodule //bombe_datapath
