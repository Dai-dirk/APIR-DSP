/*****************************************************************
*	Configuration bits order :
*			AUTORESET_PATDET[0] <= configuration_input;
*			AUTORESET_PATDET[1] <= AUTORESET_PATDET[0];
*			AUTORESET_PRIORITY <= AUTORESET_PATDET[1];
*			IS_RSTP_INVERTED <= AUTORESET_PRIORITY;
*			configuration_output = IS_RSTP_INVERTED
*****************************************************************/
`timescale 1 ns / 100 ps  
module output_manager_proposed (
		clk,

		RSTP,
		CEP,
		
		inter_MULTSIGNOUT,
		inter_CARRYCASCOUT,
		inter_XOROUT,
		inter_P,
		inter_result_SIMD_carry_out,
		
		PATTERNDETECT,		
		PATTERNBDETECT,
		
		PREG,

		MULTSIGNOUT,
		CARRYCASCOUT,
		XOROUT,
		P,
		P_SIMD_carry,
		
		configuration_input,
		configuration_enable,
		configuration_output
	);	
	// parameters 
	parameter input_freezed = 1'b0;
	parameter precision_loss_width = 16;
	
	
	// input and outputs 
	input clk;

	input RSTP;
	input CEP;
	
	input inter_MULTSIGNOUT;
	input inter_CARRYCASCOUT;
	input [7:0] inter_XOROUT;
	input [47:0] inter_P;
	input [precision_loss_width-1:0] inter_result_SIMD_carry_out;
	
	input PATTERNDETECT;
	input PATTERNBDETECT;
	
	input PREG;

	output reg MULTSIGNOUT;
	output reg CARRYCASCOUT;
	output reg [7:0] XOROUT;
	output reg [47:0] P;
	output reg [precision_loss_width-1:0] P_SIMD_carry;
	
	input configuration_input;
	input configuration_enable;
	output configuration_output;
		
	
	
	
	
	
	// configuring bits
	reg [1:0] AUTORESET_PATDET;
	reg AUTORESET_PRIORITY;
	reg IS_RSTP_INVERTED;
		
	always@(posedge clk)begin
		if (configuration_enable)begin
			AUTORESET_PATDET[0] <= configuration_input;
			AUTORESET_PATDET[1] <= AUTORESET_PATDET[0];
			AUTORESET_PRIORITY <= AUTORESET_PATDET[1];
			IS_RSTP_INVERTED <= AUTORESET_PRIORITY;
		end
	end
	assign configuration_output = IS_RSTP_INVERTED;
	
	// output_manager	
	reg inter_MULTSIGNOUT_reg;
	reg [47:0] inter_PCOUT_reg;
	reg inter_CARRYCASCOUT_reg;
	reg [7:0] inter_XOROUT_reg;
	reg [47:0] inter_P_reg;
	reg [15:0] inter_result_SIMD_carry_out_reg;
	
	wire RSTP_xored;
	assign RSTP_xored = IS_RSTP_INVERTED ^ RSTP;
	
	always@(posedge clk) begin
		if (RSTP_xored) begin
			inter_P_reg <= 48'b0;
			inter_result_SIMD_carry_out_reg <= 16'b0;
		end
		else begin
			case (AUTORESET_PATDET) 
				2'b00: begin
					if (CEP) begin
						inter_P_reg <= inter_P;
						inter_result_SIMD_carry_out_reg <= inter_result_SIMD_carry_out;
					end	
				end
				2'b01: begin
					if ((AUTORESET_PRIORITY && CEP && PATTERNDETECT) || ((~AUTORESET_PRIORITY)  && PATTERNDETECT))begin
							inter_P_reg <= 48'b0;
							inter_result_SIMD_carry_out_reg <= 16'b0;
					end else if (CEP) begin
						inter_P_reg <= inter_P;
						inter_result_SIMD_carry_out_reg <= inter_result_SIMD_carry_out;
					end	
				end
				2'b10: begin
					if ((AUTORESET_PRIORITY && CEP && PATTERNBDETECT) || ((~AUTORESET_PRIORITY)  && PATTERNBDETECT))begin
							inter_P_reg <= 48'b0;
							inter_result_SIMD_carry_out_reg <= 16'b0;
					end else if (CEP) begin
						inter_P_reg <= inter_P;
						inter_result_SIMD_carry_out_reg <= inter_result_SIMD_carry_out;
					end	
				end
			endcase
		end	
		
	end
	
	always@(posedge clk) begin
		if (RSTP_xored) begin
			inter_MULTSIGNOUT_reg <= 1'b0;
			inter_CARRYCASCOUT_reg <= 1'b0;
			inter_XOROUT_reg <= 8'b0;
		end	
		else if (CEP) begin
			inter_MULTSIGNOUT_reg <= inter_MULTSIGNOUT;
			inter_CARRYCASCOUT_reg <= inter_CARRYCASCOUT;
			inter_XOROUT_reg <= inter_XOROUT;
		end	
	end
	
	always@(*)begin
		if (PREG) begin
			MULTSIGNOUT = inter_MULTSIGNOUT_reg;
			XOROUT = inter_XOROUT_reg;
		end
		else begin
			MULTSIGNOUT = inter_MULTSIGNOUT;
			XOROUT = inter_XOROUT;
		end
	end
	
	always@(*)begin
		if (input_freezed | PREG) begin
			CARRYCASCOUT = inter_CARRYCASCOUT_reg;
			P = inter_P_reg;
			P_SIMD_carry = inter_result_SIMD_carry_out_reg;
		end
		else begin
			CARRYCASCOUT = inter_CARRYCASCOUT;
			P = inter_P;
			P_SIMD_carry = inter_result_SIMD_carry_out;
		end
	end
	
	
endmodule
	
	