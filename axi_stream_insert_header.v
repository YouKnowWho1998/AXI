module axi_stream_insert_header #(
    parameter DATA_WD = 32,
    parameter DATA_BYTE_WD = DATA_WD / 8,
    parameter BYTE_CNT_WD = $clog2(DATA_BYTE_WD)
) (
    input   wire                       clk,
    input   wire                       rst_n,
// AXI Stream input original data
    input   wire                       valid_in,
    input   wire [DATA_WD-1 : 0]       data_in,
    input   wire [DATA_BYTE_WD-1 : 0]  keep_in,
    input   wire                       last_in,
    output  reg                        ready_in,
// AXI Stream output with header inserted
    output  wire                       valid_out,
    output  reg  [DATA_WD-1 : 0]       data_out,
    output  wire [DATA_BYTE_WD-1 : 0]  keep_out,
    output  wire                       last_out,
    input   wire                       ready_out,
// The header to be inserted to AXI Stream input
    input   wire                       valid_insert,
    input   wire [DATA_WD-1 : 0]       data_insert,
    input   wire [DATA_BYTE_WD-1 : 0]  keep_insert,
    input   wire [BYTE_CNT_WD-1 : 0]   byte_insert_cnt,
    output  reg                        ready_insert,
    output  reg  [DATA_WD-1 : 0]       data_word_cnt//自己添加
);
//=======================================================================================================================

reg  [7:0]                  byte0,byte1,byte2,byte3;
reg  [7:0]                  byte4,byte5,byte6,byte7;
reg  [7:0]                  byte8,byte9,byte10,byte11;
reg  [DATA_WD-1 : 0]        data_in_reg;
reg  [DATA_WD-1 : 0]        data_insert_reg;

//===============================data_processing_unit=============================================================================


//定义四个字节
always@(*) begin
    byte0 = data_in_reg[7:0];
    byte1 = data_in_reg[15:8];
    byte2 = data_in_reg[23:16];
    byte3 = data_in_reg[31:24]; end


//根据keep_in处理四个字节
always@(*) 
    if(last_in) begin
        byte0 = (keep_in[0] == 1'b1) ? byte0 : 8'b0000_0000;
        byte1 = (keep_in[1] == 1'b1) ? byte1 : 8'b0000_0000;
        byte2 = (keep_in[2] == 1'b1) ? byte2 : 8'b0000_0000;
        byte3 = (keep_in[3] == 1'b1) ? byte3 : 8'b0000_0000; end
    else    begin
        byte0 = byte0; 
        byte1 = byte1; 
        byte2 = byte2; 
        byte3 = byte3; end


//===============================header_processing_unit=============================================================================


//定义四个字节
always@(*) begin
    byte4 = data_insert_reg[7:0];
    byte5 = data_insert_reg[15:8];
    byte6 = data_insert_reg[23:16];
    byte7 = data_insert_reg[31:24]; end


//处理data_insert中每一个字中的四个字节
always@(*) 
    if(byte_insert_cnt == 'd4) begin
        byte4 = byte4;
        byte5 = byte5;
        byte6 = byte6;
        byte7 = byte7; end
    else    if(byte_insert_cnt == 'd3) begin
        byte4 = byte4;
        byte5 = byte5;
        byte6 = byte6;
        byte7 = 8'b0000_0000; end
    else    if(byte_insert_cnt == 'd2) begin
        byte4 = byte4;
        byte5 = byte5;
        byte6 = 8'b0000_0000;
        byte7 = 8'b0000_0000; end
    else    if(byte_insert_cnt == 'd1) begin
        byte4 = byte4;
        byte5 = 8'b0000_0000;
        byte6 = 8'b0000_0000;
        byte7 = 8'b0000_0000; end
    else    begin
        byte4 = byte4;
        byte5 = byte5;
        byte6 = byte6;
        byte7 = byte7; end


//===============================merge_processing_unit=============================================================================

//data_word_cnt
always@(posedge clk or negedge rst_n) 
    if(!rst_n)
        data_word_cnt <= 'd0;
    else    if(ready_insert)
        data_word_cnt <= data_word_cnt + 1'b1;
    else
        data_word_cnt <= data_word_cnt;                


//ready_insert
always@(posedge clk or negedge rst_n) 
    if(!rst_n)
        ready_insert <= 1'b0;
    else
        ready_insert <= 1'b1;


//ready_in
always@(posedge clk or negedge rst_n) 
    if(!rst_n)
        ready_in <= 1'b0;
    else if(ready_insert)
        ready_in <= 1'b1;
    else
        ready_in <= ready_in;


//data_out
always@(*)
    if((valid_insert == 1'b1) && (ready_insert == 1'b1) && (data_word_cnt[0] == 1'b0) && (valid_out == 1'b1) && (ready_out == 1'b1))
        data_out = data_insert;
    else    if((valid_in == 1'b1) && (ready_in == 1'b1) && (data_word_cnt[0] == 1'b1) && (valid_out == 1'b1) && (ready_out == 1'b1))
        data_out = data_in;    
    else
        data_out = data_out;


//valid_out ready_out
assign valid_out = ready_insert;


//===============================data_out_processing_unit=============================================================================

//last_out
assign last_out = last_in;


//keep_out
assign keep_out = 'b1110;


//定义四个字节
always@(*) begin
        byte8  = data_out[7:0];
        byte9  = data_out[15:8];
        byte10 = data_out[23:16];
        byte11 = data_out[31:24]; end


//根据keep_out处理四个字节
always@(*) 
    if(last_out) begin
        byte8  = (keep_out[0] == 1'b1) ? byte8  : 8'b0000_0000;
        byte9  = (keep_out[1] == 1'b1) ? byte9  : 8'b0000_0000;
        byte10 = (keep_out[2] == 1'b1) ? byte10 : 8'b0000_0000;
        byte11 = (keep_out[3] == 1'b1) ? byte11 : 8'b0000_0000; end
    else    begin
        byte8  = byte8 ; 
        byte9  = byte9 ; 
        byte10 = byte10; 
        byte11 = byte11; end


endmodule