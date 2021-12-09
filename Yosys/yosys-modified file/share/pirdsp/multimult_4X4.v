(* techmap_celltype = "$mul $__mul $__MULT9X9" *)
module MULT54X54(
        input [53:0] A,
        input [53:0] B,
        output [44:0] Y
 );

wire signed [7:0] C_0;
wire signed [7:0] C_1;
wire signed [7:0] C_2;
wire signed [7:0] C_3;
wire signed [7:0] C_4;
wire signed [7:0] C_5;
wire signed [7:0] C_6;
wire signed [7:0] C_7;
wire signed [7:0] C_8;
wire signed [7:0] C_9;
wire signed [7:0] C_10;
wire signed [7:0] C_11;


wire signed [4:0] A_0 = A[4:0];
wire signed [4:0] B_0 = B[4:0];
wire signed [3:0] A_1 = A[8:5];
wire signed [3:0] B_1 = B[8:5];
wire signed [4:0] A_2 = A[13:9];
wire signed [4:0] B_2 = B[13:9];
wire signed [3:0] A_3 = A[17:14];
wire signed [3:0] B_3 = B[17:14];

wire signed [4:0] A_4 = A[22:18];
wire signed [4:0] B_4 = B[22:18];
wire signed [3:0] A_5 = A[26:23];
wire signed [3:0] B_5 = B[26:23];
wire signed [4:0] A_6 = A[31:27];
wire signed [4:0] B_6 = B[31:27];
wire signed [3:0] A_7 = A[35:32];
wire signed [3:0] B_7 = B[35:32];

wire signed [4:0] A_8 = A[40:36];
wire signed [4:0] B_8 = B[40:36];
wire signed [3:0] A_9 = A[44:41];
wire signed [3:0] B_9 = B[44:41];
wire signed [4:0] A_10 = A[49:45];
wire signed [4:0] B_10 = B[49:45];
wire signed [3:0] A_11 = A[53:50];
wire signed [3:0] B_11 = B[53:50];

assign C_0 = A_0 * B_0;
assign C_1 = A_1 * B_1;
assign C_2 = A_2 * B_2;
assign C_3 = A_3 * B_3;
assign C_4 = A_4 * B_4;
assign C_5 = A_5 * B_5;
assign C_6 = A_6 * B_6;
assign C_7 = A_7 * B_7;
assign C_8 = A_8 * B_8;
assign C_9 = A_9 * B_9;
assign C_10 = A_10 * B_10;
assign C_11 = A_11 * B_11;

assign Y[44:36] = C_11 + C_10 + C_9;
assign Y[35:24] = C_8 + C_7 + C_6;
assign Y[23:12] = C_5 + C_4 + C_3;
assign Y[11:0] = C_2 + C_1 + C_0;

endmodule


