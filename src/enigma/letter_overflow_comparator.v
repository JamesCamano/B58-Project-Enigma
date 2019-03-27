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
  // convenient constants- updated for ASIC Notepad-- proj
  localparam LETTER_A = 8'h41, LETTER_Z = 8'h5A; //LETTER_A = 7'd65, LETTER_Z = 7'd90;
  localparam TRUE = 1'b1, FALSE = 1'b0;
  
  /*
  SPACE FOR COMPARITOR MODULES
  */
  always@(*)
  begin
    if(NTCV < LETTER_A) // underflow condition.
      NTCV_underflow <= TRUE;
    else
      NTCV_underflow <= FALSE;
  end

  always@(*)
  begin
    if(NTCV > LETTER_Z) // overflow condition.
      NTCV_overflow <= TRUE;
    else
      NTCV_overflow <= FALSE;
  end

  // define what side of the relationship we should
  //  success is returned
  mux2to1 ineq_relationship(
    .x(NTCV_underflow),
    .y(NTCV_overflow),
    .s(Gr),
    .m(success)
  );
endmodule
