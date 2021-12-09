/*****************************************************************
* 	this module is defined by us to control Multiplier modes and input signs
* 	interpretation of the MULUMODE signal:
*		MULTMODE[0] --> a_sign
*		MULTMODE[1] --> b_sign
*		MULTMODE[3:2] --> SIMD mode (regarding fracture level)
*		LPS --> Lowprecision streaming
* 		CHAINMODE[1:0] --> ChainMode
* 		MDR --> to control read access to the A flexible FIFO/RF 
******************************************************************
*	Configuration bits order :
*			MULTMODEREG <= configuration_input;
*			IS_MULTMODE_INVERTED <= {{IS_MULTMODE_INVERTED[2:0]},{MULTMODEREG}};
*			IS_RSTMULTMODE_INVERTED <= IS_MULTMODE_INVERTED[3];
*			LPSREG <= IS_RSTMULTMODE_INVERTED;
*			IS_LPS_INVERTED <= LPSREG;
*			IS_RSTLPS_INVERTED <= IS_LPS_INVERTED;
*			CHAINMODEREG <= IS_RSTLPS_INVERTED;
*			IS_CHAINMODE_INVERTED <= {{IS_CHAINMODE_INVERTED[0]},{CHAINMODEREG}};
*			IS_RSTCHAINMODE_INVERTED <= IS_CHAINMODE_INVERTED[1];
*			configuration_output = IS_RSTCHAINMODE_INVERTED;
*****************************************************************/
`timescale 1 ns / 100 ps   
module mult_chain_stream_mode_manager (
		input clk,
		
		input [3:0] MULTMODE_in,		
		input RSTMULTMODE,
		input CEMULTMODE,
		output [3:0] MULTMODE,
		
		input LPS_in,		
		input RSTLPS,
		input CELPS,
		output LPS,
		
		input [1:0] CHAINMODE_in,		
		input RSTCHAINMODE,
		input CECHAINMODE,
		output [1:0] CHAINMODE,
		
		input MDR_in,		
		input RSTMDR,
		input CEMDR,
		output MDR,		
		
		input configuration_input,
		input configuration_enable,
		output configuration_output
	);
	
	// configuring bits
	reg MULTMODEREG;
	reg [3:0] IS_MULTMODE_INVERTED;
	reg IS_RSTMULTMODE_INVERTED;
	
	reg LPSREG;
	reg IS_LPS_INVERTED;
	reg IS_RSTLPS_INVERTED;
	
	reg CHAINMODEREG;
	reg [1:0] IS_CHAINMODE_INVERTED;
	reg IS_RSTCHAINMODE_INVERTED;	
	
	reg MDRREG;
	reg IS_MDR_INVERTED;
	reg IS_RSTMDR_INVERTED;
	
	always@(posedge clk)begin
		if (configuration_enable)begin
			MULTMODEREG <= configuration_input;
			IS_MULTMODE_INVERTED <= {{IS_MULTMODE_INVERTED[2:0]},{MULTMODEREG}};
			IS_RSTMULTMODE_INVERTED <= IS_MULTMODE_INVERTED[3];
			
			LPSREG <= IS_RSTMULTMODE_INVERTED;
			IS_LPS_INVERTED <= LPSREG;
			IS_RSTLPS_INVERTED <= IS_LPS_INVERTED;
			
			CHAINMODEREG <= IS_RSTLPS_INVERTED;
			IS_CHAINMODE_INVERTED <= {{IS_CHAINMODE_INVERTED[0]},{CHAINMODEREG}};
			IS_RSTCHAINMODE_INVERTED <= IS_CHAINMODE_INVERTED[1];
			
			MDRREG <= IS_RSTCHAINMODE_INVERTED;
			IS_MDR_INVERTED <= MDRREG;
			IS_RSTMDR_INVERTED <= IS_MDR_INVERTED;
		end
	end
	assign configuration_output = IS_RSTMDR_INVERTED;
	
	
	// multmode_manager
	wire [3:0] MULTMODE_in_xored;
	assign MULTMODE_in_xored = IS_MULTMODE_INVERTED ^ MULTMODE_in;
	wire LPS_in_xored;
	assign LPS_in_xored = IS_LPS_INVERTED ^ LPS_in;
	wire [1:0] CHAINMODE_in_xored;
	assign CHAINMODE_in_xored = IS_CHAINMODE_INVERTED ^ CHAINMODE_in;
	wire MDR_in_xored;
	assign MDR_in_xored = IS_MDR_INVERTED ^ MDR_in;
	
	wire RSTMULTMODE_xored;
	assign RSTMULTMODE_xored = IS_RSTMULTMODE_INVERTED ^ RSTMULTMODE;
	wire RSTLPS_xored;
	assign RSTLPS_xored = IS_RSTLPS_INVERTED ^ RSTLPS;
	wire RSTCHAINMODE_xored;
	assign RSTCHAINMODE_xored = IS_RSTCHAINMODE_INVERTED ^ RSTCHAINMODE;
	wire RSTMDR_xored;
	assign RSTMDR_xored = IS_RSTMDR_INVERTED ^ RSTMDR;	

	reg [3:0] MULTMODE_in_reg;
	always @(posedge clk) begin
		if (RSTMULTMODE_xored)begin
			MULTMODE_in_reg <= 4'b0000;
			end
		else if (CEMULTMODE)begin
			MULTMODE_in_reg <= MULTMODE_in_xored;
			end
	end
	
	reg LPS_in_reg;
	always @(posedge clk) begin
		if (RSTLPS_xored)begin
			LPS_in_reg <= 1'b0;
			end
		else if (CELPS)begin
			LPS_in_reg <= LPS_in_xored;
			end
	end
	
	reg [1:0] CHAINMODE_in_reg;
	always @(posedge clk) begin
		if (RSTCHAINMODE_xored)begin
			CHAINMODE_in_reg <= 2'b00;
			end
		else if (CECHAINMODE)begin
			CHAINMODE_in_reg <= CHAINMODE_in_xored;
			end
	end

	reg MDR_in_reg;
	always @(posedge clk) begin
		if (RSTMDR_xored)begin
			MDR_in_reg <= 1'b0;
			end
		else if (CEMDR)begin
			MDR_in_reg <= MDR_in_xored;
			end
	end
	
	
	assign MULTMODE = (MULTMODEREG) ? MULTMODE_in_reg: MULTMODE_in_xored;
	assign LPS = (LPSREG) ? LPS_in_reg: LPS_in_xored;
	assign CHAINMODE = (CHAINMODEREG) ? CHAINMODE_in_reg: CHAINMODE_in_xored;
	assign MDR = (MDRREG) ? MDR_in_reg: MDR_in_xored;
endmodule
