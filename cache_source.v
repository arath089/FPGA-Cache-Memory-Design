`timescale 1ns / 1ps

module cache_source(
//general signals////////////
clk,
rst,
//Processor side/////////////
PRead_request,
PWrite_request,
PRead_ready,
PWrite_done,
PWrite_data,
PRead_data,
PAddress,
//Memory Side///////////////
MRead_request,
MWrite_request,
MRead_ready,
MWrite_done,
MWrite_data,
MRead_data,
MAddress
);
//declaring inputs and outputs////////
//general input siganls//////////////
input clk;
input rst;
//processor side////////////////////
input PRead_request;
input PWrite_request;
input [7:0] PWrite_data;
input [7:0] PAddress;
output [7:0] PRead_data;
output PRead_ready;
output PWrite_done;
//memory side///////////////////////
input MRead_ready;
input MWrite_done;
input [31:0] MRead_data;
output [7:0] MAddress;
output MRead_request;
output MWrite_request;
output [7:0] MWrite_data; 

//designing cache////////////////////
reg [31:0] blocks[7:0];
reg [2:0] tags[7:0];
reg [7:0] invalid;
reg [1:0] state;
////////////////////////////////////
wire cache_hit;
reg data_out;

//processor address decomposition///////
wire [2:0] p_tag = PAddress[7:5];
wire [2:0] p_block_select = PAddress[4:2];
wire [1:0] p_byte_in_block = PAddress[1:0];

`define IDLE       8'd0
`define READING    8'd1
`define RESPONSE   8'd2
`define WRITING    8'd3

//cache operation/////


   always@(posedge clk)
   begin
       if(rst)
       begin
          state <= `IDLE;
          invalid <= 8'hFF;
       end
          else
          begin
             case(state)
             
             
             `IDLE:
             begin
                if (PRead_request & ~cache_hit)
                begin
                     state <= `READING;
                end
                else if(PRead_request & cache_hit)
                   begin
                      state <= `RESPONSE;
                   end
                else if(PWrite_request & ~cache_hit)
                   begin 
                     state <= `WRITING;
                   end
                else if(PWrite_request & cache_hit)
                     begin
                      state <= `RESPONSE;
                     end
            end
            
             `READING:
             begin
                 if(MRead_ready)
                  begin
                    blocks[p_block_select] <= MRead_data;
                    tags[p_block_select]   <= p_tag;
                    invalid[p_block_select] <= 1'b0;
                    state <= `RESPONSE;
                   end
             end
             
             
             `RESPONSE:
             begin
                 if((~PRead_request)& (~PWrite_request))
                   begin 
                      state <= `IDLE;
                   end
                
                 else if(PWrite_request)
                 begin
                   if (tags[p_block_select]==p_tag)
                   begin
                       if(p_byte_in_block == 2'd0) begin blocks[p_block_select][7:0]<= PWrite_data;end
                       if(p_byte_in_block == 2'd1) begin blocks[p_block_select][15:8]<= PWrite_data;end
                       if(p_byte_in_block == 2'd2) begin blocks[p_block_select][23:16]<= PWrite_data;end
                       if(p_byte_in_block == 2'd3) begin blocks[p_block_select][31:24]<= PWrite_data;end
                  end    
                 else if(PRead_request)
                   begin
                   if(tags[p_block_select] == p_tag)
                    state <= `READING;              
                   end
                 end
                else 
                if(invalid[p_block_select] == 1'b0)
                state <= `IDLE;
                end
                
                `WRITING:
                  begin
                  if(MWrite_data)
                    begin
                    state<= `IDLE;
                    end
                   if(PWrite_request & ~cache_hit)
                   begin
                     blocks[p_block_select] <= MRead_data;
                    tags[p_block_select]   <= p_tag;
                    invalid[p_block_select] <= 1'b0;
                   end
                 end
             endcase
        end
   end
   
  assign cache_hit = ((tags[p_block_select] == p_tag) & ~invalid[p_block_select] ? 1'b1 : 1'b0);
  
  //output assign///////
  assign PRead_ready = PRead_request & (state == `RESPONSE);
  
  assign MRead_request = (state == `READING);
  
  assign MWrite_done = (PWrite_request & (state== `RESPONSE));
  
  assign MWrite_data = (p_byte_in_block==2'd0) ? blocks[p_block_select][7:0]:    
                                   (p_byte_in_block==2'd1) ? blocks [p_block_select][15:8]:  
                                    (p_byte_in_block==2'd2) ? blocks [p_block_select][23:16]: 
                                                              blocks [p_block_select][31:24];
  
  assign MAddress = {PAddress[7:2] , 2'b00};
  
  assign PRead_data = (p_byte_in_block == 2'd0) ? blocks[p_block_select][7:0]:
                      (p_byte_in_block == 2'd1) ? blocks[p_block_select][15:8]:
                      (p_byte_in_block == 2'd2) ? blocks[p_block_select][23:16]:
                                                  blocks[p_block_select][31:24];
  
  
          


endmodule
