`timescale 1ns / 1ns

/*
  A module that compares and returns whether or not the
    letter representation NTCV (Non-truncated-character-value)
    has exceeded past the A-Z range.
    The result of This comparison is returned by success.

    Note that the NTCV is assumed to be an uppercase english
    letter following the ASIC Notepad-- definitions, +/-
    25.

    In addition, the Gr input defines the direction of which
    to check. e.g. if Gr = 0, then this circuit will check if NTCV
    is past Z.

*/
module letter_overflow_comparator(
  output success,
  input [7:0] NTCV,
  input Gr);

  reg NTCV_underflow;
  reg NTCV_overflow;
/* if passing reg values don't work
  wire underflow_A;
  wire overflow_Z;
*/
  // convenient constants
  localparam LETTER_A = 7'd65, LETTER_B = 7'd90;
  localparam true = 1'b1, false = 1'b0;
  
  /*
  SPACE FOR COMPARITOR MODULES
  */
  always@(*)
  begin
    if(NCTV < LETTER_A) // underflow condition.
      NTCV_underflow <= true;
    else
      NTCV_underflow <= false;
  end

  always@(*)
  begin
    if(NCTV > LETTER_Z) // underflow condition.
      NTCV_overflow <= true;
    else
      NTCV_overflow <= false;
  end

  // define what side of the relationship we should
  //  success is returned
  mux2to1 ineq_relationship(
    .x(NTCV_underflow_A),
    .y(NTCV_overflow_Z),
    .s(Gr),
    .m(success)
  );
endmodule
