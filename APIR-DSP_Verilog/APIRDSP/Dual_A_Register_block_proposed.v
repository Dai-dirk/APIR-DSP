/*****************************************************************
*	$$ AREG[1:0] & AMULTSEL[1:0] & A_INPUT hazf shod 
*	Configuration bits order :
*			IS_RSTA_INVERTED <= configuration_input;
*			configuration_output = IS_RSTA_INVERTED
*****************************************************************/
`timescale 1 ns / 100 ps  
module Dual_A_Register_block_proposed(
		 clk,
		
		 A,
		 ACIN,
		 A_INPUT,
		
		 AD_DATA,
		 B1B0_stream,
		 B_MUX,
		
		 RF_load,
		 A_addr,
		
		 ACOUT,
		 ACOUT_addr,
		 MDR,
		
		 CEA1,
		 CEA2,
		 RSTA,

		 INMODEA,
		
		 chain_mode,
		
		 X_MUX,
		 A_MULT,
		 A2A1,
				
		 configuration_input,
		 configuration_enable,
		 configuration_output
	);

	// parameters 
	parameter registerfile_size = 8;
	parameter registerfile_size_log = $clog2(registerfile_size);


                input clk;

                input [29:0] A;
                input [29:0] ACIN;
                input A_INPUT;

                input [26:0] AD_DATA;
                input [17:0] B1B0_stream;
                input [17:0] B_MUX;

                input RF_load;
                input [registerfile_size_log-1:0] A_addr;

                output reg [29:0] ACOUT;
                input [registerfile_size_log-1:0] ACOUT_addr;
                input MDR;

                input CEA1;
                input CEA2;
                input RSTA;

                input INMODEA;

                input [1:0] chain_mode;

                output reg [29:0] X_MUX;
                output [53:0] A_MULT;
                output [26:0] A2A1;

                input configuration_input;
                input configuration_enable;
                output configuration_output;


	
	// integers
	integer i;
	
	// configuring bits
	reg AMULTSEL;
	reg IS_RSTA_INVERTED;
	
	always@(posedge clk)begin
		if (configuration_enable)begin
			AMULTSEL <= configuration_input;
			IS_RSTA_INVERTED <= AMULTSEL;
		end
	end
	assign configuration_output = IS_RSTA_INVERTED;
	
	// File Registers, A_RF 
	reg [29:0] A_RF [registerfile_size-1:0];
	
	// input selection
	wire [29:0] a_acin_mux;
	assign a_acin_mux = (A_INPUT) ? ACIN : A;
	
	// reset and reset bar controller 
	wire RSTA_xored;
	assign RSTA_xored = IS_RSTA_INVERTED ^ RSTA;
	
	// RF as a shift register 
	always@(posedge clk) begin
		if (RSTA_xored) begin 
			for (i = 0; i < registerfile_size; i = i + 1) begin 
				A_RF[i] <= 30'b0;
			end
		end 
		else begin 
			if (CEA1 | RF_load) begin 
				A_RF[0] <= a_acin_mux;
			end 
			if (CEA2 | RF_load) begin 
				A_RF[1] <= A_RF[0];
			end 
			if (RF_load) begin 
				for (i = 2; i < registerfile_size; i = i + 1) begin 
					A_RF[i] <= A_RF[i-1];
				end 
			end			
		end
	end

	// ACOUT manager 
	always @ (*) begin
		case (chain_mode)
			2'b00: begin 
				if (ACOUT_addr == 0) begin 
					ACOUT = a_acin_mux;
				end 
				else begin 
					ACOUT = A_RF[ACOUT_addr - 1];
				end 
			end
			2'b01: begin
				ACOUT = {{9'b0_0000_0000},{B1B0_stream}};//B1B0_stream is B1/B2 MSB
			end
			2'b10: begin
				ACOUT = {{9'b0_0000_0000},{B_MUX}};//B_MUX IS X_MUX[17:0]
			end
			2'b11: begin
				ACOUT = 18'bx;
			end 
		endcase 
	end
	
	// 
	reg [26:0] a_mult_temp_0;	
	reg [26:0] a_mult_temp_1;	
	always @ (*) begin
		if (MDR) begin
			a_mult_temp_0 = A_RF[(A_addr < 1)][26:0];
			a_mult_temp_1 = A_RF[(A_addr < 1) + 1][26:0];
			X_MUX = A_RF[(A_addr < 1)];//X_MUX IS FOR AB COMBINATION
		end
		else begin
			if (A_addr == 0) begin 
				a_mult_temp_0 = a_acin_mux[26:0];
				a_mult_temp_1 = 27'bx;
				X_MUX = a_acin_mux;
			end 
			else begin 
				a_mult_temp_0 = A_RF[A_addr][26:0];
				a_mult_temp_1 = 27'bx;
				X_MUX = A_RF[A_addr];
			end 
		end
		
	end 
	
	assign A2A1 = (a_mult_temp_0) & ({27{INMODEA}});
	
	assign A_MULT[26:0] = (AMULTSEL) ? AD_DATA: A2A1;
	assign A_MULT[53:27] = a_mult_temp_1;
endmodule
