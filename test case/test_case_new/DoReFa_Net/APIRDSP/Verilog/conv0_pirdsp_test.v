module conv0_test(
	input				clk,
	input				rst_n,
	
	input		[63:0]	idata,
	input				idata_empty,
	output				odata_rd,
	
	input		[127:0]	ipara,
	input				ipara_empty,
	output				opara_rd,
	
	output		[31:0]	odata,
	output				ovalid
);
	
	parameter			OUTPUT_NUM = 16;

	wire		[7:0]	data_ch0;
	wire		[7:0]	data_ch1;
	wire		[7:0]	data_ch2;
	wire				data_valid;
	
	wire		[7:0]	row_cnt;
	wire		[7:0]	col_cnt;
	wire				row_flag;
	
	wire				para_valid_ch0;
	wire				para_valid_ch1;
	wire				para_valid_ch2;
	
	wire		[7:0]	para_ch[OUTPUT_NUM - 1 : 0];
	
	wire				finish_flag[OUTPUT_NUM - 1 : 0];
	wire				over_flag;
	
/*	wire		[71:0]	result_map0[OUTPUT_NUM - 1 : 0];
	wire		[71:0]	result_map1[OUTPUT_NUM - 1 : 0];
	wire		[71:0]	result_map2[OUTPUT_NUM - 1 : 0];
*/
	wire		[71:0]	result_map[OUTPUT_NUM - 1 : 0];

	wire		[8:0]	result_valid[OUTPUT_NUM - 1 : 0];
	wire				wr_valid[OUTPUT_NUM - 1 : 0];
	
	wire		[1:0]	out_result[OUTPUT_NUM - 1 : 0];
	wire				out_valid[OUTPUT_NUM - 1 : 0];
	
	conv0_st_test conv0_st_inst(
		.clk				(clk),
		.rst_n				(rst_n),
		.idata				(idata),
		.idata_empty		(idata_empty),
		.odata_rd			(odata_rd),
		.ipara_empty		(ipara_empty),
		.opara_rd			(opara_rd),
		.odata_ch0			(data_ch0),
		.odata_ch1			(data_ch1),
		.odata_ch2			(data_ch2),
		.odata_valid		(data_valid),
		.orow_cnt			(row_cnt),
		.ocol_cnt			(col_cnt),
		.orow_flag			(row_flag),
		.opara_valid_ch0	(para_valid_ch0),
		.opara_valid_ch1	(para_valid_ch1),
		.opara_valid_ch2	(para_valid_ch2),
		.ifinish_flag		(finish_flag[0]),
		.oover_flag			(over_flag)
	);
	
	assign para_ch[0] = ipara[7:0];
	assign para_ch[1] = ipara[15:8];
	assign para_ch[2] = ipara[23:16];
	assign para_ch[3] = ipara[31:24];
	assign para_ch[4] = ipara[39:32];
	assign para_ch[5] = ipara[47:40];
	assign para_ch[6] = ipara[55:48];
	assign para_ch[7] = ipara[63:56];
	assign para_ch[8] = ipara[71:64];
	assign para_ch[9] = ipara[79:72];
	assign para_ch[10] = ipara[87:80];
	assign para_ch[11] = ipara[95:88];
	assign para_ch[12] = ipara[103:96];
	assign para_ch[13] = ipara[111:104];
	assign para_ch[14] = ipara[119:112];
	assign para_ch[15] = ipara[127:120];
	
	genvar ii;
	generate
	begin:	conv0_ch0_function
		for(ii=0;ii<OUTPUT_NUM;ii=ii+1) begin
			conv0_fu_test	conv0_fu_map0_inst(
				.clk				(clk),
				.rst_n				(rst_n),

				.idata0				(data_ch0),
				.idata1				(data_ch1),
				.idata2				(data_ch2),

				.id_valid			(data_valid),
				.iweight			(para_ch[ii]),
				.iw_valid0			(para_valid_ch0),
				.iw_valid1			(para_valid_ch1),
				.iw_valid2			(para_valid_ch2),

				.irow_cnt			(row_cnt),
				.icol_cnt			(col_cnt),
				.irow_flag			(row_flag),
				.ofinish_flag		(finish_flag[ii]),
				.odata				(result_map[ii]),
				.owr_valid			(wr_valid[ii]),
				.oresult_valid		(result_valid[ii])
			);
			
			conv0_go_test	conv0_go_inst(
				.clk				(clk),
				.rst_n				(rst_n),
				
				.idata_map			(result_map[ii]),
				
				.itemp_valid		(wr_valid[ii]),
				.iresult_valid		(result_valid[ii]),
				.ifinish_flag		(finish_flag[ii]),
				
				.odata				(out_result[ii]),
				.ovalid				(out_valid[ii])
			);
		end
	end
	endgenerate
	
	assign odata = {out_result[15],out_result[14],out_result[13],out_result[12],out_result[11],out_result[10],out_result[9],out_result[8],out_result[7],out_result[6],out_result[5],out_result[4],out_result[3],out_result[2],out_result[1],out_result[0]};
	assign ovalid = out_valid[0];
	
	// this is for debug
	reg        [19:0]          data_cnt;
	reg        [19:0]          result_cnt;
	always @(posedge clk)
	begin
	   if(!rst_n)
	       data_cnt <= 20'h0;
	   else if(data_valid)
	       data_cnt <= data_cnt + 1'b1;
	end
	
	always @(posedge clk)
	begin
	   if(!rst_n)
	       result_cnt <= 20'h0;
	   else if(wr_valid[0])
	       result_cnt <= result_cnt + 1'b1;
	end

endmodule	

