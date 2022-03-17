(* techmap_celltype = "MULT_9x9" *)
module MULT_9x9_map(
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
MULT54X54 #(.A_w(18),.B_w(18))inst(
    .A(A),
    .B(B),
    .Y(Y)
);

endmodule

