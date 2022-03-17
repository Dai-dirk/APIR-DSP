(* techmap_celltype = "$mul $__mul $__MULT9X9" *)
module MULT_9x9(
        input [17:0] A,
        input [17:0] B,
        output [35:0] Y
 );
parameter A_w = 0;
parameter B_w = 0;
parameter A_SIGNED = 0;
parameter B_SIGNED = 0;
parameter A_WIDTH = 1;
parameter B_WIDTH = 1;
parameter Y_WIDTH = 1;
wire signed [17:0] C_0;
wire signed [17:0] C_1;

wire signed [8:0] A_0 = A[8:0];
wire signed [8:0] B_0 = B[8:0];
wire signed [8:0] A_1 = A[17:9];
wire signed [8:0] B_1 = B[17:9];

assign C_0 = A_0 * B_0;
assign C_1 = A_1 * B_1;
/*
assign C_0 = A[8:0] * B[8:0];
assign C_1 = A[17:9] * B[17:9];
assign C_2 = A[26:18] * B[26:18];
assign C_3 = A[35:27] * B[35:27];
assign C_4 = A[44:36] * B[44:36];
assign C_5 = A[53:45] * B[53:45];
*/
/* bitwidth:45,$add:3?? error
wire [44:0] C_0_shifted = {{18{1'b0}}, {C_0}, {9{1'b0}}};
wire [44:0] C_1_shifted = {{18{1'b0}}, {C_1}, {9{1'b0}}};
wire [44:0] C_2_shifted = {{18{1'b0}}, {C_2}, {9{1'b0}}};
wire [44:0] C_3_shifted = {{C_3}, {27{1'b0}}};
wire [44:0] C_4_shifted = {{C_4}, {27{1'b0}}};
wire [44:0] C_5_shifted = {{C_5}, {27{1'b0}}};

assign P = C_5_shifted + C_4_shifted + C_3_shifted + C_2_shifted + C_1_shifted + C_0_shifted;
*/
/* no $shl
wire [26:0] C_0_shifted = {{C_0}, {9{1'b0}}};
wire [26:0] C_1_shifted = {{C_1}, {9{1'b0}}};
wire [26:0] C_2_shifted = {{C_2}, {9{1'b0}}};
wire [44:0] C_3_shifted = {{C_3}, {27{1'b0}}};
wire [44:0] C_4_shifted = {{C_4}, {27{1'b0}}};
wire [44:0] C_5_shifted = {{C_5}, {27{1'b0}}};

assign P = {{(C_5_shifted + C_4_shifted + C_3_shifted)},{(C_2_shifted + C_1_shifted + C_0_shifted)}};
*/
/*
wire [26:0] C_0_shifted =  C_0 << 9;
wire [26:0] C_1_shifted =  C_1 << 9;
wire [26:0] C_2_shifted =  C_2 << 9;
wire [44:0] C_3_shifted =  C_3 << 27;
wire [44:0] C_4_shifted =  C_4 << 27;
wire [44:0] C_5_shifted =  C_5 << 27;

assign P = {{(C_5_shifted + C_4_shifted + C_3_shifted)},{(C_2_shifted + C_1_shifted + C_0_shifted)}};*/

//assign Y = {(C_5 + C_4 + C_3),(C_2 + C_1 + C_0)};

//assign Y[44:24] = 0;
assign Y = C_1 + C_0;

// assign  Y = {(C_5 + C_4 + C_3),{6{0}},(C_2 + C_1 + C_0)};

endmodule

