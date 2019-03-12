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
  output reg [6:0] rotor_out,   // 7-bit representation
  input clk,                    // sync incrementer
  input load_init_state,        // async set
  input [4:0] rotor_init_state
  );

  localparam TWO_BIT_SIGN_EXT = 2'b00;
  localparam DEFAULT_VALUE = 7'd0;
  localparam BEGINNING_VALUE = 7'd0, END_VALUE = 7'd25;
  localparam ONE = 7'd1;

  always@(load_init_state) // always when load_init_state changes - or always@(*)
  begin: reset
    if (load_init_state == 1'b1)
      begin: check_invalid
        if (load_init_state > END_VALUE)                   // if past 7'd25 
          rotor_out <= DEFAULT_VALUE;                      // set to default
        else
          rotor_out <= {TWO_BIT_SIGN_EXT, rotor_init_state}; // set to inital state
      end // check_invalid
  end

  // NOTE: what happens if user just presses wihout
  // setting?
  always@(posedge clk) // clock has incremented.
  begin: increment
    rotor_out <= rotor_out + ONE;
    begin: check_overflow // check if we have overflowed
      if (rotor_out > END_VALUE)
        rotor_out <= BEGINNING_VALUE;
    end // check_overflow
  end // increment
endmodule
