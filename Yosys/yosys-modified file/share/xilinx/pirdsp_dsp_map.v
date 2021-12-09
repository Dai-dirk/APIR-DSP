module MULT54X54 (input [53:0] A, input [53:0] B, output [44:0] Y);
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
		.MULTMODEREG(1),
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



