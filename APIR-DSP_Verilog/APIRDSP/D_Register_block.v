/*****************************************************************
*	Configuration bits order :
*			PREADDINSEL <= configuration_input;
*			ADREG <= PREADDINSEL;
*			DREG <= ADREG;
*			IS_RSTD_INVERTED <= DREG;
*			configuration_output = IS_RSTD_INVERTED;
*****************************************************************/
`timescale 1 ns / 100 ps   
module D_Register_block(
		input clk,
		
		input [26:0] D,
	
		input CED,
		input RSTD,
		input CEAD,

		input [4:0] INMODE,

		input [26:0] A2A1,
		input [17:0] B2B1,
		
		output [26:0] AD_DATA,
		output reg INMODEA,
		output reg INMODEB,
	
		
		input configuration_input,
		input configuration_enable,
		output configuration_output
	);

	parameter input_freezed = 1'b0;
	
	// configuring bits
	reg PREADDINSEL;
	reg ADREG;
	reg DREG;
	reg IS_RSTD_INVERTED;
	
	always@(posedge clk)begin
		if (configuration_enable)begin
			PREADDINSEL <= configuration_input;
			ADREG <= PREADDINSEL;
			DREG <= ADREG;
			IS_RSTD_INVERTED <= DREG;
		end
	end
	assign configuration_output = IS_RSTD_INVERTED;	
	
	
	// D
	wire [26:0] PREADD_AB;
	assign PREADD_AB = (PREADDINSEL) ? ({{9{B2B1[17]}},{B2B1}}): A2A1;
	
	reg [26:0] D_reg;
	
	wire RSTD_xored;
	assign RSTD_xored = IS_RSTD_INVERTED ^ RSTD;
	
	always @(posedge clk) begin
		if (RSTD_xored) 
			D_reg <= 27'b0;
		else if (CED) 
			D_reg <= D;
	end
	
	wire [26:0] d_dreg_mux2to1;
	wire [26:0] d_dreg_mux2to1_and;
	wire [26:0] d_dreg_mux2to1_and_xor;
	wire [26:0] AD;
	
	assign d_dreg_mux2to1 = (input_freezed | DREG) ? D_reg: D;
	assign d_dreg_mux2to1_and = d_dreg_mux2to1 & ( {27{INMODE[2]}});
	assign d_dreg_mux2to1_and_xor = d_dreg_mux2to1_and ^ ( {27{INMODE[3]}});
	assign AD = d_dreg_mux2to1_and_xor + PREADD_AB;
	
	reg [26:0] AD_reg;
	always@(posedge clk)begin
		if (RSTD_xored) 
			AD_reg <= 27'b0;
		else if (CEAD) 
			AD_reg <= AD;
	end

	assign AD_DATA = (ADREG) ? (AD_reg): (AD);


	always @(*) begin
		if (PREADDINSEL == 0 )
			INMODEA = ~(INMODE[1]);
		else 
			INMODEA = 1'b1;
	end	
	
	always @(*) begin
		if (PREADDINSEL == 1'b0 )
			INMODEB = 1'b1;
		else 
			INMODEB = ~(INMODE[1]);
	end	
	
endmodule
