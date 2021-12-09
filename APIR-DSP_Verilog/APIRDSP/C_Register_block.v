/*****************************************************************
*	Configuration bits order :
*
*			IS_RSTC_INVERTED <= configuration_input;
*			CREG <= IS_RSTC_INVERTED;
*			configuration_output = CREG;
*****************************************************************/
`timescale 1 ns / 100 ps   
module C_Register_block(
		input clk,
		
		input [47:0] C,

		input RSTC,
		input CEC,

		output [47:0] C_MUX,

		input configuration_input,
		input configuration_enable,
		output configuration_output
	);
	
	parameter input_freezed = 1'b0;
	
	// configuring bits
	reg IS_RSTC_INVERTED;
	reg CREG;
	
	always@(posedge clk)begin
		if (configuration_enable)begin
			IS_RSTC_INVERTED <= configuration_input;
			CREG <= IS_RSTC_INVERTED;
		end
	end
	assign configuration_output = CREG;

	// C
	wire RSTC_xored;
	assign RSTC_xored = IS_RSTC_INVERTED ^ RSTC;
	
	reg	[47:0] C_reg;
	always@(posedge clk) begin
		if (RSTC_xored) 
			C_reg <= 48'b0;
		else if (CEC) 
			C_reg <= C;
	end

	assign C_MUX = (input_freezed | CREG) ? C_reg: C;

endmodule
