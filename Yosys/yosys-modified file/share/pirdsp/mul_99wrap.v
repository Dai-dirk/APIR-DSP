(* techmap_celltype =  "$__MULT9X9"*)
module $__MULT9X9_wrap(A, B, Y);
parameter A_SIGNED = 0;
parameter B_SIGNED = 0;
parameter A_WIDTH = 1;
parameter B_WIDTH = 1;
parameter Y_WIDTH = 1;
input [A_WIDTH-1:0] A;
input [B_WIDTH-1:0] B;
output [Y_WIDTH-1:0] Y;
wire [8:0] AA=A;
wire [8:0] BB=B;
wire [35:0] YY;
assign Y=YY;
wire    [1023:0]    _TECHMAP_DO_    =    "proc;    clean";
reg    _TECHMAP_FAIL_;
initial    begin
_TECHMAP_FAIL_    <=    0;
if (A_WIDTH>9&&B_WIDTH>9)
 _TECHMAP_FAIL_<= 1;
end
\$__MULT9X9_wrapper #(
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
(* techmap_celltype =  "$add"*)
module ADD_WRA(A, B, Y);
parameter A_SIGNED = 0;
parameter B_SIGNED = 0;
parameter A_WIDTH = 1;
parameter B_WIDTH = 1;
parameter Y_WIDTH = 1;
input [A_WIDTH-1:0] A;
input [B_WIDTH-1:0] B;
output [Y_WIDTH-1:0] Y;
wire [35:0] AA=A;
wire [35:0] BB=B;
wire [35:0] YY;
assign Y=YY;
wire    [1023:0]    _TECHMAP_DO_    =    "proc;    clean";
reg    _TECHMAP_FAIL_;
initial    begin
_TECHMAP_FAIL_    <=    0;
if (Y_WIDTH>45)
 _TECHMAP_FAIL_<= 1;
end
\$__add_wrapper #(
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
