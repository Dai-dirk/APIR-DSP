/*****************************************************************
*	Configuration bits order :
*			CARRYINREG <= configuration_input;
*			MREG <= CARRYINREG;
*			IS_CARRYIN_INVERTED <= MREG;
*			IS_RSTALLCARRYIN_INVERTED <= IS_CARRYIN_INVERTED;
*			configuration_output = IS_RSTALLCARRYIN_INVERTED;	
*****************************************************************/
`timescale 1 ns / 100 ps   
module carry_in_manager(
		input clk,
		
		input RSTALLCARRYIN,//control two register

		input CECARRYIN,
		input CEM,
		
		input CARRYIN,
		input A_mult_msb,
		input B_mult_msb,
		input PCIN_msb,
		input P_msb,
		
		input CARRYCASCIN,
		input CARRYCASCOUT,
		input [2:0] CARRYINSEL,
		
		output reg CIN,
		output reg MREG,

		input configuration_input,
		input configuration_enable,
		output configuration_output
	);
	
	// configuring bits
	reg CARRYINREG;
	reg IS_CARRYIN_INVERTED;
	reg IS_RSTALLCARRYIN_INVERTED;
	
	always@(posedge clk)begin
		if (configuration_enable)begin
			CARRYINREG <= configuration_input;
			MREG <= CARRYINREG;
			IS_CARRYIN_INVERTED <= MREG;
			IS_RSTALLCARRYIN_INVERTED <= IS_CARRYIN_INVERTED;
		end
	end
	assign configuration_output = IS_RSTALLCARRYIN_INVERTED;	
	
	
	// carry_in_manager
	wire RSTALLCARRYIN_xored;
	assign RSTALLCARRYIN_xored = IS_RSTALLCARRYIN_INVERTED ^ RSTALLCARRYIN;
	
	wire CARRYIN_xored;
	assign CARRYIN_xored = CARRYIN ^ IS_CARRYIN_INVERTED;
	
	reg CARRYIN_reg;
	always@(posedge clk)begin
		if (RSTALLCARRYIN_xored)
			CARRYIN_reg <= 1'b0;
		else if (CECARRYIN)
			CARRYIN_reg <= CARRYIN_xored;
	end
	
	wire CARRYIN_CARRYIN_reg__mux2to1; 
	assign CARRYIN_CARRYIN_reg__mux2to1 = (CARRYINREG)? CARRYIN_reg: CARRYIN_xored;
	
	
	
	wire A26_XNOR_B17;
	assign A26_XNOR_B17 = ~(A_mult_msb^ B_mult_msb);//tonghuo
	
	reg A26_XNOR_B17_reg;
	always@(posedge clk)begin
		if (RSTALLCARRYIN_xored)
			A26_XNOR_B17_reg <= 1'b0;
		else if (CEM)
			A26_XNOR_B17_reg <= A26_XNOR_B17;
	end
	
	wire A26_XNOR_B17_A26_XNOR_B17_reg_mux2to1; 
	assign A26_XNOR_B17_A26_XNOR_B17_reg_mux2to1 = (MREG)? A26_XNOR_B17_reg: A26_XNOR_B17;
	
	always@(*)begin
		case (CARRYINSEL)
			3'b000: CIN = CARRYIN_CARRYIN_reg__mux2to1;
			3'b001: CIN = ~PCIN_msb;
			3'b010: CIN = CARRYCASCIN;
			3'b011: CIN = PCIN_msb;
			
			3'b100: CIN = CARRYCASCOUT;
			3'b101: CIN = ~P_msb;
			3'b110: CIN = A26_XNOR_B17_A26_XNOR_B17_reg_mux2to1;
			3'b111: CIN = P_msb;
		endcase
	end

endmodule
