`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 2021/01/20 
// Module Name: approximate 3 x 3 multiplier
// Developer: Yao Lu 
//////////////////////////////////////////////////////////////////////////////////
module appro_mul ( a, b, result );
  input [2:0] a;
  input [2:0] b;
  output [5:0] result;
  wire   N13, n17, n18, n19, n20, n21, n22, n23, n24, n25, n26, n27, n28, n29,
         n30, n31, n32, n33, n34, n35, n36, n37, n38, n39, n40, n41, n42, n43,
         n44, n45;
  assign result[5] = N13;

  INVxp33_ASAP7_75t_SRAM U24 ( .A(b[1]), .Y(n25) );
  NOR2x1p5_ASAP7_75t_R U25 ( .A(n18), .B(n26), .Y(n29) );
  CKINVDCx5p33_ASAP7_75t_R U26 ( .A(a[0]), .Y(n30) );
  INVx2_ASAP7_75t_SRAM U27 ( .A(n38), .Y(n39) );
  NAND2x1p5_ASAP7_75t_R U28 ( .A(a[1]), .B(b[1]), .Y(n38) );
  INVx5_ASAP7_75t_SRAM U29 ( .A(a[1]), .Y(n26) );
  INVxp33_ASAP7_75t_R U30 ( .A(n45), .Y(result[0]) );
  INVx6_ASAP7_75t_SRAM U31 ( .A(b[2]), .Y(n21) );
  INVx3_ASAP7_75t_SRAM U32 ( .A(b[0]), .Y(n28) );
  CKINVDCx8_ASAP7_75t_R U33 ( .A(a[2]), .Y(n37) );
  NAND2x2_ASAP7_75t_R U34 ( .A(a[1]), .B(b[1]), .Y(n43) );
  INVx5_ASAP7_75t_SRAM U35 ( .A(b[1]), .Y(n18) );
  NOR2x1p5_ASAP7_75t_R U36 ( .A(n21), .B(n37), .Y(n22) );
  NAND2x1p5_ASAP7_75t_R U37 ( .A(b[2]), .B(a[2]), .Y(n44) );
  NAND4xp75_ASAP7_75t_R U38 ( .A(n42), .B(a[0]), .C(b[2]), .D(n37), .Y(n41) );
  A2O1A1Ixp33_ASAP7_75t_R U39 ( .A1(n37), .A2(n30), .B(n17), .C(n29), .Y(n34)
         );
  XNOR2x1_ASAP7_75t_R U40 ( .A(b[0]), .B(b[2]), .Y(n17) );
  NAND4xp75_ASAP7_75t_R U41 ( .A(n39), .B(a[2]), .C(b[0]), .D(n44), .Y(n40) );
  INVx1_ASAP7_75t_SRAM U42 ( .A(n20), .Y(n24) );
  INVx2_ASAP7_75t_R U43 ( .A(n43), .Y(n42) );
  NAND3xp33_ASAP7_75t_R U44 ( .A(n32), .B(n37), .C(n38), .Y(n33) );
  NAND2x1p5_ASAP7_75t_R U45 ( .A(a[0]), .B(b[1]), .Y(n19) );
  NAND2x1p5_ASAP7_75t_R U46 ( .A(a[1]), .B(b[0]), .Y(n20) );
  XOR2xp5_ASAP7_75t_R U47 ( .A(n19), .B(n20), .Y(result[1]) );
  INVx1_ASAP7_75t_SRAM U48 ( .A(n19), .Y(n27) );
  AOI31xp67_ASAP7_75t_R U49 ( .A1(n29), .A2(n21), .A3(n37), .B(n22), .Y(n23)
         );
  NAND2x1p5_ASAP7_75t_R U50 ( .A(a[0]), .B(b[0]), .Y(n45) );
  OAI332xp33_ASAP7_75t_R U51 ( .A1(n27), .A2(n21), .A3(n26), .B1(n37), .B2(n25), .B3(n24), .C1(n23), .C2(n45), .Y(result[3]) );
  OAI21xp5_ASAP7_75t_R U52 ( .A1(a[0]), .A2(n43), .B(a[2]), .Y(n36) );
  NAND2x1p5_ASAP7_75t_R U53 ( .A(b[2]), .B(a[0]), .Y(n31) );
  XNOR2xp5_ASAP7_75t_R U54 ( .A(n28), .B(n31), .Y(n35) );
  INVxp67_ASAP7_75t_R U55 ( .A(n31), .Y(n32) );
  OAI211xp5_ASAP7_75t_R U56 ( .A1(n36), .A2(n35), .B(n34), .C(n33), .Y(
        result[2]) );
  OAI211xp5_ASAP7_75t_R U57 ( .A1(n42), .A2(n44), .B(n41), .C(n40), .Y(
        result[4]) );
  NOR2xp33_ASAP7_75t_R U58 ( .A(n44), .B(n43), .Y(N13) );
endmodule
