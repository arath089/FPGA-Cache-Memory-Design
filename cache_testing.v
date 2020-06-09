`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/27/2020 02:29:29 PM
// Design Name: 
// Module Name: cache_testing
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module cache_testing;

    reg clk;
    reg rst;

    reg PRead_request;
    //input PWrite_request;
    reg PWrite_request;
    //input request;
    wire PRead_ready;
    //output PWrite_done;
    //input [7:0] PWrite_data;
    wire PWrite_done;
    
    wire [7:0] PRead_data;
    wire [7:0] PWrite_data;
    reg [7:0] PAddress;
    //memory side
    wire MRead_request;
    wire MWrite_request;
    //output MWrite_request;
    reg MRead_ready;
    reg MWrite_ready;
    //input MWrite_done;
    //output [7:0] MWrite_data;
    reg [31:0] MRead_data;
    reg [31:0] MWrite_data;
    wire [7:0] MAddress;


    cache dut(
        .clk(clk),
        .rst(rst),
        //processor side
        .PRead_request(PRead_request),
        .PRead_ready(PRead_ready),
        .PRead_data(PRead_data),
        .PAddress(PAddress),
        .PWrite_request(PWrite_request),
        .PWrite_ready(PWrite_ready),
        .PWrite_data(PWrite_data),
        //memory side
        .MRead_request(MRead_request),
        .MRead_ready(MRead_ready),
        .MRead_data(MRead_data),
        .MAddress(MAddress),
        .MWrite_request(MWrite_request),
        .MWrite_ready(MWrite_ready),
        .MWrite_data(MWrite_data)
        );

initial
begin
    clk = 0;
    rst = 1;
    
    PRead_request = 0;
    PAddress = 0;
    MRead_ready = 0;
    MRead_data = 0;
    
    #10;
    @(posedge clk);
    rst = 0;
    #10;
    
    //test logic for cache miss
    @(posedge clk);
    PAddress = 3;
    PRead_request = 1;
    #10;
    @(posedge clk);
    MRead_ready = 1;
    @(posedge clk);
    MRead_ready = 0;
    wait(PRead_ready);
    @(posedge clk);
    PRead_request = 0;
    #10;
    
    //test logic for cache hit
    @(posedge clk);
    PAddress = 2;
    PRead_request = 1;
    wait(PRead_ready);
    @(posedge clk);
    PRead_request = 0;
    #10;
    
    PWrite_request = 0;
    MWrite_ready = 1;
    MWrite_data = 0;
    
    #10;
    @(posedge clk);
    rst = 0;
    #10;
    
    @(posedge clk);
    PAddress = 3;
    PWrite_request = 1;
    #10;
    @(posedge clk);
    MWrite_ready = 1;
    @(posedge clk);
    MWrite_ready = 0;
    wait(PWrite_ready);
    @(posedge clk);
    PWrite_request = 0;
    #10;
    
    
    @(posedge clk);
    PAddress = 2;
    PWrite_request = 1;
    wait(PWrite_ready);
    @(posedge clk);
    PWrite_request = 0;
    #10;
end

always clk = #1 ~clk;

endmodule

   
