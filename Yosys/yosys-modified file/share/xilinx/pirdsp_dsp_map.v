module MULT54X54 (input [53:0] A, input [53:0] B, output [44:0] Y);
	parameter A_SIGNED = 0;
	parameter B_SIGNED = 0;
	parameter A_WIDTH = 0;
	parameter B_WIDTH = 0;
	parameter Y_WIDTH = 0;
        parameter A_w = 0;
        parameter B_w = 0;
        parameter C_w = 48;
        parameter D_w = 27;
        wire [29:0]A_i;
	wire [47:0] P_48;
        //assign A_i={{3{A[26]}},A[26:0]};
	apirdsp #(
		// Disable all registers
		.ACASCREG(0),
		.ADREG(0),
		.A_INPUT("DIRECT"),
		.ALUMODEREG(0),
		.AREG(0),
		.BCASCREG(0),
		.B_INPUT("DIRECT"),
		.BREG(0),
		.CARRYINREG(0),
		.CARRYINSELREG(0),
		.CREG(0),
		.DREG(0),
		.INMODEREG(0),
		.MREG(0),
		.OPMODEREG(0),
		.PREG(0),
		.USE_MULT("MULTIPLY"),
		.USE_SIMD("9X9"),
		.MULTMODEREG(0),
		.AMULTSEL("A"),
		.BMULTSEL("B"),
                .A_WIDTH(A_w),
                .B_WIDTH(B_w),
                .C_WIDTH(C_w),
                .D_WIDTH(D_w)
	) _TECHMAP_REPLACE_ (
		//Data path
		.A(A[A_w-1:0]),
		.B(B[B_w-1:0]),
		.C((C_w)'b0),
		.D(27'b0),
		.P(P_48),

		.INMODE(5'b00000),
		.ALUMODE(4'b0000),
		.OPMODE(9'b000000101),
		.CARRYINSEL(3'b000),
		.MULTMODE(4'b0111),
		.LPS(0),

		.ACIN(54'b0),
		.BCIN(54'b0),
		.PCIN(48'b0),
		.CARRYIN(1'b0)
	);

	assign Y = P_48;


endmodule
module $__MULT9X9 (input [8:0] A, input [8:0] B, output [44:0] Y);
	parameter A_SIGNED = 0;
	parameter B_SIGNED = 0;
	parameter A_WIDTH = 0;
	parameter B_WIDTH = 0;
	parameter Y_WIDTH = 0;

	wire [44:0] P_48;
	apirdsp #(
		// Disable all registers
		.ACASCREG(0),
		.ADREG(0),
		.A_INPUT("DIRECT"),
		.ALUMODEREG(0),
		.AREG(0),
		.BCASCREG(0),
		.B_INPUT("DIRECT"),
		.BREG(0),
		.CARRYINREG(0),
		.CARRYINSELREG(0),
		.CREG(0),
		.DREG(0),
		.INMODEREG(0),
		.MREG(0),
		.OPMODEREG(0),
		.PREG(0),
		.USE_MULT("MULTIPLY"),
		.USE_SIMD("9X9"),
		.MULTMODEREG(0),
		.AMULTSEL("A"),
		.BMULTSEL("B")
	) _TECHMAP_REPLACE_ (
		//Data path
		.A(A[A_WIDTH-1:0]),
		.B(B[B_WIDTH-1:0]),
		.C(48'b0),
		.D(27'b0),
		.P(P_48),

		.INMODE(5'b00000),
		.ALUMODE(4'b0000),
		.OPMODE(9'b000000101),
		.CARRYINSEL(3'b000),
		.MULTMODE(4'b0111),
		.LPS(0),

		.ACIN(54'b0),
		.BCIN(54'b0),
		.PCIN(48'b0),
		.CARRYIN(1'b0)
	);

	assign Y = P_48;


endmodule

module $__MULT4X4 (input [53:0] A, input [53:0] B, output [44:0] Y);
	parameter A_SIGNED = 0;
	parameter B_SIGNED = 0;
	parameter A_WIDTH = 0;
	parameter B_WIDTH = 0;
	parameter Y_WIDTH = 0;

	wire [47:0] P_48;
	pirdsp2 #(
		// Disable all registers
		.ACASCREG(0),
		.ADREG(0),
		.A_INPUT("DIRECT"),
		.ALUMODEREG(0),
		.AREG(0),
		.BCASCREG(0),
		.B_INPUT("DIRECT"),
		.BREG(0),
		.CARRYINREG(0),
		.CARRYINSELREG(0),
		.CREG(0),
		.DREG(0),
		.INMODEREG(0),
		.MREG(0),
		.OPMODEREG(0),
		.PREG(0),
		.USE_MULT("MULTIPLY"),
		.USE_SIMD("9X9"),
		.MULTMODEREG(0),
		.AMULTSEL("A"),
		.BMULTSEL("B")
	) _TECHMAP_REPLACE_ (
		//Data path
		.A(A),
		.B(B),
		.C(48'b0),
		.D(27'b0),
		.P(P_48),

		.INMODE(5'b00000),
		.ALUMODE(4'b0000),
		.OPMODE(9'b000000101),
		.CARRYINSEL(3'b000),
		.MULTMODE(4'b0111),
		.LPS(0),

		.ACIN(54'b0),
		.BCIN(54'b0),
		.PCIN(48'b0),
		.CARRYIN(1'b0)
	);

	assign Y = P_48;


endmodule
