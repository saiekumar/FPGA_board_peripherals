`timescale 1ns / 10ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:18:47 08/01/2014 
// Design Name: 
// Module Name:    sample 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module seven_segment_display(
	CLK,
	RST,
	INP_MODE,
	OUT_SEG_DISP
);

parameter 	IDLE		=	3'b000;
parameter	ADD_DELAY	=	3'b111;
parameter	FIRST_SEG	=	3'b001;
parameter	SCND_SEG	=	3'b010;
parameter	THRD_SEG	=	3'b011;
parameter	FRTH_SEG	=	3'b100;

input	CLK;
input	RST;
input	[01:0]	INP_MODE;
output	[11:0]	OUT_SEG_DISP;


wire 	CLK;
wire	RST;
wire	[01:0]	INP_MODE;
reg	[11:0]	OUT_SEG_DISP;

reg	[5:0]	ip_freq_counter;
reg	[9:0]	micro_sec_counter;
reg	[9:0]	milli_sec_counter;
reg	[9:0]	sec_counter;

wire	[15:0]	hex_counter;
reg	[15:0]	hex_counter_temp;
reg	[19:0]	four_ms_counter;

reg	[2:0]	seg_state;
reg	[2:0]	prev_state;

reg		sec_ctr_valid;


always @(posedge CLK or posedge RST)
begin
	if(RST)
	begin
		ip_freq_counter		<=	6'h0;
		micro_sec_counter	<=	10'h0;
		milli_sec_counter	<=	10'h0;
		sec_counter		<=	10'h0;
		sec_ctr_valid		<=	1'b0;
	end
	else
	begin
		sec_ctr_valid		<=	1'b0;
		ip_freq_counter		<=	ip_freq_counter		+	6'h1;
		if(ip_freq_counter 	==	6'd50)
		begin
			ip_freq_counter		<=	6'h0;
			micro_sec_counter	<=	micro_sec_counter	+	10'h1;
			if(micro_sec_counter	==	10'd1000)
			begin
				micro_sec_counter	<=	10'h0;
				milli_sec_counter	<=	milli_sec_counter	+	10'h1;
				if(milli_sec_counter	==	10'd1000)
				begin
					milli_sec_counter	<=	10'h0;	
					sec_counter		<=	sec_counter	+	10'h1;
					sec_ctr_valid		<=	1'b1;
					
				end
			end

		end
	end
end

//assign	hex_counter	=	{6'h0,sec_counter};

hex_to_decimal		dec_conv(
				.CLK(CLK),
				.RST(RST),
				.INP_VALID(sec_ctr_valid),
				.INP_HEX_DATA(sec_counter),
				.OUT_DEC_DATA(hex_counter)
				);

always @(posedge CLK or posedge RST)
begin
	if(RST)
	begin
		OUT_SEG_DISP	=	12'h000;
		seg_state	=	IDLE;
		prev_state	=	IDLE;
		hex_counter_temp=	16'hFFFF;
		four_ms_counter	=	20'h0;
	end
	else
	begin
		case(seg_state)
			IDLE:
			begin
				if(hex_counter_temp	!=	hex_counter)
				begin
					seg_state		=	FIRST_SEG;
					hex_counter_temp	=	hex_counter;
				end
				else
					seg_state		=	FIRST_SEG;
			end
			ADD_DELAY:
			begin
				if(four_ms_counter	==	20'd200000)
				begin
					four_ms_counter	=	20'h0;
					if(prev_state	==	FIRST_SEG)
						seg_state	=	SCND_SEG;
					else if(prev_state	==	SCND_SEG)
						seg_state	=	THRD_SEG;
					else if(prev_state	==	THRD_SEG)
						seg_state	=	FRTH_SEG;
					else if(prev_state	==	FRTH_SEG)
						seg_state	=	IDLE;
					else
						seg_state	=	IDLE;
				end
				else
				begin
					four_ms_counter	=	four_ms_counter	+ 20'h1;
				end
			end
			FIRST_SEG:
			begin
				OUT_SEG_DISP	=	{segment_value(hex_counter[03:00]),4'hE};	
				prev_state	=	FIRST_SEG;
				seg_state	=	ADD_DELAY;
			end
			SCND_SEG:
			begin
				OUT_SEG_DISP	=	{segment_value(hex_counter[07:04]),4'hD};	
				prev_state	=	SCND_SEG;
				seg_state	=	ADD_DELAY;
			end
			THRD_SEG:
			begin
				OUT_SEG_DISP	=	{segment_value(hex_counter[11:08]),4'hB};	
				prev_state	=	THRD_SEG;
				seg_state	=	ADD_DELAY;
			end
			FRTH_SEG:
			begin
				OUT_SEG_DISP	=	{segment_value(hex_counter[15:12]),4'h7};	
				prev_state	=	FRTH_SEG;
				seg_state	=	ADD_DELAY;
			end
		endcase

	end
end


function [7:0] segment_value(input [3:0] hex_input);
	case(hex_input)
	4'h0: 	segment_value	=	8'hC0;
	4'h1:	segment_value	=	8'hF9;
	4'h2:	segment_value	=	8'hA4;
	4'h3:	segment_value	=	8'hB0;
	4'h4:	segment_value	=	8'h99;
	4'h5:	segment_value	=	8'h92;
	4'h6:	segment_value	=	8'h82;
	4'h7:	segment_value	=	8'hF8;
	4'h8:	segment_value	=	8'h80;
	4'h9:	segment_value	=	8'h90;
	4'hA:	segment_value	=	8'h08;
	4'hB:	segment_value	=	8'h00;
	4'hC:	segment_value	=	8'h46;
	4'hD:	segment_value	=	8'h40;
	4'hE:	segment_value	=	8'h06;
	4'hF:	segment_value	=	8'h0E;
	endcase
endfunction
	
endmodule
