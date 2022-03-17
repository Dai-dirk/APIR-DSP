
module apirdsp(
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
    parameter A_WIDTH = 27;
    parameter B_WIDTH = 18;
    parameter C_WIDTH = 48;
    parameter D_WIDTH = 27;
    
        input CLK;

        input [A_WIDTH-1:0] A;
        input [B_WIDTH-1:0] B;
        input [C_WIDTH-1:0] C;
        input [D_WIDTH-1:0] D;



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
pirdsp2 #(
		// Disable all registers
		.ACASCREG(ACASCREG),
		.ADREG(ADREG),
		.A_INPUT(A_INPUT),
		.ALUMODEREG(ALUMODEREG),
		.AREG(AREG),
		.BCASCREG(BCASCREG),
		.B_INPUT(B_INPUT),
		.BREG(BREG),
		.CARRYINREG(CARRYINREG),
		.CARRYINSELREG(CARRYINSELREG),
		.CREG(CREG),
		.DREG(DREG),
		.INMODEREG(INMODEREG),
		.MREG(MREG),
		.OPMODEREG(OPMODEREG),
		.PREG(PREG),
		.USE_MULT(USE_MULT),
		.USE_SIMD(USE_SIMD),
		.MULTMODEREG(MULTMODEREG),
		.AMULTSEL(AMULTSEL),
		.BMULTSEL(BMULTSEL)
	) _TECHMAP_REPLACE_ (
		//Data path
		.A({{(27-A_WIDTH)'b0},A}),
		.B({{(27-B_WIDTH)'b0},B}),
		.C(C),
		.D({{(27-D_WIDTH)'b0},D}),
		.P(P),
                .CLK(CLK),
		.INMODE(INMODE),
		.ALUMODE(ALUMODE),
		.OPMODE(OPMODE),
		.CARRYINSEL(CARRYINSEL),
		.MULTMODE(MULTMODE),
		.LPS(LPS),
               
		.ACIN(ACIN),
		.BCIN(BCIN),
		.PCIN(PCIN),
		.CARRYIN(CARRYIN),
                .CEB1(CEB1),
                .CEB2(CEB2),
                .CEA1(CEA1),
                .CEA2(CEA2),
                .CEAD(CEAD),
                .CED(CED),
                .CEC(CEC),
                .CEP(CEP),
                .CEM(CEM),
         .CECARRYIN(CECARRYIN),

        .RSTCTRL(RSTCTRL),
        .RSTD(RSTD),
        .RSTC(RSTC),
        .RSTB(RSTB),
        .RSTA(RSTA),
        .RSTP(RSTP),
        .RSTM(RSTM),
        .RSTALLCARRYIN(RSTALLCARRYIN),

        .ACIN(ACIN),
        .BCIN(BCIN),              // modified
        .PCIN(PCIN)
	);
endmodule
