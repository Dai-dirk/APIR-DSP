// TODO: DSP48E2 (Ultrascale).

`ifdef YOSYS
(* abc9_box=!(PREG || AREG || ADREG || BREG || CREG || DREG || MREG),
   lib_whitebox=!(PREG || AREG || ADREG || BREG || CREG || DREG || MREG) *)
`endif

module DSP48E2(
    output [29:0] ACOUT,
    output [17:0] BCOUT,
    output reg CARRYCASCOUT,
    output reg [3:0] CARRYOUT,
    output reg MULTSIGNOUT,
    output OVERFLOW,
    output reg signed [47:0] P,
    output reg PATTERNBDETECT,
    output reg PATTERNDETECT,
    output [47:0] PCOUT,
    output UNDERFLOW,
    output [7:0] XOROUT,   //NEW
    
    input signed [29:0] A,
    input [29:0] ACIN,
    input [3:0] ALUMODE,
    input signed [17:0] B,
    input [17:0] BCIN,
    input [47:0] C,
    input CARRYCASCIN,
    input CARRYIN,
    input [2:0] CARRYINSEL,
    input CEA1,
    input CEA2,
    input CEAD,
    input CEALUMODE,
    input CEB1,
    input CEB2,
    input CEC,
    input CECARRYIN,
    input CECTRL,
    input CED,
    input CEINMODE,
    input CEM,
    input CEP,
    (* clkbuf_sink *) input CLK,
  //  input [24:0] D,
    input [26:0] D,
    
    input [4:0] INMODE,
    input MULTSIGNIN,
//    input [6:0] OPMODE,
    input [8:0] OPMODE,
    
    input [47:0] PCIN,
    input RSTA,
    input RSTALLCARRYIN,
    input RSTALUMODE,
    input RSTB,
    input RSTC,
    input RSTCTRL,
    input RSTD,
    input RSTINMODE,
    input RSTM,
    input RSTP
    );
    
    parameter integer ACASCREG = 1;
    parameter integer ADREG = 1;
    parameter integer ALUMODEREG = 1;
    parameter AMULTSEL = "A"; //NEW 
    parameter integer AREG = 1;
    parameter AUTORESET_PATDET = "NO_RESET";
    parameter AUTORESET_PRIORITY = "RESET"; //NEW
    parameter A_INPUT = "DIRECT";
    parameter integer BCASCREG = 1;
    parameter BMULTSEL = "B"; //NEW  
    parameter integer BREG = 1;
    parameter B_INPUT = "DIRECT";
    parameter integer CARRYINREG = 1;
    parameter integer CARRYINSELREG = 1;
    parameter integer CREG = 1;
    parameter integer DREG = 1;
    parameter integer INMODEREG = 1; 
    parameter [3:0] IS_ALUMODE_INVERTED = 4'b0;
    parameter [0:0] IS_CARRYIN_INVERTED = 1'b0;
    parameter [0:0] IS_CLK_INVERTED = 1'b0;
    parameter [4:0] IS_INMODE_INVERTED = 5'b0;
    parameter [8:0] IS_OPMODE_INVERTED = 9'b0; 
    //NEW 
    parameter [0:0] IS_RSTALLCARRYIN_INVERTED = 1'b0;
    parameter [0:0] IS_RSTALUMODE_INVERTED = 1'b0;
    parameter [0:0] IS_RSTA_INVERTED = 1'b0;
    parameter [0:0] IS_RSTB_INVERTED = 1'b0;
    parameter [0:0] IS_RSTCTRL_INVERTED = 1'b0;
    parameter [0:0] IS_RSTC_INVERTED = 1'b0;
    parameter [0:0] IS_RSTD_INVERTED = 1'b0;
    parameter [0:0] IS_RSTINMODE_INVERTED = 1'b0;
    parameter [0:0] IS_RSTM_INVERTED = 1'b0;
    parameter [0:0] IS_RSTP_INVERTED = 1'b0;     
  //NEW
  
    parameter [47:0] MASK = 48'h3FFFFFFFFFFF;
    parameter integer MREG = 1;
    parameter integer OPMODEREG = 1;
    parameter [47:0] PATTERN = 48'h000000000000;
    parameter PREADDINSEL = "A"; //NEW
    parameter integer PREG = 1;
    parameter [47:0] RND = 48'h000000000000; //NEW
    parameter SEL_MASK = "MASK";
    parameter SEL_PATTERN = "PATTERN";
//      parameter USE_DPORT = "FALSE";  //NONE 
    parameter USE_MULT = "MULTIPLY";
    parameter USE_PATTERN_DETECT = "NO_PATDET";
    parameter USE_SIMD = "ONE48";
    parameter USE_WIDEXOR = "FALSE"; //NEW
    parameter XORSIMD = "XOR24_48_96";  //NEW 
   
   
    initial begin
`ifndef YOSYS
        if (AUTORESET_PATDET != "NO_RESET") $fatal(1, "Unsupported AUTORESET_PATDET value");
        if (SEL_MASK != "MASK")     $fatal(1, "Unsupported SEL_MASK value");
        if (SEL_PATTERN != "PATTERN") $fatal(1, "Unsupported SEL_PATTERN value");
        if (USE_SIMD != "ONE48" && USE_SIMD != "TWO24" && USE_SIMD != "FOUR12")    $fatal(1, "Unsupported USE_SIMD value");
        if (IS_ALUMODE_INVERTED != 4'b0) $fatal(1, "Unsupported IS_ALUMODE_INVERTED value");
        if (IS_CARRYIN_INVERTED != 1'b0) $fatal(1, "Unsupported IS_CARRYIN_INVERTED value");
        if (IS_CLK_INVERTED != 1'b0) $fatal(1, "Unsupported IS_CLK_INVERTED value");
        if (IS_INMODE_INVERTED != 5'b0) $fatal(1, "Unsupported IS_INMODE_INVERTED value");
        if (IS_OPMODE_INVERTED != 9'b0) $fatal(1, "Unsupported IS_OPMODE_INVERTED value");
`endif
    end

    wire signed [29:0] A_muxed;
    wire signed [17:0] B_muxed;

    generate
        if (A_INPUT == "CASCADE") assign A_muxed = ACIN;
        else assign A_muxed = A;

        if (B_INPUT == "CASCADE") assign B_muxed = BCIN;
        else assign B_muxed = B;
    endgenerate

    reg signed [29:0] Ar1, Ar2;
    reg signed [26:0] Dr;
    reg signed [17:0] Br1, Br2;
    reg signed [47:0] Cr;
    reg        [4:0]  INMODEr;
    reg        [8:0]  OPMODEr;
    reg        [3:0]  ALUMODEr;
    reg        [2:0]  CARRYINSELr;

    generate
        // Configurable A register
        if (AREG == 2) begin
            initial Ar1 = 30'b0;
            initial Ar2 = 30'b0;
            always @(posedge CLK)
                if (RSTA) begin
                    Ar1 <= 30'b0;
                    Ar2 <= 30'b0;
                end else begin
                    if (CEA1) Ar1 <= A_muxed;
                    if (CEA2) Ar2 <= Ar1;
                end
        end else if (AREG == 1) begin
            //initial Ar1 = 30'b0;
            initial Ar2 = 30'b0;
            always @(posedge CLK)
                if (RSTA) begin
                    Ar1 <= 30'b0;
                    Ar2 <= 30'b0;
                end else begin
                    if (CEA1) Ar1 <= A_muxed;
                    if (CEA2) Ar2 <= A_muxed;
                end
        end else begin
            always @* Ar1 <= A_muxed;
            always @* Ar2 <= A_muxed;
        end

        // Configurable B register
        if (BREG == 2) begin
            initial Br1 = 18'b0;
            initial Br2 = 18'b0;
            always @(posedge CLK)
                if (RSTB) begin
                    Br1 <= 18'b0;
                    Br2 <= 18'b0;
                end else begin
                    if (CEB1) Br1 <= B_muxed;
                    if (CEB2) Br2 <= Br1;
                end
        end else if (BREG == 1) begin
            //initial Br1 = 18'b0;
            initial Br2 = 18'b0;
            always @(posedge CLK)
                if (RSTB) begin
                    Br1 <= 18'b0;
                    Br2 <= 18'b0;
                end else begin
                    if (CEB1) Br1 <= B_muxed;
                    if (CEB2) Br2 <= B_muxed;
                end
        end else begin
            always @* Br1 <= B_muxed;
            always @* Br2 <= B_muxed;
        end

        // C and D registers
        if (CREG == 1) initial Cr = 48'b0;
        if (CREG == 1) begin always @(posedge CLK) if (RSTC) Cr <= 48'b0; else if (CEC) Cr <= C; end
        else           always @* Cr <= C;

        if (DREG == 1) initial Dr = 27'b0;
        if (DREG == 1) begin always @(posedge CLK) if (RSTD) Dr <= 27'b0; else if (CED) Dr <= D; end
        else           always @* Dr <= D;

        // Control registers
        if (INMODEREG == 1) initial INMODEr = 5'b0;
        if (INMODEREG == 1) begin always @(posedge CLK) if (RSTINMODE) INMODEr <= 5'b0; else if (CEINMODE) INMODEr <= INMODE; end
        else           always @* INMODEr <= INMODE;
        if (OPMODEREG == 1) initial OPMODEr = 9'b0;
        if (OPMODEREG == 1) begin always @(posedge CLK) if (RSTCTRL) OPMODEr <= 9'b0; else if (CECTRL) OPMODEr <= OPMODE; end
        else           always @* OPMODEr <= OPMODE;
        if (ALUMODEREG == 1) initial ALUMODEr = 4'b0;
        if (ALUMODEREG == 1) begin always @(posedge CLK) if (RSTALUMODE) ALUMODEr <= 4'b0; else if (CEALUMODE) ALUMODEr <= ALUMODE; end
        else           always @* ALUMODEr <= ALUMODE;
        if (CARRYINSELREG == 1) initial CARRYINSELr = 3'b0;
        if (CARRYINSELREG == 1) begin always @(posedge CLK) if (RSTCTRL) CARRYINSELr <= 3'b0; else if (CECTRL) CARRYINSELr <= CARRYINSEL; end
        else           always @* CARRYINSELr <= CARRYINSEL;
    endgenerate

    // A and B cascade
    generate
        if (ACASCREG == 1 && AREG == 2) assign ACOUT = Ar1;
        else assign ACOUT = Ar2;
        if (BCASCREG == 1 && BREG == 2) assign BCOUT = Br1;
        else assign BCOUT = Br2;
    endgenerate

    // A/D input selection and pre-adder
    wire signed [26:0] Ar12_muxed = INMODEr[0] ? Ar1 : Ar2;
    wire signed [17:0] Br12_muxed = INMODEr[4] ? Br1 : Br2;
    
    wire INMODEA = (PREADDINSEL == "A") ? INMODEr[1] : 0;
    wire INMODEB = (PREADDINSEL == "B") ? INMODEr[1] : 0;
    
    wire signed [26:0] A2A1 = ( ~INMODEA ) ? Ar12_muxed : 0;
    wire signed [17:0] B2B1 = ( ~INMODEB ) ? Br12_muxed : 0;
    
    wire signed [26:0] Dr_gated   = INMODEr[2] ? Dr : 27'b0;
    
    wire signed [26:0] PREADD_AB = (PREADDINSEL == "A") ? A2A1 : B2B1;
    wire signed [26:0] AD_result  = INMODEr[3] ? (Dr_gated - PREADD_AB) : (Dr_gated + PREADD_AB);
    
    reg  signed [26:0] AD_DATA;
    generate
        if (ADREG == 1) initial AD_DATA = 27'b0;
        if (ADREG == 1) begin always @(posedge CLK) if (RSTD) AD_DATA <= 27'b0; else if (CEAD) AD_DATA <= AD_result; end
        else            always @* AD_DATA <= AD_result;
    endgenerate

    // 27x18 multiplier
    wire signed [26:0] A_MULT = (AMULTSEL == "A") ? A2A1 : AD_DATA;
    wire signed [17:0] B_MULT = (BMULTSEL == "B") ? B2B1 : AD_DATA[17:0];


    wire signed [44:0] M = A_MULT * B_MULT;
    wire signed [44:0] Mx = (CARRYINSEL == 3'b010) ? 45'bx : M;
    reg  signed [44:0] Mr = 45'b0;
    // Multiplier result register
    generate
        if (MREG == 1) begin always @(posedge CLK) if (RSTM) Mr <= 45'b0; else if (CEM) Mr <= Mx; end
        else           always @* Mr <= Mx;
    endgenerate
    wire signed [44:0] Mrx = (CARRYINSELr == 3'b010) ? 45'bx : Mr;

    // W, X, Y and Z ALU inputs
    reg signed [47:0] W, X, Y, Z;

    always @* begin
        // X multiplexer
        case (OPMODEr[1:0])
            2'b00: X = 48'b0;
            2'b01: begin X = $signed(Mrx);
`ifndef YOSYS
                if (OPMODEr[3:2] != 2'b01) $fatal(1, "OPMODEr[3:2] must be 2'b01 when OPMODEr[1:0] is 2'b01");
`endif
            end
            2'b10: begin X = P;
`ifndef YOSYS
                if (PREG != 1) $fatal(1, "PREG must be 1 when OPMODEr[1:0] is 2'b10");
`endif
            end
            2'b11: X = $signed({Ar2, Br2});
            default: X = 48'bx;
        endcase

        // Y multiplexer
        case (OPMODEr[3:2])
            2'b00: Y = 48'b0;
//            2'b01: begin Y = 48'b0; // FIXME: more accurate partial product modelling?
            2'b01: begin Y = $signed(Mrx);
`ifndef YOSYS
                if (OPMODEr[1:0] != 2'b01) $fatal(1, "OPMODEr[1:0] must be 2'b01 when OPMODEr[3:2] is 2'b01");
`endif
            end
            2'b10: Y = {48{1'b1}};
            2'b11: Y = Cr;
            default: Y = 48'bx;
        endcase

        // Z multiplexer
        case (OPMODEr[6:4])
            3'b000: Z = 48'b0;
            3'b001: Z = PCIN;
            3'b010: begin Z = P;
`ifndef YOSYS
                if (PREG != 1) $fatal(1, "PREG must be 1 when OPMODEr[6:4] i0s 3'b010");
`endif
            end
            3'b011: Z = Cr;
            3'b100: begin Z = P;
`ifndef YOSYS
                if (PREG != 1) $fatal(1, "PREG must be 1 when OPMODEr[6:4] is 3'b100");
                if (OPMODEr[3:0] != 4'b1000) $fatal(1, "OPMODEr[3:0] must be 4'b1000 when OPMODEr[6:4] i0s 3'b100");
`endif
            end
            3'b101: Z = $signed(PCIN[47:17]);
            3'b110: begin Z = $signed(P[47:17]);