//conv0 layer base storeage unit
module conv0_st_test(
	input				clk,
	input				rst_n,
	
	input		[63:0]	idata,
	input				idata_empty,
	output				odata_rd,
	
	input				ipara_empty,
	output				opara_rd,
	
	output		[7:0]	odata_ch0,
	output		[7:0]	odata_ch1,
	output		[7:0]	odata_ch2,
	output	reg			odata_valid,
	output	reg	[7:0]	orow_cnt,
	output	reg	[7:0]	ocol_cnt,
	output				orow_flag,
	
	output	reg			opara_valid_ch0,
	output	reg			opara_valid_ch1,
	output	reg			opara_valid_ch2,
	
	input				ifinish_flag,
	output				oover_flag
);

	parameter			SIDLE = 3'b000;
	parameter			SSTD = 3'b001;				//first stage, store data
	parameter			SLDP = 3'b010;				//second stage, load para
	parameter			SLDD = 3'b011;				//third stage, load data
	parameter			SFICYCLE = 3'b100;			//finish a cycle of calc
	
	parameter			DATA_SIZE = 15'd18816;
	parameter			PARA_SIZE = 9'd432;
	
	reg			[2:0]	cur_state;
	reg			[2:0]	nxt_state;
	
	reg			[14:0]	data_cnt;						//counter for data to restore, 224*224*3*8bit/64bit=18816
	reg			[14:0]	data_cnt_delay;
	reg			[8:0]	para_cnt;						//counter for para to restore, 12*12*3*16*8bits/128bits=432
	
	//ping data bram
	reg					wea_bram0_ch0;
	reg			[15:0]	addra_bram0_ch0;
	wire		[7:0]	dout_bram0_ch0;
	reg					wea_bram0_ch1;
	reg			[15:0]	addra_bram0_ch1;
	wire		[7:0]	dout_bram0_ch1;
	reg					wea_bram0_ch2;
	reg			[15:0]	addra_bram0_ch2;
	wire		[7:0]	dout_bram0_ch2;
	reg			[63:0]	din_bram0;
	
	//pang
	reg					wea_bram1_ch0;
	reg					wea_bram1_ch1;
	reg					wea_bram1_ch2;
	reg			[15:0]	addra_bram1_ch0;
	reg			[15:0]	addra_bram1_ch1;
	reg			[15:0]	addra_bram1_ch2;
	wire		[7:0]	dout_bram1_ch0;
	wire		[7:0]	dout_bram1_ch1;
	wire		[7:0]	dout_bram1_ch2;
	
	wire				bram_rdy;
	reg			[1:0]	bram_status;
	reg					bram_onuse;
	reg					bram_onwr;
	reg					finish_state_flag;			//this is for bram_status control
	
	reg					data_rd_r;
	reg					data_in_valid;
	reg					data_valid_temp;
	reg					para_rd_r;
	reg			[1:0]	para_rd_ch;
	
	reg			[18:0]	wait_cnt;					// wait 311040 cycles to read data again
	
	reg			[2:0]	cycles;
	reg					aux_finish_flag;			//aux signal to judge finish a cycle of reading bram
	
	always @(posedge clk or negedge rst_n)
	begin
		if(!rst_n)
			cur_state <= 3'h0;
		else
			cur_state <= nxt_state;
	end
	
	always @(*)
	begin
		case(cur_state)
			SIDLE:		if(bram_rdy)
							nxt_state <= SLDP;
						else if(!idata_empty)
							nxt_state <= SSTD;
						else
							nxt_state <= SIDLE;
			SSTD:		if((data_cnt_delay == (DATA_SIZE - 1'b1)) && data_in_valid)
							nxt_state <= SLDP;
						else
							nxt_state <= SSTD;
			SLDP:		if(para_cnt == PARA_SIZE)
							nxt_state <= SLDD;
						else
							nxt_state <= SLDP;
			SLDD:		if(ifinish_flag)
							nxt_state <= SFICYCLE;
						else
							nxt_state <= SLDD;
			SFICYCLE:	if(finish_state_flag) begin
							if(cycles == 3'b101)
								nxt_state <= SIDLE;
							else
								nxt_state <= SLDP;
						end
						else
							nxt_state <= SFICYCLE;
			default:	nxt_state <= SIDLE;
		endcase
	end
	
	//generate data rd signal, if brams are not full filled
	always @(posedge clk or negedge rst_n)
	begin
		if(!rst_n)
			data_rd_r <= 1'b0;
		else begin
			if((cur_state != SIDLE) && (nxt_state != SFICYCLE) && (bram_status != 2'b11) && (!idata_empty))
				data_rd_r <= (wait_cnt == 0);
			else
				data_rd_r <= 1'b0;
		end
	end
	assign odata_rd = data_rd_r & (!idata_empty) & (bram_status != 2'b11);
	
	always @(posedge clk or negedge rst_n)
	begin
		if(!rst_n)
			wait_cnt <= 19'h0;
		else if((data_cnt_delay == (DATA_SIZE - 1'b1)) && data_in_valid)
			wait_cnt <= 19'h1;
		else if(wait_cnt == 19'd400_000)
			wait_cnt <= 19'h0;
		else if(wait_cnt != 0)
			wait_cnt <= wait_cnt + 1'b1;
	end
	
	always @(posedge clk) begin
		data_in_valid <= odata_rd;
		data_cnt_delay <= data_cnt;
	end
	
	always @(posedge clk or negedge rst_n)
	begin
		if(!rst_n)
			data_cnt <= 15'h0;
		else if(odata_rd) begin
			if(data_cnt == (DATA_SIZE - 1'b1))
				data_cnt <= 15'h0;
			else
				data_cnt <= data_cnt + 1'b1;
		end
	end
	
	//set bram status and bram_rdy
	always @(posedge clk or negedge rst_n)
	begin
		if(!rst_n)
			bram_status <= 2'b00;
		else begin
			if((data_cnt_delay == (DATA_SIZE - 1'b1)) && data_in_valid)
				case(bram_status)
					2'b00:	bram_status <= bram_onwr ? 2'b10 : 2'b01;
					2'b01:	bram_status <= 2'b11;
					2'b10:	bram_status <= 2'b11;
				endcase
			else if((cur_state == SFICYCLE) && (nxt_state == SIDLE))
				case(bram_status)
					2'b01:	bram_status <= 2'b00;
					2'b10:	bram_status <= 2'b00;
					2'b11:	bram_status <= bram_onuse ? 2'b01 : 2'b10;
				endcase
		end
	end
	assign bram_rdy = |bram_status;
	
	//set bram_onuse signal, flag = 0 indicate bram0 are used, flag = 1 indicate bram1 are used
	always @(posedge clk or negedge rst_n)
	begin
		if(!rst_n)
			bram_onuse <= 1'b0;
		else if((cur_state == SFICYCLE) && (nxt_state == SIDLE))
			bram_onuse <= ~bram_onuse;
	end
	
	always @(posedge clk or negedge rst_n)
	begin
		if(!rst_n)
			bram_onwr <= 1'b0;
		else if(data_in_valid && (data_cnt_delay == DATA_SIZE - 1))
			bram_onwr <= ~bram_onwr;
	end
	
	//avoid bram_status increate and sub at same time
	always @(posedge clk or negedge rst_n)
	begin
		if(!rst_n)
			finish_state_flag <= 1'b0;
		else if(cur_state == SFICYCLE)
			finish_state_flag <= 1'b1;
		else
			finish_state_flag <= 1'b0;
	end
	
	//count for calc cycles
	always @(posedge clk or negedge rst_n)
	begin
		if(!rst_n)
			cycles <= 3'h0;
		else if((cur_state == SFICYCLE) && finish_state_flag)
			cycles <= cycles + 1'b1;
		else if(cur_state == SIDLE)
			cycles <= 3'h0;
	end
	
	//generate bram write signal
	always @(posedge clk or negedge rst_n)
	begin
		if(!rst_n) begin
			wea_bram0_ch0 <= 1'b0;
			wea_bram0_ch1 <= 1'b0;
			wea_bram0_ch2 <= 1'b0;
			wea_bram1_ch0 <= 1'b0;
			wea_bram1_ch1 <= 1'b0;
			wea_bram1_ch2 <= 1'b0;
			din_bram0 <= 64'h0;
		end
		else begin
			if(data_in_valid) begin
				if(data_cnt_delay < 15'd6272) begin
					wea_bram0_ch0 <= ~bram_onwr;
					wea_bram1_ch0 <= bram_onwr;
					wea_bram0_ch1 <= 1'b0;
					wea_bram1_ch1 <= 1'b0;
					wea_bram0_ch2 <= 1'b0;
					wea_bram1_ch2 <= 1'b0;
				end
				else if(data_cnt_delay < 15'd12544) begin
					wea_bram0_ch1 <= ~bram_onwr;
					wea_bram1_ch1 <= bram_onwr;
					wea_bram0_ch0 <= 1'b0;
					wea_bram1_ch0 <= 1'b0;
					wea_bram0_ch2 <= 1'b0;
					wea_bram1_ch2 <= 1'b0;
				end
				else begin
					wea_bram0_ch2 <= ~bram_onwr;
					wea_bram1_ch2 <= bram_onwr;
					wea_bram0_ch0 <= 1'b0;
					wea_bram1_ch0 <= 1'b0;
					wea_bram0_ch1 <= 1'b0;
					wea_bram1_ch1 <= 1'b0;
				end
				din_bram0 <= idata;
			end
			else begin
				wea_bram0_ch0 <= 1'b0;
				wea_bram0_ch1 <= 1'b0;
				wea_bram0_ch2 <= 1'b0;
				wea_bram1_ch0 <= 1'b0;
				wea_bram1_ch1 <= 1'b0;
				wea_bram1_ch2 <= 1'b0;
			end
		end
	end	
	
	//generate bram address
	always @(posedge clk or negedge rst_n)
	begin
		if(!rst_n) begin
			addra_bram0_ch0 <= 16'h0;
			addra_bram0_ch1 <= 16'h0;
			addra_bram0_ch2 <= 16'h0;
			addra_bram1_ch0 <= 16'h0;
			addra_bram1_ch1 <= 16'h0;
			addra_bram1_ch2 <= 16'h0;
		end
		else begin
			if(wea_bram0_ch0) begin
				if(addra_bram0_ch0 == 16'd50168)				//224��224-8=50176-8=50168
					addra_bram0_ch0 <= 16'h0;
				else
					addra_bram0_ch0 <= addra_bram0_ch0 + 4'h8;
			end
			else if(data_valid_temp && (!bram_onuse))
				addra_bram0_ch0 <= addra_bram0_ch0 + 1'b1;
			else if((cur_state == SFICYCLE) && (!bram_onuse))
				addra_bram0_ch0 <= 16'h0;
				
			if(wea_bram0_ch1) begin
				if(addra_bram0_ch1 == 16'd50168)
					addra_bram0_ch1 <= 16'h0;
				else
					addra_bram0_ch1 <= addra_bram0_ch1 + 4'h8;
			end
			else if(data_valid_temp && (!bram_onuse))
				addra_bram0_ch1 <= addra_bram0_ch1 + 1'b1;
			else if((cur_state == SFICYCLE) && (!bram_onuse))
				addra_bram0_ch1 <= 16'h0;
				
			if(wea_bram0_ch2) begin
				if(addra_bram0_ch2 == 16'd50168)
					addra_bram0_ch2 <= 16'h0;
				else
					addra_bram0_ch2 <= addra_bram0_ch2 + 4'h8;
			end
			else if(data_valid_temp && (!bram_onuse))
				addra_bram0_ch2 <= addra_bram0_ch2 + 1'b1;
			else if((cur_state == SFICYCLE) && (!bram_onuse))
				addra_bram0_ch2 <= 16'h0;
			
			if(wea_bram1_ch0) begin
				if(addra_bram1_ch0 == 16'd50168)
					addra_bram1_ch0 <= 16'h0;
				else
					addra_bram1_ch0 <= addra_bram1_ch0 + 4'h8;
			end
			else if(data_valid_temp && bram_onuse)
				addra_bram1_ch0 <= addra_bram1_ch0 + 1'b1;
			else if((cur_state == SFICYCLE) && bram_onuse)
				addra_bram1_ch0 <= 16'h0;
				
			if(wea_bram1_ch1) begin
				if(addra_bram1_ch1 == 16'd50168)
					addra_bram1_ch1 <= 16'h0;
				else
					addra_bram1_ch1 <= addra_bram1_ch1 + 4'h8;
			end
			else if(data_valid_temp && bram_onuse)
				addra_bram1_ch1 <= addra_bram1_ch1 + 1'b1;
			else if((cur_state == SFICYCLE) && bram_onuse)
				addra_bram1_ch1 <= 16'h0;
				
			if(wea_bram1_ch2) begin
				if(addra_bram1_ch2 == 16'd50168)
					addra_bram1_ch2 <= 16'h0;
				else
					addra_bram1_ch2 <= addra_bram1_ch2 + 4'h8;
			end
			else if(data_valid_temp && bram_onuse)
				addra_bram1_ch2 <= addra_bram1_ch2 + 1'b1;
			else if((cur_state == SFICYCLE) && bram_onuse)
				addra_bram1_ch2 <= 16'h0;
		end
	end			
			
	//data store
	RAMB36E2 conv0_data_inst_bram0_ch0_0(
  		.CLKARDCLK(clk),    // input wire clka
  		.ENARDEN(1'b1),      // input wire ena
  		.WEA(wea_bram0_ch0),      // input wire [0 : 0] wea
  		.ADDRARDADDR(addra_bram0_ch0),  // input wire [15 : 0] addra
  		.DINADIN(din_bram0[31:0]),    // input wire [63 : 0] dina
  		.DOUTADOUT(dout_bram0_ch0[3:0])  // output wire [7 : 0] douta
	);
	
    RAMB36E2 conv0_data_inst_bram0_ch0_1(
  		.CLKARDCLK(clk),    // input wire clka
  		.ENARDEN(1'b1),      // input wire ena
  		.WEA(wea_bram0_ch0),      // input wire [0 : 0] wea
  		.ADDRARDADDR(addra_bram0_ch0),  // input wire [15 : 0] addra
  		.DINADIN(din_bram0[63:32]),    // input wire [63 : 0] dina
  		.DOUTADOUT(dout_bram0_ch0[7:4])  // output wire [7 : 0] douta
	);
	
	RAMB36E2 conv0_data_inst_bram0_ch1_0(
  		.CLKARDCLK(clk),    // input wire clka
  		.ENARDEN(1'b1),      // input wire ena
  		.WEA(wea_bram0_ch1),      // input wire [0 : 0] wea
  		.ADDRARDADDR(addra_bram0_ch1),  // input wire [15 : 0] addra
  		.DINADIN(din_bram0[31:0]),    // input wire [63 : 0] dina
  		.DOUTADOUT(dout_bram0_ch1[3:0])  // output wire [7 : 0] douta
	);
	
    RAMB36E2 conv0_data_inst_bram0_ch1_1(
  		.CLKARDCLK(clk),    // input wire clka
  		.ENARDEN(1'b1),      // input wire ena
  		.WEA(wea_bram0_ch1),      // input wire [0 : 0] wea
  		.ADDRARDADDR(addra_bram0_ch1),  // input wire [15 : 0] addra
  		.DINADIN(din_bram0[63:32]),    // input wire [63 : 0] dina
  		.DOUTADOUT(dout_bram0_ch1[7:4])  // output wire [7 : 0] douta
	);
	
	RAMB36E2 conv0_data_inst_bram0_ch2_0(
  		.CLKARDCLK(clk),    // input wire clka
  		.ENARDEN(1'b1),      // input wire ena
  		.WEA(wea_bram0_ch2),      // input wire [0 : 0] wea
  		.ADDRARDADDR(addra_bram0_ch2),  // input wire [15 : 0] addra
  		.DINADIN(din_bram0[31:0]),    // input wire [63 : 0] dina
  		.DOUTADOUT(dout_bram0_ch2[3:0])  // output wire [7 : 0] douta
	);
	
    RAMB36E2 conv0_data_inst_bram0_ch2_1(
  		.CLKARDCLK(clk),    // input wire clka
  		.ENARDEN(1'b1),      // input wire ena
  		.WEA(wea_bram0_ch2),      // input wire [0 : 0] wea
  		.ADDRARDADDR(addra_bram0_ch2),  // input wire [15 : 0] addra
  		.DINADIN(din_bram0[63:32]),    // input wire [63 : 0] dina
  		.DOUTADOUT(dout_bram0_ch2[7:4])  // output wire [7 : 0] douta
	);
	
	
	RAMB36E2 conv0_data_inst_bram1_ch0_0(
  		.CLKARDCLK(clk),    // input wire clka
  		.ENARDEN(1'b1),      // input wire ena
  		.WEA(wea_bram1_ch0),      // input wire [0 : 0] wea
  		.ADDRARDADDR(addra_bram1_ch0),  // input wire [15 : 0] addra
  		.DINADIN(din_bram0[31:0]),    // input wire [63 : 0] dina
  		.DOUTADOUT(dout_bram1_ch0[3:0])  // output wire [7 : 0] douta
	);
	
	RAMB36E2 conv0_data_inst_bram1_ch1_0(
  		.CLKARDCLK(clk),    // input wire clka
  		.ENARDEN(1'b1),      // input wire ena
  		.WEA(wea_bram1_ch1),      // input wire [0 : 0] wea
  		.ADDRARDADDR(addra_bram1_ch1),  // input wire [15 : 0] addra
  		.DINADIN(din_bram0[31:0]),    // input wire [63 : 0] dina
  		.DOUTADOUT(dout_bram1_ch1[3:0])  // output wire [7 : 0] douta
	);
	
	RAMB36E2 conv0_data_inst_bram1_ch2_0(
  		.CLKARDCLK(clk),    // input wire clka
  		.ENARDEN(1'b1),      // input wire ena
  		.WEA(wea_bram1_ch2),      // input wire [0 : 0] wea
  		.ADDRARDADDR(addra_bram1_ch2),  // input wire [15 : 0] addra
  		.DINADIN(din_bram0[31:0]),    // input wire [63 : 0] dina
  		.DOUTADOUT(dout_bram1_ch2[3:0])  // output wire [7 : 0] douta
	);
	
		
	RAMB36E2 conv0_data_inst_bram1_ch0_1(
  		.CLKARDCLK(clk),    // input wire clka
  		.ENARDEN(1'b1),      // input wire ena
  		.WEA(wea_bram1_ch0),      // input wire [0 : 0] wea
  		.ADDRARDADDR(addra_bram1_ch0),  // input wire [15 : 0] addra
  		.DINADIN(din_bram0[63:32]),    // input wire [63 : 0] dina
  		.DOUTADOUT(dout_bram1_ch0[7:4])  // output wire [7 : 0] douta
	);
	
	RAMB36E2 conv0_data_inst_bram1_ch1_1(
  		.CLKARDCLK(clk),    // input wire clka
  		.ENARDEN(1'b1),      // input wire ena
  		.WEA(wea_bram1_ch1),      // input wire [0 : 0] wea
  		.ADDRARDADDR(addra_bram1_ch1),  // input wire [15 : 0] addra
  		.DINADIN(din_bram0[63:32]),    // input wire [63 : 0] dina
  		.DOUTADOUT(dout_bram1_ch1[7:4])  // output wire [7 : 0] douta
	);
	
	RAMB36E2 conv0_data_inst_bram1_ch2_1(
  		.CLKARDCLK(clk),    // input wire clka
  		.ENARDEN(1'b1),      // input wire ena
  		.WEA(wea_bram1_ch2),      // input wire [0 : 0] wea
  		.ADDRARDADDR(addra_bram1_ch2),  // input wire [15 : 0] addra
  		.DINADIN(din_bram0[63:32]),    // input wire [63 : 0] dina
  		.DOUTADOUT(dout_bram1_ch2[7:4])  // output wire [7 : 0] douta
	);
	
	//generate data output signals
	always @(posedge clk or negedge rst_n)
	begin
		if(!rst_n)
			data_valid_temp <= 1'b0;
		else if(cur_state == SLDD) begin
			if(((orow_cnt == 8'd222) && (ocol_cnt == 8'd223) && data_valid_temp) || aux_finish_flag)
				data_valid_temp <= 1'b0;
			else
				data_valid_temp <= 1'b1;
		end
		else
			data_valid_temp <= 1'b0;
	end
	
	always @(posedge clk or negedge rst_n)
	begin
		if(!rst_n) begin
			odata_valid <= 1'b0;
			orow_cnt <= 8'h0;
			ocol_cnt <= 8'h0;
		end
		else begin
			odata_valid <= data_valid_temp;
			if(odata_valid) begin
				if(orow_cnt == 8'd223) begin
					orow_cnt <= 8'h0;
					ocol_cnt <= ocol_cnt + 1'b1;
				end
				else
					orow_cnt <= orow_cnt + 1'b1;
			end
			else if(cur_state == SFICYCLE) begin
				orow_cnt <= 8'h0;
				ocol_cnt <= 8'h0;
			end
		end
	end
	assign orow_flag = odata_valid && (orow_cnt == 8'd0);	
					
	always @(posedge clk or negedge rst_n)
	begin
		if(!rst_n)
			aux_finish_flag <= 1'b0;
		else if(cur_state == SLDD) begin
			if((orow_cnt == 8'd222) && (ocol_cnt == 8'd223) && data_valid_temp)
				aux_finish_flag <= 1'b1;
		end
		else
			aux_finish_flag <= 1'b0;
	end
	
	//select output data
	assign odata_ch0 = bram_onuse ? dout_bram1_ch0 : dout_bram0_ch0;
	assign odata_ch1 = bram_onuse ? dout_bram1_ch1 : dout_bram0_ch1;
	assign odata_ch2 = bram_onuse ? dout_bram1_ch2 : dout_bram0_ch2;
	
	//generate para read and valid signals
	always @(posedge clk or negedge rst_n)
	begin
		if(!rst_n)
			para_rd_r <= 1'b0;
		else if((cur_state == SLDP) && (para_cnt < (PARA_SIZE - 1'b1)))
			para_rd_r <= !ipara_empty;
		else
			para_rd_r <= 1'b0;
	end
	assign opara_rd = para_rd_r & (!ipara_empty);
	
	always @(posedge clk or negedge rst_n)
	begin
		if(!rst_n)
			para_cnt <= 9'h0;
		else if(opara_rd)
			para_cnt <= para_cnt + 1'b1;
		else if(cur_state != SLDP)
			para_cnt <= 9'h0;
	end
	
	always @(posedge clk or negedge rst_n)
	begin
		if(!rst_n)
			para_rd_ch <= 2'b00;
		else if(opara_rd)
			if(para_rd_ch == 2'b10)
				para_rd_ch <= 2'b00;
			else
				para_rd_ch <= para_rd_ch + 1'b1;
	end
	
	always @(posedge clk or negedge rst_n)
	begin
		if(!rst_n) begin
			opara_valid_ch0 <= 1'b0;
			opara_valid_ch1 <= 1'b0;
			opara_valid_ch2 <= 1'b0;
		end
		else if(opara_rd) begin
			if(para_rd_ch == 2'b00) begin
				opara_valid_ch0 <= 1'b1;
				opara_valid_ch1 <= 1'b0;
				opara_valid_ch2 <= 1'b0;
			end
			else if(para_rd_ch == 2'b01) begin
				opara_valid_ch0 <= 1'b0;
				opara_valid_ch1 <= 1'b1;
				opara_valid_ch2 <= 1'b0;
			end
			else if(para_rd_ch == 2'b10) begin
				opara_valid_ch0 <= 1'b0;
				opara_valid_ch1 <= 1'b0;
				opara_valid_ch2 <= 1'b1;
			end 
		end
		else begin
			opara_valid_ch0 <= 1'b0;
			opara_valid_ch1 <= 1'b0;
			opara_valid_ch2 <= 1'b0;
		end
	end
	
	assign oover_flag = (cur_state == SFICYCLE) && finish_state_flag && (cycles == 3'b101);

endmodule

//conv0 layer base functional unit
module conv0_fu_test(
	input					clk,
	input					rst_n,

	input		[7:0]		idata0,
	input 		[7:0]		idata1,
	input		[7:0]		idata2,

	input					id_valid,

	input		[7:0]		iweight,
	input					iw_valid0,
	input					iw_valid1,
	input					iw_valid2,

	input		[7:0]		irow_cnt,
	input		[7:0]		icol_cnt,
	
	input					irow_flag,			//signal indicate a new row
	output	reg				ofinish_flag,		//finish a cycle of calc

	output	reg	[71:0]		odata,
	output	reg				owr_valid,				//temp result
	output	reg	[8:0]		oresult_valid
	);
	
	parameter				KERNEL_NUM_ROW = 3;
	parameter				KERNEL_NUM_COL = 3;
	parameter				KERNEL_NUM = KERNEL_NUM_ROW * KERNEL_NUM_COL;
	parameter				KERNEL_SIZE = 12;
	parameter				KERNEL = 144;
	
	//state machine parameter
	parameter				SIDLE = 2'b00;
	parameter				SSTART = 2'b01;
	parameter				SACCU = 2'b10;
	parameter				SLAST = 2'b11;
	
	reg			[7:0]		data_r0[KERNEL_NUM-1:0];
	reg			[7:0]		data_r1[KERNEL_NUM-1:0];
	reg			[7:0]		data_r2[KERNEL_NUM-1:0];

(* max_fanout = "10000" *)	reg			[7:0]		weight_buf0;
(* max_fanout = "10000" *)	reg			[7:0]		weight_buf1;
(* max_fanout = "10000" *)	reg			[7:0]		weight_buf2;

	reg						iw_valid_delay0 = 1'b0;
	reg						iw_valid_delay1 = 1'b0;
	reg						iw_valid_delay2 = 1'b0;

(* ram_style="distributed" *)	reg			[7:0]		weight_store0[KERNEL - 1:0];
(* ram_style="distributed" *)	reg			[7:0]		weight_store1[KERNEL - 1:0];
(* ram_style="distributed" *)	reg			[7:0]		weight_store2[KERNEL - 1:0];

	reg			[7:0]		weight_wr_addr0;
	reg			[7:0]		weight_wr_addr1;
	reg			[7:0]		weight_wr_addr2;

	wire		[7:0]		weight_rd_addr0[KERNEL_NUM - 1:0];
	wire		[7:0]		weight_rd_addr1[KERNEL_NUM - 1:0];
	wire		[7:0]		weight_rd_addr2[KERNEL_NUM - 1:0];

	reg			[7:0]		weight_in0[KERNEL_NUM - 1:0];
	reg			[7:0]		weight_in1[KERNEL_NUM - 1:0];
	reg			[7:0]		weight_in2[KERNEL_NUM - 1:0];


	reg		[47:0]		P[KERNEL_NUM - 1:0];
	
	wire		[23:0]		kernel_temp[KERNEL_NUM - 1:0];
	reg						mode_sel[KERNEL_NUM - 1:0];

	
	reg			[3:0]		row_addr[KERNEL_NUM_ROW - 1:0];
	reg			[3:0]		col_addr[KERNEL_NUM_COL - 1:0];
	
	reg			[1:0]		row_cur_state[KERNEL_NUM_ROW - 1:0];
	reg			[1:0]		row_nxt_state[KERNEL_NUM_ROW - 1:0];
	reg			[1:0]		col_cur_state[KERNEL_NUM_COL - 1:0];
	reg			[1:0]		col_nxt_state[KERNEL_NUM_COL - 1:0];
	wire					row_valid_flag[KERNEL_NUM_ROW - 1:0];
//	wire					row_repeat_flag[KERNEL_NUM_ROW - 1:0];
	wire					row_end_flag[KERNEL_NUM_ROW - 1:0];
	reg						row_end_flag_exp;											//as the third kernel has a row_cnt input of 223, but the same time as last state
	wire					row_last_flag[KERNEL_NUM_ROW - 1:0];
	wire					col_valid_flag[KERNEL_NUM_COL - 1:0];
//	wire					col_repeat_flag[KERNEL_NUM_COL - 1:0];
	wire					col_end_flag[KERNEL_NUM_COL - 1:0];
	wire					col_last_flag[KERNEL_NUM_COL - 1:0];
	reg						col_end_flag_exp;
	integer					i,j,k;
	
	reg			[2:0]			wr_en_r;
	reg			[2:0]			wr_en_delay;
	reg			[2:0]			wr_en_delay1;
	
	reg			[2:0]			col_wr_valid;
	reg			[2:0]			wr_valid_delay;
	reg			[2:0]			wr_valid_delay1;
	
	reg			[8:0]			result_valid_temp;
	reg			[8:0]			result_valid_delay;
	reg			[8:0]			result_valid_delay1;
	reg			[8:0]			result_valid_delay2;
	
	reg							last_line_flag;	
	reg			[3:0]			finish_delay;				//delay flag to generate finish flag at proper time
	
	//delay a cycle for input data
	always @(*)
	begin
			data_r0[0] <= idata0;
			data_r0[1] <= idata0;
			data_r0[2] <= idata0;
			data_r0[3] <= idata0;
			data_r0[4] <= idata0;
			data_r0[5] <= idata0;
			data_r0[6] <= idata0;
			data_r0[7] <= idata0;
			data_r0[8] <= idata0;
			data_r1[0] <= idata1;
			data_r1[1] <= idata1;
			data_r1[2] <= idata1;
			data_r1[3] <= idata1;
			data_r1[4] <= idata1;
			data_r1[5] <= idata1;
			data_r1[6] <= idata1;
			data_r1[7] <= idata1;
			data_r1[8] <= idata1;
			data_r2[0] <= idata2;
			data_r2[1] <= idata2;
			data_r2[2] <= idata2;
			data_r2[3] <= idata2;
			data_r2[4] <= idata2;
			data_r2[5] <= idata2;
			data_r2[6] <= idata2;
			data_r2[7] <= idata2;
			data_r2[8] <= idata2;
	end
	always @(posedge clk or negedge rst_n)
	begin
		if(!rst_n) begin
			weight_buf0 <= 8'h0;
			weight_buf1 <= 8'h0;
			weight_buf2 <= 8'h0;
		end
		else begin
			weight_buf0 <= iweight;
                                                weight_buf1 <= iweight;
			weight_buf2 <= iweight;

		end
	end
	always @(posedge clk) begin
		iw_valid_delay0 <= iw_valid0;
		iw_valid_delay1 <= iw_valid1;
		iw_valid_delay2 <= iw_valid2;
    end

	
	//buffer weight0
	always @(posedge clk or negedge rst_n)
	begin
		if(!rst_n)
			weight_wr_addr0 <= 8'h0;
		else if(iw_valid_delay0) begin
			if(weight_wr_addr0 == KERNEL - 1)
				weight_wr_addr0 <= 8'h0;
			else
				weight_wr_addr0 <= weight_wr_addr0 + 1'b1;
		end
	end
	
	always @(posedge clk or negedge rst_n)
	begin
		if(!rst_n)
			for(k=0;k<KERNEL;k=k+1)
				weight_store0[k] <= 8'h0;
		else begin
			if(iw_valid_delay0)
				weight_store0[weight_wr_addr0] <= weight_buf0;
		end
	end
	//buffer weight1
	always @(posedge clk or negedge rst_n)
	begin
		if(!rst_n)
			weight_wr_addr1 <= 8'h0;
		else if(iw_valid_delay1) begin
			if(weight_wr_addr1 == KERNEL - 1)
				weight_wr_addr1 <= 8'h0;
			else
				weight_wr_addr1 <= weight_wr_addr1 + 1'b1;
		end
	end
	
	always @(posedge clk or negedge rst_n)
	begin
		if(!rst_n)
			for(k=0;k<KERNEL;k=k+1)
				weight_store1[k] <= 8'h0;
		else begin
			if(iw_valid_delay1)
				weight_store1[weight_wr_addr1] <= weight_buf1;
		end
	end
	//buffer weight2
	always @(posedge clk or negedge rst_n)
	begin
		if(!rst_n)
			weight_wr_addr2 <= 8'h0;
		else if(iw_valid_delay2) begin
			if(weight_wr_addr2 == KERNEL - 1)
				weight_wr_addr2 <= 8'h0;
			else
				weight_wr_addr2 <= weight_wr_addr2 + 1'b1;
		end
	end
	
	always @(posedge clk or negedge rst_n)
	begin
		if(!rst_n)
			for(k=0;k<KERNEL;k=k+1)
				weight_store2[k] <= 8'h0;
		else begin
			if(iw_valid_delay2)
				weight_store2[weight_wr_addr2] <= weight_buf2;
		end
	end
	
	//transfer condition for state machines
	assign row_valid_flag[0] = id_valid & (irow_cnt < 8'd216);
	assign row_valid_flag[1] = id_valid & (irow_cnt < 8'd220) & (irow_cnt > 8'd3);
	assign row_valid_flag[2] = id_valid & (irow_cnt > 8'd7);
	assign row_end_flag[0] = id_valid & (irow_cnt >= 8'd216);
	assign row_end_flag[1] = id_valid & (irow_cnt >= 8'd220);
	
	always @(posedge clk or negedge rst_n)
	begin
		if(!rst_n)
			row_end_flag_exp <= 1'b0;
		else if(id_valid & (irow_cnt == 8'd223))
			row_end_flag_exp <= 1'b1;
		else
			row_end_flag_exp <= 1'b0;
	end
	assign row_end_flag[2] = row_end_flag_exp;
			
	//row state machine
	genvar ii;
	generate
	begin: row_state_machine_inst
		for(ii=0;ii<KERNEL_NUM_ROW;ii=ii+1)
		begin
			always @(posedge clk or negedge rst_n)
			begin
				if(!rst_n)
					row_cur_state[ii] <= SIDLE;
				else
					row_cur_state[ii] <= row_nxt_state[ii];
			end
		
			always @(*)
			begin
				row_nxt_state[ii] <= SIDLE;
				case(row_cur_state[ii])
					SIDLE:		if(row_valid_flag[ii])
									row_nxt_state[ii] <= SSTART;
								else
									row_nxt_state[ii] <= SIDLE;
					SSTART:		if(row_valid_flag[ii])
									row_nxt_state[ii] <= SACCU;
								else
									row_nxt_state[ii] <= SSTART;
					SACCU:		if(row_last_flag[ii])
									row_nxt_state[ii] <= SLAST;
								else
									row_nxt_state[ii] <= SACCU;
					SLAST:		if(row_end_flag[ii])
									row_nxt_state[ii] <= SIDLE;
								else if(row_valid_flag[ii])
									row_nxt_state[ii] <= SSTART;
								else
									row_nxt_state[ii] <= SLAST;
					default:	row_nxt_state[ii] <= SIDLE;
				endcase
			end
			
			//generate 2D address of feature in kernel
			always @(posedge clk or negedge rst_n)
			begin
				if(!rst_n)
					row_addr[ii] <= 4'h0;
				else begin
					if(row_valid_flag[ii]) begin
						if(row_nxt_state[ii] == SLAST)
							row_addr[ii] <= 4'h0;
						else if((row_nxt_state[ii] == SACCU) || (row_nxt_state[ii] == SSTART))
							row_addr[ii] <= row_addr[ii] + 1'b1;
					end
				end
			end
			
//			assign row_repeat_flag[ii] = id_valid && (row_addr[ii] == 4'd0);
			assign row_last_flag[ii] = id_valid && (row_addr[ii] == 4'd11);	 
		end
	end
	endgenerate
	
	//transfer condition for state machines
	assign col_valid_flag[0] = irow_flag & (icol_cnt < 8'd216);
	assign col_valid_flag[1] = irow_flag & (icol_cnt < 8'd220) & (icol_cnt > 8'd3);
	assign col_valid_flag[2] = irow_flag & (icol_cnt > 8'd7);
	assign col_end_flag[0] = irow_flag & (icol_cnt >= 8'd216);
	assign col_end_flag[1] = irow_flag & (icol_cnt >= 8'd220);
	
	always @(posedge clk or negedge rst_n)
	begin
		if(!rst_n)
			col_end_flag_exp <= 1'b0;
		else
			col_end_flag_exp <= id_valid & (irow_cnt == 8'd223) & (icol_cnt == 8'd223);
	end
	assign col_end_flag[2] = col_end_flag_exp;
			
	//col state machine
	genvar jj;
	generate
	begin: col_state_machine_inst
		for(jj=0;jj<KERNEL_NUM_COL;jj=jj+1)
		begin
			always @(posedge clk or negedge rst_n)
			begin
				if(!rst_n)
					col_cur_state[jj] <= SIDLE;
				else
					col_cur_state[jj] <= col_nxt_state[jj];
			end
		
			always @(*)
			begin
				col_nxt_state[jj] <= SIDLE;
				case(col_cur_state[jj])
					SIDLE:		if(col_valid_flag[jj])
									col_nxt_state[jj] <= SSTART;
								else
									col_nxt_state[jj] <= SIDLE;
					SSTART:		if(col_valid_flag[jj])
									col_nxt_state[jj] <= SACCU;
								else
									col_nxt_state[jj] <= SSTART;
					SACCU:		if(col_last_flag[jj])
									col_nxt_state[jj] <= SLAST;
								else
									col_nxt_state[jj] <= SACCU;
					SLAST:		if(col_end_flag[jj])
									col_nxt_state[jj] <= SIDLE;
								else if(col_valid_flag[jj])
									col_nxt_state[jj] <= SSTART;
								else
									col_nxt_state[jj] <= SLAST;
					default:	col_nxt_state[jj] <= SIDLE;
				endcase
			end
			
			//generate 2D address of feature in kernel
			always @(posedge clk or negedge rst_n)
			begin
				if(!rst_n)
					col_addr[jj] <= 4'h0;
				else begin
					if(id_valid && (irow_cnt == 8'd223)) begin
						if(col_nxt_state[jj] == SLAST)
							col_addr[jj] <= 4'h0;
						else if((col_nxt_state[jj] == SACCU) || (col_nxt_state[jj] == SSTART))
							col_addr[jj] <= col_addr[jj] + 1'b1;
					end
				end
			end
			
//			assign col_repeat_flag[jj] = irow_flag && (col_addr[jj] == 4'd0);	 
			assign col_last_flag[jj] = irow_flag && (col_addr[jj] == 4'd11);	
		end
	end
	endgenerate
	
	//generate weight read address
	assign weight_rd_addr0[0] = col_addr[0] * 4'd12 + row_addr[0];
	assign weight_rd_addr0[1] = col_addr[0] * 4'd12 + row_addr[1];
	assign weight_rd_addr0[2] = col_addr[0] * 4'd12 + row_addr[2];
	assign weight_rd_addr0[3] = col_addr[1] * 4'd12 + row_addr[0];
	assign weight_rd_addr0[4] = col_addr[1] * 4'd12 + row_addr[1];
	assign weight_rd_addr0[5] = col_addr[1] * 4'd12 + row_addr[2];
	assign weight_rd_addr0[6] = col_addr[2] * 4'd12 + row_addr[0];
	assign weight_rd_addr0[7] = col_addr[2] * 4'd12 + row_addr[1];
	assign weight_rd_addr0[8] = col_addr[2] * 4'd12 + row_addr[2];

	assign weight_rd_addr1[0] = col_addr[0] * 4'd12 + row_addr[0];
	assign weight_rd_addr1[1] = col_addr[0] * 4'd12 + row_addr[1];
	assign weight_rd_addr1[2] = col_addr[0] * 4'd12 + row_addr[2];
	assign weight_rd_addr1[3] = col_addr[1] * 4'd12 + row_addr[0];
	assign weight_rd_addr1[4] = col_addr[1] * 4'd12 + row_addr[1];
	assign weight_rd_addr1[5] = col_addr[1] * 4'd12 + row_addr[2];
	assign weight_rd_addr1[6] = col_addr[2] * 4'd12 + row_addr[0];
	assign weight_rd_addr1[7] = col_addr[2] * 4'd12 + row_addr[1];
	assign weight_rd_addr1[8] = col_addr[2] * 4'd12 + row_addr[2];

	assign weight_rd_addr2[0] = col_addr[0] * 4'd12 + row_addr[0];
	assign weight_rd_addr2[1] = col_addr[0] * 4'd12 + row_addr[1];
	assign weight_rd_addr2[2] = col_addr[0] * 4'd12 + row_addr[2];
	assign weight_rd_addr2[3] = col_addr[1] * 4'd12 + row_addr[0];
	assign weight_rd_addr2[4] = col_addr[1] * 4'd12 + row_addr[1];
	assign weight_rd_addr2[5] = col_addr[1] * 4'd12 + row_addr[2];
	assign weight_rd_addr2[6] = col_addr[2] * 4'd12 + row_addr[0];
	assign weight_rd_addr2[7] = col_addr[2] * 4'd12 + row_addr[1];
	assign weight_rd_addr2[8] = col_addr[2] * 4'd12 + row_addr[2];	
	
	//feed feature and weight into kernel
	always @(posedge clk or negedge rst_n)
	begin
		if(!rst_n)
			for(i=0;i<KERNEL_NUM;i=i+1)
				weight_in0[i] <= 8'h0;
		else begin
			if(id_valid)
				for(i=0;i<KERNEL_NUM;i=i+1)
					weight_in0[i] <= weight_store0[weight_rd_addr0[i]];
			else
			    for(i=0;i<KERNEL_NUM;i=i+1)
				    weight_in0[i] <= 8'h0;
		end
	end

	always @(posedge clk or negedge rst_n)
	begin
		if(!rst_n)
			for(i=0;i<KERNEL_NUM;i=i+1)
				weight_in1[i] <= 8'h0;
		else begin
			if(id_valid)
				for(i=0;i<KERNEL_NUM;i=i+1)
					weight_in1[i] <= weight_store1[weight_rd_addr1[i]];
			else
			    for(i=0;i<KERNEL_NUM;i=i+1)
				    weight_in1[i] <= 8'h0;
		end
	end

	always @(posedge clk or negedge rst_n)
	begin
		if(!rst_n)
			for(i=0;i<KERNEL_NUM;i=i+1)
				weight_in2[i] <= 8'h0;
		else begin
			if(id_valid)
				for(i=0;i<KERNEL_NUM;i=i+1)
					weight_in2[i] <= weight_store2[weight_rd_addr2[i]];
			else
			    for(i=0;i<KERNEL_NUM;i=i+1)
				    weight_in2[i] <= 8'h0;
		end
	end
	
	//select mode of accu
	always @(posedge clk or negedge rst_n)
	begin
		if(!rst_n)
			for(i=0;i<KERNEL_NUM;i=i+1)
				mode_sel[i] <= 1'b0;
		else begin
			for(i=0;i<KERNEL_NUM_ROW;i=i+1)
				for(j=0;j<KERNEL_NUM_COL;j=j+1)
					if(((row_nxt_state[i] == SACCU) || (row_nxt_state[i] == SLAST)) && (col_nxt_state[j] != SIDLE))
						mode_sel[j * KERNEL_NUM_ROW + i] <= 1'b1;
					else
						mode_sel[j * KERNEL_NUM_ROW + i] <= 1'b0;
		end
	end
	wire [17:0] data_a[KERNEL_NUM-1:0]; 
                wire [8:0] data_a0[KERNEL_NUM-1:0]; 
	wire [17:0] data_b[KERNEL_NUM-1:0];
	wire [8:0] data_b0[KERNEL_NUM-1:0];
	reg [17:0] data_b_reg[KERNEL_NUM-1:0];
	reg [8:0] data_b0_reg[KERNEL_NUM-1:0];
	wire [53:0] data_amult[KERNEL_NUM-1:0];
	wire [8:0] opmode[KERNEL_NUM - 1:0];

	genvar nn;
	generate 
	begin
		for(nn=0;nn<KERNEL_NUM;nn=nn+1)
		begin

	        assign data_b[nn] = {data_r1[nn][7],data_r1[nn][7:0],data_r0[nn][7],data_r0[nn][7:0]};
                        assign data_b0[nn] = {data_r2[7:0],data_r2[nn][7:0]};
	        assign data_a[nn] ={weight_in1[nn][7],weight_in1[nn][7:0],weight_in0[nn][7],weight_in0[nn][7:0]};
                        assign data_a0[nn] ={weight_in2[nn][7],weight_in2[nn][7:0]};
			//assign opmode[nn] = mode_sel[nn] ? 9'b0_0010_0101 : 9'b0_0011_0101; // 0: A*B+C; 1: A*B+P
             
	always @(posedge clk or negedge rst_n)
	begin
		if(!rst_n) begin
			data_b_reg[nn] <=18'b0;
                                                data_b0_reg[nn] <=9'b0;
		end
		else begin
			data_b_reg[nn] <=data_b[nn];
                                                data_b0_reg[nn] <=data_b0[nn];;
 		end

		end
	end
end
	endgenerate


	wire		[47:0]		Y[KERNEL_NUM - 1:0];
                wire                         [23:0]                        Y0[KERNEL_NUM - 1:0];
	genvar nn;
	generate
	begin: conv0_kernel_calc
		for(nn=0;nn<KERNEL_NUM;nn=nn+1)
		begin

			wire signed [23:0] C_0;
			wire signed [15:0] C_2;

			//wire signed [8:0] A_0 = data_a[nn][8:0];
			//wire signed [8:0] B_0 = data_b_reg[nn][8:0];
			//wire signed [8:0] A_1 = data_a[nn][17:9];
			//wire signed [8:0] B_1 = data_b_reg[nn][17:9];
			wire signed [8:0] A_2 = data_a0[nn];
			wire signed [8:0] B_2 = data_b0_reg[nn];
                                               //using multiple 9bit MAC
                                              MULT54X54 #(.A_w(18),.B_w(18))inst(
                                                                      .A(data_a[nn]),
                                                                     .B(data_b_reg[nn]),
                                                                     .Y(C_0)
                                                                               );
			assign C_2 = A_2 * B_2;

                                                assign Y0[nn] = C_0;
                                                assign Y[nn] = Y0[nn]+C_2;
			/*assign Y[nn][44:24] = C_5 + C_4 + C_3;
			assign Y[nn][23:0] = C_2 + C_1 + C_0;*/
/*
		always @(posedge clk or negedge rst_n)
		begin
			if(!rst_n)
				P[nn] <= 0;
			else
				P[nn] <= Y[nn];
		end
*/


		always @(posedge clk)
		begin
			if(mode_sel[nn])
				P[nn] <= P[nn] + Y[nn];
			else
				P[nn] <= Y[nn];
		end

	        	

			assign kernel_temp[nn] = P[nn][23:0];
		end
	end
	endgenerate

	
	//buffer row calc results
	always @(posedge clk or negedge rst_n)
	begin
		if(!rst_n)
			last_line_flag <= 1'b0;
		else
			last_line_flag <= (icol_cnt == 8'd223);
	end
	
	//generate wr_en signal to write result of row into fifo, as dsp has 2 cycles delay, so delay two cycles to get right result
	always @(posedge clk or negedge rst_n)
	begin
		if(!rst_n) begin
			wr_en_r <= 3'h0;
			wr_en_delay <= 3'h0;
			wr_en_delay1 <= 3'h0;
			owr_valid <= 1'b0;
			col_wr_valid <= 3'b000;
			wr_valid_delay <= 3'b000;
			wr_valid_delay1 <= 3'b000;
		end
		else begin
			wr_en_r <= {(row_cur_state[2] == SLAST) & (!last_line_flag),
						(row_cur_state[1] == SLAST) & (!last_line_flag),
						(row_cur_state[0] == SLAST) & (!last_line_flag)};
			wr_en_delay <= wr_en_r;
			wr_en_delay1 <= wr_en_delay;
			col_wr_valid <= {(col_cur_state[2] != SIDLE),(col_cur_state[1] != SIDLE),(col_cur_state[0] != SIDLE)};
			wr_valid_delay <= col_wr_valid;
			wr_valid_delay1 <= wr_valid_delay;
			owr_valid <= |wr_en_delay1;
		end
	end
	
	//3 rows has temp result come at the same time, combine them to a 48 bits
	always @(posedge clk or negedge rst_n)
	begin
		if(!rst_n)
			odata <= 72'h0;
		else begin
			if(wr_en_delay1[0] | result_valid_delay2[0] | result_valid_delay2[3] | result_valid_delay2[6]) begin
				odata[23:0] <= wr_valid_delay1[0] ? kernel_temp[0] : 24'h0;
				odata[47:24] <= wr_valid_delay1[1] ? kernel_temp[3] : 24'h0;
				odata[71:48] <= wr_valid_delay1[2] ? kernel_temp[6] : 24'h0;
			end
			else if(wr_en_delay1[1] | result_valid_delay2[1] | result_valid_delay2[4] | result_valid_delay2[7]) begin
				odata[23:0] <= wr_valid_delay1[0] ? kernel_temp[1] : 24'h0;
				odata[47:24] <= wr_valid_delay1[1] ? kernel_temp[4] : 24'h0;
				odata[71:48] <= wr_valid_delay1[2] ? kernel_temp[7] : 24'h0;
			end
			else if(wr_en_delay1[2] | result_valid_delay2[2] | result_valid_delay2[5] | result_valid_delay2[8]) begin
				odata[23:0] <= wr_valid_delay1[0] ? kernel_temp[2] : 24'h0;
				odata[47:24] <= wr_valid_delay1[1] ? kernel_temp[5] : 24'h0;
				odata[71:48] <= wr_valid_delay1[2] ? kernel_temp[8] : 24'h0;
			end
		end
	end
	
	//output result
	always @(posedge clk or negedge rst_n)
	begin
		if(!rst_n)
			result_valid_temp <= 9'h0;
		else begin
			result_valid_temp[0] <= (row_nxt_state[0] == SLAST) && id_valid && (col_cur_state[0] == SLAST);
			result_valid_temp[1] <= (row_nxt_state[1] == SLAST) && id_valid && (col_cur_state[0] == SLAST);
			result_valid_temp[2] <= (row_nxt_state[2] == SLAST) && id_valid && (col_cur_state[0] == SLAST);
			result_valid_temp[3] <= (row_nxt_state[0] == SLAST) && id_valid && (col_cur_state[1] == SLAST);
			result_valid_temp[4] <= (row_nxt_state[1] == SLAST) && id_valid && (col_cur_state[1] == SLAST);
			result_valid_temp[5] <= (row_nxt_state[2] == SLAST) && id_valid && (col_cur_state[1] == SLAST);
			result_valid_temp[6] <= (row_nxt_state[0] == SLAST) && id_valid && (col_cur_state[2] == SLAST);
			result_valid_temp[7] <= (row_nxt_state[1] == SLAST) && id_valid && (col_cur_state[2] == SLAST);
			result_valid_temp[8] <= (row_nxt_state[2] == SLAST) && id_valid && (col_cur_state[2] == SLAST);
		end
	end
	
	always @(posedge clk or negedge rst_n)
	begin
		if(!rst_n) begin
			result_valid_delay <= 9'h0;
			result_valid_delay1 <= 9'h0;
			result_valid_delay2 <= 9'h0;
			oresult_valid <= 9'h0;
		end
		else begin
			result_valid_delay <= result_valid_temp;
			result_valid_delay1 <= result_valid_delay;
			result_valid_delay2 <= result_valid_delay1;
			oresult_valid <= result_valid_delay2;
		end
	end
	
	//generate finish_flag signal
	always @(posedge clk or negedge rst_n)
	begin
		if(!rst_n) begin
			finish_delay <= 4'h0;
			ofinish_flag <= 1'b0;
		end
		else begin
			finish_delay[0] <= (irow_cnt == 8'd223) && (icol_cnt == 8'd223) && id_valid;
			finish_delay[3:1] <= finish_delay[2:0];
			ofinish_flag <= finish_delay[3];
		end
	end
	
endmodule

//conv0 layer generate output feature map
module conv0_go_test(
	input					clk,
	input					rst_n,
	
	input		[71:0]		idata_map,
	
	input					itemp_valid,
	input		[8:0]		iresult_valid,
	input					ifinish_flag,
	
	output	reg	[1:0]		odata,
	output	reg				ovalid
);

	parameter				REF_VALUE0 = 16'd21;			// 128/6=21
	parameter				REF_VALUE1 = 16'd64;			// 128/2=64
	parameter				REF_VALUE2 = 16'd107;			// 128*5/6=107
//	reg			[23:0]		data_sum1[2:0];
//	reg			[23:0]		data_sum2[2:0];

	reg			[23:0]		data_sum[2:0];

	reg			[23:0]		temp_in[2:0];
	wire		[23:0]		temp_out[2:0];
	reg			[8:0]		go_valid[2:0];
	
	reg			[1:0]		wr_en_r;
	reg						wr_en;
	wire		[71:0]		data_temp_in;
	wire					rd_en;
	wire		[71:0]		data_temp_out;
	wire					full;
	wire					empty;
	wire		[5:0]		data_count;
	reg						rd_flag;
	reg			[3:0]		finish_flag_delay;
	
	always @(posedge clk or negedge rst_n)
	begin
		if(!rst_n) begin
			wr_en <= 1'b0;
			wr_en_r <= 2'b00;
		
			data_sum[0] <= 24'h0;
			data_sum[1] <= 24'h0;
			data_sum[2] <= 24'h0;
		end
		else begin
			wr_en_r <= {wr_en_r[0],itemp_valid};
			wr_en <= wr_en_r[1];
			if(wr_en_r[0] | go_valid[0]) begin
				data_sum[2] <= temp_out[2] + idata_map[71:48];
				data_sum[1] <= temp_out[1] + idata_map[47:24];
				data_sum[0] <= temp_out[0] + idata_map[23:0];
			end
		end
	end
	
	always @(posedge clk or negedge rst_n)
	begin
		if(!rst_n) begin
			temp_in[0] <= 24'h0;
			temp_in[1] <= 24'h0;
			temp_in[2] <= 24'h0;
			go_valid[0] <= 9'h0;
			go_valid[1] <= 9'h0;
			go_valid[2] <= 9'h0;
		end
		else begin
			go_valid[0] <= iresult_valid;
			go_valid[1] <= go_valid[0];
			go_valid[2] <= go_valid[1];
			if(wr_en_r[1] | go_valid[1]) begin
				temp_in[0] <= data_sum[0];
				temp_in[1] <= data_sum[1];
				temp_in[2] <= data_sum[2];
			end
		end
	end
	assign data_temp_in[23:0] = (go_valid[2][0] | go_valid[2][1] | go_valid[2][2]) ? 24'h0 : temp_in[0];
	assign data_temp_in[47:24] = (go_valid[2][3] | go_valid[2][4] | go_valid[2][5]) ? 24'h0 : temp_in[1];
	assign data_temp_in[71:48] = (go_valid[2][6] | go_valid[2][7] | go_valid[2][8]) ? 24'h0 : temp_in[2];
	
	always @(posedge clk or negedge rst_n)
	begin
		if(!rst_n) begin
			finish_flag_delay <= 4'h0;
			rd_flag <= 1'b0;
		end
		else begin
			finish_flag_delay <= {finish_flag_delay[2:0],ifinish_flag};
			if(data_count == 6'd54)
				rd_flag <= 1'b1;
			else if(finish_flag_delay[3])
				rd_flag <= 1'b0;
		end
	end
	assign rd_en = (itemp_valid | (|iresult_valid)) & rd_flag;
	
	conv0_temp_buf_test conv0_temp_buf_inst (
  		.clk(clk),                // input wire clk
  		.rst(!rst_n),                // input wire rst
  		.din(data_temp_in),                // input wire [71 : 0] din
  		.wr_en(wr_en),            // input wire wr_en
  		.rd_en(rd_en),            // input wire rd_en
  		.dout(data_temp_out),              // output wire [71 : 0] dout
  		.full(full),              // output wire full
  		.empty(empty),            // output wire empty
  		.data_count(data_count)  // output wire [5 : 0] data_count
	);
	assign temp_out[0] = rd_flag ? data_temp_out[23:0] : 24'h0;
	assign temp_out[1] = rd_flag ? data_temp_out[47:24] : 24'h0;
	assign temp_out[2] = rd_flag ? data_temp_out[71:48] : 24'h0;
			
	always @(posedge clk or negedge rst_n)
	begin
		if(!rst_n) begin
			odata <= 2'b00;
			ovalid <= 1'b0;
		end
		else begin
			ovalid <= |go_valid[2];
			case({(go_valid[2][8] | go_valid[2][7] | go_valid[2][6]),(go_valid[2][5] | go_valid[2][4] | go_valid[2][3]),(go_valid[2][2] | go_valid[2][1] | go_valid[2][0])})
				3'b001:		begin
								if(temp_in[0][23] || (temp_in[0][23:7] < REF_VALUE0))							//multiplication cause point drifting, so divided by 128
									odata <= 2'b00;
								else if(temp_in[0][23:7] < REF_VALUE1)
									odata <= 2'b01;
								else if(temp_in[0][23:7] < REF_VALUE2)
									odata <= 2'b10;
								else
									odata <= 2'b11;
							end
				3'b010:		begin
								if(temp_in[1][23] || (temp_in[1][23:7] < REF_VALUE0))							//multiplication cause point drifting, so divided by 128
									odata <= 2'b00;
								else if(temp_in[1][23:7] < REF_VALUE1)
									odata <= 2'b01;
								else if(temp_in[1][23:7] < REF_VALUE2)
									odata <= 2'b10;
								else
									odata <= 2'b11;
							end
				3'b100:		begin
								if(temp_in[2][23] || (temp_in[2][23:7] < REF_VALUE0))							//multiplication cause point drifting, so divided by 128
									odata <= 2'b00;
								else if(temp_in[2][23:7] < REF_VALUE1)
									odata <= 2'b01;
								else if(temp_in[2][23:7] < REF_VALUE2)
									odata <= 2'b10;
								else
									odata <= 2'b11;
							end
			endcase
		end
	end

endmodule

module conv0_temp_buf_test#(
                 parameter   data_width = 72,
                 parameter   data_depth = 64,
                 parameter   addr_width = 6
)


(
                  input                           clk,
                  input                           rst,//active high
                  input                           wr_en,
                  input       [data_width-1:0]    din,         
                  input                           rd_en,
                  output reg  [5:0]               data_count,
                  output reg [data_width-1:0]     dout,
                  output                          empty,
                  output                          full
    );


reg  [addr_width-1:0]  wr_addr;// 写地址
reg  [addr_width-1:0]  rd_addr;// 读地址
reg  [addr_width  :0]  gap_addr;//读写地址距离       


reg [data_width-1:0] fifo_ram [data_depth-1:0];

//=========================================================write fifo
integer i;

always@(posedge clk or posedge rst)
    begin
 if(rst) begin
	 for(i=0; i < data_depth; i = i+1)		 
          fifo_ram[i] <= 0;
  	end
  else begin
	if(wr_en && (~full))
          fifo_ram[wr_addr] <= din;
       else
         fifo_ram[wr_addr] <= fifo_ram[wr_addr];
    end   
end      
//========================================================read_fifo
always@(posedge clk or posedge rst)
   begin
      if(rst)
         begin
            dout <= 'h0;
            data_count <= 5'b0;
         end
      else if(rd_en && (~empty))
         begin
            dout <= fifo_ram[rd_addr];
            data_count <= data_count + 1;
         end
      else
         begin
            dout <= dout;
            data_count <= data_count;
         end
   end

//=======================================================control addr
always@(posedge clk  or  posedge rst) 
   begin
      if(rst)
         begin
            wr_addr <= 'h0;
            rd_addr <= 'h0;
            gap_addr <= 'h0;
         end
     else
        case({wr_en,rd_en})
           2'b00:;
           2'b01:
              begin
                 if(~empty)
                    begin
                       wr_addr <= wr_addr;
                       rd_addr <= rd_addr + 1;
                       gap_addr <= gap_addr -1 ;
                    end
              end
           2'b10:
              begin
                 if(~full)
                    begin
                       wr_addr <= wr_addr + 1;
                       rd_addr <= rd_addr ;
                       gap_addr <= gap_addr + 1 ;                       
                    end 
              end
           2'b11:
              begin
                 if(full)
                    begin
                       wr_addr <= wr_addr;
                       rd_addr <= rd_addr + 1'b1;
                       gap_addr <= gap_addr -1 ;                                             
                    end
                 else if(empty)
                    begin
                       wr_addr <= wr_addr + 1;
                       rd_addr <= rd_addr ;
                       gap_addr <= gap_addr + 1 ;                        
                    end
                 else
                    begin
                       wr_addr <= wr_addr + 1;
                       rd_addr <= rd_addr + 1;
                       gap_addr <= gap_addr ;                        
                    end

              end
           default:
              begin
                   wr_addr <= 'h0;
                   rd_addr <= 'h0;
                   gap_addr <= 'h0;
                end        
        endcase
   end

 assign empty = (gap_addr == 'h0)?1'b1:1'b0;
 assign full  = (rst)?1'b1:((gap_addr == (data_depth))?1'b1:1'b0);
endmodule

