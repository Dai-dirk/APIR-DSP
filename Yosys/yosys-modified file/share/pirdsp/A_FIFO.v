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
