`timescale 1ns/1ns
`define clk_period 20
module tb_axi_stream_insert_header();

//=============================================================================================================

parameter DATA_WD = 32;
parameter DATA_BYTE_WD = DATA_WD / 8;
parameter BYTE_CNT_WD = $clog2(DATA_BYTE_WD);

reg                       clk;
reg                       rst_n;
reg                       valid_in;
reg [DATA_WD-1 : 0]       data_in;
reg [DATA_WD-1 : 0]       data_insert;
wire [3:0]                keep_in;
wire [3:0]                keep_insert;
wire                      ready_in;
wire                      keep_out;
wire                      last_out;
wire                      valid_out;
wire [DATA_WD-1 : 0]      data_out;
wire                      ready_out;
wire                      ready_insert;
reg [BYTE_CNT_WD-1 : 0]   byte_insert_cnt;
reg                       valid_insert;
reg                       last_in;
wire [DATA_WD-1 : 0]      data_word_cnt;



//=============================================================================================================

//生成50MHZ 20ns的时钟信号
always #(`clk_period/2) clk = ~clk; 


//初始化clk和rst_n信号
initial begin
    clk = 1'b1;
    rst_n <= 1'b0;
    #(`clk_period)
    rst_n <= 1'b1; end


//data_insert
initial begin
    #(`clk_period*2)    
    data_insert = $random % 2000;
    #(`clk_period)
    data_insert = 'b0;
    #(`clk_period)    
    data_insert = $random % 2000;    
    #(`clk_period)
    data_insert = 'b0;
    #(`clk_period)    
    data_insert = $random % 2000;
    #(`clk_period)
    data_insert = 'b0;    
    #(`clk_period)    
    data_insert = $random % 2000; end


//data_in
initial begin
    #(`clk_period*3)    
    data_in = {$random} % 2000;
    #(`clk_period)
    data_in = 'b0;
    #(`clk_period)    
    data_in = {$random} % 2000;    
    #(`clk_period)
    data_in = 'b0;
    #(`clk_period)    
    data_in = {$random} % 2000;
    #(`clk_period)
    data_in = 'b0;    
    #(`clk_period)    
    data_in = {$random} % 2000; end



//keep_in
assign keep_in = 4'b1100;


//keep_insert
assign keep_insert = 4'b0011;


//ready_out
assign ready_out = valid_out;


//byte_insert_cnt 
always@(*)
    case(keep_insert)
        1111    :   byte_insert_cnt = 'd4;
        0111    :   byte_insert_cnt = 'd3;
        0011    :   byte_insert_cnt = 'd2;
        0001    :   byte_insert_cnt = 'd1;
        default :   byte_insert_cnt = 'd0;
    endcase

//valid_in
initial begin
    valid_in = 1'b0;
    #(`clk_period*3) //60ns
    valid_in = 1'b1;
    #(`clk_period) //80ns
    valid_in = 1'b0;    
    #(`clk_period) //100ns
    valid_in = 1'b1; 
    #(`clk_period) //120ns
    valid_in = 1'b0;  
    #(`clk_period) //140ns
    valid_in = 1'b1; 
    #(`clk_period) //160ns
    valid_in = 1'b0;
    #(`clk_period) //180ns
    valid_in = 1'b1; end


//valid_insert
initial begin
    valid_insert = 1'b0;
    #(`clk_period*2) //40ns
    valid_insert = 1'b1;
    #(`clk_period) //60ns
    valid_insert = 1'b0;    
    #(`clk_period) //80ns
    valid_insert = 1'b1; 
    #(`clk_period) //100ns
    valid_insert = 1'b0;  
    #(`clk_period) //120ns
    valid_insert = 1'b1; 
    #(`clk_period) //140ns
    valid_insert = 1'b0;
    #(`clk_period)    
    valid_insert = 1'b1; end


//last_in
initial begin
    last_in = 1'b0;
    #(`clk_period*9)
    last_in = 1'b1;
    #(`clk_period)
    last_in = 1'b0; end




//=============================================================================================================


axi_stream_insert_header axi_stream_insert_header_inst
(
    .clk            (clk),
    .rst_n          (rst_n),
// AXI Stream input original data
    .valid_in       (valid_in),
    .data_in        (data_in),
    .keep_in        (keep_in),
    .last_in        (last_in),
    .ready_in       (ready_in),//output
// AXI Stream output with header inserted
    .valid_out      (valid_out),//output
    .data_out       (data_out),//output
    .keep_out       (keep_out),//output
    .last_out       (last_out),//output
    .ready_out      (ready_out),
// The header to be inserted to AXI Stream input
    .valid_insert   (valid_insert),
    .data_insert    (data_insert),
    .keep_insert    (keep_insert),
    .byte_insert_cnt(byte_insert_cnt),
    .ready_insert   (ready_insert),//output
    .data_word_cnt  (data_word_cnt)
);


endmodule