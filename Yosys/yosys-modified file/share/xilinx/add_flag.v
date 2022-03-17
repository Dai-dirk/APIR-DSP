(* techmap_celltype =  "$add"*)
module add_f_map(A, B, Y);
parameter A_SIGNED = 0;
parameter B_SIGNED = 0;
parameter A_WIDTH = 1;
parameter B_WIDTH = 1;
parameter Y_WIDTH = 1;
input [A_WIDTH-1:0] A;
input [B_WIDTH-1:0] B;
output [Y_WIDTH-1:0] Y;
wire    [1023:0]    _TECHMAP_DO_    =    "proc;    clean";
reg    _TECHMAP_FAIL_;
initial    begin
_TECHMAP_FAIL_    <=    0;
end
\$__add_flag #(
   .A_SIGNED(A_SIGNED),
   .B_SIGNED(B_SIGNED),
   .A_WIDTH(A_WIDTH),
   .B_WIDTH(B_WIDTH),
   .Y_WIDTH(Y_WIDTH),
   .PACK(1'b0)

) _TECHMAP_REPLACE_ (
    .A(A),
    .B(B),
    .Y(Y)
);
endmodule
