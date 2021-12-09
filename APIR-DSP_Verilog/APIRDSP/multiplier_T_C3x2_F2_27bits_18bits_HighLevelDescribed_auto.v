`timescale 1 ns / 100 ps  
module multiplier_T_C3x2_F2_27bits_18bits_HighLevelDescribed_auto(
		input clk,
		input reset,
		
		input [53:0] a,
		input [53:0] b,
		
		input a_sign,
		input b_sign,
		
		input [1:0] mode,
		
		output reg [44:0] result_0,
		output reg [44:0] result_1,
		output reg [15:0] result_SIMD_carry
	);

// functionality modes 
parameter mode_27x18	= 2'b00;
parameter mode_sum_9x9	= 2'b01;
parameter mode_sum_4x4	= 2'b10;
parameter mode_sum_2x2	= 2'b11;
// internal signal for half mode detection
wire HALF_0;
wire HALF_1;
wire HALF_2;

// input of partial multipliers
reg [8:0] A_0;
reg [8:0] A_1;
reg [8:0] A_2;
reg [8:0] A_3;
reg [8:0] A_4;
reg [8:0] A_5;

reg [8:0] B_0;
reg [8:0] B_1;
reg [8:0] B_2;
reg [8:0] B_3;
reg [8:0] B_4;
reg [8:0] B_5;

wire [17:0] C_0;
wire [17:0] C_1;
wire [17:0] C_2;
wire [17:0] C_3;
wire [17:0] C_4;
wire [17:0] C_5;

reg A_sign_0;
reg A_sign_1;
reg A_sign_2;
reg A_sign_3;
reg A_sign_4;
reg A_sign_5;

reg B_sign_0;
reg B_sign_1;
reg B_sign_2;
reg B_sign_3;
reg B_sign_4;
reg B_sign_5;

reg mode_SIMD;

// to assign the input to sub multipliers 
always @(*) begin
	case (mode_SIMD)//27*18
		1'b0: begin
			A_0 = a[8:0];
			A_1 = a[17:9];
			A_4 = a[26:18];
			A_2 = a[8:0];
			A_3 = a[17:9];
			A_5 = a[26:18];

			B_0 = b[8:0];
			B_1 = b[8:0];
			B_4 = b[8:0];
			B_2 = b[17:9];
			B_3 = b[17:9];
			B_5 = b[17:9];
		end
		1'b1: begin//54*54(6x(9*9))
			A_0 = a[8:0];
			A_1 = a[17:9];
			A_4 = a[44:36];
			A_2 = a[26:18];
			A_3 = a[35:27];
			A_5 = a[53:45];

			B_0 = b[8:0];
			B_1 = b[17:9];
			B_4 = b[44:36];
			B_2 = b[26:18];
			B_3 = b[35:27];
			B_5 = b[53:45];
		end
	endcase
end

//sign controller


always @(*) begin
	case (mode)
		mode_27x18: begin//(27*18)
			mode_SIMD = 1'b0;
			A_sign_0 = 1'b0;
			A_sign_1 = 1'b0;
			A_sign_4 = a_sign;
			A_sign_2 = 1'b0;
			A_sign_3 = 1'b0;
			A_sign_5 = a_sign;

			B_sign_0 = 1'b0;
			B_sign_1 = 1'b0;
			B_sign_4 = 1'b0;
			B_sign_2 = b_sign;
			B_sign_3 = b_sign;
			B_sign_5 = b_sign;
		end
		default: begin//(6x(9*9))
			mode_SIMD = 1'b1;
			A_sign_0 = a_sign;
			A_sign_1 = a_sign;
			A_sign_4 = a_sign;
			A_sign_2 = a_sign;
			A_sign_3 = a_sign;
			A_sign_5 = a_sign;

			B_sign_0 = b_sign;
			B_sign_1 = b_sign;
			B_sign_4 = b_sign;
			B_sign_2 = b_sign;
			B_sign_3 = b_sign;
			B_sign_5 = b_sign;
		end
	endcase
end

// Assigning half mode signals
assign FULL = (mode == mode_27x18);
assign HALF_0 = (mode == mode_sum_9x9);
assign HALF_1 = (mode == mode_sum_4x4);
assign HALF_2 = (mode == mode_sum_2x2);

approximate_mul_99		approximate_mul_99_in0(
	.clk(clk),
	.reset(reset),

	.A(A_0),
	.B(B_0),

	.signA(A_sign_0),
	.signB(B_sign_0),

	.HALF_0(HALF_0 | FULL),
	.HALF_1(HALF_1),
	.HALF_2(HALF_2),

	.result_out(C_0)
);

approximate_mul_99		approximate_mul_99_in1(
	.clk(clk),
	.reset(reset),

	.A(A_1),
	.B(B_1),

	.signA(A_sign_1),
	.signB(B_sign_1),

	.HALF_0(HALF_0 | FULL),
	.HALF_1(HALF_1),
	.HALF_2(HALF_2),

	.result_out(C_1)
);
approximate_mul_99		approximate_mul_99_in2(
	.clk(clk),
	.reset(reset),

	.A(A_2),
	.B(B_2),

	.signA(A_sign_2),
	.signB(B_sign_2),

	.HALF_0(HALF_0 | FULL),
	.HALF_1(HALF_1),
	.HALF_2(HALF_2),

	.result_out(C_2)
);
approximate_mul_99		approximate_mul_99_in3(
	.clk(clk),
	.reset(reset),

	.A(A_3),
	.B(B_3),

	.signA(A_sign_3),
	.signB(B_sign_3),

	.HALF_0(HALF_0 | FULL),
	.HALF_1(HALF_1),
	.HALF_2(HALF_2),

	.result_out(C_3)
);
approximate_mul_99		approximate_mul_99_in4(
	.clk(clk),
	.reset(reset),

	.A(A_4),
	.B(B_4),

	.signA(A_sign_4),
	.signB(B_sign_4),

	.HALF_0(HALF_0 | FULL),
	.HALF_1(HALF_1),
	.HALF_2(HALF_2),

	.result_out(C_4)
);
approximate_mul_99		approximate_mul_99_in5(
	.clk(clk),
	.reset(reset),

	.A(A_5),
	.B(B_5),

	.signA(A_sign_5),
	.signB(B_sign_5),

	.HALF_0(HALF_0 | FULL),
	.HALF_1(HALF_1),
	.HALF_2(HALF_2),

	.result_out(C_5)
);



// to implement shifters for SIMD modes
reg [44:0] C_0_shifted;
reg [44:0] C_1_shifted;
reg [44:0] C_2_shifted;
reg [44:0] C_3_shifted;
reg [44:0] C_4_shifted;
reg [44:0] C_5_shifted;
always @ (*) begin
	case (mode_SIMD)
		1'b0: begin
			C_0_shifted = {{27{(C_0[17])&((A_sign_0)|(B_sign_0))}}, {C_0}};
			C_1_shifted = {{18{(C_1[17])&((A_sign_1)|(B_sign_1))}}, {C_1}, {9{1'b0}}};
			C_4_shifted = {{9{(C_4[17])&((A_sign_4)|(B_sign_4))}}, {C_4}, {18{1'b0}}};
			C_2_shifted = {{18{(C_2[17])&((A_sign_2)|(B_sign_2))}}, {C_2}, {9{1'b0}}};
			C_3_shifted = {{9{(C_3[17])&((A_sign_3)|(B_sign_3))}}, {C_3}, {18{1'b0}}};
			C_5_shifted = {{C_5}, {27{1'b0}}};
		end
		1'b1: begin
			C_0_shifted = {{18{1'b0}}, {C_0}, {C_0[8:0]}};
			C_1_shifted = {{18{1'b0}}, {C_1}, {9{1'b0}}};
			C_4_shifted = {{C_4}, {9{1'b0}}, {18{1'b0}}};
			C_2_shifted = {{18{1'b0}}, {C_2}, {9{1'b0}}};
			C_3_shifted = {{C_3}, {9{1'b0}}, {18{1'b0}}};
			C_5_shifted = {{C_5}, {27{1'b0}}};
		end
	endcase
end

// to assign output pairs 
reg [44:0] result_temp_0;
reg [46:0] result_temp_1;
always @ (*) begin
	result_temp_1 [12:0] = 13'b0;
	result_1 [12:0] = result_temp_1 [12:0];
	result_temp_0 [16:0] = {{2{((C_0_shifted[12])&(HALF_2))&((a_sign|b_sign))}},{C_0_shifted [12:0]}} + {{2{((C_1_shifted[12])&(HALF_2))&((a_sign|b_sign))}},{C_1_shifted [12:0]}} + {{2{((C_2_shifted[12])&(HALF_2))&((a_sign|b_sign))}},{C_2_shifted [12:0]}} + {{2{((C_3_shifted[12])&(HALF_2))&((a_sign|b_sign))}},{C_3_shifted [12:0]}} + {{2{((C_4_shifted[12])&(HALF_2))&((a_sign|b_sign))}},{C_4_shifted [12:0]}} + {{2{((C_5_shifted[12])&(HALF_2))&((a_sign|b_sign))}},{C_5_shifted [12:0]}};
	result_0 [16:0] = {{(result_temp_0 [16:13])&(~({4{HALF_2}}))},{result_temp_0 [12:0]}};
	result_SIMD_carry[1:0] = result_temp_0 [14:13];
	result_temp_1 [22:13] = {{2{((C_0_shifted[16])&((HALF_1)|(HALF_2)))&((a_sign|b_sign))}},{C_0_shifted [16:13]}} + {{2{((C_1_shifted[16])&((HALF_1)|(HALF_2)))&((a_sign|b_sign))}},{C_1_shifted [16:13]}} + {{2{((C_2_shifted[16])&((HALF_1)|(HALF_2)))&((a_sign|b_sign))}},{C_2_shifted [16:13]}} + {{2{((C_3_shifted[16])&((HALF_1)|(HALF_2)))&((a_sign|b_sign))}},{C_3_shifted [16:13]}} + {{2{((C_4_shifted[16])&((HALF_1)|(HALF_2)))&((a_sign|b_sign))}},{C_4_shifted [16:13]}} + {{2{((C_5_shifted[16])&((HALF_1)|(HALF_2)))&((a_sign|b_sign))}},{C_5_shifted [16:13]}};
	result_1 [22:13] = {{(result_temp_1 [22:17])&(~({6{(HALF_1)|(HALF_2)}}))},{result_temp_1 [16:13]}};
	result_SIMD_carry[3:2] = result_temp_1 [18:17];
	result_temp_0 [26:17] = {{2{((C_0_shifted[22])&(HALF_2))&((a_sign|b_sign))}},{C_0_shifted [22:17]}} + {{2{((C_1_shifted[22])&(HALF_2))&((a_sign|b_sign))}},{C_1_shifted [22:17]}} + {{2{((C_2_shifted[22])&(HALF_2))&((a_sign|b_sign))}},{C_2_shifted [22:17]}} + {{2{((C_3_shifted[22])&(HALF_2))&((a_sign|b_sign))}},{C_3_shifted [22:17]}} + {{2{((C_4_shifted[22])&(HALF_2))&((a_sign|b_sign))}},{C_4_shifted [22:17]}} + {{2{((C_5_shifted[22])&(HALF_2))&((a_sign|b_sign))}},{C_5_shifted [22:17]}};
	result_0 [26:17] = {{(result_temp_0 [26:23])&(~({4{HALF_2}}))},{result_temp_0 [22:17]}};
	result_SIMD_carry[5:4] = result_temp_0 [24:23];
	result_temp_1 [30:23] = {{2{((C_0_shifted[26])&(((HALF_0)|(HALF_1))|(HALF_2)))&((a_sign|b_sign))}},{C_0_shifted [26:23]}} + {{2{((C_1_shifted[26])&(((HALF_0)|(HALF_1))|(HALF_2)))&((a_sign|b_sign))}},{C_1_shifted [26:23]}} + {{2{((C_2_shifted[26])&(((HALF_0)|(HALF_1))|(HALF_2)))&((a_sign|b_sign))}},{C_2_shifted [26:23]}} + {{2{((C_3_shifted[26])&(((HALF_0)|(HALF_1))|(HALF_2)))&((a_sign|b_sign))}},{C_3_shifted [26:23]}} + {{2{((C_4_shifted[26])&(((HALF_0)|(HALF_1))|(HALF_2)))&((a_sign|b_sign))}},{C_4_shifted [26:23]}} + {{2{((C_5_shifted[26])&(((HALF_0)|(HALF_1))|(HALF_2)))&((a_sign|b_sign))}},{C_5_shifted [26:23]}};
	result_1 [30:23] = {{(result_temp_1 [30:27])&(~({4{((HALF_0)|(HALF_1))|(HALF_2)}}))},{result_temp_1 [26:23]}};
	result_SIMD_carry[7:6] = result_temp_1 [28:27];
	result_temp_0 [34:27] = {{2{((C_0_shifted[30])&(HALF_2))&((a_sign|b_sign))}},{C_0_shifted [30:27]}} + {{2{((C_1_shifted[30])&(HALF_2))&((a_sign|b_sign))}},{C_1_shifted [30:27]}} + {{2{((C_2_shifted[30])&(HALF_2))&((a_sign|b_sign))}},{C_2_shifted [30:27]}} + {{2{((C_3_shifted[30])&(HALF_2))&((a_sign|b_sign))}},{C_3_shifted [30:27]}} + {{2{((C_4_shifted[30])&(HALF_2))&((a_sign|b_sign))}},{C_4_shifted [30:27]}} + {{2{((C_5_shifted[30])&(HALF_2))&((a_sign|b_sign))}},{C_5_shifted [30:27]}};
	result_0 [34:27] = {{(result_temp_0 [34:31])&(~({4{HALF_2}}))},{result_temp_0 [30:27]}};
	result_SIMD_carry[9:8] = result_temp_0 [32:31];
	result_temp_1 [40:31] = {{2{((C_0_shifted[34])&((HALF_1)|(HALF_2)))&((a_sign|b_sign))}},{C_0_shifted [34:31]}} + {{2{((C_1_shifted[34])&((HALF_1)|(HALF_2)))&((a_sign|b_sign))}},{C_1_shifted [34:31]}} + {{2{((C_2_shifted[34])&((HALF_1)|(HALF_2)))&((a_sign|b_sign))}},{C_2_shifted [34:31]}} + {{2{((C_3_shifted[34])&((HALF_1)|(HALF_2)))&((a_sign|b_sign))}},{C_3_shifted [34:31]}} + {{2{((C_4_shifted[34])&((HALF_1)|(HALF_2)))&((a_sign|b_sign))}},{C_4_shifted [34:31]}} + {{2{((C_5_shifted[34])&((HALF_1)|(HALF_2)))&((a_sign|b_sign))}},{C_5_shifted [34:31]}};
	result_1 [40:31] = {{(result_temp_1 [40:35])&(~({6{(HALF_1)|(HALF_2)}}))},{result_temp_1 [34:31]}};
	result_SIMD_carry[11:10] = result_temp_1 [36:35];
	result_temp_0 [44:35] = {{2{((C_0_shifted[40])&(HALF_2))&((a_sign|b_sign))}},{C_0_shifted [40:35]}} + {{2{((C_1_shifted[40])&(HALF_2))&((a_sign|b_sign))}},{C_1_shifted [40:35]}} + {{2{((C_2_shifted[40])&(HALF_2))&((a_sign|b_sign))}},{C_2_shifted [40:35]}} + {{2{((C_3_shifted[40])&(HALF_2))&((a_sign|b_sign))}},{C_3_shifted [40:35]}} + {{2{((C_4_shifted[40])&(HALF_2))&((a_sign|b_sign))}},{C_4_shifted [40:35]}} + {{2{((C_5_shifted[40])&(HALF_2))&((a_sign|b_sign))}},{C_5_shifted [40:35]}};
	result_0 [44:35] = {{(result_temp_0 [44:41])&(~({4{HALF_2}}))},{result_temp_0 [40:35]}};
	result_SIMD_carry[13:12] = result_temp_0 [42:41];
	result_temp_1 [46:41] = {{2{((C_0_shifted[44])&(((HALF_0)|(HALF_1))|(HALF_2)))&((a_sign|b_sign))}},{C_0_shifted [44:41]}} + {{2{((C_1_shifted[44])&(((HALF_0)|(HALF_1))|(HALF_2)))&((a_sign|b_sign))}},{C_1_shifted [44:41]}} + {{2{((C_2_shifted[44])&(((HALF_0)|(HALF_1))|(HALF_2)))&((a_sign|b_sign))}},{C_2_shifted [44:41]}} + {{2{((C_3_shifted[44])&(((HALF_0)|(HALF_1))|(HALF_2)))&((a_sign|b_sign))}},{C_3_shifted [44:41]}} + {{2{((C_4_shifted[44])&(((HALF_0)|(HALF_1))|(HALF_2)))&((a_sign|b_sign))}},{C_4_shifted [44:41]}} + {{2{((C_5_shifted[44])&(((HALF_0)|(HALF_1))|(HALF_2)))&((a_sign|b_sign))}},{C_5_shifted [44:41]}};
	result_1 [44:41] = result_temp_1 [44:41];
	result_SIMD_carry[15:14] = result_temp_1 [46:45];
end


endmodule