`ifndef YOSYS
                if (PREG != 1) $fatal(1, "PREG must be 1 when OPMODEr[6:4] i0s 3'b110");
`endif    
           end       
            default: Z = 48'bx;
        endcase
       
        // W multiplexer
        case (OPMODEr[8:7])
            2'b00: W = 48'b0;

            2'b01: begin W = P;
`ifndef YOSYS
                if (PREG != 1) $fatal(1, "PREG must be 1 when OPMODEr[8:7] i0s 2'b01");
`endif   
            end
            2'b10: W = RND;
            2'b11: W = Cr;
            default: W = 48'bx;
        endcase 
        
        
    end

    // Carry in
    wire A24_xnor_B17d = A_MULT[26] ~^ B_MULT[17];
    reg CARRYINr, A24_xnor_B17;
    generate
        if (CARRYINREG == 1) initial CARRYINr = 1'b0;
        if (CARRYINREG == 1) begin always @(posedge CLK) if (RSTALLCARRYIN) CARRYINr <= 1'b0; else if (CECARRYIN) CARRYINr <= CARRYIN; end
        else                 always @* CARRYINr = CARRYIN;

        if (MREG == 1) initial A24_xnor_B17 = 1'b0;
        if (MREG == 1) begin always @(posedge CLK) if (RSTALLCARRYIN) A24_xnor_B17 <= 1'b0; else if (CEM) A24_xnor_B17 <= A24_xnor_B17d; end
        else                 always @* A24_xnor_B17 = A24_xnor_B17d;
    endgenerate

    reg cin_muxed;

    always @(*) begin
        case (CARRYINSELr)
            3'b000: cin_muxed = CARRYINr;
            3'b001: cin_muxed = ~PCIN[47];
            3'b010: cin_muxed = CARRYCASCIN;
            3'b011: cin_muxed = PCIN[47];
            3'b100: cin_muxed = CARRYCASCOUT;
            3'b101: cin_muxed = ~P[47];
            3'b110: cin_muxed = A24_xnor_B17;
            3'b111: cin_muxed = P[47];
            default: cin_muxed = 1'bx;
        endcase
    end

    wire alu_cin = (ALUMODEr[3] || ALUMODEr[2]) ? 1'b0 : cin_muxed; //[3:2]为00时，才是加法/减法

    // ALU core
    wire [47:0] Z_muxinv = ALUMODEr[0] ? ~Z : Z;//为1取反 减法
    
    //按位计算
    //S = A ^ B ^ CIN
    //COUT = AB + BCIN + ACIN
    wire [47:0] S = X ^ Y ^ Z_muxinv;
    wire [47:0] COUT = (X & Y) | (X & Z_muxinv) | (Y & Z_muxinv);
    
    wire [47:0] S1 = S ^ COUT ^ W;
    wire [47:0] COUT1 = (S & COUT) | (S & W) | (COUT & W);
    
    wire [47:0] xor_xyz =(ALUMODEr[3] || ALUMODEr[2])? S : S1;
    wire [47:0] maj_xyz =(ALUMODEr[3] || ALUMODEr[2])? COUT : COUT1;

    wire [47:0] xor_xyz_muxed = ALUMODEr[3] ? maj_xyz : xor_xyz;
    wire [47:0] maj_xyz_gated = ALUMODEr[2] ? 48'b0 :  maj_xyz;

    wire [48:0] maj_xyz_simd_gated;
    wire [3:0] int_carry_in, int_carry_out, ext_carry_out;
    wire [47:0] alu_sum;
    assign int_carry_in[0] = 1'b0;
    wire [3:0] carryout_reset;

    generate
        if (USE_SIMD == "FOUR12") begin
            assign maj_xyz_simd_gated = {
                    maj_xyz_gated[47:36],
                    1'b0, maj_xyz_gated[34:24],
                    1'b0, maj_xyz_gated[22:12],
                    1'b0, maj_xyz_gated[10:0],
                    alu_cin
                };
            assign int_carry_in[3:1] = 3'b000;
            assign ext_carry_out = {
                    int_carry_out[3],
                    maj_xyz_gated[35] ^ int_carry_out[2],
                    maj_xyz_gated[23] ^ int_carry_out[1],
                    maj_xyz_gated[11] ^ int_carry_out[0]
                };
            assign carryout_reset = 4'b0000;
        end else if (USE_SIMD == "TWO24") begin
            assign maj_xyz_simd_gated = {
                    maj_xyz_gated[47:24],
                    1'b0, maj_xyz_gated[22:0],
                    alu_cin
                };
            assign int_carry_in[3:1] = {int_carry_out[2], 1'b0, int_carry_out[0]};
            assign ext_carry_out = {
                    int_carry_out[3],
                    1'bx,
                    maj_xyz_gated[23] ^ int_carry_out[1],
                    1'bx
                };
            assign carryout_reset = 4'b0x0x;
        end else begin
            assign maj_xyz_simd_gated = {maj_xyz_gated, alu_cin};
            assign int_carry_in[3:1] = int_carry_out[2:0];
            assign ext_carry_out = {
                    int_carry_out[3],
                    3'bxxx
                };
            assign carryout_reset = 4'b0xxx;
        end

        genvar i;
        for (i = 0; i < 4; i = i + 1)
        begin
            assign {int_carry_out[i], alu_sum[i*12 +: 12]} = {1'b0, maj_xyz_simd_gated[i*12 +: ((i == 3) ? 13 : 12)]} + xor_xyz_muxed[i*12 +: 12] + int_carry_in[i];
        end 
    endgenerate

    wire signed [47:0] Pd = ALUMODEr[1] ? ~alu_sum : alu_sum; //为1取反 减法
    wire [3:0] CARRYOUTd = (OPMODEr[3:0] == 4'b0101 || ALUMODEr[3:2] != 2'b00) ? 4'bxxxx :
                           ((ALUMODEr[0] & ALUMODEr[1]) ? ~ext_carry_out : ext_carry_out);
    wire CARRYCASCOUTd = ext_carry_out[3];
    wire MULTSIGNOUTd = Mrx[44];

    generate
        if (PREG == 1) begin
            initial P = 48'b0;
            initial CARRYOUT = carryout_reset;
            initial CARRYCASCOUT = 1'b0;
            initial MULTSIGNOUT = 1'b0;
            always @(posedge CLK)
                if (RSTP) begin
                    P <= 48'b0;
                    CARRYOUT <= carryout_reset;
                    CARRYCASCOUT <= 1'b0;
                    MULTSIGNOUT <= 1'b0;
                end else if (CEP) begin
                    P <= Pd;
                    CARRYOUT <= CARRYOUTd;
                    CARRYCASCOUT <= CARRYCASCOUTd;
                    MULTSIGNOUT <= MULTSIGNOUTd;
                end
        end else begin
            always @* begin
                P = Pd;
                CARRYOUT = CARRYOUTd;
                CARRYCASCOUT = CARRYCASCOUTd;
                MULTSIGNOUT = MULTSIGNOUTd;
            end
        end
    endgenerate

    assign PCOUT = P;

    generate
        wire PATTERNDETECTd, PATTERNBDETECTd;

        if (USE_PATTERN_DETECT == "PATDET") begin
            // TODO: Support SEL_PATTERN != "PATTERN" and SEL_MASK != "MASK
            assign PATTERNDETECTd = &(~(Pd ^ PATTERN) | MASK);
            assign PATTERNBDETECTd = &((Pd ^ PATTERN) | MASK);
        end else begin
            assign PATTERNDETECTd = 1'b1;
            assign PATTERNBDETECTd = 1'b1;
        end

        if (PREG == 1) begin
            reg PATTERNDETECTPAST, PATTERNBDETECTPAST;
            initial PATTERNDETECT = 1'b0;
            initial PATTERNBDETECT = 1'b0;
            initial PATTERNDETECTPAST = 1'b0;
            initial PATTERNBDETECTPAST = 1'b0;
            always @(posedge CLK)
                if (RSTP) begin
                    PATTERNDETECT <= 1'b0;
                    PATTERNBDETECT <= 1'b0;
                    PATTERNDETECTPAST <= 1'b0;
                    PATTERNBDETECTPAST <= 1'b0;
                end else if (CEP) begin
                    PATTERNDETECT <= PATTERNDETECTd;
                    PATTERNBDETECT <= PATTERNBDETECTd;
                    PATTERNDETECTPAST <= PATTERNDETECT;
                    PATTERNBDETECTPAST <= PATTERNBDETECT;
                end
            assign OVERFLOW = &{PATTERNDETECTPAST, ~PATTERNBDETECT, ~PATTERNDETECT};
            assign UNDERFLOW = &{PATTERNBDETECTPAST, ~PATTERNBDETECT, ~PATTERNDETECT};
        end else begin
            always @* begin
                PATTERNDETECT = PATTERNDETECTd;
                PATTERNBDETECT = PATTERNBDETECTd;
            end
            assign OVERFLOW = 1'bx, UNDERFLOW = 1'bx;
        end
    endgenerate
    
//wide xor
	wire XOR12A;
	wire XOR12B;
	wire XOR12C;
	wire XOR12D;
	wire XOR12E;
	wire XOR12F;
	wire XOR12G;
	wire XOR12H;
	
	wire XOR24A;
	wire XOR24B;
	wire XOR24C;
	wire XOR24D;
	
	wire XOR48A;
	wire XOR48B;
	
	wire XOR96;
	
	
	assign XOR12A = ^S[5:0];
	assign XOR12B = ^S[11:6];
	assign XOR12C = ^S[17:12];
	assign XOR12D = ^S[23:18];
	assign XOR12E = ^S[29:24];
	assign XOR12F = ^S[35:30];
	assign XOR12G = ^S[41:36];
	assign XOR12H = ^S[47:42];
	
	
	assign XOR24A = XOR12A ^ XOR12B;
	assign XOR24B = XOR12C ^ XOR12D;
	assign XOR24C = XOR12E ^ XOR12F;
	assign XOR24D = XOR12G ^ XOR12H;
	
	assign XOR48A = XOR24A ^ XOR24B;
	assign XOR48B = XOR24C ^ XOR24D;
	
	assign XOR96 = XOR48A ^ XOR48B;
	
	assign XOROUT[0] = (XORSIMD)	? XOR24A	: XOR12A;
	assign XOROUT[1] = (XORSIMD)	? XOR48A	: XOR12B;
	assign XOROUT[2] = (XORSIMD)	? XOR24B	: XOR12C;
	assign XOROUT[3] = (XORSIMD)	? XOR96  	: XOR12D;
	assign XOROUT[4] = (XORSIMD)	? XOR24C	: XOR12E;
	assign XOROUT[5] = (XORSIMD)	? XOR48B	: XOR12F;
	assign XOROUT[6] = (XORSIMD)	? XOR24D	: XOR12G;
	assign XOROUT[7] = XOR12H;


endmodule


//internal
module MULT9X9(
    input  [8:0] A,
    input  [8:0] B,
    output reg [17:0] P,
    
    input A_sign,
    input B_sign,
    
    input    CLK,
    input    RSTM,

    input    HALF_0,    // a selector bit to switch computation to half mode level 0
    input    HALF_1,    // a selector bit to switch computation to half mode level 1
    input    HALF_2 // a selector bit to switch computation to half mode level 2
    );

parameter A_chop_size = 9;
parameter B_chop_size = 9;


// to support both signed and unsigned multiplication
// sign extension regarding extra sign identifier
wire A_extended_level0_0;
wire B_extended_level0_0;
assign A_extended_level0_0 = (A[8])&(A_sign);
assign B_extended_level0_0 = (B[8])&(B_sign);

wire A_extended_level1_0;
wire B_extended_level1_0;
assign A_extended_level1_0 = (A[8])&(A_sign);
assign B_extended_level1_0 = (B[8])&(B_sign);
wire A_extended_level1_1;
wire B_extended_level1_1;
assign A_extended_level1_1 = (A[3])&(A_sign);
assign B_extended_level1_1 = (B[3])&(B_sign);

wire A_extended_level2_0;
wire B_extended_level2_0;
assign A_extended_level2_0 = (A[8])&(A_sign);
assign B_extended_level2_0 = (B[8])&(B_sign);
wire A_extended_level2_1;
wire B_extended_level2_1;
assign A_extended_level2_1 = (A[6])&(A_sign);
assign B_extended_level2_1 = (B[6])&(B_sign);
wire A_extended_level2_2;
wire B_extended_level2_2;
assign A_extended_level2_2 = (A[3])&(A_sign);
assign B_extended_level2_2 = (B[3])&(B_sign);
wire A_extended_level2_3;
wire B_extended_level2_3;
assign A_extended_level2_3 = (A[1])&(A_sign);
assign B_extended_level2_3 = (B[1])&(B_sign);


reg [A_chop_size:0] PP [B_chop_size:0];
always @(*) begin
    PP[0][0] = (A[0])&(B[0]);
    PP[0][1] = (A[1])&(B[0]);
    PP[0][2] = ((((A[2])&(~(HALF_2)))|((A_extended_level2_3)&(HALF_2)))&(B[0]))^(HALF_2);
    PP[0][3] = ((A[3])&(B[0]))&(~(HALF_2));
    PP[0][4] = (((((A[4])&(~(HALF_1)))|((A_extended_level1_1)&(HALF_1)))&(B[0]))^(HALF_1))&(~(HALF_2));
    PP[0][5] = (((A[5])&(B[0]))&(~(HALF_1)))&(~(HALF_2));
    PP[0][6] = (((A[6])&(B[0]))&(~(HALF_1)))&(~(HALF_2));
    PP[0][7] = (((A[7])&(B[0]))&(~(HALF_1)))&(~(HALF_2));
    PP[0][8] = (((A[8])&(B[0]))&(~(HALF_1)))&(~(HALF_2));
    PP[0][9] = ((~((A_extended_level0_0)&(B[0])))&(~(HALF_1)))&(~(HALF_2));
    PP[1][0] = (A[0])&(B[1]);
    PP[1][1] = (A[1])&(B[1]);
    PP[1][2] = ((((A[2])&(~(HALF_2)))|((A_extended_level2_3)&(HALF_2)))&(B[1]))^(HALF_2);
    PP[1][3] = ((A[3])&(B[1]))&(~(HALF_2));
    PP[1][4] = (((((A[4])&(~(HALF_1)))|((A_extended_level1_1)&(HALF_1)))&(B[1]))^(HALF_1))&(~(HALF_2));
    PP[1][5] = (((A[5])&(B[1]))&(~(HALF_1)))&(~(HALF_2));
    PP[1][6] = (((A[6])&(B[1]))&(~(HALF_1)))&(~(HALF_2));
    PP[1][7] = (((A[7])&(B[1]))&(~(HALF_1)))&(~(HALF_2));
    PP[1][8] = (((A[8])&(B[1]))&(~(HALF_1)))&(~(HALF_2));
    PP[1][9] = ((~((A_extended_level0_0)&(B[1])))&(~(HALF_1)))&(~(HALF_2));
    PP[2][0] = ((A[0])&(((B[2])&(~(HALF_2)))|((B_extended_level2_3)&(HALF_2))))^(HALF_2);
    PP[2][1] = ((A[1])&(((B[2])&(~(HALF_2)))|((B_extended_level2_3)&(HALF_2))))^(HALF_2);
    PP[2][2] = (A[2])&(B[2]);
    PP[2][3] = (A[3])&(B[2]);
    PP[2][4] = ((((((A[4])&(~(HALF_1)))|((A_extended_level1_1)&(HALF_1)))&(~(HALF_2)))|((A_extended_level2_2)&(HALF_2)))&(B[2]))^((HALF_1)|(HALF_2));
    PP[2][5] = (((A[5])&(B[2]))&(~(HALF_1)))&(~(HALF_2));
    PP[2][6] = (((A[6])&(B[2]))&(~(HALF_1)))&(~(HALF_2));
    PP[2][7] = (((A[7])&(B[2]))&(~(HALF_1)))&(~(HALF_2));
    PP[2][8] = (((A[8])&(B[2]))&(~(HALF_1)))&(~(HALF_2));
    PP[2][9] = ((~((A_extended_level0_0)&(B[2])))&(~(HALF_1)))&(~(HALF_2));
    PP[3][0] = ((A[0])&(B[3]))&(~(HALF_2));
    PP[3][1] = ((A[1])&(B[3]))&(~(HALF_2));
    PP[3][2] = (A[2])&(B[3]);
    PP[3][3] = (A[3])&(B[3]);
    PP[3][4] = ((((((A[4])&(~(HALF_1)))|((A_extended_level1_1)&(HALF_1)))&(~(HALF_2)))|((A_extended_level2_2)&(HALF_2)))&(B[3]))^((HALF_1)|(HALF_2));
    PP[3][5] = (((A[5])&(B[3]))&(~(HALF_1)))&(~(HALF_2));
    PP[3][6] = (((A[6])&(B[3]))&(~(HALF_1)))&(~(HALF_2));
    PP[3][7] = (((A[7])&(B[3]))&(~(HALF_1)))&(~(HALF_2));
    PP[3][8] = (((A[8])&(B[3]))&(~(HALF_1)))&(~(HALF_2));
    PP[3][9] = ((~((A_extended_level0_0)&(B[3])))&(~(HALF_1)))&(~(HALF_2));
    PP[4][0] = (((A[0])&(((B[4])&(~(HALF_1)))|((B_extended_level1_1)&(HALF_1))))^(HALF_1))&(~(HALF_2));
    PP[4][1] = (((A[1])&(((B[4])&(~(HALF_1)))|((B_extended_level1_1)&(HALF_1))))^(HALF_1))&(~(HALF_2));
    PP[4][2] = ((A[2])&(((((B[4])&(~(HALF_1)))|((B_extended_level1_1)&(HALF_1)))&(~(HALF_2)))|((B_extended_level2_2)&(HALF_2))))^((HALF_1)|(HALF_2));
    PP[4][3] = ((A[3])&(((((B[4])&(~(HALF_1)))|((B_extended_level1_1)&(HALF_1)))&(~(HALF_2)))|((B_extended_level2_2)&(HALF_2))))^((HALF_1)|(HALF_2));
    PP[4][4] = (((A[4])&(B[4]))&(~(HALF_1)))&(~(HALF_2));
    PP[4][5] = (((A[5])&(B[4]))&(~(HALF_1)))&(~(HALF_2));
    PP[4][6] = (((A[6])&(B[4]))&(~(HALF_1)))&(~(HALF_2));
    PP[4][7] = (((A[7])&(B[4]))&(~(HALF_1)))&(~(HALF_2));
    PP[4][8] = (((A[8])&(B[4]))&(~(HALF_1)))&(~(HALF_2));
    PP[4][9] = ((~((A_extended_level0_0)&(B[4])))&(~(HALF_1)))&(~(HALF_2));
    PP[5][0] = (((A[0])&(B[5]))&(~(HALF_1)))&(~(HALF_2));
    PP[5][1] = (((A[1])&(B[5]))&(~(HALF_1)))&(~(HALF_2));
    PP[5][2] = (((A[2])&(B[5]))&(~(HALF_1)))&(~(HALF_2));
    PP[5][3] = (((A[3])&(B[5]))&(~(HALF_1)))&(~(HALF_2));
    PP[5][4] = (((A[4])&(B[5]))&(~(HALF_1)))&(~(HALF_2));
    PP[5][5] = (A[5])&(B[5]);
    PP[5][6] = (A[6])&(B[5]);
    PP[5][7] = ((((A[7])&(~(HALF_2)))|((A_extended_level2_1)&(HALF_2)))&(B[5]))^(HALF_2);
    PP[5][8] = ((A[8])&(B[5]))&(~(HALF_2));
    PP[5][9] = (~((((A_extended_level0_0)&(~(HALF_1)))|((A_extended_level1_0)&(HALF_1)))&(B[5])))&(~(HALF_2));
    PP[6][0] = (((A[0])&(B[6]))&(~(HALF_1)))&(~(HALF_2));
    PP[6][1] = (((A[1])&(B[6]))&(~(HALF_1)))&(~(HALF_2));
    PP[6][2] = (((A[2])&(B[6]))&(~(HALF_1)))&(~(HALF_2));
    PP[6][3] = (((A[3])&(B[6]))&(~(HALF_1)))&(~(HALF_2));
    PP[6][4] = (((A[4])&(B[6]))&(~(HALF_1)))&(~(HALF_2));
    PP[6][5] = (A[5])&(B[6]);
    PP[6][6] = (A[6])&(B[6]);
    PP[6][7] = ((((A[7])&(~(HALF_2)))|((A_extended_level2_1)&(HALF_2)))&(B[6]))^(HALF_2);
    PP[6][8] = ((A[8])&(B[6]))&(~(HALF_2));
    PP[6][9] = (~((((A_extended_level0_0)&(~(HALF_1)))|((A_extended_level1_0)&(HALF_1)))&(B[6])))&(~(HALF_2));
    PP[7][0] = (((A[0])&(B[7]))&(~(HALF_1)))&(~(HALF_2));
    PP[7][1] = (((A[1])&(B[7]))&(~(HALF_1)))&(~(HALF_2));
    PP[7][2] = (((A[2])&(B[7]))&(~(HALF_1)))&(~(HALF_2));
    PP[7][3] = (((A[3])&(B[7]))&(~(HALF_1)))&(~(HALF_2));
    PP[7][4] = (((A[4])&(B[7]))&(~(HALF_1)))&(~(HALF_2));
    PP[7][5] = ((A[5])&(((B[7])&(~(HALF_2)))|((B_extended_level2_1)&(HALF_2))))^(HALF_2);
    PP[7][6] = ((A[6])&(((B[7])&(~(HALF_2)))|((B_extended_level2_1)&(HALF_2))))^(HALF_2);
    PP[7][7] = (A[7])&(B[7]);
    PP[7][8] = (A[8])&(B[7]);
    PP[7][9] = ~((((((A_extended_level0_0)&(~(HALF_1)))|((A_extended_level1_0)&(HALF_1)))&(~(HALF_2)))|((A_extended_level2_0)&(HALF_2)))&(B[7]));
    PP[8][0] = (((A[0])&(B[8]))&(~(HALF_1)))&(~(HALF_2));
    PP[8][1] = (((A[1])&(B[8]))&(~(HALF_1)))&(~(HALF_2));
    PP[8][2] = (((A[2])&(B[8]))&(~(HALF_1)))&(~(HALF_2));
    PP[8][3] = (((A[3])&(B[8]))&(~(HALF_1)))&(~(HALF_2));
    PP[8][4] = (((A[4])&(B[8]))&(~(HALF_1)))&(~(HALF_2));
    PP[8][5] = ((A[5])&(B[8]))&(~(HALF_2));
    PP[8][6] = ((A[6])&(B[8]))&(~(HALF_2));
    PP[8][7] = (A[7])&(B[8]);
    PP[8][8] = (A[8])&(B[8]);
    PP[8][9] = ~((((((A_extended_level0_0)&(~(HALF_1)))|((A_extended_level1_0)&(HALF_1)))&(~(HALF_2)))|((A_extended_level2_0)&(HALF_2)))&(B[8]));
    PP[9][0] = ((~((A[0])&(B_extended_level0_0)))&(~(HALF_1)))&(~(HALF_2));
    PP[9][1] = ((~((A[1])&(B_extended_level0_0)))&(~(HALF_1)))&(~(HALF_2));
    PP[9][2] = ((~((A[2])&(B_extended_level0_0)))&(~(HALF_1)))&(~(HALF_2));
    PP[9][3] = ((~((A[3])&(B_extended_level0_0)))&(~(HALF_1)))&(~(HALF_2));
    PP[9][4] = ((~((A[4])&(B_extended_level0_0)))&(~(HALF_1)))&(~(HALF_2));
    PP[9][5] = (~((A[5])&(((B_extended_level0_0)&(~(HALF_1)))|((B_extended_level1_0)&(HALF_1)))))&(~(HALF_2));
    PP[9][6] = (~((A[6])&(((B_extended_level0_0)&(~(HALF_1)))|((B_extended_level1_0)&(HALF_1)))))&(~(HALF_2));
    PP[9][7] = ~((A[7])&(((((B_extended_level0_0)&(~(HALF_1)))|((B_extended_level1_0)&(HALF_1)))&(~(HALF_2)))|((B_extended_level2_0)&(HALF_2))));
    PP[9][8] = ~((A[8])&(((((B_extended_level0_0)&(~(HALF_1)))|((B_extended_level1_0)&(HALF_1)))&(~(HALF_2)))|((B_extended_level2_0)&(HALF_2))));
    PP[9][9] = (A_extended_level0_0)&(B_extended_level0_0);
end

// sum of PPs
integer j;
integer i_0;
integer i_1;
integer i_2;
integer i_3;

wire [18:0] Baugh_Wooley_0;
assign Baugh_Wooley_0 = {{1'b0},{(HALF_2)|(1'b0)},{1'b0},{(HALF_1)|(1'b0)},{1'b0},{(HALF_2)|(1'b0)},{1'b0},{1'b0},{(HALF_0)|(1'b0)},{1'b0},{1'b0},{(HALF_2)|(1'b0)},{1'b0},{(HALF_1)|(1'b0)},{1'b0},{(HALF_2)|(1'b0)},{1'b0},{1'b0},{1'b0}};
wire [18:0] Baugh_Wooley_1;
assign Baugh_Wooley_1 = {{1'b0},{1'b0},{1'b0},{1'b0},{1'b0},{1'b0},{1'b0},{1'b0},{1'b0},{1'b0},{1'b0},{1'b0},{1'b0},{1'b0},{1'b0},{1'b0},{1'b0},{1'b0},{1'b0}};

reg [18:0] PP_temp [9:0];
always @(*) begin
    for (j = 0; j < (B_chop_size +1); j = j + 1 ) begin
        PP_temp[j] = 19'b0 ;
    end
    for (j = 0; j < (B_chop_size +1); j = j + 1 ) begin
        PP_temp[j] = (PP[j] << j);
    end
end

reg [17:0] P_temp_0;
reg [17:0] P_temp_1;
reg [17:0] P_0;
reg [17:0] P_1;
always @(*) begin
    P_temp_1 [3:0] = 4'b0;
    P_1 [3:0] = P_temp_1 [3:0];
    P_temp_0[7:0] = PP_temp[0][3: 0] + PP_temp[1][3: 0] + PP_temp[2][3: 0] + PP_temp[3][3: 0] + PP_temp[4][3: 0] + PP_temp[5][3: 0] + PP_temp[6][3: 0] + PP_temp[7][3: 0] + PP_temp[8][3: 0] + PP_temp[9][3: 0] + Baugh_Wooley_0[3: 0] + Baugh_Wooley_1[3: 0];
    P_0[7:0] = (P_temp_0[7:0])&(~({{4{HALF_2}},{4{1'b0}}}));
    P_temp_1[13:4] = PP_temp[0][7: 4] + PP_temp[1][7: 4] + PP_temp[2][7: 4] + PP_temp[3][7: 4] + PP_temp[4][7: 4] + PP_temp[5][7: 4] + PP_temp[6][7: 4] + PP_temp[7][7: 4] + PP_temp[8][7: 4] + PP_temp[9][7: 4] + Baugh_Wooley_0[7: 4] + Baugh_Wooley_1[7: 4];
    P_1[13:4] = (P_temp_1[13:4])&(~({{6{(HALF_1)|(HALF_2)}},{4{1'b0}}}));
    P_temp_0[17:8] = PP_temp[0][13: 8] + PP_temp[1][13: 8] + PP_temp[2][13: 8] + PP_temp[3][13: 8] + PP_temp[4][13: 8] + PP_temp[5][13: 8] + PP_temp[6][13: 8] + PP_temp[7][13: 8] + PP_temp[8][13: 8] + PP_temp[9][13: 8] + Baugh_Wooley_0[13: 8] + Baugh_Wooley_1[13: 8];
    P_0[17:8] = (P_temp_0[17:8])&(~({{4{HALF_2}},{6{1'b0}}}));
    P_temp_1[17:14] = PP_temp[0][17: 14] + PP_temp[1][17: 14] + PP_temp[2][17: 14] + PP_temp[3][17: 14] + PP_temp[4][17: 14] + PP_temp[5][17: 14] + PP_temp[6][17: 14] + PP_temp[7][17: 14] + PP_temp[8][17: 14] + PP_temp[9][17: 14] + Baugh_Wooley_0[17: 14] + Baugh_Wooley_1[17: 14];
    P_1[17:14] = (P_temp_1[17:14])&(~({{0{((HALF_0)|(HALF_1))|(HALF_2)}},{4{1'b0}}}));
end

reg P_carry_temp_0;
reg P_carry_temp_1;
reg P_carry_temp_2;
reg signed [A_chop_size+B_chop_size-1:0] P_temp;
always @(*) begin
    P_temp[3: 0] = P_0[3: 0] + P_1[3: 0];
    P_carry_temp_0 = ((((P_0[3])&(P_1[3])))|(((P_0[3])^(P_1[3]))&((P_0[2])&(P_1[2])))|(((P_0[3])^(P_1[3]))&((P_0[2])^(P_1[2]))&((P_0[1])&(P_1[1])))|(((P_0[3])^(P_1[3]))&((P_0[2])^(P_1[2]))&((P_0[1])^(P_1[1]))&((P_0[0])&(P_1[0])))|(((P_0[3])^(P_1[3]))&((P_0[2])^(P_1[2]))&((P_0[1])^(P_1[1]))&((P_0[0])^(P_1[0]))&(1'b0)));
    P_temp[7: 4] = P_0[7: 4] + P_1[7: 4] + ((P_carry_temp_0)&(~(HALF_2)));
    P_carry_temp_1 = ((((P_0[7])&(P_1[7])))|(((P_0[7])^(P_1[7]))&((P_0[6])&(P_1[6])))|(((P_0[7])^(P_1[7]))&((P_0[6])^(P_1[6]))&((P_0[5])&(P_1[5])))|(((P_0[7])^(P_1[7]))&((P_0[6])^(P_1[6]))&((P_0[5])^(P_1[5]))&((P_0[4])&(P_1[4])))|(((P_0[7])^(P_1[7]))&((P_0[6])^(P_1[6]))&((P_0[5])^(P_1[5]))&((P_0[4])^(P_1[4]))&P_carry_temp_0));
    P_temp[13: 8] = P_0[13: 8] + P_1[13: 8] + ((P_carry_temp_1)&(~((HALF_1)|(HALF_2))));
    P_carry_temp_2 = ((((P_0[13])&(P_1[13])))|(((P_0[13])^(P_1[13]))&((P_0[12])&(P_1[12])))|(((P_0[13])^(P_1[13]))&((P_0[12])^(P_1[12]))&((P_0[11])&(P_1[11])))|(((P_0[13])^(P_1[13]))&((P_0[12])^(P_1[12]))&((P_0[11])^(P_1[11]))&((P_0[10])&(P_1[10])))|(((P_0[13])^(P_1[13]))&((P_0[12])^(P_1[12]))&((P_0[11])^(P_1[11]))&((P_0[10])^(P_1[10]))&((P_0[9])&(P_1[9])))|(((P_0[13])^(P_1[13]))&((P_0[12])^(P_1[12]))&((P_0[11])^(P_1[11]))&((P_0[10])^(P_1[10]))&((P_0[9])^(P_1[9]))&((P_0[8])&(P_1[8])))|(((P_0[13])^(P_1[13]))&((P_0[12])^(P_1[12]))&((P_0[11])^(P_1[11]))&((P_0[10])^(P_1[10]))&((P_0[9])^(P_1[9]))&((P_0[8])^(P_1[8]))&P_carry_temp_1));
    P_temp[17: 14] = P_0[17: 14] + P_1[17: 14] + ((P_carry_temp_2)&(~(HALF_2)));
end
always @ (posedge CLK) begin
    if(RSTM)
        P <= 0;
    else
        P <= P_temp[A_chop_size+B_chop_size-1:0];
end


endmodule

module shift(
    input [17:0] C_0,
    input [17:0] C_1,
     input [17:0] C_2,
     input [17:0] C_3,
     input [17:0] C_4,
     input [17:0] C_5,  
     input [3:0] MULTMODE,
     
     output [44:0] M
    );
    
reg A_sign_0;
reg A_sign_1;
reg A_sign_2;
reg A_sign_3;
reg A_sign_4;
reg A_sign_5;

reg B_sign_0;
reg B_sign_1;
reg B_sign_2;
reg B_sign_3;
reg B_sign_4;
reg B_sign_5;

always @(*) begin
    case (MULTMODE[3:2])
        2'b00: begin    
            A_sign_0 = 1'b0;
            A_sign_1 = 1'b0;
            A_sign_4 = MULTMODE[0];
            A_sign_2 = 1'b0;
            A_sign_3 = 1'b0;
            A_sign_5 = MULTMODE[0];

            B_sign_0 = 1'b0;
            B_sign_1 = 1'b0;
            B_sign_4 = 1'b0;
            B_sign_2 = MULTMODE[1];
            B_sign_3 = MULTMODE[1];
            B_sign_5 = MULTMODE[1];
        end
        default: begin              
            A_sign_0 = MULTMODE[0];
            A_sign_1 = MULTMODE[0];
            A_sign_4 = MULTMODE[0];
            A_sign_2 = MULTMODE[0];
            A_sign_3 = MULTMODE[0];
            A_sign_5 = MULTMODE[0];

            B_sign_0 = MULTMODE[1];
            B_sign_1 = MULTMODE[1];
            B_sign_4 = MULTMODE[1];
            B_sign_2 = MULTMODE[1];
            B_sign_3 = MULTMODE[1];
            B_sign_5 = MULTMODE[1];
        end
    endcase
end
    
reg [44:0] C_0_shifted;
reg [44:0] C_1_shifted;
reg [44:0] C_2_shifted;
reg [44:0] C_3_shifted;
reg [44:0] C_4_shifted;
reg [44:0] C_5_shifted;

always @ (*) begin
    case (MULTMODE[3:2])
        2'b00: begin
            C_0_shifted = {{27{(C_0[17])&((A_sign_0)|(B_sign_0))}}, {C_0}};
            C_1_shifted = {{18{(C_1[17])&((A_sign_1)|(B_sign_1))}}, {C_1}, {9{1'b0}}};
            C_4_shifted = {{9{(C_4[17])&((A_sign_4)|(B_sign_4))}}, {C_4}, {18{1'b0}}};
            C_2_shifted = {{18{(C_2[17])&((A_sign_2)|(B_sign_2))}}, {C_2}, {9{1'b0}}};
            C_3_shifted = {{9{(C_3[17])&((A_sign_3)|(B_sign_3))}}, {C_3}, {18{1'b0}}};
            C_5_shifted = {{C_5}, {27{1'b0}}};
        end
        default : begin
            C_0_shifted = {{18{1'b0}}, {C_0}, {C_0[8:0]}};
            C_1_shifted = {{18{1'b0}}, {C_1}, {9{1'b0}}};
            C_4_shifted = {{C_4},{27{1'b0}}};
            C_2_shifted = {{18{1'b0}}, {C_2}, {9{1'b0}}};
            C_3_shifted = {{C_3}, {27{1'b0}}};
            C_5_shifted = {{C_5}, {27{1'b0}}};
        end
    endcase
end

 assign M = C_0_shifted + C_1_shifted + C_2_shifted + C_3_shifted + C_4_shifted + C_5_shifted;   
       
endmodule

module MULT54X54(
        input [53:0] A,
        input [53:0] B,
        output [44:0] Y
 );

wire signed [17:0] C_0;
wire signed [17:0] C_1;
wire signed [17:0] C_2;
wire signed [17:0] C_3;
wire signed [17:0] C_4;
wire signed [17:0] C_5;

wire signed [8:0] A_0 = A[8:0];
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
assign C_5 = A_5 * B_5;


assign Y[44:24] = C_5 + C_4 + C_3;
assign Y[23:0] = C_2 + C_1 + C_0;

endmodule


module  FIFO(
    CLK,
    RSTA,
    CEA1,
    CEA2,
    RF_load,
    MDRr,
    r_addr,
    A,
    A_MULT
 );

     parameter registerfile_size = 8;
     parameter registerfile_size_log = $clog2(registerfile_size);

    input CLK;
    input RSTA;
    input CEA1;
    input CEA2;
    input RF_load;
    input MDRr;
    input [2:0] r_addr;
    input signed [26:0] A;

    output [53:0] A_MULT;

    reg [29:0] A_RF [7:0];

    generate
    integer j;
    // RF as a shift register
    always@(posedge CLK) begin
        if (RSTA) begin
            for ( j = 0; j < 8; j = j + 1) begin
                A_RF[j] <= 30'b0;
            end
        end
        else begin
            if (CEA1 | RF_load) begin
                A_RF[0] <= A;
            end
            /*if (CEA2 | RF_load) begin

                A_RF[1] <= A_RF[0];
            end*/
            if (CEA2 | RF_load) begin
                for (j = 1; j < 8; j = j + 1) begin
                    A_RF[j] <= A_RF[j-1];
                end
            end
        end
    end

    endgenerate

    reg [26:0] a_mult_temp_0;
    reg [26:0] a_mult_temp_1;
    always @ (*) begin
        if (MDRr) begin
            a_mult_temp_0 = A_RF[r_addr][26:0];
            a_mult_temp_1 = A_RF[r_addr + 1][26:0];
        end
        else begin
            a_mult_temp_0 = A_RF[r_addr][26:0];
            a_mult_temp_1 = 27'bx;

        end
    end


   wire signed [53:0] A_MULT = {a_mult_temp_1,a_mult_temp_0};

endmodule



module pirdsp2(
        // Inputs
        CLK,

         A,
         B,
         C,
         D,

         OPMODE,
         ALUMODE,
         CARRYINSEL,

         CARRYIN,
         INMODE,
         MULTMODE,          // new
         LPS,               // Please change it to 1 bit from 2 bits     new
         CHAINMODE,         // new
         MDR,                               // new

         CEB1,
         CEB2,
         CEA1,
         CEA2,
         CEAD,
         CED,
         CEC,
         CEP,
         CEM,
         CECARRYIN,
         CEALUMODE,
         CECTRL,
         CEINMODE,
         CEMULTMODE,                // new
         CELPS,         // new
         CECHAINMODE,               // new
         CEMDR,                         // new

         RSTCTRL,
         RSTALUMODE,
         RSTD,
         RSTC,
         RSTB,
         RSTA,
         RSTP,
         RSTM,
         RSTALLCARRYIN,
         RSTINMODE,
         RSTMULTMODE,           // new
         RSTLPS,    // new
         RSTCHAINMODE,      // new
         RSTMDR,                    // new

         ACIN,
         BCIN,              // modified
         PCIN,
         CARRYCASCIN,
        //input MULTSIGNIN,             //  <------------------ Question: sued for 96 MAC --> to forward carry bit from a ALU to next ALU as we use 4 bit adders.
        // End of Inputs


        // Outputs
         ACOUT,
         BCOUT,         // modified
         PCOUT,

         P,
  //       P_SIMD_carry,  // NEW (DoM : Depends on Multiplier)

         CARRYOUT,
         CARRYCASCOUT,
         MULTSIGNOUT,

         PATTERNDETECT,
         PATTERNBDETECT,

         OVERFLOW,
         UNDERFLOW,

         XOROUT
        // End of Outputs

//       configuration_input,
//       configuration_enable
    );

    parameter registerfile_size = 8;
    parameter registerfile_size_log = $clog2(registerfile_size);

    parameter integer ACASCREG = 1;
    parameter integer ADREG = 1;
    parameter integer ALUMODEREG = 1;
    parameter AMULTSEL = "A"; //NEW
    parameter integer AREG = 1;
    parameter AUTORESET_PATDET = "NO_RESET";
    parameter AUTORESET_PRIORITY = "RESET"; //NEW
    parameter A_INPUT = "DIRECT";
    parameter integer BCASCREG = 1;
    parameter BMULTSEL = "B"; //NEW
    parameter integer BREG = 1;
    parameter B_INPUT = "DIRECT";
    parameter integer CARRYINREG = 1;
    parameter integer CARRYINSELREG = 1;
    parameter integer CREG = 1;
    parameter integer DREG = 1;
    parameter integer INMODEREG = 1;
    parameter [3:0] IS_ALUMODE_INVERTED = 4'b0;
    parameter [0:0] IS_CARRYIN_INVERTED = 1'b0;
    parameter [0:0] IS_CLK_INVERTED = 1'b0;
    parameter [4:0] IS_INMODE_INVERTED = 5'b0;
    parameter [8:0] IS_OPMODE_INVERTED = 9'b0;
    //NEW
    parameter [0:0] IS_RSTALLCARRYIN_INVERTED = 1'b0;
    parameter [0:0] IS_RSTALUMODE_INVERTED = 1'b0;
    parameter [0:0] IS_RSTA_INVERTED = 1'b0;
    parameter [0:0] IS_RSTB_INVERTED = 1'b0;
    parameter [0:0] IS_RSTCTRL_INVERTED = 1'b0;
    parameter [0:0] IS_RSTC_INVERTED = 1'b0;
    parameter [0:0] IS_RSTD_INVERTED = 1'b0;
    parameter [0:0] IS_RSTINMODE_INVERTED = 1'b0;
    parameter [0:0] IS_RSTM_INVERTED = 1'b0;
    parameter [0:0] IS_RSTP_INVERTED = 1'b0;
  //NEW
    parameter integer MULTMODEREG = 1;
    parameter [3:0] IS_MULTMODE_INVERTED = 1'b0;
    parameter IS_RSTMULTMODE_INVERTED = 1'b0;

    parameter integer LPSREG = 1;
    parameter IS_LPS_INVERTED = 1'b0;
    parameter IS_RSTLPS_INVERTED = 1'b0;

    parameter integer CHAINMODEREG = 1;
    parameter [1:0] IS_CHAINMODE_INVERTED = 1'b0;
    parameter IS_RSTCHAINMODE_INVERTED = 1'b0;

    parameter integer MDRREG = 1;
    parameter IS_MDR_INVERTED = 1'b0;
    parameter IS_RSTMDR_INVERTED = 1'b0;

  //NEW
    parameter [47:0] MASK = 48'h3FFFFFFFFFFF;
    parameter integer MREG = 1;
    parameter integer OPMODEREG = 1;
    parameter [47:0] PATTERN = 48'h000000000000;
    parameter PREADDINSEL = "A"; //NEW
    parameter integer PREG = 1;
    parameter [47:0] RND = 48'h000000000000; //NEW
    parameter SEL_MASK = "MASK";
    parameter SEL_PATTERN = "PATTERN";
//      parameter USE_DPORT = "FALSE";  //NONE
    parameter USE_MULT = "MULTIPLY";
    parameter USE_PATTERN_DETECT = "NO_PATDET";
    parameter USE_SIMD = "ONE48";
    parameter USE_WIDEXOR = "FALSE"; //NEW
    parameter XORSIMD = "XOR24_48_96";  //NEW

        input CLK;

        input [29:0] A;
        input [26:0] B;
        input [47:0] C;
        input [26:0] D;


        input [8:0] OPMODE;
        input [3:0] ALUMODE;
        input [2:0] CARRYINSEL;

        input CARRYIN;
        input [4:0] INMODE;
        input [3:0] MULTMODE;           // new
        input LPS;                              // new
        input [1:0] CHAINMODE;          // new
        input MDR;                              // new

        input CEB1;
        input CEB2;
        input CEA1;
        input CEA2;
        input CEAD;
        input CED;
        input CEC;
        input CEP;
        input CEM;
        input CECARRYIN;
        input CEALUMODE;
        input CECTRL;
        input CEINMODE;
        input CEMULTMODE;               // new
        input CELPS;            // new
        input CECHAINMODE;              // new
        input CEMDR;                            // new

        input RSTCTRL;
        input RSTALUMODE;
        input RSTD;
        input RSTC;
        input RSTB;
        input RSTA;
        input RSTP;
        input RSTM;
        input RSTALLCARRYIN;
        input RSTINMODE;
        input RSTMULTMODE;          // new
        input RSTLPS;   // new
        input RSTCHAINMODE;     // new
        input RSTMDR;                   // new

        input [29:0] ACIN;
        input [26:0] BCIN;              // modified
        input [47:0] PCIN;
        input CARRYCASCIN;
        //input MULTSIGNIN;             //  <------------------ Question: sued for 96 MAC --> to forward carry bit from a ALU to next ALU as we use 4 bit adders.
        // End of Inputs


        // Outputs
        output reg [29:0] ACOUT;
        output reg [26:0] BCOUT;            // modified
        output [47:0] PCOUT;

        output reg [47:0] P;
    //  output [15:0] P_SIMD_carry; // NEW (DoM : Depends on Multiplier)

        output reg [7:0] CARRYOUT;
        output reg CARRYCASCOUT;
        output reg MULTSIGNOUT;

        output reg PATTERNDETECT;
        output reg PATTERNBDETECT;

        output OVERFLOW;
        output UNDERFLOW;

        output [7:0] XOROUT;


    initial begin
`ifndef YOSYS
        if (AUTORESET_PATDET != "NO_RESET") $fatal(1, "Unsupported AUTORESET_PATDET value");
        if (SEL_MASK != "MASK")     $fatal(1, "Unsupported SEL_MASK value");
        if (SEL_PATTERN != "PATTERN") $fatal(1, "Unsupported SEL_PATTERN value");
        if (USE_SIMD != "2X2" && USE_SIMD != "4X4" && USE_SIMD != "9X9" && USE_SIMD != "27X18")    $fatal(1, "Unsupported USE_SIMD value");
        if (IS_ALUMODE_INVERTED != 4'b0) $fatal(1, "Unsupported IS_ALUMODE_INVERTED value");
        if (IS_CARRYIN_INVERTED != 1'b0) $fatal(1, "Unsupported IS_CARRYIN_INVERTED value");
        if (IS_CLK_INVERTED != 1'b0) $fatal(1, "Unsupported IS_CLK_INVERTED value");
        if (IS_INMODE_INVERTED != 5'b0) $fatal(1, "Unsupported IS_INMODE_INVERTED value");
        if (IS_OPMODE_INVERTED != 9'b0) $fatal(1, "Unsupported IS_OPMODE_INVERTED value");
`endif
    end

    wire signed [29:0] A_muxed;
    wire signed [26:0] B_muxed;

    generate
        if (A_INPUT == "CASCADE") assign A_muxed = ACIN;
        else assign A_muxed = A;

        if (B_INPUT == "CASCADE") assign B_muxed = BCIN;
        else assign B_muxed = {{9'b0_0000_0000},{B}};
    endgenerate

    //reg signed [29:0] Ar1, Ar2;
    reg signed [26:0] Dr;
   // reg signed [17:0] Br1, Br2;
    reg signed [47:0] Cr;
    reg        [4:0]  INMODEr;
    reg        [8:0]  OPMODEr;
    reg        [3:0]  ALUMODEr;
    reg        [2:0]  CARRYINSELr;
    reg        [3:0]  MULTMODEr;
    reg        LPSr;
    reg        [1:0]  CHAINMODEr;
    reg        MDRr;

    reg [29:0] A_RF [registerfile_size-1:0];
    generate

        // Control registers
    if (INMODEREG == 1) initial INMODEr = 5'b0;
    if (INMODEREG == 1) begin always @(posedge CLK) if (RSTINMODE) INMODEr <= 5'b0; else if (CEINMODE) INMODEr <= INMODE; end
    else           always @* INMODEr <= INMODE;
    if (OPMODEREG == 1) initial OPMODEr = 9'b0;
    if (OPMODEREG == 1) begin always @(posedge CLK) if (RSTCTRL) OPMODEr <= 9'b0; else if (CECTRL) OPMODEr <= OPMODE; end
    else           always @* OPMODEr <= OPMODE;
    if (ALUMODEREG == 1) initial ALUMODEr = 4'b0;
    if (ALUMODEREG == 1) begin always @(posedge CLK) if (RSTALUMODE) ALUMODEr <= 4'b0; else if (CEALUMODE) ALUMODEr <= ALUMODE; end
    else           always @* ALUMODEr <= ALUMODE;
    if (CARRYINSELREG == 1) initial CARRYINSELr = 3'b0;
    if (CARRYINSELREG == 1) begin always @(posedge CLK) if (RSTCTRL) CARRYINSELr <= 3'b0; else if (CECTRL) CARRYINSELr <= CARRYINSEL; end
    else           always @* CARRYINSELr <= CARRYINSEL;

    if (MULTMODEREG == 1) initial MULTMODEr = 4'b0;
    if (MULTMODEREG == 1) begin always @(posedge CLK) if (RSTMULTMODE) MULTMODEr <= 4'b0; else if (CEMULTMODE) MULTMODEr <= MULTMODE; end
    else           always @* MULTMODEr <= MULTMODE;
    if (LPSREG == 1) initial LPSr = 0;
    if (LPSREG == 1) begin always @(posedge CLK) if (RSTLPS) LPSr <= 0; else if (CELPS) LPSr <= LPS; end
    else           always @* LPSr <= LPS;
    if (CHAINMODEREG == 1) initial CHAINMODEr = 0;
    if (CHAINMODEREG == 1) begin always @(posedge CLK) if (RSTCHAINMODE) CHAINMODEr <= 0; else if (CECHAINMODE) CHAINMODEr <= CHAINMODE; end
    else           always @* CHAINMODEr <= CHAINMODE;
    if (MDRREG == 1) initial MDRr = 0;
    if (MDRREG == 1) begin always @(posedge CLK) if (RSTMDR) MDRr <= 0; else if (CEMDR) MDRr <= MDR; end
    else           always @* MDRr <= MDR;


    // Configurable A register
    reg [29:0] A1;
    reg [29:0] A2;
    wire [29:0] Ar2;

        // Configurable A register
        always@(posedge CLK) begin
            if (RSTA)
                A1 <= 29'b0;
           else if (CEA1)
                case (LPSr)
                    1'b0: begin
                        A1[29:0] <= A_muxed[29:0];
                    end
                    1'b1: begin
                        A1[29:0] <= A1[29:0];
                    end
                endcase

        end

        always @ (posedge CLK) begin
            if (RSTA)
                A2 <= 29'b0;
            else if (CEA2)
                case (LPSr)
                    1'b0: begin
                        A2[29:0] <= A1[29:0];
                    end
                    1'b1: begin
                        A2[29:0] <= A2[29:0];
                    end
                endcase
        end

        assign Ar2 = (AREG == 2) ? A2[29:0] : A_muxed;


    // Configurable B register
    reg [26:0] B1;
    reg [26:0] B2;
    wire [26:0] Br2;

        // Configurable B register
        always@(posedge CLK) begin
            if (RSTB)
                B1 <= 27'b0;
           else if (CEB1)
                case (LPSr)
                    1'b0: begin
                        B1[17:0] <= B_muxed[17:0];
                    end
                    1'b1: begin
                        B1[26:0] <= {{B1[17:0]},{B_muxed[8:0]}};
                    end
                endcase

        end

        always @ (posedge CLK) begin
            if (RSTB)
                B2 <= 27'b0;
            else if (CEB2)
                case (LPSr)
                    1'b0: begin
                        B2[17:0] <= B1[17:0];
                    end
                    1'b1: begin
                        B2[26:0] <= {{B2[17:0]},{B_muxed[17:9]}};
                    end
                endcase
        end

        assign Br2 = (BREG == 2) ? B2[26:0] : B_muxed;


        // C and D registers
        if (CREG == 1) initial Cr = 48'b0;
        if (CREG == 1) begin always @(posedge CLK) if (RSTC) Cr <= 48'b0; else if (CEC) Cr <= C; end
        else           always @* Cr <= C;

        if (DREG == 1) initial Dr = 27'b0;
        if (DREG == 1) begin always @(posedge CLK) if (RSTD) Dr <= 27'b0; else if (CED) Dr <= D; end
        else           always @* Dr <= D;

    endgenerate

    // A and B cascade

    generate

       always @ (*) begin
        case (LPSr)
            1'b0: begin
                case (ACASCREG)
                    2'b00: begin
                        ACOUT = A_muxed;
                    end
                    2'b01: begin
                        ACOUT = A1[29:0];
                    end
                    2'b10: begin
                        ACOUT = A2[29:0];
                    end
                    2'b11: begin                // stream & broadcast
                        ACOUT = 30'bx;
                    end
                endcase
            end
            1'b1: begin
                ACOUT = {{A2[26:18]},{A1[26:18]}};
            end
        endcase
    end

       always @ (*) begin
        case (LPSr)
            1'b0: begin
                case (BCASCREG)
                    2'b00: begin
                        BCOUT = B_muxed;
                    end
                    2'b01: begin
                        BCOUT = B1[26:0];
                    end
                    2'b10: begin
                        BCOUT = B2[26:0];
                    end
                    2'b11: begin                // stream & broadcast
                        BCOUT = 27'bx;
                    end
                endcase
            end
            1'b1: begin
                BCOUT = {{B2[26:18]},{B1[26:18]}};
            end
        endcase
    end
    endgenerate


    // A/D input selection and pre-adder
    wire signed [26:0] Ar12_muxed = INMODEr[0] ? A1[26:0] : Ar2[26:0];
    wire signed [17:0] Br12_muxed = INMODEr[4] ? B1[17:0] : Br2[17:0];

    wire INMODEA = (PREADDINSEL == "A") ? INMODEr[1] : 0;
    wire INMODEB = (PREADDINSEL == "B") ? INMODEr[1] : 0;

    wire signed [26:0] A2A1 = ( ~INMODEA ) ? Ar12_muxed : 0;
    wire signed [17:0] B2B1 = ( ~INMODEB ) ? Br12_muxed : 0;

    wire signed [26:0] Dr_gated   = INMODEr[2] ? Dr : 27'b0;

    wire signed [26:0] PREADD_AB = (PREADDINSEL == "A") ? A2A1 : ({{9{B2B1[17]}},{B2B1}});
    wire signed [26:0] AD_result  = INMODEr[3] ? (Dr_gated - PREADD_AB) : (Dr_gated + PREADD_AB);

    reg  signed [26:0] AD_DATA;
    generate
        if (ADREG == 1) initial AD_DATA = 27'b0;
        if (ADREG == 1) begin always @(posedge CLK) if (RSTD) AD_DATA <= 27'b0; else if (CEAD) AD_DATA <= AD_result; end
        else            always @* AD_DATA <= AD_result;
    endgenerate

//multiply
    wire [53:0] A_MULT;         //new
    wire [53:0] B_MULT;         //new

    assign A_MULT[26:0] = (AMULTSEL=="A") ? A2A1: AD_DATA;
    assign A_MULT[53:27] = A2[26:0];

    assign B_MULT[17:0]  = (BMULTSEL == "B") ? B2B1 : AD_DATA[17:0];
    assign B_MULT[26:18] = B1[26:18];
    assign B_MULT[53:27] = B2;


    wire signed [44:0] M;

     MULT54X54
        MULT_inst(

         .A(A_MULT),
         .B(B_MULT),

         .Y(M)
    );

    wire signed [44:0] Mx = (CARRYINSEL == 3'b010) ? 45'bx : M;
    reg  signed [44:0] Mr = 45'b0;
    // Multiplier result register
    generate
        if (MREG == 1) begin always @(posedge CLK) if (RSTM) Mr <= 45'b0; else if (CEM) Mr <= Mx; end
        else           always @* Mr <= Mx;
    endgenerate
    wire signed [44:0] Mrx = (CARRYINSELr == 3'b010) ? 45'bx : Mr;


    // W, X, Y and Z ALU inputs
    reg signed [47:0] W, X, Y, Z;

    always @* begin
        // X multiplexer
        case (OPMODEr[1:0])
            2'b00: X = 48'b0;
            2'b01: begin X = $signed(Mrx);
`ifndef YOSYS
                if (OPMODEr[3:2] != 2'b01) $fatal(1, "OPMODEr[3:2] must be 2'b01 when OPMODEr[1:0] is 2'b01");
`endif
            end
            2'b10: begin X = P;
`ifndef YOSYS
                if (PREG != 1) $fatal(1, "PREG must be 1 when OPMODEr[1:0] is 2'b10");
`endif
            end
            2'b11: X = $signed({Ar2, Br2});
            default: X = 48'bx;
        endcase

        // Y multiplexer
        case (OPMODEr[3:2])
            2'b00: Y = 48'b0;
           2'b01: begin Y = 48'b0; // FIXME: more accurate partial product modelling?
//             2'b01: begin Y = $signed(Mrx);
`ifndef YOSYS
                if (OPMODEr[1:0] != 2'b01) $fatal(1, "OPMODEr[1:0] must be 2'b01 when OPMODEr[3:2] is 2'b01");
`endif
            end
            2'b10: Y = {48{1'b1}};
            2'b11: Y = Cr;
            default: Y = 48'bx;
        endcase

        // Z multiplexer
        case (OPMODEr[6:4])
            3'b000: Z = 48'b0;
            3'b001: Z = PCIN;
            3'b010: begin Z = P;
`ifndef YOSYS
                if (PREG != 1) $fatal(1, "PREG must be 1 when OPMODEr[6:4] i0s 3'b010");
`endif
            end
            3'b011: Z = Cr;
            3'b100: begin Z = P;
`ifndef YOSYS
                if (PREG != 1) $fatal(1, "PREG must be 1 when OPMODEr[6:4] is 3'b100");
                if (OPMODEr[3:0] != 4'b1000) $fatal(1, "OPMODEr[3:0] must be 4'b1000 when OPMODEr[6:4] i0s 3'b100");
`endif
            end
            3'b101: Z = $signed(PCIN[47:17]);
            3'b110: begin Z = $signed(P[47:17]);
`ifndef YOSYS
                if (PREG != 1) $fatal(1, "PREG must be 1 when OPMODEr[6:4] i0s 3'b110");
`endif
           end
            default: Z = 48'bx;
        endcase

        // W multiplexer
        case (OPMODEr[8:7])
            2'b00: W = 48'b0;

            2'b01: begin W = P;
`ifndef YOSYS
                if (PREG != 1) $fatal(1, "PREG must be 1 when OPMODEr[8:7] i0s 2'b01");
`endif
            end
            2'b10: W = RND;
            2'b11: W = Cr;
            default: W = 48'bx;
        endcase

    end

    // Carry in
    wire A24_xnor_B17d = A_MULT[26] ~^ B_MULT[17];
    reg CARRYINr, A24_xnor_B17;
    generate
        if (CARRYINREG == 1) initial CARRYINr = 1'b0;
        if (CARRYINREG == 1) begin always @(posedge CLK) if (RSTALLCARRYIN) CARRYINr <= 1'b0; else if (CECARRYIN) CARRYINr <= CARRYIN; end
        else                 always @* CARRYINr = CARRYIN;

        if (MREG == 1) initial A24_xnor_B17 = 1'b0;
        if (MREG == 1) begin always @(posedge CLK) if (RSTALLCARRYIN) A24_xnor_B17 <= 1'b0; else if (CEM) A24_xnor_B17 <= A24_xnor_B17d; end
        else                 always @* A24_xnor_B17 = A24_xnor_B17d;
    endgenerate

    reg cin_muxed;

    always @(*) begin
        case (CARRYINSELr)
            3'b000: cin_muxed = CARRYINr;
            3'b001: cin_muxed = ~PCIN[47];
            3'b010: cin_muxed = CARRYCASCIN;
            3'b011: cin_muxed = PCIN[47];
            3'b100: cin_muxed = CARRYCASCOUT;
            3'b101: cin_muxed = ~P[47];
            3'b110: cin_muxed = A24_xnor_B17;
            3'b111: cin_muxed = P[47];
            default: cin_muxed = 1'bx;
        endcase
    end

    wire alu_cin = (ALUMODEr[3] || ALUMODEr[2]) ? 1'b0 : cin_muxed; //[3:2]为00时，才是加法/减法

    // ALU core
    wire [47:0] Z_muxinv = ALUMODEr[0] ? ~Z : Z;//为1取反 减法

    //按位计算
    //S = A ^ B ^ CIN
    //COUT = AB + BCIN + ACIN
     wire [47:0] S = X ^ Y ^ Z_muxinv;
        wire [47:0] COUT = (X & Y) | (X & Z_muxinv) | (Y & Z_muxinv);

        wire [47:0] S1 = S ^ COUT ^ W;
        wire [47:0] COUT1 = (S & COUT) | (S & W) | (COUT & W);

        wire [47:0] xor_xyz =(ALUMODEr[3] || ALUMODEr[2])? S : S1;
        wire [47:0] maj_xyz =(ALUMODEr[3] || ALUMODEr[2])? COUT : COUT1;

        wire [47:0] xor_xyz_muxed = ALUMODEr[3] ? maj_xyz : xor_xyz;
        wire [47:0] maj_xyz_gated = ALUMODEr[2] ? 48'b0 :  maj_xyz;

        wire [48:0] maj_xyz_simd_gated;
        wire [7:0] int_carry_in, int_carry_out, ext_carry_out;
        wire [47:0] alu_sum;
        assign int_carry_in[0] = 1'b0;
        wire [7:0] carryout_reset;

        generate
                  if (USE_SIMD == "2X2") begin
            assign maj_xyz_simd_gated = {
                    maj_xyz_gated[47:42],
                    1'b0, maj_xyz_gated[40:36],
                    1'b0, maj_xyz_gated[34:30],
                    1'b0, maj_xyz_gated[28:24],
                    1'b0, maj_xyz_gated[22:18],
                    1'b0, maj_xyz_gated[16:12],
                    1'b0, maj_xyz_gated[10:6],
                    1'b0, maj_xyz_gated[4:0],
                    alu_cin
                };
            assign int_carry_in[7:1] = 7'b000_0000;
            assign ext_carry_out = {
                    int_carry_out[7],
                    maj_xyz_gated[41] ^ int_carry_out[6],
                    maj_xyz_gated[35] ^ int_carry_out[5],
                    maj_xyz_gated[29] ^ int_carry_out[4],
                    maj_xyz_gated[23] ^ int_carry_out[3],
                    maj_xyz_gated[17] ^ int_carry_out[2],
                    maj_xyz_gated[11] ^ int_carry_out[1],
                    maj_xyz_gated[5] ^ int_carry_out[0]
                };
            assign carryout_reset = 8'b0000_0000;
        end else if (USE_SIMD == "4X4") begin
                 assign maj_xyz_simd_gated = {
                         maj_xyz_gated[47:36],
                         1'b0, maj_xyz_gated[34:24],
                         1'b0, maj_xyz_gated[22:12],
                         1'b0, maj_xyz_gated[10:0],
                         alu_cin
                     };
                 assign int_carry_in[7:1] = {int_carry_out[6], 1'b0, int_carry_out[4], 1'b0, int_carry_out[2], 1'b0, int_carry_out[0]};
                             assign ext_carry_out = {
                                     int_carry_out[7],
                                     1'bx,
                                     maj_xyz_gated[35] ^ int_carry_out[5],
                                     1'bx,
                                     maj_xyz_gated[23] ^ int_carry_out[3],
                                     1'bx,
                                     maj_xyz_gated[11] ^ int_carry_out[1],
                                     1'bx
                                 };
                             assign carryout_reset = 8'b0x0x_0x0x;
             end else if (USE_SIMD == "9X9") begin
                 assign maj_xyz_simd_gated = {
                         maj_xyz_gated[47:24],
                         1'b0, maj_xyz_gated[22:0],
                         alu_cin
                     };
                 assign int_carry_in[7:1] = {int_carry_out[6:4], 1'b0, int_carry_out[2:0]};
                 assign ext_carry_out = {
                         int_carry_out[7],
                         3'bx,
                         maj_xyz_gated[23] ^ int_carry_out[3],
                         3'bx
                     };
                 assign carryout_reset = 8'b0xxx_0xxx;
             end else begin
                 assign maj_xyz_simd_gated = {maj_xyz_gated, alu_cin};
                 assign int_carry_in[7:1] = int_carry_out[6:0];
                 assign ext_carry_out = {
                         int_carry_out[7],
                         7'bxxx
                     };
                 assign carryout_reset = 8'b0xxx_xxxx;
             end

        genvar i;
        for (i = 0; i < 8; i = i + 1)
            assign {int_carry_out[i], alu_sum[i*6 +: 6]} = {1'b0, maj_xyz_simd_gated[i*6 +: ((i == 7) ? 7 : 6)]} + xor_xyz_muxed[i*6 +: 6] + int_carry_in[i];


        endgenerate

        wire signed [47:0] Pd = ALUMODEr[1] ? ~alu_sum : alu_sum; //为1取反 减法
        wire [7:0] CARRYOUTd = (OPMODEr[3:0] == 4'b0101 || ALUMODEr[3:2] != 2'b00) ? 8'bxxxx_xxxx :
                               ((ALUMODEr[0] & ALUMODEr[1]) ? ~ext_carry_out : ext_carry_out);
        wire CARRYCASCOUTd = ext_carry_out[7];
        wire MULTSIGNOUTd = Mrx[44];

    generate
        if (PREG == 1) begin
            initial P = 48'b0;
            initial CARRYOUT = carryout_reset;
            initial CARRYCASCOUT = 1'b0;
            initial MULTSIGNOUT = 1'b0;
            always @(posedge CLK)
                if (RSTP) begin
                    P <= 48'b0;
                    CARRYOUT <= carryout_reset;
                    CARRYCASCOUT <= 1'b0;
                    MULTSIGNOUT <= 1'b0;
                end else if (CEP) begin
                    P <= Pd;
                    CARRYOUT <= CARRYOUTd;
                    CARRYCASCOUT <= CARRYCASCOUTd;
                    MULTSIGNOUT <= MULTSIGNOUTd;
                end
        end else begin
            always @* begin
                P = Pd;
                CARRYOUT = CARRYOUTd;
                CARRYCASCOUT = CARRYCASCOUTd;
                MULTSIGNOUT = MULTSIGNOUTd;
            end
        end
    endgenerate

    assign PCOUT = P;

    generate
        wire PATTERNDETECTd, PATTERNBDETECTd;

        if (USE_PATTERN_DETECT == "PATDET") begin
            // TODO: Support SEL_PATTERN != "PATTERN" and SEL_MASK != "MASK
            assign PATTERNDETECTd = &(~(Pd ^ PATTERN) | MASK);
            assign PATTERNBDETECTd = &((Pd ^ PATTERN) | MASK);
        end else begin
            assign PATTERNDETECTd = 1'b1;
            assign PATTERNBDETECTd = 1'b1;
        end

        if (PREG == 1) begin
            reg PATTERNDETECTPAST, PATTERNBDETECTPAST;
            initial PATTERNDETECT = 1'b0;
            initial PATTERNBDETECT = 1'b0;
            initial PATTERNDETECTPAST = 1'b0;
            initial PATTERNBDETECTPAST = 1'b0;
            always @(posedge CLK)
                if (RSTP) begin
                    PATTERNDETECT <= 1'b0;
                    PATTERNBDETECT <= 1'b0;
                    PATTERNDETECTPAST <= 1'b0;
                    PATTERNBDETECTPAST <= 1'b0;
                end else if (CEP) begin
                    PATTERNDETECT <= PATTERNDETECTd;
                    PATTERNBDETECT <= PATTERNBDETECTd;
                    PATTERNDETECTPAST <= PATTERNDETECT;
                    PATTERNBDETECTPAST <= PATTERNBDETECT;
                end
            assign OVERFLOW = &{PATTERNDETECTPAST, ~PATTERNBDETECT, ~PATTERNDETECT};
            assign UNDERFLOW = &{PATTERNBDETECTPAST, ~PATTERNBDETECT, ~PATTERNDETECT};
        end else begin
            always @* begin
                PATTERNDETECT = PATTERNDETECTd;
                PATTERNBDETECT = PATTERNBDETECTd;
            end
            assign OVERFLOW = 1'bx, UNDERFLOW = 1'bx;
        end
    endgenerate

//wide xor
    wire XOR12A;
    wire XOR12B;
    wire XOR12C;
    wire XOR12D;
    wire XOR12E;
    wire XOR12F;
    wire XOR12G;
    wire XOR12H;

    wire XOR24A;
    wire XOR24B;
    wire XOR24C;
    wire XOR24D;

    wire XOR48A;
    wire XOR48B;

    wire XOR96;


    assign XOR12A = ^S[5:0];
    assign XOR12B = ^S[11:6];
    assign XOR12C = ^S[17:12];
    assign XOR12D = ^S[23:18];
    assign XOR12E = ^S[29:24];
    assign XOR12F = ^S[35:30];
    assign XOR12G = ^S[41:36];
    assign XOR12H = ^S[47:42];


    assign XOR24A = XOR12A ^ XOR12B;
    assign XOR24B = XOR12C ^ XOR12D;
    assign XOR24C = XOR12E ^ XOR12F;
    assign XOR24D = XOR12G ^ XOR12H;

    assign XOR48A = XOR24A ^ XOR24B;
    assign XOR48B = XOR24C ^ XOR24D;

    assign XOR96 = XOR48A ^ XOR48B;

    assign XOROUT[0] = (XORSIMD)    ? XOR24A    : XOR12A;
    assign XOROUT[1] = (XORSIMD)    ? XOR48A    : XOR12B;
    assign XOROUT[2] = (XORSIMD)    ? XOR24B    : XOR12C;
    assign XOROUT[3] = (XORSIMD)    ? XOR96     : XOR12D;
    assign XOROUT[4] = (XORSIMD)    ? XOR24C    : XOR12E;
    assign XOROUT[5] = (XORSIMD)    ? XOR48B    : XOR12F;
    assign XOROUT[6] = (XORSIMD)    ? XOR24D    : XOR12G;
    assign XOROUT[7] = XOR12H;


endmodule

module pirdsp3(
        // Inputs
        CLK,

         A,
         B,
         C,
         D,

         RF_load,
         A_addr,
//         ACOUT_addr,

         OPMODE,
         ALUMODE,
         CARRYINSEL,

         CARRYIN,
         INMODE,
         MULTMODE,          // new
         LPS,               // Please change it to 1 bit from 2 bits     new
         CHAINMODE,         // new
         MDR,                               // new

         CEB1,
         CEB2,
         CEA1,
         CEA2,
         CEAD,
         CED,
         CEC,
         CEP,
         CEM,
         CECARRYIN,
         CEALUMODE,
         CECTRL,
         CEINMODE,
         CEMULTMODE,                // new
         CELPS,         // new
         CECHAINMODE,               // new
         CEMDR,                         // new

         RSTCTRL,
         RSTALUMODE,
         RSTD,
         RSTC,
         RSTB,
         RSTA,
         RSTP,
         RSTM,
         RSTALLCARRYIN,
         RSTINMODE,
         RSTMULTMODE,           // new
         RSTLPS,    // new
         RSTCHAINMODE,      // new
         RSTMDR,                    // new

         ACIN,
         BCIN,              // modified
         PCIN,
         CARRYCASCIN,
        //input MULTSIGNIN,             //  <------------------ Question: sued for 96 MAC --> to forward carry bit from a ALU to next ALU as we use 4 bit adders.
        // End of Inputs


        // Outputs
         ACOUT,
         BCOUT,         // modified
         PCOUT,

         P,
  //       P_SIMD_carry,  // NEW (DoM : Depends on Multiplier)

         CARRYOUT,
         CARRYCASCOUT,
         MULTSIGNOUT,

         PATTERNDETECT,
         PATTERNBDETECT,

         OVERFLOW,
         UNDERFLOW,

         XOROUT
        // End of Outputs

//       configuration_input,
//       configuration_enable
    );

    parameter registerfile_size = 8;
    parameter registerfile_size_log = $clog2(registerfile_size);

    parameter integer ACASCREG = 1;
    parameter integer ADREG = 1;
    parameter integer ALUMODEREG = 1;
    parameter AMULTSEL = "A"; //NEW
    parameter integer AREG = 1;
    parameter AUTORESET_PATDET = "NO_RESET";
    parameter AUTORESET_PRIORITY = "RESET"; //NEW
    parameter A_INPUT = "DIRECT";
    parameter integer BCASCREG = 1;
    parameter BMULTSEL = "B"; //NEW
    parameter integer BREG = 1;
    parameter B_INPUT = "DIRECT";
    parameter integer CARRYINREG = 1;
    parameter integer CARRYINSELREG = 1;
    parameter integer CREG = 1;
    parameter integer DREG = 1;
    parameter integer INMODEREG = 1;
    parameter [3:0] IS_ALUMODE_INVERTED = 4'b0;
    parameter [0:0] IS_CARRYIN_INVERTED = 1'b0;
    parameter [0:0] IS_CLK_INVERTED = 1'b0;
    parameter [4:0] IS_INMODE_INVERTED = 5'b0;
    parameter [8:0] IS_OPMODE_INVERTED = 9'b0;
    //NEW
    parameter [0:0] IS_RSTALLCARRYIN_INVERTED = 1'b0;
    parameter [0:0] IS_RSTALUMODE_INVERTED = 1'b0;
    parameter [0:0] IS_RSTA_INVERTED = 1'b0;
    parameter [0:0] IS_RSTB_INVERTED = 1'b0;
    parameter [0:0] IS_RSTCTRL_INVERTED = 1'b0;
    parameter [0:0] IS_RSTC_INVERTED = 1'b0;
    parameter [0:0] IS_RSTD_INVERTED = 1'b0;
    parameter [0:0] IS_RSTINMODE_INVERTED = 1'b0;
    parameter [0:0] IS_RSTM_INVERTED = 1'b0;
    parameter [0:0] IS_RSTP_INVERTED = 1'b0;
  //NEW
    parameter integer MULTMODEREG = 1;
    parameter [3:0] IS_MULTMODE_INVERTED = 1'b0;
    parameter IS_RSTMULTMODE_INVERTED = 1'b0;

    parameter integer LPSREG = 1;
    parameter IS_LPS_INVERTED = 1'b0;
    parameter IS_RSTLPS_INVERTED = 1'b0;

    parameter integer CHAINMODEREG = 1;
    parameter [1:0] IS_CHAINMODE_INVERTED = 1'b0;
    parameter IS_RSTCHAINMODE_INVERTED = 1'b0;

    parameter integer MDRREG = 1;
    parameter IS_MDR_INVERTED = 1'b0;
    parameter IS_RSTMDR_INVERTED = 1'b0;

  //NEW
    parameter [47:0] MASK = 48'h3FFFFFFFFFFF;
    parameter integer MREG = 1;
    parameter integer OPMODEREG = 1;
    parameter [47:0] PATTERN = 48'h000000000000;
    parameter PREADDINSEL = "A"; //NEW
    parameter integer PREG = 1;
    parameter [47:0] RND = 48'h000000000000; //NEW
    parameter SEL_MASK = "MASK";
    parameter SEL_PATTERN = "PATTERN";
//      parameter USE_DPORT = "FALSE";  //NONE
    parameter USE_MULT = "MULTIPLY";
    parameter USE_PATTERN_DETECT = "NO_PATDET";
    parameter USE_SIMD = "ONE48";
    parameter USE_WIDEXOR = "FALSE"; //NEW
    parameter XORSIMD = "XOR24_48_96";  //NEW

        input CLK;

        input [29:0] A;
        input [26:0] B;
        input [47:0] C;
        input [26:0] D;

        input RF_load;
        input [registerfile_size_log-1:0] A_addr;
   //    input [registerfile_size_log-1:0] ACOUT_addr;


        input [8:0] OPMODE;
        input [3:0] ALUMODE;
        input [2:0] CARRYINSEL;

        input CARRYIN;
        input [4:0] INMODE;
        input [3:0] MULTMODE;           // new
        input LPS;                              // new
        input [1:0] CHAINMODE;          // new
        input MDR;                              // new

        input CEB1;
        input CEB2;
        input CEA1;
        input CEA2;
        input CEAD;
        input CED;
        input CEC;
        input CEP;
        input CEM;
        input CECARRYIN;
        input CEALUMODE;
        input CECTRL;
        input CEINMODE;
        input CEMULTMODE;               // new
        input CELPS;            // new
        input CECHAINMODE;              // new
        input CEMDR;                            // new

        input RSTCTRL;
        input RSTALUMODE;
        input RSTD;
        input RSTC;
        input RSTB;
        input RSTA;
        input RSTP;
        input RSTM;
        input RSTALLCARRYIN;
        input RSTINMODE;
        input RSTMULTMODE;          // new
        input RSTLPS;   // new
        input RSTCHAINMODE;     // new
        input RSTMDR;                   // new

        input [29:0] ACIN;
        input [26:0] BCIN;              // modified
        input [47:0] PCIN;
        input CARRYCASCIN;
        //input MULTSIGNIN;             //  <------------------ Question: sued for 96 MAC --> to forward carry bit from a ALU to next ALU as we use 4 bit adders.
        // End of Inputs


        // Outputs
        output reg [29:0] ACOUT;
        output reg [26:0] BCOUT;            // modified
        output [47:0] PCOUT;

        output reg [47:0] P;
    //  output [15:0] P_SIMD_carry; // NEW (DoM : Depends on Multiplier)

        output reg [7:0] CARRYOUT;
        output reg CARRYCASCOUT;
        output reg MULTSIGNOUT;

        output reg PATTERNDETECT;
        output reg PATTERNBDETECT;

        output OVERFLOW;
        output UNDERFLOW;

        output [7:0] XOROUT;


    initial begin
`ifndef YOSYS
        if (AUTORESET_PATDET != "NO_RESET") $fatal(1, "Unsupported AUTORESET_PATDET value");
        if (SEL_MASK != "MASK")     $fatal(1, "Unsupported SEL_MASK value");
        if (SEL_PATTERN != "PATTERN") $fatal(1, "Unsupported SEL_PATTERN value");
        if (USE_SIMD != "2X2" && USE_SIMD != "4X4" && USE_SIMD != "9X9" && USE_SIMD != "27X18")    $fatal(1, "Unsupported USE_SIMD value");
        if (IS_ALUMODE_INVERTED != 4'b0) $fatal(1, "Unsupported IS_ALUMODE_INVERTED value");
        if (IS_CARRYIN_INVERTED != 1'b0) $fatal(1, "Unsupported IS_CARRYIN_INVERTED value");
        if (IS_CLK_INVERTED != 1'b0) $fatal(1, "Unsupported IS_CLK_INVERTED value");
        if (IS_INMODE_INVERTED != 5'b0) $fatal(1, "Unsupported IS_INMODE_INVERTED value");
        if (IS_OPMODE_INVERTED != 9'b0) $fatal(1, "Unsupported IS_OPMODE_INVERTED value");
`endif
    end

    wire signed [29:0] A_muxed;
    wire signed [26:0] B_muxed;

    generate
        if (A_INPUT == "CASCADE") assign A_muxed = ACIN;
        else assign A_muxed = A;

        if (B_INPUT == "CASCADE") assign B_muxed = BCIN;
        else assign B_muxed = {{9'b0_0000_0000},{B}};
    endgenerate

    //reg signed [29:0] Ar1, Ar2;
    reg signed [26:0] Dr;
   // reg signed [17:0] Br1, Br2;
    reg signed [47:0] Cr;
    reg        [4:0]  INMODEr;
    reg        [8:0]  OPMODEr;
    reg        [3:0]  ALUMODEr;
    reg        [2:0]  CARRYINSELr;
    reg        [3:0]  MULTMODEr;
    reg        LPSr;
    reg        [1:0]  CHAINMODEr;
    reg        MDRr;


    generate

        // Control registers
    if (INMODEREG == 1) initial INMODEr = 5'b0;
    if (INMODEREG == 1) begin always @(posedge CLK) if (RSTINMODE) INMODEr <= 5'b0; else if (CEINMODE) INMODEr <= INMODE; end
    else           always @* INMODEr <= INMODE;
    if (OPMODEREG == 1) initial OPMODEr = 9'b0;
    if (OPMODEREG == 1) begin always @(posedge CLK) if (RSTCTRL) OPMODEr <= 9'b0; else if (CECTRL) OPMODEr <= OPMODE; end
    else           always @* OPMODEr <= OPMODE;
    if (ALUMODEREG == 1) initial ALUMODEr = 4'b0;
    if (ALUMODEREG == 1) begin always @(posedge CLK) if (RSTALUMODE) ALUMODEr <= 4'b0; else if (CEALUMODE) ALUMODEr <= ALUMODE; end
    else           always @* ALUMODEr <= ALUMODE;
    if (CARRYINSELREG == 1) initial CARRYINSELr = 3'b0;
    if (CARRYINSELREG == 1) begin always @(posedge CLK) if (RSTCTRL) CARRYINSELr <= 3'b0; else if (CECTRL) CARRYINSELr <= CARRYINSEL; end
    else           always @* CARRYINSELr <= CARRYINSEL;

    if (MULTMODEREG == 1) initial MULTMODEr = 4'b0;
    if (MULTMODEREG == 1) begin always @(posedge CLK) if (RSTMULTMODE) MULTMODEr <= 4'b0; else if (CEMULTMODE) MULTMODEr <= MULTMODE; end
    else           always @* MULTMODEr <= MULTMODE;
    if (LPSREG == 1) initial LPSr = 0;
    if (LPSREG == 1) begin always @(posedge CLK) if (RSTLPS) LPSr <= 0; else if (CELPS) LPSr <= LPS; end
    else           always @* LPSr <= LPS;
    if (CHAINMODEREG == 1) initial CHAINMODEr = 0;
    if (CHAINMODEREG == 1) begin always @(posedge CLK) if (RSTCHAINMODE) CHAINMODEr <= 0; else if (CECHAINMODE) CHAINMODEr <= CHAINMODE; end
    else           always @* CHAINMODEr <= CHAINMODE;
    if (MDRREG == 1) initial MDRr = 0;
    if (MDRREG == 1) begin always @(posedge CLK) if (RSTMDR) MDRr <= 0; else if (CEMDR) MDRr <= MDR; end
    else           always @* MDRr <= MDR;


    // Configurable A register
    reg [29:0] A_RF [registerfile_size-1:0];
    reg [29:0] A1;
    reg [29:0] A2;
    wire [29:0] Ar2;

    integer j;
    // RF as a shift register
    always@(posedge CLK) begin
        if (RSTA) begin
            for ( j = 0; j < registerfile_size; j = j + 1) begin
                A_RF[j] <= 30'b0;
            end
        end
        else begin
            if (CEA1 | RF_load) begin
                A_RF[0] <= A_muxed;
            end
            if (CEA2 | RF_load) begin
                A_RF[1] <= A_RF[0];
            end
            if (RF_load) begin
                for (j = 2; j < registerfile_size; j = j + 1) begin
                    A_RF[j] <= A_RF[j-1];
                end
            end
        end
    end

    reg [26:0] a_mult_temp_0;
    reg [26:0] a_mult_temp_1;
    always @ (*) begin
        if (MDRr) begin
            a_mult_temp_0 = A_RF[(A_addr < 1)][26:0];
            a_mult_temp_1 = A_RF[(A_addr < 1) + 1][26:0];
        end
        else begin
            if (A_addr == 0) begin
                a_mult_temp_0 = A_muxed[26:0];
                a_mult_temp_1 = 27'bx;
            end
            else begin
                a_mult_temp_0 = A_RF[A_addr][26:0];
                a_mult_temp_1 = 27'bx;
            end
        end
    end

    // Configurable B register
    reg [26:0] B1;
    reg [26:0] B2;
    wire [26:0] Br2;

        // Configurable B register
        always@(posedge CLK) begin
            if (RSTB)
                B1 <= 27'b0;
           else if (CEB1)
                case (LPSr)
                    1'b0: begin
                        B1[17:0] <= B_muxed[17:0];
                    end
                    1'b1: begin
                        B1[26:0] <= {{B1[17:0]},{B_muxed[8:0]}};
                    end
                endcase

        end

        always @ (posedge CLK) begin
            if (RSTB)
                B2 <= 27'b0;
            else if (CEB2)
                case (LPSr)
                    1'b0: begin
                        B2[17:0] <= B1[17:0];
                    end
                    1'b1: begin
                        B2[26:0] <= {{B2[17:0]},{B_muxed[17:9]}};
                    end
                endcase
        end

        assign Br2 = (BREG == 2) ? B2[26:0] : B_muxed;


        // C and D registers
        if (CREG == 1) initial Cr = 48'b0;
        if (CREG == 1) begin always @(posedge CLK) if (RSTC) Cr <= 48'b0; else if (CEC) Cr <= C; end
        else           always @* Cr <= C;

        if (DREG == 1) initial Dr = 27'b0;
        if (DREG == 1) begin always @(posedge CLK) if (RSTD) Dr <= 27'b0; else if (CED) Dr <= D; end
        else           always @* Dr <= D;

    endgenerate

    // A and B cascade

    generate

       always @ (*) begin
        case (LPSr)
            1'b0: begin
                case (ACASCREG)
                    2'b00: begin
                        ACOUT = A_muxed;
                    end
                    2'b01: begin
                        ACOUT = A_RF[0];
                    end
                    2'b10: begin
                        ACOUT = A_RF[1];
                    end
                    2'b11: begin                // stream & broadcast
                        ACOUT = 30'bx;
                    end
                endcase
            end
            1'b1: begin
                ACOUT = {{A2[26:18]},{A1[26:18]}};
            end
        endcase
    end

       always @ (*) begin
        case (LPSr)
            1'b0: begin
                case (BCASCREG)
                    2'b00: begin
                        BCOUT = B_muxed;
                    end
                    2'b01: begin
                        BCOUT = B1[26:0];
                    end
                    2'b10: begin
                        BCOUT = B2[26:0];
                    end
                    2'b11: begin                // stream & broadcast
                        BCOUT = 27'bx;
                    end
                endcase
            end
            1'b1: begin
                BCOUT = {{B2[26:18]},{B1[26:18]}};
            end
        endcase
    end
    endgenerate


    // A/D input selection and pre-adder
  //  wire signed [26:0] Ar12_muxed = INMODEr[0] ? A1[26:0] : Ar2[26:0];
    wire signed [17:0] Br12_muxed = INMODEr[4] ? B1[17:0] : Br2[17:0];

    wire INMODEA = (PREADDINSEL == "A") ? INMODEr[1] : 0;
    wire INMODEB = (PREADDINSEL == "B") ? INMODEr[1] : 0;

   // wire signed [26:0] A2A1 = ( ~INMODEA ) ? Ar12_muxed : 0;
    wire signed [26:0] A2A1 = ( ~INMODEA ) ? a_mult_temp_0 : 0;
    wire signed [17:0] B2B1 = ( ~INMODEB ) ? Br12_muxed : 0;

    wire signed [26:0] Dr_gated   = INMODEr[2] ? Dr : 27'b0;

    wire signed [26:0] PREADD_AB = (PREADDINSEL == "A") ? A2A1 : ({{9{B2B1[17]}},{B2B1}});
    wire signed [26:0] AD_result  = INMODEr[3] ? (Dr_gated - PREADD_AB) : (Dr_gated + PREADD_AB);

    reg  signed [26:0] AD_DATA;
    generate
        if (ADREG == 1) initial AD_DATA = 27'b0;
        if (ADREG == 1) begin always @(posedge CLK) if (RSTD) AD_DATA <= 27'b0; else if (CEAD) AD_DATA <= AD_result; end
        else            always @* AD_DATA <= AD_result;
    endgenerate

//multiply
    wire [53:0] A_MULT;         //new
    wire [53:0] B_MULT;         //new

    assign A_MULT[26:0] = (AMULTSEL=="A") ? A2A1: AD_DATA;
    assign A_MULT[53:27] = a_mult_temp_1;

    assign B_MULT[17:0]  = (BMULTSEL == "B") ? B2B1 : AD_DATA[17:0];
    assign B_MULT[26:18] = B1[26:18];
    assign B_MULT[53:27] = B2;


    wire signed [44:0] M;

     MULT54X54
        MULT_inst(

         .A(A_MULT),
         .B(B_MULT),

         .Y(M)
    );

    wire signed [44:0] Mx = (CARRYINSEL == 3'b010) ? 45'bx : M;
    reg  signed [44:0] Mr = 45'b0;
    // Multiplier result register
    generate
        if (MREG == 1) begin always @(posedge CLK) if (RSTM) Mr <= 45'b0; else if (CEM) Mr <= Mx; end
        else           always @* Mr <= Mx;
    endgenerate
    wire signed [44:0] Mrx = (CARRYINSELr == 3'b010) ? 45'bx : Mr;


    // W, X, Y and Z ALU inputs
    reg signed [47:0] W, X, Y, Z;

    always @* begin
        // X multiplexer
        case (OPMODEr[1:0])
            2'b00: X = 48'b0;
            2'b01: begin X = $signed(Mrx);
`ifndef YOSYS
                if (OPMODEr[3:2] != 2'b01) $fatal(1, "OPMODEr[3:2] must be 2'b01 when OPMODEr[1:0] is 2'b01");
`endif
            end
            2'b10: begin X = P;
`ifndef YOSYS
                if (PREG != 1) $fatal(1, "PREG must be 1 when OPMODEr[1:0] is 2'b10");
`endif
            end
            2'b11: X = $signed({Ar2, Br2});
            default: X = 48'bx;
        endcase

        // Y multiplexer
        case (OPMODEr[3:2])
            2'b00: Y = 48'b0;
           2'b01: begin Y = 48'b0; // FIXME: more accurate partial product modelling?
//             2'b01: begin Y = $signed(Mrx);
`ifndef YOSYS
                if (OPMODEr[1:0] != 2'b01) $fatal(1, "OPMODEr[1:0] must be 2'b01 when OPMODEr[3:2] is 2'b01");
`endif
            end
            2'b10: Y = {48{1'b1}};
            2'b11: Y = Cr;
            default: Y = 48'bx;
        endcase

        // Z multiplexer
        case (OPMODEr[6:4])
            3'b000: Z = 48'b0;
            3'b001: Z = PCIN;
            3'b010: begin Z = P;
`ifndef YOSYS
                if (PREG != 1) $fatal(1, "PREG must be 1 when OPMODEr[6:4] i0s 3'b010");
`endif
            end
            3'b011: Z = Cr;
            3'b100: begin Z = P;
`ifndef YOSYS
                if (PREG != 1) $fatal(1, "PREG must be 1 when OPMODEr[6:4] is 3'b100");
                if (OPMODEr[3:0] != 4'b1000) $fatal(1, "OPMODEr[3:0] must be 4'b1000 when OPMODEr[6:4] i0s 3'b100");
`endif
            end
            3'b101: Z = $signed(PCIN[47:17]);
            3'b110: begin Z = $signed(P[47:17]);
`ifndef YOSYS
                if (PREG != 1) $fatal(1, "PREG must be 1 when OPMODEr[6:4] i0s 3'b110");
`endif
           end
            default: Z = 48'bx;
        endcase

        // W multiplexer
        case (OPMODEr[8:7])
            2'b00: W = 48'b0;

            2'b01: begin W = P;
`ifndef YOSYS
                if (PREG != 1) $fatal(1, "PREG must be 1 when OPMODEr[8:7] i0s 2'b01");
`endif
            end
            2'b10: W = RND;
            2'b11: W = Cr;
            default: W = 48'bx;
        endcase

    end

    // Carry in
    wire A24_xnor_B17d = A_MULT[26] ~^ B_MULT[17];
    reg CARRYINr, A24_xnor_B17;
    generate
        if (CARRYINREG == 1) initial CARRYINr = 1'b0;
        if (CARRYINREG == 1) begin always @(posedge CLK) if (RSTALLCARRYIN) CARRYINr <= 1'b0; else if (CECARRYIN) CARRYINr <= CARRYIN; end
        else                 always @* CARRYINr = CARRYIN;

        if (MREG == 1) initial A24_xnor_B17 = 1'b0;
        if (MREG == 1) begin always @(posedge CLK) if (RSTALLCARRYIN) A24_xnor_B17 <= 1'b0; else if (CEM) A24_xnor_B17 <= A24_xnor_B17d; end
        else                 always @* A24_xnor_B17 = A24_xnor_B17d;
    endgenerate

    reg cin_muxed;

    always @(*) begin
        case (CARRYINSELr)
            3'b000: cin_muxed = CARRYINr;
            3'b001: cin_muxed = ~PCIN[47];
            3'b010: cin_muxed = CARRYCASCIN;
            3'b011: cin_muxed = PCIN[47];
            3'b100: cin_muxed = CARRYCASCOUT;
            3'b101: cin_muxed = ~P[47];
            3'b110: cin_muxed = A24_xnor_B17;
            3'b111: cin_muxed = P[47];
            default: cin_muxed = 1'bx;
        endcase
    end

    wire alu_cin = (ALUMODEr[3] || ALUMODEr[2]) ? 1'b0 : cin_muxed; //[3:2]为00时，才是加法/减法

    // ALU core
    wire [47:0] Z_muxinv = ALUMODEr[0] ? ~Z : Z;//为1取反 减法

    //按位计算
    //S = A ^ B ^ CIN
    //COUT = AB + BCIN + ACIN
     wire [47:0] S = X ^ Y ^ Z_muxinv;
        wire [47:0] COUT = (X & Y) | (X & Z_muxinv) | (Y & Z_muxinv);

        wire [47:0] S1 = S ^ COUT ^ W;
        wire [47:0] COUT1 = (S & COUT) | (S & W) | (COUT & W);

        wire [47:0] xor_xyz =(ALUMODEr[3] || ALUMODEr[2])? S : S1;
        wire [47:0] maj_xyz =(ALUMODEr[3] || ALUMODEr[2])? COUT : COUT1;

        wire [47:0] xor_xyz_muxed = ALUMODEr[3] ? maj_xyz : xor_xyz;
        wire [47:0] maj_xyz_gated = ALUMODEr[2] ? 48'b0 :  maj_xyz;

        wire [48:0] maj_xyz_simd_gated;
        wire [7:0] int_carry_in, int_carry_out, ext_carry_out;
        wire [47:0] alu_sum;
        assign int_carry_in[0] = 1'b0;
        wire [7:0] carryout_reset;

        generate
                  if (USE_SIMD == "2X2") begin
            assign maj_xyz_simd_gated = {
                    maj_xyz_gated[47:42],
                    1'b0, maj_xyz_gated[40:36],
                    1'b0, maj_xyz_gated[34:30],
                    1'b0, maj_xyz_gated[28:24],
                    1'b0, maj_xyz_gated[22:18],
                    1'b0, maj_xyz_gated[16:12],
                    1'b0, maj_xyz_gated[10:6],
                    1'b0, maj_xyz_gated[4:0],
                    alu_cin
                };
            assign int_carry_in[7:1] = 7'b000_0000;
            assign ext_carry_out = {
                    int_carry_out[7],
                    maj_xyz_gated[41] ^ int_carry_out[6],
                    maj_xyz_gated[35] ^ int_carry_out[5],
                    maj_xyz_gated[29] ^ int_carry_out[4],
                    maj_xyz_gated[23] ^ int_carry_out[3],
                    maj_xyz_gated[17] ^ int_carry_out[2],
                    maj_xyz_gated[11] ^ int_carry_out[1],
                    maj_xyz_gated[5] ^ int_carry_out[0]
                };
            assign carryout_reset = 8'b0000_0000;
        end else if (USE_SIMD == "4X4") begin
                 assign maj_xyz_simd_gated = {
                         maj_xyz_gated[47:36],
                         1'b0, maj_xyz_gated[34:24],
                         1'b0, maj_xyz_gated[22:12],
                         1'b0, maj_xyz_gated[10:0],
                         alu_cin
                     };
                 assign int_carry_in[7:1] = {int_carry_out[6], 1'b0, int_carry_out[4], 1'b0, int_carry_out[2], 1'b0, int_carry_out[0]};
                             assign ext_carry_out = {
                                     int_carry_out[7],
                                     1'bx,
                                     maj_xyz_gated[35] ^ int_carry_out[5],
                                     1'bx,
                                     maj_xyz_gated[23] ^ int_carry_out[3],
                                     1'bx,
                                     maj_xyz_gated[11] ^ int_carry_out[1],
                                     1'bx
                                 };
                             assign carryout_reset = 8'b0x0x_0x0x;
             end else if (USE_SIMD == "9X9") begin
                 assign maj_xyz_simd_gated = {
                         maj_xyz_gated[47:24],
                         1'b0, maj_xyz_gated[22:0],
                         alu_cin
                     };
                 assign int_carry_in[7:1] = {int_carry_out[6:4], 1'b0, int_carry_out[2:0]};
                 assign ext_carry_out = {
                         int_carry_out[7],
                         3'bx,
                         maj_xyz_gated[23] ^ int_carry_out[3],
                         3'bx
                     };
                 assign carryout_reset = 8'b0xxx_0xxx;
             end else begin
                 assign maj_xyz_simd_gated = {maj_xyz_gated, alu_cin};
                 assign int_carry_in[7:1] = int_carry_out[6:0];
                 assign ext_carry_out = {
                         int_carry_out[7],
                         7'bxxx
                     };
                 assign carryout_reset = 8'b0xxx_xxxx;
             end

        genvar i;
        for (i = 0; i < 8; i = i + 1)begin
            assign {int_carry_out[i], alu_sum[i*6 +: 6]} = {1'b0, maj_xyz_simd_gated[i*6 +: ((i == 7) ? 7 : 6)]} + xor_xyz_muxed[i*6 +: 6] + int_carry_in[i];
        end

        endgenerate

        wire signed [47:0] Pd = ALUMODEr[1] ? ~alu_sum : alu_sum; //为1取反 减法
        wire [7:0] CARRYOUTd = (OPMODEr[3:0] == 4'b0101 || ALUMODEr[3:2] != 2'b00) ? 8'bxxxx_xxxx :
                               ((ALUMODEr[0] & ALUMODEr[1]) ? ~ext_carry_out : ext_carry_out);
        wire CARRYCASCOUTd = ext_carry_out[7];
        wire MULTSIGNOUTd = Mrx[44];

    generate
        if (PREG == 1) begin
            initial P = 48'b0;
            initial CARRYOUT = carryout_reset;
            initial CARRYCASCOUT = 1'b0;
            initial MULTSIGNOUT = 1'b0;
            always @(posedge CLK)
                if (RSTP) begin
                    P <= 48'b0;
                    CARRYOUT <= carryout_reset;
                    CARRYCASCOUT <= 1'b0;
                    MULTSIGNOUT <= 1'b0;
                end else if (CEP) begin
                    P <= Pd;
                    CARRYOUT <= CARRYOUTd;
                    CARRYCASCOUT <= CARRYCASCOUTd;
                    MULTSIGNOUT <= MULTSIGNOUTd;
                end
        end else begin
            always @* begin
                P = Pd;
                CARRYOUT = CARRYOUTd;
                CARRYCASCOUT = CARRYCASCOUTd;
                MULTSIGNOUT = MULTSIGNOUTd;
            end
        end
    endgenerate

    assign PCOUT = P;

    generate
        wire PATTERNDETECTd, PATTERNBDETECTd;

        if (USE_PATTERN_DETECT == "PATDET") begin
            // TODO: Support SEL_PATTERN != "PATTERN" and SEL_MASK != "MASK
            assign PATTERNDETECTd = &(~(Pd ^ PATTERN) | MASK);
            assign PATTERNBDETECTd = &((Pd ^ PATTERN) | MASK);
        end else begin
            assign PATTERNDETECTd = 1'b1;
            assign PATTERNBDETECTd = 1'b1;
        end

        if (PREG == 1) begin
            reg PATTERNDETECTPAST, PATTERNBDETECTPAST;
            initial PATTERNDETECT = 1'b0;
            initial PATTERNBDETECT = 1'b0;
            initial PATTERNDETECTPAST = 1'b0;
            initial PATTERNBDETECTPAST = 1'b0;
            always @(posedge CLK)
                if (RSTP) begin
                    PATTERNDETECT <= 1'b0;
                    PATTERNBDETECT <= 1'b0;
                    PATTERNDETECTPAST <= 1'b0;
                    PATTERNBDETECTPAST <= 1'b0;
                end else if (CEP) begin
                    PATTERNDETECT <= PATTERNDETECTd;
                    PATTERNBDETECT <= PATTERNBDETECTd;
                    PATTERNDETECTPAST <= PATTERNDETECT;
                    PATTERNBDETECTPAST <= PATTERNBDETECT;
                end
            assign OVERFLOW = &{PATTERNDETECTPAST, ~PATTERNBDETECT, ~PATTERNDETECT};
            assign UNDERFLOW = &{PATTERNBDETECTPAST, ~PATTERNBDETECT, ~PATTERNDETECT};
        end else begin
            always @* begin
                PATTERNDETECT = PATTERNDETECTd;
                PATTERNBDETECT = PATTERNBDETECTd;
            end
            assign OVERFLOW = 1'bx, UNDERFLOW = 1'bx;
        end
    endgenerate

//wide xor
    wire XOR12A;
    wire XOR12B;
    wire XOR12C;
    wire XOR12D;
    wire XOR12E;
    wire XOR12F;
    wire XOR12G;
    wire XOR12H;

    wire XOR24A;
    wire XOR24B;
    wire XOR24C;
    wire XOR24D;

    wire XOR48A;
    wire XOR48B;

    wire XOR96;


    assign XOR12A = ^S[5:0];
    assign XOR12B = ^S[11:6];
    assign XOR12C = ^S[17:12];
    assign XOR12D = ^S[23:18];
    assign XOR12E = ^S[29:24];
    assign XOR12F = ^S[35:30];
    assign XOR12G = ^S[41:36];
    assign XOR12H = ^S[47:42];


    assign XOR24A = XOR12A ^ XOR12B;
    assign XOR24B = XOR12C ^ XOR12D;
    assign XOR24C = XOR12E ^ XOR12F;
    assign XOR24D = XOR12G ^ XOR12H;

    assign XOR48A = XOR24A ^ XOR24B;
    assign XOR48B = XOR24C ^ XOR24D;

    assign XOR96 = XOR48A ^ XOR48B;

    assign XOROUT[0] = (XORSIMD)    ? XOR24A    : XOR12A;
    assign XOROUT[1] = (XORSIMD)    ? XOR48A    : XOR12B;
    assign XOROUT[2] = (XORSIMD)    ? XOR24B    : XOR12C;
    assign XOROUT[3] = (XORSIMD)    ? XOR96     : XOR12D;
    assign XOROUT[4] = (XORSIMD)    ? XOR24C    : XOR12E;
    assign XOROUT[5] = (XORSIMD)    ? XOR48B    : XOR12F;
    assign XOROUT[6] = (XORSIMD)    ? XOR24D    : XOR12G;
    assign XOROUT[7] = XOR12H;

endmodule


