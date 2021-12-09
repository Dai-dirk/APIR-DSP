/*****************************************************************
*	Configuration bits order :
*			INMODEREG <= configuration_input;
*			IS_INMODE_INVERTED <= {{IS_INMODE_INVERTED[3:0]},{INMODEREG}};
*			IS_RSTINMODE_INVERTED <= IS_INMODE_INVERTED[4];
*			configuration_output = IS_RSTINMODE_INVERTED;
*****************************************************************/
`timescale 1 ns / 100 ps   
module inmode_manager (
		input clk,
		
		input [4:0] INMODE_in,
		input RSTINMODE,
		input CEINMODE,
		
		output [4:0] INMODE,
					
		input configuration_input,
		input configuration_enable,
		output configuration_output
	);
	
	// configuring bits
	reg INMODEREG;
	reg [4:0] IS_INMODE_INVERTED;
	reg IS_RSTINMODE_INVERTED;
		
	always@(posedge clk)begin
		if (configuration_enable)begin
			INMODEREG <= configuration_input;
			IS_INMODE_INVERTED <= {{IS_INMODE_INVERTED[3:0]},{INMODEREG}};
			IS_RSTINMODE_INVERTED <= IS_INMODE_INVERTED[4];
		end
	end
	assign configuration_output = IS_RSTINMODE_INVERTED;
	
	
	// inmode_manager
	wire [4:0] INMODE_in_xored;
	assign INMODE_in_xored = IS_INMODE_INVERTED ^ INMODE_in;
	
	wire RSTINMODE_xored;
	assign RSTINMODE_xored = IS_RSTINMODE_INVERTED ^ RSTINMODE;
	
	reg [4:0] INMODE_in_reg;
	always @(posedge clk) begin
		if (RSTINMODE_xored)
			INMODE_in_reg <= 5'b00000;
		else if (CEINMODE)
			INMODE_in_reg <= INMODE_in_xored;
	end
	
	assign INMODE = (INMODEREG) ? INMODE_in_reg: INMODE_in_xored;
	
endmodule
