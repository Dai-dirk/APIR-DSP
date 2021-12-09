/**********************************************************************
*
* 	Developer:			SeyedRamin Rasoulinezhad 
*
*	Email: 					raminrasoolinezhad@gmail.com
* 	
*	Design Title:		Xilinx DSP48E2
* 	
*	Design source: 	According UG579-Ultrascale-dsp.pdf
*
*	Date 					19 Oct. 2018
* 
* *********************************************************************
*
*	Modules:				
*			(Input registers & multiplexers):
*					- Dual_A_Register_block
*					- Dual_B_Register_block
*					- C_Register_block
*					- D_Register_block
*					- XYZW_manager
*					- carry_in_manager
*
*			(Operation manager registers):
*					- operation_manager
*					- inmode_manager
*
*			(Operation & Computation):
*					- Multiplier_xilinx
*					- multiplier_output_manager
*					- ALU
*					- pattern_detection
*					- wide_xor_block
*					
*			(Output registers):
*					- output_manager
*
**********************************************************************/
`timescale 1 ns / 100 ps  
module DSP_proposed(

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
		 MULTMODE_in,			// new
		 LPS_in,								// new
		 CHAINMODE_in,			// new
		 MDR_in, 								// new
				
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
		 CEMULTMODE,				// new
		 CELPS,			// new
		 CECHAINMODE,				// new
		 CEMDR,							// new

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
		 RSTMULTMODE,			// new
		 RSTLPS,	// new
		 RSTCHAINMODE,		// new
		 RSTMDR,					// new
			
		 ACIN,
		 BCIN,				// modified
		 PCIN,
		 CARRYCASCIN,
		//input MULTSIGNIN,				//	<------------------ Question: sued for 96 MAC --> to forward carry bit from a ALU to next ALU as we use 4 bit adders.
		// End of Inputs
		
		
		// Outputs
		 ACOUT,
		 BCOUT,			// modified
		 PCOUT,
		
		 P,
		 P_SIMD_carry,	// NEW (DoM : Depends on Multiplier)
		
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

/*******************************************************
*		Parameters  
*******************************************************/
	parameter input_freezed = 1'b0;
	
	// parameters Dual_A_Register_block_proposed
	parameter registerfile_size = 8;
	parameter registerfile_size_log = $clog2(registerfile_size);



		input clk;		
		
		input [29:0] A;
		input [17:0] B;
		input [47:0] C;
		input [26:0] D;
		
		input A_INPUT;//control ACIN/A MUX
		
		input RF_load;
                input [registerfile_size_log-1:0] A_addr;
                input [registerfile_size_log-1:0] ACOUT_addr;
	
		input B_INPUT;//control BCIN/B MUX
		input [1:0] BREG;//select B(register/comb)
		input [1:0] BCASCREG;
	
		input [8:0] OPMODE_in;//Controls the input to the W, X, Y, and Z multiplexers
		input [3:0] ALUMODE_in;//Controls the selection of the logic function in the DSP48E2 slice.
		input [2:0] CARRYINSEL_in;	//control CIN for alu
		
		input CARRYIN;
		input [4:0] INMODE_in;//control pre-adder
		input [3:0] MULTMODE_in;			// new
		input LPS_in;								// new
		input [1:0] CHAINMODE_in;			// new
		input MDR_in; 								// new
				
		input CEB1;//first b reg_en
		input CEB2;//second b reg_en		
		input CEA1;//first a reg_en
		input CEA2;//second a reg_en
		input CEAD;//pre-adder output
		input CED;
		input CEC;
		input CEP;
		input CEM;
		input CECARRYIN;//Clock enable for the CARRYIN (input from the logic) register.
		input CEALUMODE;//Clock enable for ALUMODE (control inputs) registers.		
		input CECTRL;//clock_en for opmode and carryinsel
		input CEINMODE;//clock_en for inmode	
		input CEMULTMODE;				// new
		input CELPS;			// new
		input CECHAINMODE;				// new
		input CEMDR;							// new
/*****reset signal******/		
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
		input RSTMULTMODE;			// new
		input RSTLPS;	// new
		input RSTCHAINMODE;		// new
		input RSTMDR;					// new
			
		input [29:0] ACIN;
		input [26:0] BCIN;				// modified(used to be 18)
		input [47:0] PCIN;
		input CARRYCASCIN;
		//input MULTSIGNIN;				//	<------------------ Question: sued for 96 MAC --> to forward carry bit from a ALU to next ALU as we use 4 bit adders.
		// End of Inputs
		
		
		// Outputs
		output [29:0] ACOUT;
		output [26:0] BCOUT;			// modified
		output [47:0] PCOUT;
		
		output [47:0] P;
		output [15:0] P_SIMD_carry;	// NEW (DoM : Depends on Multiplier)
		
		output CARRYCASCOUT;	
		output MULTSIGNOUT;//Sign of the multiplied result cascaded to the next DSP48E2 slice for MACC extension.
		
		output PATTERNDETECT;		
		output PATTERNBDETECT;//pattern_detect used for finish the job like auto reset when a count value has been reached
		
		output OVERFLOW;			
		output UNDERFLOW;		
		
		output [7:0] XOROUT;	//	Wide XOR outputs, based on XORSIMD attribute
		// End of Outputs
		
		input configuration_input;
		input configuration_enable;


	
/*******************************************************
*		Input / Outputs
*******************************************************/


/*******************************************************
*		InterConnections 
*******************************************************/
// (Input registers & multiplexers):
	wire [47:0] X_MUX;
	
	wire [53:0] A_MULT;			//new
	wire [53:0] B_MULT;			//new
	
	wire [17:0] B1B0_stream;		//new
	
	wire [26:0] AD_DATA;
	wire [47:0] C_MUX;
	
	wire [17:0] B2B1;
	wire [26:0] A2A1;
		
	wire CIN;	
	
	wire [47:0] W;
	wire [47:0] Z;
	wire [47:0] Y;
	wire [47:0] X;	
	wire [15:0] M_SIMD_carry_Mux;		// NEW (DoM : Depends on Multiplier)
// (Operation manager registers):
	wire [8:0] OPMODE;
	wire [2:0] CARRYINSEL;
	wire [3:0] ALUMODE;
	
	wire [4:0] INMODE;
	wire INMODEA;
	wire INMODEB;
	wire [3:0] MULTMODE;					// New
	wire LPS;											// New
	wire [1:0] CHAINMODE;					// New
	
	wire  [15:0] result_SIMD_carry;			// New (DoM : Depends on Multiplier)
	wire [15:0] M_SIMD;						// New (DoM : Depends on Multiplier)
	wire [15:0] result_SIMD_carry_out; 	// New (DoM : Depends on Multiplier)
// (Operation & Computation):
	wire PATTERNDETECTPAST;
	wire PATTERNBDETECTPAST;
	
	wire [89:0] M_temp;
	wire [89:0] M;
	
// (Output registers):
	wire [7:0] inter_XOROUT;
	
	wire COUT;								//new
	wire [47:0] S;
	wire PREG;
	wire MREG;
	

	
// Configurations	
	wire COF_Dual_A_Register_block_inst;
	wire COF_Dual_B_Register_block_inst;
	wire COF_C_Register_block_inst;
	wire COF_D_Register_block_inst;
	wire COF_XYZW_manager_block_inst;
	wire COF_carry_in_manager_block_inst;
	wire COF_operation_manager_block_inst;
	wire COF_inmode_manager_block_inst;
	wire COF_multmode_manager_block_inst;			//new
	wire COF_multiplier_output_manager_block_inst;
	wire COF_multiplier_ALU_block_inst;
	wire COF_pattern_detection_block_inst;
	wire COF_wide_xor_block_block_inst;
	
/*******************************************************
*			(Input registers & multiplexers):
*					- Dual_A_Register_block
*					- Dual_B_Register_block
*					- C_Register_block
*					- D_Register_block
*					- XYZW_manager
*					- carry_in_manager
*******************************************************/

	defparam Dual_A_Register_block_proposed_inst.registerfile_size = registerfile_size;	
	Dual_A_Register_block_proposed 			Dual_A_Register_block_proposed_inst(
		.clk(clk),

		.A(A),
		.ACIN(ACIN),
		.A_INPUT(A_INPUT),
		
		.AD_DATA(AD_DATA),
		.B1B0_stream(B1B0_stream),
		.B_MUX(X_MUX[17:0]),
		
		.RF_load(RF_load),
		.A_addr(A_addr),
		
		.ACOUT(ACOUT),
		.ACOUT_addr(ACOUT_addr),
		.MDR(MDR),
		
		.CEA1(CEA1),
		.CEA2(CEA2),
		.RSTA(RSTA),

		.INMODEA(INMODEA),
		
		.chain_mode(CHAINMODE),
		
		.X_MUX(X_MUX[47:18]),
		.A_MULT(A_MULT),
		.A2A1(A2A1),
		
		.configuration_input(configuration_input),
		.configuration_enable(configuration_enable),
		.configuration_output(COF_Dual_A_Register_block_inst)
	);

	Dual_B_Register_block_proposed 			Dual_B_Register_block_proposed_inst(
		.clk(clk),
		
		.B(B),
		.BCIN(BCIN),
		.B_INPUT(B_INPUT),
		.BREG(BREG),
		.BCASCREG(BCASCREG),
		
		.AD_DATA(AD_DATA[17:0]),
	    
		.CEB1(CEB1),
		.CEB2(CEB2),
		.RSTB(RSTB),
		
		.INMODE_4(INMODE[4]),
		.INMODEB(INMODEB),
		.LPS(LPS),					/// 1bit <-- 2bits beshavad
		
		.B2B1(B2B1),
		.B1B0_stream(B1B0_stream),
		.BCOUT(BCOUT),
		
		.X_MUX(X_MUX[17:0]),
		.B_MULT(B_MULT),
		
		.configuration_input(COF_Dual_A_Register_block_inst),
		.configuration_enable(configuration_enable),
		.configuration_output(COF_Dual_B_Register_block_inst)
	);
		
	C_Register_block 					C_Register_block_inst(
		.clk(clk),
		
		.C(C),
	    
		.RSTC(RSTC),
		.CEC(CEC),

		.C_MUX(C_MUX),
	
		.configuration_input(COF_Dual_B_Register_block_inst),
		.configuration_enable(configuration_enable),
		.configuration_output(COF_C_Register_block_inst)
	);
	
	D_Register_block 					D_Register_block_inst(
		.clk(clk),
		
		.D(D),
		
		.CED(CED),
		.RSTD(RSTD),
		.CEAD(CEAD),
        
		.INMODE(INMODE),
        
		.A2A1(A2A1),
		.B2B1(B2B1),
		
		.AD_DATA(AD_DATA),
		.INMODEA(INMODEA),
		.INMODEB(INMODEB),

		.configuration_input(COF_C_Register_block_inst),
		.configuration_enable(configuration_enable),
		.configuration_output(COF_D_Register_block_inst)
	);
	
	XYZW_manager_proposed 	XYZW_manager_proposed_inst (
		.clk(clk),
		
		.OPMODE(OPMODE),
		.P(P),
		
		.C(C_MUX),
		
		.M1(M[44:0]),//result_0				
		.M2(M[89:45]),//result_1
		.M_SIMD_carry(M_SIMD),
		
		.AB(X_MUX),			
		.PCIN(PCIN),

		.W(W),
		.Z(Z),
		.Y(Y),
		.X(X),
		.M_SIMD_carry_Mux(M_SIMD_carry_Mux),

		.configuration_input(COF_D_Register_block_inst),
		.configuration_enable(configuration_enable),
		.configuration_output(COF_XYZW_manager_block_inst)
	);	

	carry_in_manager 		carry_in_manager_inst(
		.clk(clk),
		
		.RSTALLCARRYIN(RSTALLCARRYIN),
        
		.CECARRYIN(CECARRYIN),
		.CEM(CEM),
		
		.CARRYIN(CARRYIN),
		.A_mult_msb(A_MULT[26]),
		.B_mult_msb(B_MULT[17]),
		.PCIN_msb(PCIN[47]),
		.P_msb(P[47]),
		
		.CARRYCASCIN(CARRYCASCIN),
		.CARRYCASCOUT(CARRYCASCOUT),
		.CARRYINSEL(CARRYINSEL),
				
		.CIN(CIN),
		.MREG(MREG),

		.configuration_input(COF_XYZW_manager_block_inst),
		.configuration_enable(configuration_enable),
		.configuration_output(COF_carry_in_manager_block_inst)
	);
	
/*******************************************************
*			(Operation manager registers):
*					- operation_manager
*					- inmode_manager
*******************************************************/

	operation_manager 		operation_manager_inst (
		.clk(clk),

		.RSTCTRL(RSTCTRL),
		.RSTALUMODE(RSTALUMODE),

		.CECTRL(CECTRL),
		.CEALUMODE(CEALUMODE),

		.OPMODE_in(OPMODE_in),
		.ALUMODE_in(ALUMODE_in),
		.CARRYINSEL_in(CARRYINSEL_in),
		
		.OPMODE(OPMODE),
		.ALUMODE(ALUMODE),
		.CARRYINSEL(CARRYINSEL),
		
		.configuration_input(COF_carry_in_manager_block_inst),
		.configuration_enable(configuration_enable),
		.configuration_output(COF_operation_manager_block_inst)
	);	
	
	inmode_manager 				inmode_manager_inst (
		.clk(clk),
		
		.INMODE_in(INMODE_in),
		.RSTINMODE(RSTINMODE),
		.CEINMODE(CEINMODE),
		
		.INMODE(INMODE),
		
		.configuration_input(COF_operation_manager_block_inst),
		.configuration_enable(configuration_enable),
		.configuration_output(COF_inmode_manager_block_inst)
	);

	mult_chain_stream_mode_manager 		mult_chain_stream_mode_manager_inst (
		.clk(clk),
		
		.MULTMODE_in(MULTMODE_in),
		.RSTMULTMODE(RSTMULTMODE),
		.CEMULTMODE(CEMULTMODE),
		.MULTMODE(MULTMODE),
	
		.LPS_in(LPS_in),					// Please change it to 1 bit from 2 bits
		.RSTLPS(RSTLPS),
		.CELPS(CELPS),
		.LPS(LPS),
		
		.CHAINMODE_in(CHAINMODE_in),		
		.RSTCHAINMODE(RSTCHAINMODE),
		.CECHAINMODE(CECHAINMODE),
		.CHAINMODE(CHAINMODE),
		
		.MDR_in(MDR_in),		
		.RSTMDR(RSTMDR),
		.CEMDR(CEMDR),
		.MDR(MDR),
		
		.configuration_input(COF_inmode_manager_block_inst),
		.configuration_enable(configuration_enable),
		.configuration_output(COF_multmode_manager_block_inst)
	);
	
/*******************************************************
*			(Operation & Computation):
*					- Multiplier_xilinx
*					- multiplier_output_manager
*					- ALU
*					- pattern_detection
*					- wide_xor_block
*******************************************************/		
	multiplier_T_C3x2_F2_27bits_18bits_HighLevelDescribed_auto 			multiplier_T_C3x2_F2_27bits_18bits_HighLevelDescribed_auto_inst (
		.clk(clk),
		.reset(RSTM),
		
		.a(A_MULT),	
		.b(B_MULT),			
		
		.a_sign(MULTMODE[0]),			
		.b_sign(MULTMODE[1]),			
		
		.mode(MULTMODE[3:2]),				
		
		.result_0(M_temp[44:0]),		
		.result_1(M_temp[89:45]),	
		.result_SIMD_carry(result_SIMD_carry)	
	); 
	
	multiplier_output_manager_proposed 			multiplier_output_manager_proposed_inst (
		.clk(clk),
		
		.M_temp(M_temp),
		.result_SIMD_carry(result_SIMD_carry),
		
		.RSTM(RSTM),
		.CEM(CEM),
		
		.MREG(MREG),
		
		.M(M),
		.M_SIMD(M_SIMD),
		
		.configuration_input(COF_multmode_manager_block_inst),
		.configuration_enable(configuration_enable),
		.configuration_output(COF_multiplier_output_manager_block_inst)
	);	
	
	//wire [1:0] USE_SIMD;  --> MULTMODE[3:2]. So now there is no 12bit 24bit SIMD add/sub
	// So SIMD is just adding SIMD jobs
	
	ALU_T_C3x2_F2_27bits_18bits_HighLevelDescribed_auto_DSP48E2_new		ALU_T_C3x2_F2_27bits_18bits_HighLevelDescribed_auto_DSP48E2_new_inst(
		.ALUMODE(ALUMODE),
		.OPMODE(OPMODE),

		.USE_SIMD(MULTMODE[3:2]),
		
		.W(W),
		.Z(Z),
		.Y(Y),
		.X(X),
		
		.CIN(CIN),
		
		.S(S),
		
		.COUT(COUT),
		
		.result_SIMD_carry_in(M_SIMD_carry_Mux),	
		.result_SIMD_carry_out(result_SIMD_carry_out)
	);	

	pattern_detection 			pattern_detection_inst(
		.clk(clk),
		
		.C_reg(C_MUX),
		.inter_P(S),
		
		.RSTP(RSTP),
		.CEP(CEP),
		
		.PREG(PREG),
		.PATTERNDETECT(PATTERNDETECT),
		.PATTERNBDETECT(PATTERNBDETECT),
		.PATTERNDETECTPAST(PATTERNDETECTPAST),
		.PATTERNBDETECTPAST(PATTERNBDETECTPAST),
		.Overflow(OVERFLOW),
		.Underflow(UNDERFLOW),
		
		.configuration_input(COF_multiplier_output_manager_block_inst),
		.configuration_enable(configuration_enable),
		.configuration_output(COF_pattern_detection_block_inst)
	);
	
	wide_xor_block 			wide_xor_block_inst (
		.clk(clk),
		.S(S),
		.XOROUT(inter_XOROUT),
				
		.configuration_input(COF_pattern_detection_block_inst),
		.configuration_enable(configuration_enable),
		.configuration_output(COF_wide_xor_block_block_inst)
	);
		
/*******************************************************
*			(Output registers):
*					- output_manager
*******************************************************/
	
	defparam output_manager_proposed_inst.input_freezed = input_freezed;
	output_manager_proposed 		output_manager_proposed_inst (
		.clk(clk),
        
		.RSTP(RSTP),
		.CEP(CEP),
		
		.inter_MULTSIGNOUT(COUT),
		.inter_CARRYCASCOUT(COUT),
		.inter_XOROUT(inter_XOROUT),
		.inter_P(S),
		.inter_result_SIMD_carry_out(result_SIMD_carry_out),
		
		.PATTERNDETECT(PATTERNDETECT),		
		.PATTERNBDETECT(PATTERNBDETECT),

		.PREG(PREG),
		
		.MULTSIGNOUT(MULTSIGNOUT),
		.CARRYCASCOUT(CARRYCASCOUT),
		.XOROUT(XOROUT),
		.P(P),
		.P_SIMD_carry(P_SIMD_carry),
		
		.configuration_input(COF_wide_xor_block_block_inst),
		.configuration_enable(configuration_enable),
		.configuration_output()
	);	
	
	assign PCOUT = P;
	
endmodule
