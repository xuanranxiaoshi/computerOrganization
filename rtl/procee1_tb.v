`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/05/27 19:58:08
// Design Name: 
// Module Name: procee1_tb
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


module procee1_tb();


reg clk,rst; 
always #5 clk = ~clk;

 initial begin
     clk = 1'b0;
     rst = 1'b1;
     #10 rst = 1'b0;
 end
 
top test(
clk,rst
);

endmodule