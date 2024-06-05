`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.06.2024 18:23:02
// Design Name: 
// Module Name: Asyn_FIFO
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


module Asyn_FIFO(wclk,rclk,wen,ren,wr,rd,rst,valid,empty,full,overflow,underflow);
parameter WIDTH=8;
parameter DEPTH=8;
parameter addr=4;//one extra bit in msb to show Asynchronous FIFO is full or empty
input wen;
input ren;
input wclk;
input rclk;
input  [DEPTH-1:0] wr;
output reg [DEPTH-1:0] rd;
input rst;
output reg valid;
output empty;
output full;
output reg overflow;
output reg underflow;
wire [addr-1:0] wpointer_g;
wire [addr-1:0] rpointer_g;
reg [addr-1:0] wpointer,wpointer_g_s1,wpointer_g_s2;
reg [addr-1:0] rpointer,rpointer_g_s1,rpointer_g_s2;
reg [WIDTH-1:0] mem[DEPTH-1:0];
//write operation
always@(posedge wclk)
begin
if(rst)
wpointer<=0;
else
begin
if(wen && !full)
begin
wpointer<=wpointer+1;
mem[wpointer]<=wr;
end  
end  
end 
//read operation
always@(posedge rclk)
begin
if(rst)
rpointer<=0;
else
begin
if(ren && !empty)
begin
rpointer<=rpointer+1;
rd<=mem[rpointer];
end  
end  
end 
//read and write synchronizer
assign wpointer_g=wpointer^(wpointer>>1);  
assign rpointer_g=rpointer^(rpointer>>1);
always@(posedge rclk)
begin
if(rst)
begin
wpointer_g_s1<=0;
wpointer_g_s2<=0;
end 
else begin
wpointer_g_s1 <= wpointer_g;
wpointer_g_s2 <= wpointer_g_s1;
end
end 
always@(posedge wclk)
begin
if(rst)
begin
rpointer_g_s1<=0;
rpointer_g_s2<=0;
end 
else begin
rpointer_g_s1 <= rpointer_g;
rpointer_g_s2 <= rpointer_g_s1;
end
end
assign empty=(rpointer_g==rpointer_g_s2);//empty condition
assign full=(wpointer_g[addr-1]!= rpointer_g_s2[addr-1])//full condition
&& (wpointer_g[addr-2]!= rpointer_g_s2[addr-2])
&& (wpointer_g[addr-3]!= rpointer_g_s2[addr-3]);
always@(posedge wclk) overflow<=full && wen;
always@(posedge rclk)
begin 
underflow<=(empty && ren);//underflow condition
valid<=(!empty && ren);//valid condition
end
endmodule
