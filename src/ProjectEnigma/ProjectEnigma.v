`timescale 1ns / 1ns

/*
NOTE: KEY SYNTAX

input [n:m] KEY
...
KEY[j]


HEX SYNTAX

output [6:0]HEXN

...

... = HEXN

*/


// main project file
module Enigma (
        input PS2_KBCLK,                            // Keyboard clock
        input PS2_KBDAT,                            // Keyboard input data
        input CLOCK_50,                             //    On Board 50 MHz
        input [1:0] KEY,                            // Reset key
		  input [17:0] SW,
        // The ports below are for the VGA output.  Do not change.
        output VGA_CLK,                             //    VGA Clock
        output VGA_HS,                              //    VGA H_SYNC
        output VGA_VS,                              //    VGA V_SYNC
        output VGA_BLANK_N,                         //    VGA BLANK
        output VGA_SYNC_N,                          //    VGA SYNC
        output [9:0] VGA_R,                         //    VGA Red[9:0]
        output [9:0] VGA_G,                         //    VGA Green[9:0]
        output [9:0] VGA_B,                          //    VGA Blue[9:0]
		  output [6:0] HEX0,
		  output [6:0] HEX1,
		  output [6:0] HEX2,
		  output [6:0] HEX3,
		  output [6:0] HEX4,
		  output [6:0] HEX5,
		  output [6:0] HEX6,
		  output [6:0] HEX7,
		  output [17:0]LEDR
    );
/*

	hex_display h0(
	       .IN(pixel_counter_transfer[3:0]),
	       .OUT(HEX0)
	);
	hex_display h1(
	       .IN(pixel_counter_transfer[7:4]),
	       .OUT(HEX1)
	);
	hex_display h2(
	       .IN(line_pos_counter_transfer[3:0]),
	       .OUT(HEX2)
	);
*/

    wire resetn;
    assign resetn = KEY[0];

    // Create the colour, x, y and writeEn wires that are inputs to the VGA adapter.
    wire [2:0] colour;
    wire [8:0] x;
    wire [7:0] y;
    wire writeEn;
    // Create wires used to transfer signals and data between datapath and FSM
    wire [7:0] pixel_counter_transfer;
    wire [5:0] x_pos_counter_transfer;
    wire [5:0] x_load;
    wire x_parallel;
    wire [5:0] line_pos_counter_transfer;
    wire [5:0] line_load;
    wire line_parallel;
    wire [3:0] y_pos_counter_transfer;
    wire [3:0] cursor_pixel_counter_transfer;
    wire [3:0] y_load;
    wire y_parallel;
    wire inc_pixel_counter_transfer, dec_x_pos_counter_transfer, inc_x_pos_counter_transfer,
        inc_y_pos_counter_transfer, dec_y_pos_counter_transfer, inc_line_pos_counter_transfer,
        dec_line_pos_counter_transfer;
    wire reset_pixel_counter_transfer, reset_x_pos_counter_transfer, reset_y_pos_counter_transfer,
        reset_line_pos_counter_transfer, load_char_transfer;
    wire shift_for_cursor_transfer, plot_cursor_transfer;
    // Create wires used to transfer keyboard input to datapath and FSM
    wire [7:0] ASCII_value;
    wire [7:0] kb_scan_code;
    wire kb_sc_ready, kb_letter_case;

    // Create an Instance of a VGA controller - there can be only one!
    // Define the number of colours as well as the initial background
    // image file (.MIF) for the controller.
    vga_adapter VGA
        (
            .resetn(resetn),
            .clock(CLOCK_50),
            .colour(colour),
            .x(x),
            .y(y),
            .plot(writeEn),
            /* Signals for the DAC to drive the monitor. */
            .VGA_R(VGA_R),
            .VGA_G(VGA_G),
            .VGA_B(VGA_B),
            .VGA_HS(VGA_HS),
            .VGA_VS(VGA_VS),
            .VGA_BLANK(VGA_BLANK_N),
            .VGA_SYNC(VGA_SYNC_N),
            .VGA_CLK(VGA_CLK)
        );

    defparam VGA.RESOLUTION = "320x240"; // "160x120" works, for sure
    defparam VGA.MONOCHROME = "FALSE";
    defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
    defparam VGA.BACKGROUND_IMAGE = "black_320.mif";

    // Instantiate keyboard input
    keyboard kd
        (
            .clk(CLOCK_50),
            .reset(~resetn),
            .ps2d(PS2_KBDAT),
            .ps2c(PS2_KBCLK),
            .scan_code(kb_scan_code),
            .scan_code_ready(kb_sc_ready),
            .letter_case_out(kb_letter_case)
        );

    key2ascii SC2A
        (
            .ascii_code(ASCII_value),
            .scan_code(kb_scan_code),
            .letter_case(kb_letter_case)
        );

  // PROJECT_ENIGMA SPACE.
  // This space is designated for 'global' entities that are relevant to both the Enigma machine and
  //  the bombe machine.
  // convenient constants
  localparam ORD_A = 8'h41;
  localparam ORD_Z = 8'h5A;
  localparam NULL_CHAR = 8'h0;

  wire user_pressed_key;  // a flag to signal that the user has pressed a key on the keyboard.
  wire is_valid_ascii;    // a bit flag to signal that we are in the correct character range.
  wire [7:0] new_ascii;   // a 8-bit representation of an ascii value. This will be used to transfer encrypted
                          //  values from Enigma (given correct input), or transfer regular input given to the Nombe,
                          //  to the monitor (given correct input.)

  assign is_valid_ascii   = ASCII_value <= ORD_Z && ASCII_value >= ORD_A;
  assign user_pressed_key = load_char_transfer && is_valid_ascii;

  // ENIGMA SPACE - comment out when done

	// ENIGMA: the encrypted ascii value.
  wire [7:0] enigma_out;  // the output of enigma. Persists until the next keypress.

  wire flag_encrypt                   = SW[17];
  wire flag_load_init_state           = SW[16];
  wire [3:0] rotor_init_state_setting = SW[3:0];


  assign new_ascii = is_valid_ascii ? enigma_out : NULL_CHAR; // default to the null character if we do not have a valid ascii value.

	// instantiate enigma machine
	enigma eni(
		.letter_out(enigma_out),
		.encrypt(flag_encrypt),
		.char_input(ASCII_value),
		.char_pressed(load_char_transfer),  // load_char_transfer is our signal that the user has pressed a key.
		.rotor_init_state(rotor_init_state_setting),
		.load_init_state(flag_load_init_state)
	);
// END OF ENIGMA SPACE - comment out when done.


// BOMBE SPACE  - comment out when done.
/*
  // bombe machine
  wire [7:0] bombe_result; // 8-bit ouput of bombe machine
  wire flag_deduct_go;  // deduction flag.
  wire flag_reset;      // reset flag.

  assign flag_deduct_go = ~KEY[1];
  assign flag_reset = SW[17];

  assign new_ascii = is_valid_ascii ? ASCII_value : NULL_CHAR;
	bombe bom(
		.bombe_out(bombe_result),
		.char_in(ASCII_value),
		.go(flag_deduct_go),
    .key_press(load_char_transfer),
		.clk(CLOCK_50),
		.reset(flag_reset)
	);

  assign LEDR[7:0] = bombe_result;
  */

// END OF BOMBE SPACE - comment out when done.

// DEBUG SPACE

	hex_display ascii_low(
	       .IN(ASCII_value[3:0]),
	       .OUT(HEX4)
	);

	hex_display ascii_high(
	       .IN(ASCII_value[7:4]),
	       .OUT(HEX5)
	);


	hex_display new_ascii_low(
	       .IN(new_ascii[3:0]),
	       .OUT(HEX6)
	);


	hex_display new_ascii_high(
	       .IN(new_ascii[7:4]),
	       .OUT(HEX7)
	);
// END OF DEBUG SPACE

// END OF PROJECT_ENIGMA SPACE



   // Instantiate datapath
    datapath d0
        (
            .x_out(x),
            .y_out(y),
            .colour_out(colour),
            .pixel_counter(pixel_counter_transfer),
				.load_char(load_char_transfer),
            .x_pos_counter(x_pos_counter_transfer),
            .y_pos_counter(y_pos_counter_transfer),
            .line_pos_counter(line_pos_counter_transfer),
            .clk(CLOCK_50),
            .reset_n(~resetn),
            .colour_in(3'b010),
            .plot_cursor(plot_cursor_transfer),
            .inc_pixel_counter(inc_pixel_counter_transfer),
            .reset_pixel_counter(reset_pixel_counter_transfer),
            .cursor_pixel_counter(cursor_pixel_counter_transfer),
            .inc_x_pos_counter(inc_x_pos_counter_transfer),
            .dec_x_pos_counter(dec_x_pos_counter_transfer),
            .x_load(x_load),
            .x_parallel(x_parallel),
            .reset_x_pos_counter(reset_x_pos_counter_transfer),
            .inc_y_pos_counter(inc_y_pos_counter_transfer),
            .dec_y_pos_counter(dec_y_pos_counter_transfer),
            .y_load(y_load),
            .y_parallel(y_parallel),
            .reset_y_pos_counter(reset_y_pos_counter_transfer),
            .inc_line_pos_counter(inc_line_pos_counter_transfer),
            .dec_line_pos_counter(dec_line_pos_counter_transfer),
            .line_load(line_load),
            .line_parallel(line_parallel),
            .reset_line_pos_counter(reset_line_pos_counter_transfer),
            .letter_in(new_ascii),
            .shift_for_cursor(shift_for_cursor_transfer)
        );

    // Instantiate FSM control
    control_FSM c0
        (
            .plot(writeEn),
            .inc_pixel_counter(inc_pixel_counter_transfer),
            .reset_pixel_counter(reset_pixel_counter_transfer),
				.load_char(load_char_transfer),
            .inc_line_pos_counter(inc_line_pos_counter_transfer),
            .dec_line_pos_counter(dec_line_pos_counter_transfer),
            .line_load(line_load),
            .line_parallel(line_parallel),
            .reset_line_pos_counter(reset_line_pos_counter_transfer),
            .inc_x_pos_counter(inc_x_pos_counter_transfer),
            .dec_x_pos_counter(dec_x_pos_counter_transfer),
            .x_load(x_load),
            .x_parallel(x_parallel),
            .reset_x_pos_counter(reset_x_pos_counter_transfer),
            .inc_y_pos_counter(inc_y_pos_counter_transfer),
            .dec_y_pos_counter(dec_y_pos_counter_transfer),
            .y_load(y_load),
            .y_parallel(y_parallel),
            .reset_y_pos_counter(reset_y_pos_counter_transfer),
            .shift_for_cursor(shift_for_cursor_transfer),
            .cursor_colour(plot_cursor_transfer),
            .cursor_pixel_counter(cursor_pixel_counter_transfer),
            .clk(CLOCK_50),
            .reset_n(~resetn),
            .char_available(kb_sc_ready),
            .pixel_counter_in(pixel_counter_transfer),
            .x_pos_counter_in(x_pos_counter_transfer),
            .y_pos_counter_in(y_pos_counter_transfer),
            .line_pos_counter_in(line_pos_counter_transfer),
            .ascii_code(new_ascii)
        );
endmodule

module datapath
    (
        output reg [8:0] x_out,
        output reg [7:0] y_out,
        output reg [2:0] colour_out,
        output [7:0] pixel_counter,
        output [5:0] line_pos_counter,
        output [5:0] x_pos_counter,
        output [3:0] y_pos_counter,
        input clk,
		  input load_char,
        input reset_n,
        input [2:0] colour_in,
        input inc_pixel_counter,
        input reset_pixel_counter,
        input plot_cursor,
        input [3:0] cursor_pixel_counter,
        input inc_x_pos_counter,
        input dec_x_pos_counter,
        input [5:0] x_load,
        input x_parallel,
        input reset_x_pos_counter,
        input inc_y_pos_counter,
        input dec_y_pos_counter,
        input [3:0] y_load,
        input y_parallel,
        input reset_y_pos_counter,
        input inc_line_pos_counter,
        input dec_line_pos_counter,
        input [5:0] line_load,
        input line_parallel,
        input reset_line_pos_counter,
        input [6:0] letter_in,
        input shift_for_cursor
    );
    wire top_shifter_bit;
    wire [127:0] letter_out;

    // Instantiate line-position counter
    counter_6bit lineposc0
        (
            .Q_OUT(line_pos_counter),
            .load(line_load),
            .parallel(line_parallel),
            .increase(inc_line_pos_counter),
            .decrease(dec_line_pos_counter),
            .CLK(clk),
            .CLR(reset_line_pos_counter)
        );

    // Instantiate relative pixel position pixel_counter
    counter_8bit pxcnt0
        (
            .Q_OUT(pixel_counter),
            .EN(inc_pixel_counter),
            .CLK(clk),
            .CLR(reset_pixel_counter)
        );

    // Instantiate x-position counter
    counter_6bit xposc0
        (
            .Q_OUT(x_pos_counter),
            .load(x_load),
            .parallel(x_parallel),
            .increase(inc_x_pos_counter),
            .decrease(dec_x_pos_counter),
            .CLK(clk),
            .CLR(reset_x_pos_counter)
        );

    // Instantiate y-position counter
    counter_4bit yposc0
        (
            .Q_OUT(y_pos_counter),
            .load(y_load),
            .parallel(y_parallel),
            .increase(inc_y_pos_counter),
            .decrease(dec_y_pos_counter),
            .CLK(clk),
            .CLR(reset_y_pos_counter)
        );

    // Instantiate character decoder (forms bitmaps from ascii values)
    char_decoder decoder0
        (
            .OUT(letter_out),
            .IN(letter_in)
        );


   // Instantiate shifting register to store character bitmap
   shifter_128bit s0
        (
            .result(top_shifter_bit),
            .load_val(letter_out),
            .load_n(load_char),
            .shift(inc_pixel_counter),
            .reset(reset_pixel_counter),
            .clock(clk)
        );

    always @(negedge clk)
    begin: colour_activator
        if (letter_in > 7'h1F && letter_in < 7'h7F && (top_shifter_bit || plot_cursor))
            colour_out = colour_in;
        else
            colour_out = 3'b000;
    end // colour_activator

    always @(posedge clk)
    begin: coordinate_shifter
        if (shift_for_cursor)
          begin
            y_out = (y_pos_counter << 4) + 4'd13;
            x_out = (x_pos_counter << 3) + cursor_pixel_counter;
          end
        if (~inc_pixel_counter)
        begin
            x_out = (x_pos_counter << 3) + pixel_counter[2:0];
            y_out = (y_pos_counter << 4) + pixel_counter[6:3];
        end
    end // coordinate_shifter
endmodule

module control_FSM(
        output reg plot,
        output reg load_char,
        output reg inc_pixel_counter,
        output reg reset_pixel_counter,
        output reg inc_line_pos_counter,
        output reg dec_line_pos_counter,
        output reg [5:0] line_load,
        output reg line_parallel,
        output reg reset_line_pos_counter,
        output reg inc_x_pos_counter,
        output reg dec_x_pos_counter,
        output reg [5:0] x_load,
        output reg x_parallel,
        output reg reset_x_pos_counter,
        output reg inc_y_pos_counter,
        output reg dec_y_pos_counter,
        output reg [3:0] y_load,
        output reg y_parallel,
        output reg reset_y_pos_counter,
        output reg shift_for_cursor,
        output reg cursor_colour,
        output [3:0] cursor_pixel_counter,
        input clk,
        input reset_n,
        input char_available,
        input [7:0] pixel_counter_in,
        input [5:0] line_pos_counter_in,
        input [5:0] x_pos_counter_in,
        input [3:0] y_pos_counter_in,
        input [6:0] ascii_code
    );

    reg char_ready, backspace, delete;

    // Instantiate Rate Divider
    rate_divider RD
        (
        .OUT(half_hz_clock),
        .IN(clk)
        );

    // Insantiate Cursor pixel counter
    counter_4bit cpc
        (
            .Q_OUT(cursor_pixel_counter),
            .increase(inc_cursor_pixel_counter),
            .CLK(clk),
            .CLR(reset_cursor_pixel_counter)
        );

    reg [5:0] current_state, next_state;
    reg control_char;
    reg inc_cursor_pixel_counter, reset_cursor_pixel_counter;
    wire half_hz_clock;

    localparam  CHAR_SIZE             = 8'd127,
                MAX_X_POS             = 6'd39,
                MAX_Y_POS             = 4'd14,
                MAX_CURSOR_W          = 4'd7;

    localparam  S_PLOT_CURSOR           = 6'd0,
                S_PLOT_CURSOR_WAIT      = 6'd1,
                S_CURSOR_INC            = 6'd2,
                S_CURSOR_INC_WAIT       = 6'd3,
                S_FLIP_CURSOR_COLOUR    = 6'd4,
                S_CURSOR_WAIT           = 6'd5,
                S_CHECK_CHAR            = 6'd6,
                S_SAVE_CHAR             = 6'd7,
                S_SAVE_CHAR_WAIT        = 6'd8,
                S_PLOT_PIXEL            = 6'd9,
                S_PLOT_WAIT             = 6'd10,
                S_INC_PIXEL             = 6'd11,
                S_INC_PIXEL_WAIT        = 6'd12,
                S_INC_X_POS             = 6'd13,
                S_INC_X_POS_WAIT        = 6'd14,
                S_INC_Y_POS             = 6'd15,
                S_INC_Y_POS_WAIT        = 6'd16,
                S_START_NEXT_LINE       = 6'd17,
                S_START_LINE            = 6'd18,
                S_END_LINE              = 6'd19,
                S_START_NEXT_PAGE       = 6'd20,
                S_DEC_X_POS             = 6'd21,
                S_DEC_Y_POS             = 6'd22,
                S_SCROLL_UP             = 6'd23,
                S_SCROLL_DOWN           = 6'd24,
                S_END_PREV_LINE         = 6'd25,
                S_PLOT_CURSOR2          = 6'd26,
                S_DEC_X_POS_PRE         = 6'd27,
                S_DEC_Y_POS_PRE         = 6'd28,
                S_END_PREV_PAGE         = 6'd29,
                S_INC_X_POS_PRE         = 6'd30,
                S_INC_Y_POS_PRE         = 6'd31,
                S_DEC_X_POS_WAIT        = 6'd32,
                S_DEC_Y_POS_WAIT        = 6'd33,
                S_BACKSPACE             = 6'd34,
                S_DELETE                = 6'd35,
					 S_INC_PIXEL_POST			 = 6'd36;

    localparam  NULL        = 7'h00, // NULL
                PGUP        = 7'h02, // STX
                PGDWN       = 7'h03, // ETX
                BACKSPACE   = 7'h08, // BS
                HOME        = 7'h0D, // CR
                UP          = 7'h11, // DC1
                LEFT        = 7'h12, // DC2
                DOWN        = 7'h13, // DC3
                RIGHT       = 7'h14, // DC3
                END         = 7'h17, // ETB
                ENTER       = 7'h0A, // LF
                DELETE      = 7'h7F; // DEL

    always @(posedge clk)
    begin: state_table
        case (current_state)
            S_PLOT_CURSOR:          next_state = char_ready ? S_CHECK_CHAR : S_PLOT_CURSOR2;
            S_PLOT_CURSOR2:         next_state = char_ready ? S_CHECK_CHAR : S_PLOT_CURSOR_WAIT;
            S_PLOT_CURSOR_WAIT:     next_state = char_ready ? S_CHECK_CHAR : S_CURSOR_INC;

            S_CURSOR_INC:           next_state = char_ready ? S_CHECK_CHAR : S_CURSOR_INC_WAIT;
            S_CURSOR_INC_WAIT:      next_state = char_ready ? S_CHECK_CHAR :
                ( (cursor_pixel_counter <= MAX_CURSOR_W) ? S_PLOT_CURSOR : S_FLIP_CURSOR_COLOUR );

            S_FLIP_CURSOR_COLOUR:   next_state = char_ready ? S_CHECK_CHAR : S_CURSOR_WAIT;
            S_CURSOR_WAIT:          next_state = (char_ready || control_char) ? S_CHECK_CHAR :
                (half_hz_clock ? S_PLOT_CURSOR : S_CURSOR_WAIT);

            S_CHECK_CHAR:
                        begin
                            if (ascii_code > 7'h1F && ascii_code < 7'h7F) // if a printing char
                            begin
                                control_char = 1'b0;
                                next_state =  S_SAVE_CHAR;
                            end
                            else if (control_char) // after cursor has been cleared
                            begin
                                control_char = 1'b0;
                                case(ascii_code)
                                    BACKSPACE:  next_state = S_BACKSPACE;
                                    HOME:       next_state = S_START_LINE;
                                    UP:         next_state = S_DEC_Y_POS_PRE;
                                    LEFT:       next_state = S_DEC_X_POS_PRE;
                                    DOWN:       next_state = S_INC_Y_POS_PRE;
                                    RIGHT:      next_state = S_INC_X_POS_PRE;
                                    END:        next_state = S_END_LINE;
                                    ENTER:      next_state = S_START_NEXT_LINE;
                                    DELETE:     next_state = S_DELETE;
                                    default:    next_state = S_PLOT_CURSOR;
                                endcase
                            end
                            else // if control character is pressed, before clearing cursor
                            begin
                                control_char = (ascii_code == NULL ) ? 1'b0 : 1'b1;
                                next_state = S_PLOT_CURSOR;
                            end
                        end
            S_SAVE_CHAR:            next_state = S_SAVE_CHAR_WAIT;
            S_SAVE_CHAR_WAIT:       next_state = S_PLOT_PIXEL;

            S_PLOT_PIXEL:           next_state = S_PLOT_WAIT;
            S_PLOT_WAIT:            next_state = S_INC_PIXEL;
            S_INC_PIXEL:            next_state = S_INC_PIXEL_WAIT;
            S_INC_PIXEL_WAIT:       next_state = (pixel_counter_in <= CHAR_SIZE) ? S_PLOT_PIXEL :
                ( ((backspace == 1'b1) || (delete == 1'b1)) ? S_INC_PIXEL_POST : S_INC_X_POS_PRE );
				S_INC_PIXEL_POST: 		next_state = S_PLOT_CURSOR;

            S_INC_X_POS_PRE:        next_state = (x_pos_counter_in < MAX_X_POS) ? S_INC_X_POS : S_START_NEXT_LINE;
            S_INC_X_POS:            next_state = S_INC_X_POS_WAIT;
            S_INC_X_POS_WAIT:       next_state = S_PLOT_CURSOR;

            S_DEC_X_POS_PRE:        next_state = (x_pos_counter_in > 0) ? S_DEC_X_POS : S_END_PREV_LINE;
            S_DEC_X_POS:            next_state = S_DEC_X_POS_WAIT;
            S_DEC_X_POS_WAIT:       next_state = (backspace == 1'b1) ? S_SAVE_CHAR : S_PLOT_CURSOR;

            S_INC_Y_POS_PRE:        next_state = (y_pos_counter_in < MAX_Y_POS) ? S_INC_Y_POS : S_SCROLL_DOWN;
            S_INC_Y_POS:            next_state = S_INC_Y_POS_WAIT;
            S_INC_Y_POS_WAIT:       next_state = S_PLOT_CURSOR;

            S_DEC_Y_POS_PRE:        next_state = (y_pos_counter_in > 0) ? S_DEC_Y_POS : S_SCROLL_UP;
            S_DEC_Y_POS:            next_state = S_DEC_Y_POS_WAIT;
            S_DEC_Y_POS_WAIT:       next_state = (backspace == 1'b1) ? S_SAVE_CHAR : S_PLOT_CURSOR;

            S_START_LINE:           next_state = S_PLOT_CURSOR;
            S_END_LINE:             next_state = S_PLOT_CURSOR;
            S_START_NEXT_LINE:      next_state = S_INC_Y_POS_PRE;
            S_END_PREV_LINE:        next_state = S_DEC_Y_POS_PRE;

            S_SCROLL_DOWN:          next_state = S_PLOT_CURSOR;
            S_SCROLL_UP:            next_state = S_PLOT_CURSOR;

            S_BACKSPACE:            next_state = S_DEC_X_POS_PRE;
            S_DELETE:               next_state = S_SAVE_CHAR;

            default:                next_state = S_PLOT_CURSOR;
        endcase
    end // state_table

    always @(negedge clk)
    begin: enable_signals
        char_ready = (ascii_code == NULL || control_char) ? 1'b0 : char_available;

        plot                        = 1'b0;
        load_char                   = 1'b0;

        inc_pixel_counter           = 1'b0;
        reset_pixel_counter         = 1'b0;

        line_parallel               = 1'b0;
        inc_line_pos_counter        = 1'b0;
        dec_line_pos_counter        = 1'b0;
        reset_line_pos_counter      = 1'b0;

        inc_cursor_pixel_counter    = 1'b0;
        reset_cursor_pixel_counter  = 1'b0;

        x_parallel                  = 1'b0;
        inc_x_pos_counter           = 1'b0;
        dec_x_pos_counter           = 1'b0;
        reset_x_pos_counter         = 1'b0;

        y_parallel                  = 1'b0;
        inc_y_pos_counter           = 1'b0;
        dec_y_pos_counter           = 1'b0;
        reset_y_pos_counter         = 1'b0;

        case (current_state)
            S_PLOT_CURSOR:              shift_for_cursor            = 1'b1;
            S_PLOT_CURSOR2:             plot                        = 1'b1;
            S_CURSOR_INC:               inc_cursor_pixel_counter    = 1'b1;
            S_FLIP_CURSOR_COLOUR:   begin
                                        cursor_colour               = ~cursor_colour;
                                        reset_cursor_pixel_counter  = 1'b1;
                                    end

            S_CHECK_CHAR:           begin
                                        cursor_colour               = 1'b0;
                                        reset_cursor_pixel_counter  = 1'b1;
                                    end

            S_SAVE_CHAR:
                                    begin
													 reset_pixel_counter  		  = 1'b1;
                                        reset_cursor_pixel_counter  = 1'b1;
                                        shift_for_cursor            = 1'b0;
                                    end
				S_SAVE_CHAR_WAIT:			    load_char	                 = 1'b1;

            S_PLOT_PIXEL:               plot                        = 1'b1;
            S_INC_PIXEL:            	 inc_pixel_counter           = 1'b1;
				S_INC_PIXEL_POST:			begin
													delete							  = 1'b0;
													backspace						  = 1'b0;
												end

            S_SCROLL_DOWN:              inc_line_pos_counter        = 1'b1;
            S_SCROLL_UP:                dec_line_pos_counter        = 1'b1;

            S_START_NEXT_LINE:          reset_x_pos_counter         = 1'b1;
            S_END_PREV_LINE:        begin
                                        x_load                      = MAX_X_POS;
                                        x_parallel                  = 1'b1;
                                    end

            S_INC_X_POS:                inc_x_pos_counter           = 1'b1;
            S_INC_Y_POS:                inc_y_pos_counter           = 1'b1;
            S_DEC_X_POS:                dec_x_pos_counter           = 1'b1;
            S_DEC_Y_POS:                dec_y_pos_counter           = 1'b1;

            S_START_LINE:               reset_x_pos_counter         = 1'b1;
            S_END_LINE:             begin
                                        x_load                      = MAX_X_POS;
                                        x_parallel                  = 1'b1;
                                    end

            S_BACKSPACE:             begin
													backspace                   = 1'b1;
													reset_pixel_counter 			= 1'b1;
												end
            S_DELETE:                begin
	                             			delete                      = 1'b1;
													shift_for_cursor            = 1'b0;
													reset_pixel_counter 			= 1'b1;
												end

        endcase
    end // enable_signals

    always @(posedge clk)
    begin: state_FFs
        current_state = reset_n ? S_PLOT_CURSOR : next_state;
    end // state_FFs

endmodule






module Enigma_test(
		output [7:0] LEDG,
		output [17:0] LEDR,
		output [6:0] HEX0,
		output [6:0] HEX1,
		output [6:0] HEX2,
		output [6:0] HEX3,
		output [6:0] HEX4,
		output [6:0] HEX5,
		output [6:0] HEX6,
		output [6:0] HEX7,
		input [17:0]SW,
		input [0:3] KEY,
		input CLOCK_50
		);

	localparam ONE = 1'b1;
	wire key_pressed = ~KEY[3]; // not(key[2])
	/*
	wire [3:0] state;
	wire [7:0] rotor_out;

	// rotor
	rotor_0_25 rotor(
		.rotor_out(rotor_out),
		.user_increment(KEY[2]),
		.load_init_state(SW[16]),
		.rotor_init_state(SW[4:0])
	);

	//assign LEDG[7] = key_pressed;
	assign LEDG[7:0] = rotor_out;

	// TEMP - seeing state
	hex_display state_display(
		.IN(state),
		.OUT(HEX0)
	);


	// TEMP: seeing rotor value
	hex_display rotor_val_low(
		.IN(rotor_out[3:0]),
		.OUT(HEX2)
	);


	hex_display rotor_val_high(
		.IN({1'b0, rotor_out[7:4]}),
		.OUT(HEX3)
	);

	*/

	/* ENIGMA testing
	wire [7:0] enigma_out;
	wire [7:0] rotor_out;
	wire TEMP_WRAP;

	wire [7:0] NTCS;

	hex_display input_val_low(
		.IN(SW[3:0]),
		.OUT(HEX4)
	);

		hex_display input_val_high(
		.IN(SW[7:4]),
		.OUT(HEX5)
	);


	hex_display output_val_low(
		.IN(NTCS[3:0]),
		.OUT(HEX6)
	);

	hex_display output_val_high(
		.IN(NTCS[7:4]),
		.OUT(HEX7)
	);

	hex_display rotor_out_low(
		.IN(rotor_out[3:0]),
		.OUT(HEX0)
	);

	hex_display rotor_out_high(
		.IN(rotor_out[7:4]),
		.OUT(HEX1)
	);

	enigma eni(
		.letter_out(enigma_out),
		.TEMP_WRAP(TEMP_WRAP),
		.TEMP_NTCS(NTCS),
		.TEMP_ROTOR(rotor_out),
		.encrypt(SW[17]),
		.char_input(SW[7:0]),
		.char_pressed(key_pressed),
		.rotor_init_state(SW[15:11]),
		.load_init_state(SW[10])
	);

	assign LEDG[0] = TEMP_WRAP;
	assign LEDR = NTCS;
	*/


	wire [7:0] bombe_out;
	wire [7:0] char_in = SW[7:0];
	wire key_down = key_pressed;	 // active low
	wire start_deduct = ~KEY[0];
	wire global_clk = CLOCK_50;
	wire reset = SW[17];

	wire [23:0] char_registers;

	bombe bom(
		.bombe_out(bombe_out),
		.char_in(char_in),
		.rotor_clk_out(LEDR[17]),
		.char_reg(char_registers),
		.key_press(key_down),
		.go(start_deduct),
		.clk(CLOCK_50),
		.reset(reset)
	);

	// output
	hex_display bombe_out_low(
		.IN(bombe_out[3:0]),
		.OUT(HEX0)
	);

	hex_display bombe_out_high(
		.IN(bombe_out[7:4]),
		.OUT(HEX1)
	);


	hex_display input_val_low(
		.IN(char_in[3:0]),
		.OUT(HEX4)
	);

		hex_display input_val_high(
		.IN(char_in[7:4]),
		.OUT(HEX5)
	);

	assign LEDR[16:0] = char_registers[22:7];
	assign LEDG = char_registers[6:0];

	/*
	assign LEDR[17] = ~KEY[0];
	assign increment = SW[17];
	assign load = SW[16];
	assign init_state = SW[4:0];

	clocked_rotor_0_25 r(
		.rotor_out(LEDR[7:0]),
		.current_state(LEDG[2:0]),
		.increment(increment),
		.load(load),
		.rotor_init_state(init_state),
		.clk(~KEY[0])
	);
	*/

endmodule
