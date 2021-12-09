/*****************************************************************
*	Configuration bits order :
*			RND <= {{RND[46:0]},{configuration_input}};
*			configuration_output = RND[47];
*****************************************************************/
`timescale 1 ns / 100 ps   
module XYZW_manager_proposed (
		clk,
		
		OPMODE,
		P,
		
		C,//C register or combination
		
		M1,//partial product result_0
		M2,
		M_SIMD_carry,//SIMD carry_chain
		
		AB,
		PCIN,//P carry_chain

		W,//output
		Z,
		Y,
		X,
		M_SIMD_carry_Mux,
		
		configuration_input,
		configuration_enable,
		configuration_output
	);	
	
	
	// parameters 
	parameter precision_loss_width = 16;
	
	// input and outputs 
	input clk;
		
	input [8:0] OPMODE;
	input [47:0] P;
	
	input [47:0] C;
	
	input [44:0] M1;
	input [44:0] M2;
	input [precision_loss_width-1:0] M_SIMD_carry;
	
	input [47:0] AB;//A combine with B
	input [47:0] PCIN;

	output reg [47:0] W;
	output reg [47:0] Z;
	output reg [47:0] Y;
	output reg [47:0] X;
	output reg [precision_loss_width-1:0] M_SIMD_carry_Mux;
		
	input configuration_input;
	input configuration_enable;
	output configuration_output;
	
	
	// configuring bits
	reg [47:0] RND;
	
	always@(posedge clk)begin
		if (configuration_enable)begin
			RND <= {{RND[46:0]},{configuration_input}};
		end
	end
	assign configuration_output = RND[47];	
	
	
	// XYZW
	always@(*)begin
		case(OPMODE[8:7])
			2'b00: W = 48'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000;
			2'b01: W = P;
			2'b10: W = RND;
			2'b11: W = C;	
		endcase
	end

	always@(*)begin
		case(OPMODE[1:0])
			2'b00: X = 48'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000;
			2'b01: X = {{3{1'b0}},{M1}};				//3{M1[44]}
			2'b10: X = P;
			2'b11: X = AB;	
		endcase
	end

	always@(*)begin
		case(OPMODE[3:2])
			2'b00: Y = 48'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000;
			2'b01: Y = {{3{1'b0}},{M2}};				//3{M2[44]}
			2'b10: Y = 48'b1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111;
			2'b11: Y = C;	
		endcase
	end
	
	
	always@(*)begin
		case(OPMODE[6:4])
			3'b000: Z = 48'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000;
			3'b001: Z = PCIN;
			3'b010: Z = P;
			3'b011: Z = C;
			
			3'b100: Z = P;
			3'b101: Z = { {17{PCIN[47]}}, {PCIN[47:17]} };
			3'b110: Z = { {17{P[47]}}, {P[47:17]} };
			3'b111: Z = 48'bxxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx;			
		endcase
	end
	
	always@(*)begin
		if (OPMODE[3:0] == 4'b0101)
			M_SIMD_carry_Mux = M_SIMD_carry;
		else 
			M_SIMD_carry_Mux = 0;
	end
	
endmodule 
	