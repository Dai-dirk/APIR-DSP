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

module FIFO_A(
    CLK,
    MDR,
    CHAINMODE,
    A,
    ACIN,
    RF_load,

    A_addr,
    ACOUT_addr,

    RSTA,
    RSTCHAINMODE,
    RSTMDR,

    CEA1,
    CEA2,
    CECHAINMODE,
    CEMDR,

    A_MULT,
    ACOUT
     );

    parameter registerfile_size = 8;
    parameter registerfile_size_log = $clog2(registerfile_size);

    parameter integer AREG = 1;
    parameter A_INPUT = "DIRECT";
    parameter integer CHAINMODEREG = 1;
    parameter [1:0] IS_CHAINMODE_INVERTED = 1'b0;
    parameter IS_RSTCHAINMODE_INVERTED = 1'b0;

    parameter integer MDRREG = 1;
    parameter IS_MDR_INVERTED = 1'b0;
    parameter IS_RSTMDR_INVERTED = 1'b0;


    input CLK;
    input MDR;
    input [1:0] CHAINMODE;

    input [29:0] A;
    input [29:0] ACIN;
    input RF_load;

    input [registerfile_size_log-1:0] A_addr;
    input [registerfile_size_log-1:0] ACOUT_addr;

    input RSTA;
    input RSTCHAINMODE;
    input RSTMDR;

    input CEA1;
    input CEA2;
    input CECHAINMODE;
    input CEMDR;

    output [53:0] A_MULT;
    output reg [29:0] ACOUT;

    reg        [1:0]  CHAINMODEr;
    reg        MDRr;

    wire signed [29:0] A_muxed;

generate
     if (A_INPUT == "CASCADE") assign A_muxed = ACIN;
        else assign A_muxed = A;

    if (CHAINMODEREG == 1) initial CHAINMODEr = 0;
    if (CHAINMODEREG == 1) begin always @(posedge CLK) if (RSTCHAINMODE) CHAINMODEr <= 0; else if (CECHAINMODE) CHAINMODEr <= CHAINMODE; end
    else           always @* CHAINMODEr <= CHAINMODE;
    if (MDRREG == 1) initial MDRr = 0;
    if (MDRREG == 1) begin always @(posedge CLK) if (RSTMDR) MDRr <= 0; else if (CEMDR) MDRr <= MDR; end
    else           always @* MDRr <= MDR;
endgenerate
reg [29:0] A_RF [7:0];

    generate
    integer j;
    // RF as A_muxed shift register
    always@(posedge CLK) begin
        if (RSTA) begin
            for ( j = 0; j < 8; j = j + 1) begin
                A_RF[j] <= 30'b0;
            end
        end
        else begin
            if (CEA1 | RF_load) begin
                A_RF[0] <= A_muxed;
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
            a_mult_temp_0 = A_RF[A_addr][26:0];
            a_mult_temp_1 = A_RF[A_addr + 1][26:0];
        end
        else begin
            a_mult_temp_0 = A_RF[A_addr][26:0];
            a_mult_temp_1 = 27'bx;
end
    end


   wire signed [53:0] A_MULT = {a_mult_temp_1,a_mult_temp_0};


    always @ (*) begin
        case (CHAINMODEr)
            2'b00: begin
                if (ACOUT_addr == 0) begin
                    ACOUT = A_muxed;
                end
                else begin
                    ACOUT = A_RF[ACOUT_addr - 1];
                end
            end
         /*   2'b01: begin
                ACOUT = {{9'b0_0000_0000},{B1B0_stream}};
            end
            2'b10: begin
                ACOUT = {{9'b0_0000_0000},{B_MUX}};
            end*/
            default: begin
                ACOUT = 18'bx;
            end

        endcase
    end

endmodule


