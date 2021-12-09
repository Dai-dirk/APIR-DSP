/*****************************************************************
*	B_INPUT & BREG[1:0] & BCASCREG[1:0] hazf shod
*	Configuration bits order :
*			BMULTSEL <= configuration_input;
*			IS_RSTB_INVERTED <= BMULTSEL;
*			configuration_output = IS_RSTB_INVERTED
*****************************************************************/
`timescale 1 ns / 100 ps  
module Dual_B_Register_block_proposed(
		input clk,
		
		input [17:0] B,
		input [26:0] BCIN,
		input B_INPUT,
		input [1:0] BREG,
		input [1:0] BCASCREG,
		
		input [17:0] AD_DATA,
		
		input CEB1,
		input CEB2,
		input RSTB,
		
		input INMODE_4,
		input INMODEB,
		
		input LPS,						// new
		
		output [17:0] B2B1,
		output [17:0] B1B0_stream,
		output reg [26:0] BCOUT,
		
		output [17:0] X_MUX,
		output [53:0] B_MULT,
		
		input configuration_input,
		input configuration_enable,
		output configuration_output
	);

	// configuring bits
	reg BMULTSEL;
	reg IS_RSTB_INVERTED;
		
	always@(posedge clk)begin
		if (configuration_enable)begin
			BMULTSEL <= configuration_input;
			IS_RSTB_INVERTED <= BMULTSEL;
		end
	end
	assign configuration_output = IS_RSTB_INVERTED;
	
	// B
	reg [26:0] B1;
	reg [26:0] B2;
	
	assign B1B0_stream = {{B2[26:18]},{B1[26:18]}};
	

	wire [26:0] b_bcin_mux;
	wire [26:0] b_bcin_mux_reg2;
	assign b_bcin_mux = (B_INPUT) ? BCIN : {{9'b0_0000_0000},{B}};
	assign b_bcin_mux_reg2 = (BREG[1]) ?  B2[26:0]: b_bcin_mux;


	wire RSTB_xored;
	assign RSTB_xored = IS_RSTB_INVERTED ^ RSTB;
/**********B1 OUTPUT***********/	
	always@(posedge clk) begin
		if (RSTB_xored) 
			B1 <= 27'b0;
		else if (CEB1) begin
			case (LPS)
				1'b0: begin 
					B1[17:0] <= b_bcin_mux[17:0];
				end
				1'b1: begin
					B1[26:0] <= {{B1[17:0]},{b_bcin_mux[8:0]}};//BCIN LSB
				end
			endcase 
		end
	end
	
	always @ (posedge clk) begin 
		if (RSTB_xored) 
			B2 <= 27'b0;
		else if (CEB2) 
			case (LPS)
				1'b0: begin 
					B2[17:0] <= B1[17:0];
				end
				1'b1: begin
					B2[26:0] <= {{B2[17:0]},{b_bcin_mux[17:9]}};
				end
			endcase 
	end
	
	
	always @ (*) begin
		case (LPS)
			1'b0: begin 
				case (BCASCREG)
					2'b00: begin
						BCOUT = b_bcin_mux;
					end
					2'b01: begin
						BCOUT = B1[26:0];
					end
					2'b10: begin
						BCOUT = B2[26:0];
					end
					2'b11: begin				// stream & broadcast
						BCOUT = 18'bx;
					end
				endcase 
			end
			1'b1: begin
				BCOUT = {{B2[26:18]},{B1[26:18]}};
			end
		endcase
	end
	
	assign X_MUX = (BREG == 2'b01) ?  (b_bcin_mux_reg2[17:0]) : (B1[17:0]);
	
	wire [17:0] b_mult_temp;
	assign b_mult_temp = (INMODE_4) ? B1[17:0] :  b_bcin_mux_reg2[17:0];
	
	assign B2B1 = (b_mult_temp) & ({18{INMODEB}});
	assign B_MULT[17:0]  = (BMULTSEL) ? (AD_DATA[17:0]) : B2B1;
	assign B_MULT[26:18] = B1[26:18];
	assign B_MULT[53:27] = B2;
	
endmodule
