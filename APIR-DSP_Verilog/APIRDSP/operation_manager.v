/*****************************************************************
*	Configuration bits order :
*			OPMODEREG <= configuration_input;
*			ALUMODEREG <= OPMODEREG;
*			CARRYINSELREG <= ALUMODEREG;
*			IS_ALUMODE_INVERTED <= {{IS_ALUMODE_INVERTED[2:0]},{CARRYINSELREG}};
*			IS_OPMODE_INVERTED <= {{IS_OPMODE_INVERTED[7:0]},{IS_ALUMODE_INVERTED[3]}};
*			IS_RSTALUMODE_INVERTED <= IS_OPMODE_INVERTED[8];
*			IS_RSTCTRL_INVERTED <= IS_RSTALUMODE_INVERTED;
*			configuration_output = IS_RSTCTRL_INVERTED;
*****************************************************************/
`timescale 1 ns / 100 ps   
module operation_manager (
		input clk,
		
		input RSTCTRL,
		input RSTALUMODE,
		
		input CECTRL,
		input CEALUMODE,
		
		input [8:0] OPMODE_in,
		input [3:0] ALUMODE_in,
		input [2:0] CARRYINSEL_in,
		
		output [8:0] OPMODE,
		output [3:0] ALUMODE,
		output [2:0] CARRYINSEL,
					
		input configuration_input,
		input configuration_enable,
		output configuration_output
	);	
	
	// configuring bits
	reg OPMODEREG;
	reg ALUMODEREG;
	reg CARRYINSELREG;
	reg [3:0] IS_ALUMODE_INVERTED;
	reg [8:0] IS_OPMODE_INVERTED;
	reg IS_RSTALUMODE_INVERTED;
	reg IS_RSTCTRL_INVERTED;
		
	always@(posedge clk)begin
		if (configuration_enable)begin
			OPMODEREG <= configuration_input;
			ALUMODEREG <= OPMODEREG;
			CARRYINSELREG <= ALUMODEREG;
			IS_ALUMODE_INVERTED <= {{IS_ALUMODE_INVERTED[2:0]},{CARRYINSELREG}};
			IS_OPMODE_INVERTED <= {{IS_OPMODE_INVERTED[7:0]},{IS_ALUMODE_INVERTED[3]}};
			IS_RSTALUMODE_INVERTED <= IS_OPMODE_INVERTED[8];
			IS_RSTCTRL_INVERTED <= IS_RSTALUMODE_INVERTED;
		end
	end
	assign configuration_output = IS_RSTCTRL_INVERTED;
	
	
	// operation_manager
	wire [8:0] OPMODE_in_xored;
	assign OPMODE_in_xored = IS_OPMODE_INVERTED ^ OPMODE_in;
	
	wire RSTCTRL_xored;
	assign RSTCTRL_xored = IS_RSTCTRL_INVERTED ^ RSTCTRL;
	
	reg [8:0] OPMODE_reg;
	always@(posedge clk) begin
		if (RSTCTRL_xored)
			OPMODE_reg <= 9'b0;
		else if (CECTRL)
			OPMODE_reg <= OPMODE_in_xored;
	end
	assign OPMODE  = (OPMODEREG) ? OPMODE_reg: OPMODE_in_xored;

	
	
	wire [3:0] ALUMODE_in_xored;
	assign ALUMODE_in_xored = ALUMODE_in ^ IS_ALUMODE_INVERTED;
	
	wire RSTALUMODE_xored;
	assign RSTALUMODE_xored = IS_RSTALUMODE_INVERTED ^ RSTALUMODE;
	
	reg [3:0] ALUMODE_reg;
	always@(posedge clk) begin
		if (RSTALUMODE_xored)
			ALUMODE_reg <= 4'b0;
		else if (CEALUMODE)
			ALUMODE_reg <= ALUMODE_in_xored;
	end
	assign ALUMODE  = (ALUMODEREG) ? ALUMODE_reg: ALUMODE_in_xored;

		
		
		
	reg [2:0] CARRYINSEL_reg;
	always@(posedge clk) begin
		if (RSTCTRL_xored)
			CARRYINSEL_reg <= 3'b0;
		else if (CECTRL)
			CARRYINSEL_reg <= CARRYINSEL_in;
	end
	assign CARRYINSEL  = (CARRYINSELREG) ? CARRYINSEL_reg: CARRYINSEL_in;
	
	
endmodule
	
	