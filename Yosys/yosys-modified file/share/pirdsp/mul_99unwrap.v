module $__MULT9X9_wrapper(A, B, Y);
parameter A_SIGNED = 0;
parameter B_SIGNED = 0;
parameter A_WIDTH = 1;
parameter B_WIDTH = 1;
parameter Y_WIDTH = 1;
input [8:0] A;
input [8:0] B;
output [35:0] Y;
wire [A_WIDTH-1:0] AA=A;
wire [B_WIDTH-1:0] BB=B;
wire [Y_WIDTH-1:0] YY;
assign Y=YY;
\$__MULT9X9 #(
   .A_SIGNED(A_SIGNED),
   .B_SIGNED(B_SIGNED),
   .A_WIDTH(A_WIDTH),
   .B_WIDTH(B_WIDTH),
   .Y_WIDTH(Y_WIDTH)

) _TECHMAP_REPLACE_ (
    .A(AA),
    .B(BB),
    .Y(YY)
);
endmodule
module $__add_wrapper (A, B, Y);
parameter A_SIGNED = 0;
parameter B_SIGNED = 0;
parameter A_WIDTH = 1;
parameter B_WIDTH = 1;
parameter Y_WIDTH = 1;
input [35:0] A;
input [35:0] B;
output [35:0] Y;
wire [A_WIDTH-1:0] AA=A;
wire [B_WIDTH-1:0] BB=B;
wire [Y_WIDTH-1:0] YY;
assign Y=YY;

\$add #(
   .A_SIGNED(A_SIGNED),
   .B_SIGNED(B_SIGNED),
   .A_WIDTH(A_WIDTH),
   .B_WIDTH(B_WIDTH),
   .Y_WIDTH(Y_WIDTH)

) _TECHMAP_REPLACE_ (
    .A(AA),
    .B(BB),
    .Y(YY)
);
endmodule
