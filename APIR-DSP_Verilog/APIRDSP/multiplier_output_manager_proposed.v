/*****************************************************************
*	Configuration bits order :
*			IS_RSTM_INVERTED <= configuration_input;
*			configuration_output = IS_RSTM_INVERTED;
*****************************************************************/
`timescale 1 ns / 100 ps   
module multiplier_output_manager_proposed (
		 clk,
		
		 M_temp,
		 result_SIMD_carry,
		 RSTM,
		 CEM,
		
		 MREG,
		
		 M,
		 M_SIMD,
		
		 configuration_input,
		 configuration_enable,
		 configuration_output
	);	

	// parameters 
	parameter precision_loss_width = 16;

	// input and outputs 	
	input clk;
		
	input [89:0] M_temp;
	input [precision_loss_width-1:0] result_SIMD_carry;
	input RSTM;
	input CEM;
	
	input MREG;
	
	output [89:0] M;
	output [precision_loss_width-1:0] M_SIMD;
	
	input configuration_input;
	input configuration_enable;
	output configuration_output;
	
	
	// configuring bits
	reg IS_RSTM_INVERTED;
		
	always@(posedge clk)begin
		if (configuration_enable)begin
			IS_RSTM_INVERTED <= configuration_input;
		end
	end
	assign configuration_output = IS_RSTM_INVERTED;
	
	
	// multiplier_output_manager
	reg [89:0] M_temp_reg;
	reg [15:0] result_SIMD_carry_reg;
	
	wire RSTM_xored;
	assign RSTM_xored = IS_RSTM_INVERTED ^ RSTM;
	
	always@ (posedge clk )begin
		if (RSTM_xored) begin
			M_temp_reg <= 90'b0;
			result_SIMD_carry_reg <= 16'b0;
		end
		else if (CEM) begin
			M_temp_reg <= M_temp;
			result_SIMD_carry_reg <= result_SIMD_carry;
		end
	end
	
	assign M = (MREG) ? M_temp_reg: M_temp;
	assign M_SIMD = (MREG) ? result_SIMD_carry_reg: result_SIMD_carry;
	
endmodule 
	
	
