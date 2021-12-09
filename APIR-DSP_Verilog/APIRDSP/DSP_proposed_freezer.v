`timescale 1 ns / 100 ps  
module DSP_proposed_freezer(

		// Inputs
		clk,		
		
		A,
		B,
		C,
		D,
		
		A_INPUT,
		
		RF_load,
		A_addr,
		ACOUT_addr,		
		
		B_INPUT,
		BREG,
		BCASCREG,
		
		OPMODE_in,
		ALUMODE_in,
		CARRYINSEL_in,	
		
		CARRYIN,
		INMODE_in,
		MULTMODE_in,
		LPS_in,
		CHAINMODE_in,
		MDR_in, 	
		
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
		CEMULTMODE,
		CELPS,
		CECHAINMODE,
		CEMDR,	
		
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
		RSTMULTMODE,
		RSTLPS,
		RSTCHAINMODE,
		RSTMDR,
		
		ACIN,
		BCIN,
		PCIN,
		CARRYCASCIN,
		
		// Outputs
		ACOUT,
		BCOUT,
		PCOUT,
		
		P,	
		P_SIMD_carry,
		
		CARRYCASCOUT,	
		MULTSIGNOUT,
		
		PATTERNDETECT,		
		PATTERNBDETECT,
		
		OVERFLOW,			
		UNDERFLOW,		
		
		XOROUT,		
		// End of Outputs
			
		configuration_input,
		configuration_enable
	);  
	//////////////////////////////////////////////////////////////////////////
	//Parameters
	parameter input_freezed = 1'b1;
	// parameters Dual_A_Register_block_proposed
	parameter registerfile_size = 8;
	parameter registerfile_size_log = $clog2(registerfile_size);
	//////////////////////////////////////////////////////////////////////////
	
	// Inputs
	input clk;	

	input [29:0] A;
	input [17:0] B;
	input [47:0] C;
	input [26:0] D;

	input A_INPUT;

	input RF_load;
	input [registerfile_size_log-1:0] A_addr;
	input [registerfile_size_log-1:0] ACOUT_addr;

	input B_INPUT;
	input [1:0] BREG;
	input [1:0] BCASCREG;

	input [8:0] OPMODE_in;
	input [3:0] ALUMODE_in;
	input [2:0] CARRYINSEL_in;

	input CARRYIN;
	input [4:0] INMODE_in;
	input [3:0] MULTMODE_in;
	input LPS_in;
	input [1:0] CHAINMODE_in;
	input MDR_in;

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
	input CEMULTMODE;
	input CELPS;
	input CECHAINMODE;
	input CEMDR;

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
	input RSTMULTMODE;
	input RSTLPS;
	input RSTCHAINMODE;
	input RSTMDR;

	input [29:0] ACIN;
	input [26:0] BCIN;
	input [47:0] PCIN;
	input CARRYCASCIN;

	// Outputs
	output reg [29:0] ACOUT;
	output reg [26:0] BCOUT;
	output reg [47:0] PCOUT;

	output reg [47:0] P;
	output reg [15:0] P_SIMD_carry;

	output reg CARRYCASCOUT;
	output reg MULTSIGNOUT;

	output reg PATTERNDETECT;
	output reg PATTERNBDETECT;

	output reg OVERFLOW;
	output reg UNDERFLOW;		

	output reg [7:0] XOROUT;		
	// End of Outputs
		
	input configuration_input;
	input configuration_enable;
	
	
	//////////////////////////////////////////////////////////////////////////
	reg [29:0] A_reg;
	reg [17:0] B_reg;
	reg [47:0] C_reg;
    reg [26:0] D_reg;
	
	reg A_INPUT_reg;
	
    reg RF_load_reg;
	reg [registerfile_size_log-1:0] A_addr_reg;
	reg [registerfile_size_log-1:0] ACOUT_addr_reg;
	
	reg B_INPUT_reg;
	reg [1:0] BREG_reg;
	reg [1:0] BCASCREG_reg;
		
	reg [8:0] OPMODE_in_reg;
    reg [3:0] ALUMODE_in_reg;
    reg [2:0] CARRYINSEL_in_reg;
	
    reg CARRYIN_reg;
    reg [4:0] INMODE_in_reg;
	reg [3:0] MULTMODE_in_reg;
	reg LPS_in_reg;
	reg [1:0] CHAINMODE_in_reg;
	reg MDR_in_reg;
	
	reg [29:0] ACIN_reg;
	reg [26:0] BCIN_reg;
	reg [47:0] PCIN_reg;
	reg CARRYCASCIN_reg;
		
	reg configuration_input_reg;
	reg configuration_enable_reg;
	
	always @ (posedge clk) begin
		A_reg <= A;
	    B_reg <= B;
	    C_reg <= C;
	    D_reg <= D;
		
		A_INPUT_reg <= A_INPUT;
	
		RF_load_reg <= RF_load;
		A_addr_reg <= A_addr;
		ACOUT_addr_reg <= ACOUT_addr;
		
		B_INPUT_reg <= B_INPUT;
	
		BREG_reg <= BREG;
		BCASCREG_reg <= BCASCREG;
	
		OPMODE_in_reg <= OPMODE_in;
		ALUMODE_in_reg <= ALUMODE_in;
		CARRYINSEL_in_reg <= CARRYINSEL_in;
		
		CARRYIN_reg <= CARRYIN;
		INMODE_in_reg <= INMODE_in;
		
		MULTMODE_in_reg <= MULTMODE_in;
		LPS_in_reg <= LPS_in;
		CHAINMODE_in_reg <= CHAINMODE_in;
		MDR_in_reg <= MDR_in;
		
		ACIN_reg <= ACIN;
		BCIN_reg <= BCIN;
		PCIN_reg <= PCIN;
		CARRYCASCIN_reg <= CARRYCASCIN;
		
		configuration_input_reg <= configuration_input;
		configuration_enable_reg <= configuration_enable;
	end
	//////////////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////
	wire [29:0] ACOUT_temp;
	wire [26:0] BCOUT_temp;
	wire [47:0] PCOUT_temp;
		
	wire [47:0] P_temp;
	wire [15:0] P_SIMD_carry_temp;
	
	wire CARRYCASCOUT_temp;
	wire MULTSIGNOUT_temp;
		
	wire PATTERNDETECT_temp;		
	wire PATTERNBDETECT_temp;
		
	wire OVERFLOW_temp;			
	wire UNDERFLOW_temp;
	
	wire [7:0] XOROUT_temp;
		
	always @ (posedge clk ) begin
		ACOUT <= ACOUT_temp;
		BCOUT <= BCOUT_temp;
        PCOUT <= PCOUT_temp;
		
		P <= P_temp;
		P_SIMD_carry <= P_SIMD_carry_temp;
		
		CARRYCASCOUT <= CARRYCASCOUT_temp;
		MULTSIGNOUT <= MULTSIGNOUT_temp;
		
		PATTERNDETECT <= PATTERNDETECT_temp;
		PATTERNBDETECT <= PATTERNBDETECT_temp;
		
		OVERFLOW <= OVERFLOW_temp;
		UNDERFLOW <= UNDERFLOW_temp;
		
		XOROUT <= XOROUT_temp;	
	end	
	//////////////////////////////////////////////////////////////////////////

	//////////////////////////////////////////////////////////////////////////	
	defparam DSP_proposed_inst.input_freezed = input_freezed;
	defparam DSP_proposed_inst.registerfile_size = registerfile_size;
	DSP_proposed 	DSP_proposed_inst(
		// Inputs
		.clk(clk),		
		
		.A(A_reg),
		.B(B_reg),
		.C(C_reg),
		.D(D_reg),
		
		.A_INPUT(A_INPUT_reg),
		
		.RF_load(RF_load_reg),
		.A_addr(A_addr_reg),
		.ACOUT_addr(ACOUT_addr_reg),		
		
		.B_INPUT(B_INPUT_reg),
		.BREG(BREG_reg),
		.BCASCREG(BCASCREG_reg),
		
		.OPMODE_in(OPMODE_in_reg),
		.ALUMODE_in(ALUMODE_in_reg),
		.CARRYINSEL_in(CARRYINSEL_in_reg),	
		
		.CARRYIN(CARRYIN_reg),
		.INMODE_in(INMODE_in_reg),
		.MULTMODE_in(MULTMODE_in_reg),
		.LPS_in(LPS_in_reg),
		.CHAINMODE_in(CHAINMODE_in_reg),
		.MDR_in(MDR_in_reg),
		
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
		.CEALUMODE(CEALUMODE),		
		.CECTRL(CECTRL),
		.CEINMODE(CEINMODE),	
		.CEMULTMODE(CEMULTMODE),
		.CELPS(CELPS),
		.CECHAINMODE(CECHAINMODE),
		.CEMDR(CEMDR),
		
		.RSTCTRL(RSTCTRL),
		.RSTALUMODE(RSTALUMODE),
		.RSTD(RSTD),
		.RSTC(RSTC),
		.RSTB(RSTB),
		.RSTA(RSTA),
		.RSTP(RSTP),
		.RSTM(RSTM),				
		.RSTALLCARRYIN(RSTALLCARRYIN),
		.RSTINMODE(RSTINMODE),	
		.RSTMULTMODE(RSTMULTMODE),
		.RSTLPS(RSTLPS),
		.RSTCHAINMODE(RSTCHAINMODE),
		.RSTMDR(RSTMDR),
		
		.ACIN(ACIN_reg),
		.BCIN(BCIN_reg),
		.PCIN(PCIN_reg),
		.CARRYCASCIN(CARRYCASCIN_reg),
		
		// Outputs
		.ACOUT(ACOUT_temp),
		.BCOUT(BCOUT_temp),
		.PCOUT(PCOUT_temp),
		
		.P(P_temp),	
		.P_SIMD_carry(P_SIMD_carry_temp),
		
		.CARRYCASCOUT(CARRYCASCOUT_temp),
		.MULTSIGNOUT(MULTSIGNOUT_temp),
		
		.PATTERNDETECT(PATTERNDETECT_temp),		
		.PATTERNBDETECT(PATTERNBDETECT_temp),
		
		.OVERFLOW(OVERFLOW_temp),			
		.UNDERFLOW(UNDERFLOW_temp),		
		
		.XOROUT(XOROUT_temp),		
		// End of Outputs
		
		.configuration_input(configuration_input_reg),
		.configuration_enable(configuration_enable_reg)
	);  

endmodule 