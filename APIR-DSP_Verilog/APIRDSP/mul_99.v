//////////////////////////////////////////////////////////////////////////////////
// Create Date: 2021/07/26 
// Design Name: mul_99
// Module Name: appro_mul
//Developer: Yuan Dai 
//////////////////////////////////////////////////////////////////////////////////
module approximate_mul_99(clk,reset,HALF_0,HALF_1,HALF_2,A,B,signA,signB,result_out);
     input clk,reset,HALF_0,HALF_1,HALF_2;
     input [8:0] A,B;
     input signA,signB;
     output reg[17:0] result_out;
	  reg [17:0] result;
	  reg [8:0] A_tmp,B_tmp;
     wire A_ex,B_ex;
	  wire [5:0] tmp0,tmp1,tmp2,tmp3,tmp4,tmp5,tmp6,tmp7,tmp8;
	  wire [17:0] re0,re1,re2,re3,re4,re5,re6,re7,re8,result_tmp;
	  wire sign;
	  assign A_ex = signA? A[8]:1'b0;
	  assign B_ex = signB? B[8]:1'b0;
     //assign A_tmp = (signA&signB)? {1'b0,A[7:0]}:A;
     //assign B_tmp = (signA&signB)? {1'b0,B[7:0]}:B;
	  assign sign=A_ex^B_ex;
always@(*)begin
   if((signA&A[8])==1'b1)
  A_tmp={1'b0,(~A[7:0])+1'b1};
  else
  A_tmp=A;
  if((signB&B[8])==1'b1)
  B_tmp={1'b0,(~B[7:0])+1'b1};
  else
  B_tmp=B;
end	  
     appro_mul int0(
	  .a(A_tmp[2:0]),
	  .b(B_tmp[2:0]),
	  .result(tmp0)
	  );
	  appro_mul int1(
	  .a(A_tmp[2:0]),
	  .b(B_tmp[5:3]),
	  .result(tmp1)
	  );
     appro_mul int2(
	  .a(A_tmp[2:0]),
	  .b(B_tmp[8:6]),
	  .result(tmp2)
	  );
     appro_mul int3(
	  .a(A_tmp[5:3]),
	  .b(B_tmp[2:0]),
	  .result(tmp3)
	  );
	  appro_mul int4(
	  .a(A_tmp[5:3]),
	  .b(B_tmp[5:3]),
	  .result(tmp4)
	  );
     appro_mul int5(
	  .a(A_tmp[5:3]),
	  .b(B_tmp[8:6]),
	  .result(tmp5)
	  );
     appro_mul int6(
	  .a(A_tmp[8:6]),
	  .b(B_tmp[2:0]),
	  .result(tmp6)
	  );
	  appro_mul int7(
	  .a(A_tmp[8:6]),
	  .b(B_tmp[5:3]),
	  .result(tmp7)
	  );
     appro_mul int8(
	  .a(A_tmp[8:6]),
	  .b(B_tmp[8:6]),
	  .result(tmp8)
	  );
     assign re0={12'b0,tmp0};
	  assign re1={9'b0,tmp1,3'b0};
	  assign re2={6'b0,tmp2,6'b0};
	  assign re3={9'b0,tmp3,3'b0};
	  assign re4={6'b0,tmp4,6'b0};
	  assign re5={3'b0,tmp5,9'b0};
	  assign re6={6'b0,tmp6,6'b0};
	  assign re7={3'b0,tmp7,9'b0};
	  assign re8={tmp8,12'b0};
	  assign result_tmp=re0+re1+re2+re3+re4+re5+re6+re7+re8;
	  //assign result = ((signA&signB)==1)?{sign,1'b0,result_tmp[15:0]}:result_tmp;
     always@(*)begin
  if(signA==1'b1&&signB==1'b1)
   begin
	   if(sign==1'b1)
		result={{1{sign}},(~result_tmp[16:0])+1'b1};
		else
     	result={{1{sign}},result_tmp[16:0]};
   end
  else if(signA==1'b1&&signB==1'b0)
   begin
	   if(sign==1'b1)
      result={{1{sign}},(~result_tmp[16:0])+1'b1};
		else 
		result={{1{sign}},result_tmp[16:0]};
   end 
  else if(signA==1'b0&&signB==1'b1)
   begin
	 if(sign==1'b1)
      result={{1{sign}},(~result_tmp[16:0])+1'b1};
		else 
		result={{1{sign}},result_tmp[16:0]};
	end
  else begin
   result=result_tmp;
  end
end
always@(posedge clk)
   if(reset)
	 result_out<=0;
	else
	 result_out<=result;
endmodule
