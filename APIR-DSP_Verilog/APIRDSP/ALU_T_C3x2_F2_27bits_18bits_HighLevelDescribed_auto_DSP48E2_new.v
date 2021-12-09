/*****************************************************************
*	Configuration bits order : Nothing
*****************************************************************/
`timescale 1 ns / 100 ps  
module ALU_T_C3x2_F2_27bits_18bits_HighLevelDescribed_auto_DSP48E2_new(
		input [3:0] ALUMODE,
		input [8:0] OPMODE,

		input [1:0] USE_SIMD,
		
		input [47:0] W,
		input [47:0] Z,
		input [47:0] Y,
		input [47:0] X,

		input CIN,
		
		output [47:0] S,
		
		output COUT,
		
		input [15:0] result_SIMD_carry_in,
		output [15:0] result_SIMD_carry_out
);
//Mode parameters
// functionality modes 
parameter mode_27x18	= 2'b00;
parameter mode_sum_9x9	= 2'b01;
parameter mode_sum_4x4	= 2'b10;
parameter mode_sum_2x2	= 2'b11;
// ALU
parameter op_sum 	= 2'b00;
parameter op_xor 	= 2'b01;
parameter op_and 	= 2'b10;
parameter op_or 	= 2'b11;
//z and s controller can reffer to ug579:70?
reg Z_controller;
always@(*)begin
	case (ALUMODE)
		4'b0011: Z_controller = 0;// according to patent,0011 means add
		default: Z_controller = ALUMODE[0];
	endcase
end

reg S_controller;
always@(*)begin
	case (ALUMODE)
		4'b0011: S_controller = 0;
		default: S_controller = ALUMODE[1];
	endcase
end

wire W_X_Y_controller;
assign W_X_Y_controller = ALUMODE[1] && ALUMODE[0];

reg [1:0] op;

always@(*)begin
	case (ALUMODE[3:2])
		2'b00: op = op_sum;
		2'b01: op = op_xor;
		2'b11: begin 
			if (OPMODE[3])
				op = op_or;
			else 
				op = op_and;
		end
		default: op = 2'bxx;
	endcase
end

reg [1:0] CIN_W_X_Y_CIN [7:0];
reg [7:0] CIN_Z_W_X_Y_CIN;

wire [1:0] COUT_W_X_Y_CIN [7:0];
wire [7:0] COUT_Z_W_X_Y_CIN;

always@(*)begin
	case (USE_SIMD)
		mode_27x18: begin
			CIN_W_X_Y_CIN[0] = {{1'b0}, {CIN}};
			CIN_W_X_Y_CIN[1] = COUT_W_X_Y_CIN[0];
			CIN_W_X_Y_CIN[2] = COUT_W_X_Y_CIN[1];
			CIN_W_X_Y_CIN[3] = COUT_W_X_Y_CIN[2];
			CIN_W_X_Y_CIN[4] = COUT_W_X_Y_CIN[3];
			CIN_W_X_Y_CIN[5] = COUT_W_X_Y_CIN[4];
			CIN_W_X_Y_CIN[6] = COUT_W_X_Y_CIN[5];
			CIN_W_X_Y_CIN[7] = COUT_W_X_Y_CIN[6];

			CIN_Z_W_X_Y_CIN[0] = Z_controller;
			CIN_Z_W_X_Y_CIN[1] = COUT_Z_W_X_Y_CIN[0];
			CIN_Z_W_X_Y_CIN[2] = COUT_Z_W_X_Y_CIN[1];
			CIN_Z_W_X_Y_CIN[3] = COUT_Z_W_X_Y_CIN[2];
			CIN_Z_W_X_Y_CIN[4] = COUT_Z_W_X_Y_CIN[3];
			CIN_Z_W_X_Y_CIN[5] = COUT_Z_W_X_Y_CIN[4];
			CIN_Z_W_X_Y_CIN[6] = COUT_Z_W_X_Y_CIN[5];
			CIN_Z_W_X_Y_CIN[7] = COUT_Z_W_X_Y_CIN[6];
		end
		mode_sum_9x9: begin
			CIN_W_X_Y_CIN[0] = {2'b0};
			CIN_W_X_Y_CIN[1] = COUT_W_X_Y_CIN[0];
			CIN_W_X_Y_CIN[2] = COUT_W_X_Y_CIN[1];
			CIN_W_X_Y_CIN[3] = COUT_W_X_Y_CIN[2];
			CIN_W_X_Y_CIN[4] = {2'b0};
			CIN_W_X_Y_CIN[5] = COUT_W_X_Y_CIN[4];
			CIN_W_X_Y_CIN[6] = COUT_W_X_Y_CIN[5];
			CIN_W_X_Y_CIN[7] = COUT_W_X_Y_CIN[6];

			CIN_Z_W_X_Y_CIN[0] = Z_controller;
			CIN_Z_W_X_Y_CIN[1] = COUT_Z_W_X_Y_CIN[0];
			CIN_Z_W_X_Y_CIN[2] = COUT_Z_W_X_Y_CIN[1];
			CIN_Z_W_X_Y_CIN[3] = COUT_Z_W_X_Y_CIN[2];
			CIN_Z_W_X_Y_CIN[4] = Z_controller;
			CIN_Z_W_X_Y_CIN[5] = COUT_Z_W_X_Y_CIN[4];
			CIN_Z_W_X_Y_CIN[6] = COUT_Z_W_X_Y_CIN[5];
			CIN_Z_W_X_Y_CIN[7] = COUT_Z_W_X_Y_CIN[6];
		end
		mode_sum_4x4: begin
			CIN_W_X_Y_CIN[0] = {2'b0};
			CIN_W_X_Y_CIN[1] = COUT_W_X_Y_CIN[0];
			CIN_W_X_Y_CIN[2] = {2'b0};
			CIN_W_X_Y_CIN[3] = COUT_W_X_Y_CIN[2];
			CIN_W_X_Y_CIN[4] = {2'b0};
			CIN_W_X_Y_CIN[5] = COUT_W_X_Y_CIN[4];
			CIN_W_X_Y_CIN[6] = {2'b0};
			CIN_W_X_Y_CIN[7] = COUT_W_X_Y_CIN[6];

			CIN_Z_W_X_Y_CIN[0] = Z_controller;
			CIN_Z_W_X_Y_CIN[1] = COUT_Z_W_X_Y_CIN[0];
			CIN_Z_W_X_Y_CIN[2] = Z_controller;
			CIN_Z_W_X_Y_CIN[3] = COUT_Z_W_X_Y_CIN[2];
			CIN_Z_W_X_Y_CIN[4] = Z_controller;
			CIN_Z_W_X_Y_CIN[5] = COUT_Z_W_X_Y_CIN[4];
			CIN_Z_W_X_Y_CIN[6] = Z_controller;
			CIN_Z_W_X_Y_CIN[7] = COUT_Z_W_X_Y_CIN[6];
		end
		mode_sum_2x2: begin
			CIN_W_X_Y_CIN[0] = {2'b0};
			CIN_W_X_Y_CIN[1] = {2'b0};
			CIN_W_X_Y_CIN[2] = {2'b0};
			CIN_W_X_Y_CIN[3] = {2'b0};
			CIN_W_X_Y_CIN[4] = {2'b0};
			CIN_W_X_Y_CIN[5] = {2'b0};
			CIN_W_X_Y_CIN[6] = {2'b0};
			CIN_W_X_Y_CIN[7] = {2'b0};

			CIN_Z_W_X_Y_CIN[0] = Z_controller;
			CIN_Z_W_X_Y_CIN[1] = Z_controller;
			CIN_Z_W_X_Y_CIN[2] = Z_controller;
			CIN_Z_W_X_Y_CIN[3] = Z_controller;
			CIN_Z_W_X_Y_CIN[4] = Z_controller;
			CIN_Z_W_X_Y_CIN[5] = Z_controller;
			CIN_Z_W_X_Y_CIN[6] = Z_controller;
			CIN_Z_W_X_Y_CIN[7] = Z_controller;
		end
		
		default: begin
			CIN_W_X_Y_CIN[0] = 2'bx;
			CIN_W_X_Y_CIN[1] = 2'bx;
			CIN_W_X_Y_CIN[2] = 2'bx;
			CIN_W_X_Y_CIN[3] = 2'bx;
			CIN_W_X_Y_CIN[4] = 2'bx;
			CIN_W_X_Y_CIN[5] = 2'bx;
			CIN_W_X_Y_CIN[6] = 2'bx;
			CIN_W_X_Y_CIN[7] = 2'bx;

			CIN_Z_W_X_Y_CIN[0] = 1'bx;
			CIN_Z_W_X_Y_CIN[1] = 1'bx;
			CIN_Z_W_X_Y_CIN[2] = 1'bx;
			CIN_Z_W_X_Y_CIN[3] = 1'bx;
			CIN_Z_W_X_Y_CIN[4] = 1'bx;
			CIN_Z_W_X_Y_CIN[5] = 1'bx;
			CIN_Z_W_X_Y_CIN[6] = 1'bx;
			CIN_Z_W_X_Y_CIN[7] = 1'bx;
		end
		
	endcase
end
defparam ALU_SIMD_Width_parameterized_HighLevelDescribed_auto_inst0.Width = 13;
ALU_SIMD_Width_parameterized_HighLevelDescribed_auto	ALU_SIMD_Width_parameterized_HighLevelDescribed_auto_inst0(
	.W(W[12:0]),
	.Z(Z[12:0]),
	.Y(Y[12:0]),
	.X(X[12:0]),
	
	.op(op),
	.Z_controller(Z_controller),
	.S_controller(S_controller),
	.W_X_Y_controller(W_X_Y_controller),
	.CIN_W_X_Y_CIN(CIN_W_X_Y_CIN[0]),
	.CIN_Z_W_X_Y_CIN(CIN_Z_W_X_Y_CIN[0]),
	
	.S(S[12:0]),
	
	.COUT_W_X_Y_CIN(COUT_W_X_Y_CIN[0]),
	.COUT_Z_W_X_Y_CIN(COUT_Z_W_X_Y_CIN[0]),
	
	.result_SIMD_carry_in(result_SIMD_carry_in[1:0]),
	.result_SIMD_carry_out(result_SIMD_carry_out[1:0])
);

defparam ALU_SIMD_Width_parameterized_HighLevelDescribed_auto_inst1.Width = 4;
ALU_SIMD_Width_parameterized_HighLevelDescribed_auto	ALU_SIMD_Width_parameterized_HighLevelDescribed_auto_inst1(
	.W(W[16:13]),
	.Z(Z[16:13]),
	.Y(Y[16:13]),
	.X(X[16:13]),
	
	.op(op),
	.Z_controller(Z_controller),
	.S_controller(S_controller),
	.W_X_Y_controller(W_X_Y_controller),
	.CIN_W_X_Y_CIN(CIN_W_X_Y_CIN[1]),
	.CIN_Z_W_X_Y_CIN(CIN_Z_W_X_Y_CIN[1]),
	
	.S(S[16:13]),
	
	.COUT_W_X_Y_CIN(COUT_W_X_Y_CIN[1]),
	.COUT_Z_W_X_Y_CIN(COUT_Z_W_X_Y_CIN[1]),
	
	.result_SIMD_carry_in(result_SIMD_carry_in[3:2]),
	.result_SIMD_carry_out(result_SIMD_carry_out[3:2])
);

defparam ALU_SIMD_Width_parameterized_HighLevelDescribed_auto_inst2.Width = 6;
ALU_SIMD_Width_parameterized_HighLevelDescribed_auto	ALU_SIMD_Width_parameterized_HighLevelDescribed_auto_inst2(
	.W(W[22:17]),
	.Z(Z[22:17]),
	.Y(Y[22:17]),
	.X(X[22:17]),
	
	.op(op),
	.Z_controller(Z_controller),
	.S_controller(S_controller),
	.W_X_Y_controller(W_X_Y_controller),
	.CIN_W_X_Y_CIN(CIN_W_X_Y_CIN[2]),
	.CIN_Z_W_X_Y_CIN(CIN_Z_W_X_Y_CIN[2]),
	
	.S(S[22:17]),
	
	.COUT_W_X_Y_CIN(COUT_W_X_Y_CIN[2]),
	.COUT_Z_W_X_Y_CIN(COUT_Z_W_X_Y_CIN[2]),
	
	.result_SIMD_carry_in(result_SIMD_carry_in[5:4]),
	.result_SIMD_carry_out(result_SIMD_carry_out[5:4])
);

defparam ALU_SIMD_Width_parameterized_HighLevelDescribed_auto_inst3.Width = 4;
ALU_SIMD_Width_parameterized_HighLevelDescribed_auto	ALU_SIMD_Width_parameterized_HighLevelDescribed_auto_inst3(
	.W(W[26:23]),
	.Z(Z[26:23]),
	.Y(Y[26:23]),
	.X(X[26:23]),
	
	.op(op),
	.Z_controller(Z_controller),
	.S_controller(S_controller),
	.W_X_Y_controller(W_X_Y_controller),
	.CIN_W_X_Y_CIN(CIN_W_X_Y_CIN[3]),
	.CIN_Z_W_X_Y_CIN(CIN_Z_W_X_Y_CIN[3]),
	
	.S(S[26:23]),
	
	.COUT_W_X_Y_CIN(COUT_W_X_Y_CIN[3]),
	.COUT_Z_W_X_Y_CIN(COUT_Z_W_X_Y_CIN[3]),
	
	.result_SIMD_carry_in(result_SIMD_carry_in[7:6]),
	.result_SIMD_carry_out(result_SIMD_carry_out[7:6])
);

defparam ALU_SIMD_Width_parameterized_HighLevelDescribed_auto_inst4.Width = 4;
ALU_SIMD_Width_parameterized_HighLevelDescribed_auto	ALU_SIMD_Width_parameterized_HighLevelDescribed_auto_inst4(
	.W(W[30:27]),
	.Z(Z[30:27]),
	.Y(Y[30:27]),
	.X(X[30:27]),
	
	.op(op),
	.Z_controller(Z_controller),
	.S_controller(S_controller),
	.W_X_Y_controller(W_X_Y_controller),
	.CIN_W_X_Y_CIN(CIN_W_X_Y_CIN[4]),
	.CIN_Z_W_X_Y_CIN(CIN_Z_W_X_Y_CIN[4]),
	
	.S(S[30:27]),
	
	.COUT_W_X_Y_CIN(COUT_W_X_Y_CIN[4]),
	.COUT_Z_W_X_Y_CIN(COUT_Z_W_X_Y_CIN[4]),
	
	.result_SIMD_carry_in(result_SIMD_carry_in[9:8]),
	.result_SIMD_carry_out(result_SIMD_carry_out[9:8])
);

defparam ALU_SIMD_Width_parameterized_HighLevelDescribed_auto_inst5.Width = 4;
ALU_SIMD_Width_parameterized_HighLevelDescribed_auto	ALU_SIMD_Width_parameterized_HighLevelDescribed_auto_inst5(
	.W(W[34:31]),
	.Z(Z[34:31]),
	.Y(Y[34:31]),
	.X(X[34:31]),
	
	.op(op),
	.Z_controller(Z_controller),
	.S_controller(S_controller),
	.W_X_Y_controller(W_X_Y_controller),
	.CIN_W_X_Y_CIN(CIN_W_X_Y_CIN[5]),
	.CIN_Z_W_X_Y_CIN(CIN_Z_W_X_Y_CIN[5]),
	
	.S(S[34:31]),
	
	.COUT_W_X_Y_CIN(COUT_W_X_Y_CIN[5]),
	.COUT_Z_W_X_Y_CIN(COUT_Z_W_X_Y_CIN[5]),
	
	.result_SIMD_carry_in(result_SIMD_carry_in[11:10]),
	.result_SIMD_carry_out(result_SIMD_carry_out[11:10])
);

defparam ALU_SIMD_Width_parameterized_HighLevelDescribed_auto_inst6.Width = 6;
ALU_SIMD_Width_parameterized_HighLevelDescribed_auto	ALU_SIMD_Width_parameterized_HighLevelDescribed_auto_inst6(
	.W(W[40:35]),
	.Z(Z[40:35]),
	.Y(Y[40:35]),
	.X(X[40:35]),
	
	.op(op),
	.Z_controller(Z_controller),
	.S_controller(S_controller),
	.W_X_Y_controller(W_X_Y_controller),
	.CIN_W_X_Y_CIN(CIN_W_X_Y_CIN[6]),
	.CIN_Z_W_X_Y_CIN(CIN_Z_W_X_Y_CIN[6]),
	
	.S(S[40:35]),
	
	.COUT_W_X_Y_CIN(COUT_W_X_Y_CIN[6]),
	.COUT_Z_W_X_Y_CIN(COUT_Z_W_X_Y_CIN[6]),
	
	.result_SIMD_carry_in(result_SIMD_carry_in[13:12]),
	.result_SIMD_carry_out(result_SIMD_carry_out[13:12])
);

defparam ALU_SIMD_Width_parameterized_HighLevelDescribed_auto_inst7.Width = 4;
ALU_SIMD_Width_parameterized_HighLevelDescribed_auto	ALU_SIMD_Width_parameterized_HighLevelDescribed_auto_inst7(
	.W(W[44:41]),
	.Z(Z[44:41]),
	.Y(Y[44:41]),
	.X(X[44:41]),
	
	.op(op),
	.Z_controller(Z_controller),
	.S_controller(S_controller),
	.W_X_Y_controller(W_X_Y_controller),
	.CIN_W_X_Y_CIN(CIN_W_X_Y_CIN[7]),
	.CIN_Z_W_X_Y_CIN(CIN_Z_W_X_Y_CIN[7]),
	
	.S(S[44:41]),
	
	.COUT_W_X_Y_CIN(COUT_W_X_Y_CIN[7]),
	.COUT_Z_W_X_Y_CIN(COUT_Z_W_X_Y_CIN[7]),
	
	.result_SIMD_carry_in(result_SIMD_carry_in[15:14]),
	.result_SIMD_carry_out(result_SIMD_carry_out[15:14])
);

wire [1:0] COUT_W_X_Y_CIN_temp;
wire COUT_Z_W_X_Y_CIN_temp;
defparam ALU_SIMD_Width_parameterized_HighLevelDescribed_auto_inst8.Width = 3;
ALU_SIMD_Width_parameterized_HighLevelDescribed_auto	ALU_SIMD_Width_parameterized_HighLevelDescribed_auto_inst8(
	.W(W[47:45]),
	.Z(Z[47:45]),
	.Y(Y[47:45]),
	.X(X[47:45]),
	
	.op(op),
	.Z_controller(Z_controller),
	.S_controller(S_controller),
	.W_X_Y_controller(W_X_Y_controller),
	.CIN_W_X_Y_CIN(COUT_W_X_Y_CIN[7]),
	.CIN_Z_W_X_Y_CIN(COUT_Z_W_X_Y_CIN[7]),
	
	.S(S[47:45]),
		
	.COUT_W_X_Y_CIN(COUT_W_X_Y_CIN_temp),
	.COUT_Z_W_X_Y_CIN(COUT_Z_W_X_Y_CIN_temp),
	
	.result_SIMD_carry_in(2'b0),
	.result_SIMD_carry_out()
);
	assign COUT = COUT_W_X_Y_CIN_temp[0] + COUT_Z_W_X_Y_CIN_temp;
	
endmodule
