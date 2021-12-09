/*****************************************************************
*	Configuration bits order :
*			PATTERN <= {{PATTERN[46:0]},{configuration_input}};
*			SEL_PATTERN <= PATTERN[47];
*			SEL_MASK <= {{SEL_MASK[0]},{SEL_PATTERN}};
*			PREG <= SEL_MASK[1];
*			MASK <= {{MASK[46:0]},{PREG}};
*			configuration_output = MASK[47];
*****************************************************************/
`timescale 1 ns / 100 ps  
module pattern_detection(
		input clk,
		
		input [47:0] C_reg,
		input [47:0] inter_P,
		
		input RSTP,
		input CEP,
	
		output reg PREG,
		output reg PATTERNDETECT,
		output reg PATTERNBDETECT,
		output reg PATTERNDETECTPAST,
		output reg PATTERNBDETECTPAST,
		output Overflow,
		output Underflow,

		input configuration_input,
		input configuration_enable,
		output configuration_output
	);
	
	// configuring bits
	reg [47:0] PATTERN;
	reg SEL_PATTERN;
	reg [1:0] SEL_MASK;
	reg [47:0] MASK;
		
	always@(posedge clk)begin
		if (configuration_enable)begin
			PATTERN <= {{PATTERN[46:0]},{configuration_input}};
			SEL_PATTERN <= PATTERN[47];
			SEL_MASK <= {{SEL_MASK[0]},{SEL_PATTERN}};
			PREG <= SEL_MASK[1];
			MASK <= {{MASK[46:0]},{PREG}};
		end
	end
	assign configuration_output = MASK[47];
	
	
	// pattern_detection
	wire [47:0] Selected_pattern;
	assign Selected_pattern = (SEL_PATTERN) ? C_reg : PATTERN;
	
	wire [47:0] C_reg_not;
	assign C_reg_not = ~C_reg;
	
	reg [47:0] Selected_mask;
	always@(*)begin
		case (SEL_MASK)
			2'b00: Selected_mask = MASK;
			2'b01: Selected_mask = C_reg;
			2'b10: Selected_mask = {{C_reg_not[46:0]},{1'b0}};
			2'b11: Selected_mask = {{C_reg_not[45:0]},{2'b00}};
		endcase
	end	
	
	assign inter_PATTERNBDETECT = (&((inter_P ^ Selected_pattern) | Selected_mask));
	assign inter_PATTERNDETECT = (&((~(inter_P ^ Selected_pattern)) | Selected_mask));

	reg PATTERNDETECT_reg;
	reg PATTERNBDETECT_reg;
	always@ (posedge clk) begin
		if (RSTP) begin
			PATTERNDETECT_reg <= 1'b0;
			PATTERNBDETECT_reg <= 1'b0;
		end	
		else if (CEP) begin
			PATTERNDETECT_reg <= inter_PATTERNDETECT;
			PATTERNBDETECT_reg <= inter_PATTERNBDETECT;
		end	
	end
	

	always@(*)begin
		if (PREG) begin
			PATTERNDETECT = PATTERNDETECT_reg;
			PATTERNBDETECT = PATTERNBDETECT_reg;
		end
		else begin
			PATTERNDETECT = inter_PATTERNDETECT;
			PATTERNBDETECT = inter_PATTERNBDETECT;
		end
	end

	always@ (posedge clk) begin
		PATTERNDETECTPAST <= PATTERNDETECT;
		PATTERNBDETECTPAST <= PATTERNBDETECT;
	end
	

	assign Overflow = PATTERNDETECTPAST & (~PATTERNDETECT) & (~PATTERNBDETECT);
	assign Underflow = PATTERNBDETECTPAST & (~PATTERNDETECT) & (~PATTERNBDETECT);
	
endmodule
