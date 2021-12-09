(* techmap_celltype = "$mul $__mul $__MULT9X9" *)
module MULT54X54(
        input signed [53:0] A,
        input signed [53:0] B,
//      output signed [107:0] Y
        output signed [17:0] C_0,
        output signed [17:0] C_1,
        output signed [17:0] C_2,
        output signed [17:0] C_3,
        output signed [17:0] C_4,
        output signed [17:0] C_5
 );

wire signed [17:0] C_0;
wire signed [17:0] C_1;
wire signed [17:0] C_2;
wire signed [17:0] C_3;
wire signed [17:0] C_4;
wire signed [17:0] C_5;

/*wire signed [8:0] A_0 = A[8:0];
wire signed [8:0] B_0 = B[8:0];
wire signed [8:0] A_1 = A[17:9];
wire signed [8:0] B_1 = B[17:9];
wire signed [8:0] A_2 = A[26:18];
wire signed [8:0] B_2 = B[26:18];
wire signed [8:0] A_3 = A[35:27];
wire signed [8:0] B_3 = B[35:27];
wire signed [8:0] A_4 = A[44:36];
wire signed [8:0] B_4 = B[44:36];
wire signed [8:0] A_5 = A[53:45];
wire signed [8:0] B_5 = B[53:45];

assign C_0 = A_0 * B_0;
assign C_1 = A_1 * B_1;
assign C_2 = A_2 * B_2;
assign C_3 = A_3 * B_3;
assign C_4 = A_4 * B_4;
assign C_5 = A_5 * B_5;*/

assign C_0 = A[8:0] * B[8:0];
assign C_1 = A[17:9] * B[17:9];
assign C_2 = A[26:18] * B[26:18];
assign C_3 = A[35:27] * B[35:27];
assign C_4 = A[44:36] * B[44:36];
assign C_5 = A[53:45] * B[53:45];

//assign Y = {C_5, C_4, C_3, C_2, C_1, C_0};


endmodule
