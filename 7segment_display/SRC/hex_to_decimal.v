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

module hex_to_decimal(
	CLK,
	RST,
	INP_VALID,
	INP_HEX_DATA,
	OUT_DEC_DATA
);

parameter	IDLE		=	3'b000;
parameter	FIRST_SHIFT	=	3'b001;
parameter	SHIFTING	=	3'b010;
parameter	DONE		=	3'b011;

input	CLK;
input	RST;
input	INP_VALID;
input	[15:0]	INP_HEX_DATA;
output	[15:0]	OUT_DEC_DATA;


wire 	CLK;
wire	RST;
wire	INP_VALID;
wire	[15:0]	INP_HEX_DATA;
reg	[15:0]	OUT_DEC_DATA;


reg	[3:0]	carry;
reg	[15:0]	local_dec_data;

reg	[15:0]	inp_data_reg;
reg	[15:0]	inp_conv_data;

reg	[2:0]	state;
reg	[3:0]	count;


always @(*)
begin
	if(inp_conv_data[3:0] > 4'h9)
	begin
		local_dec_data[3:0]	=	inp_conv_data[3:0]	+ 4'h6;
		carry[0]		=	1'b1;
	end
	else
	begin
		local_dec_data[3:0]	=	inp_conv_data[3:0];
		carry[0]		=	1'b0;
	end
	if(inp_conv_data[7:4] > 4'h9)
	begin
		local_dec_data[7:4]	=	inp_conv_data[7:4]	+ 4'h6 + {3'h0, carry[0]};
		carry[1]		=	1'b1;
	end
	else
	begin
		local_dec_data[7:4]	=	inp_conv_data[7:4]	+ {3'h0, carry[0]};
		carry[1]		=	1'b0;
	end
	if(inp_conv_data[11:8] > 4'h9)
	begin
		local_dec_data[11:8]	=	inp_conv_data[11:8]	+ 4'h6 + {3'h0, carry[1]};
		carry[2]		=	1'b1;
	end
	else
	begin
		local_dec_data[11:8]	=	inp_conv_data[11:8]	+ {3'h0, carry[1]};
		carry[2]		=	1'b0;
	end
	if(inp_conv_data[15:12] > 4'h9)
	begin
		local_dec_data[15:12]	=	inp_conv_data[15:12]	+ 4'h6 + {3'h0, carry[2]};
		carry[3]		=	1'b1;
	end
	else
	begin
		local_dec_data[15:12]	=	inp_conv_data[15:12]	+ {3'h0, carry[2]};
		carry[3]		=	1'b0;
	end
end





always @(posedge CLK or posedge RST)
begin
	if(RST)
	begin
		OUT_DEC_DATA	<=	16'h0000;
		inp_conv_data	<=	16'h0000;
		state		<=	3'b000;
		count		<=	4'h0;
	end
	else
	begin
		case(state)
			IDLE:
			begin
				if(INP_VALID)
					state		<=	FIRST_SHIFT;
				else
					state		<=	IDLE;
				count			<=	4'hF;
			end
			FIRST_SHIFT:
			begin
				if(INP_VALID)
					state		<=	FIRST_SHIFT;
				else
				begin
					inp_conv_data	<=	{13'h0, inp_data_reg[15:13]};		
					count		<=	4'hC;
					state		<=	SHIFTING;
				end
			end
			SHIFTING:
			begin
				if(INP_VALID)
					state		<=	FIRST_SHIFT;
				else
				begin
					inp_conv_data	<=	{local_dec_data[14:0], inp_data_reg[count]};		
					count		<=	count - 4'h1;
					if(count	==	0)
						state	<=	DONE;
					else
						state	<=	SHIFTING;
				end
			end
			DONE:
			begin
				OUT_DEC_DATA		<=	local_dec_data;
				if(INP_VALID)
					state		<=	FIRST_SHIFT;
				else
					state		<=	IDLE;
			end
			default:	state		<=	IDLE;
		endcase
	end
end





always @(posedge CLK or posedge RST)
begin
	if(RST)
	begin
		inp_data_reg	<=	16'h0000;
	end
	else
	begin
		if(INP_VALID)
			inp_data_reg	<=	INP_HEX_DATA;
		else
			inp_data_reg	<=	inp_data_reg;
	end
end

endmodule
