`timescale 1ns / 1ns // `timescale time_unit/time_precision

//SW[2:0] data inputs
//SW[9] select signal

//LEDR[0] output display

module lab_1(LEDR, SW);
    input [9:0] SW;
    output [9:0] LEDR;

    mux2to1 my_mux(
        .x(SW[0]),
        .y(SW[1]),
        .s(SW[9]),
        .m(LEDR[0])
        );
endmodule

module mux2to1(x, y, s, m);
    input x; //selected when s is 0
    input y; //selected when s is 1
    input s; //select signal
    output m; //output
  
    assign m = s & y | ~s & x;
    // OR
    // assign m = s ? y : x;

endmodule

module mux2to1_eight_bit(
    output [7:0] m, //
    input [7:0] x, //selected when s is 0
    input [7:0] y, //selected when s is 1
    input s //select signal
	 );
	 
	 /*
	 reg [7:0] out;
	
	 always@(*)
	 begin: mux
		if (s == 1'b0) 
			out = x;
		else
			out = y;
	 end // mux
	 
    assign m = out;
	 */
	 
	 assign m = s ? y : x;
endmodule
