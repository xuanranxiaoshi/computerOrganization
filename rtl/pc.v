`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/05/07 16:50:42
// Design Name: 
// Module Name: pc
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


module pc(
input wire clk,rst,
input wire [31:0] pc_next,
input wire en,
output reg [31:0] pc
    );
    
    always @(posedge clk) begin
        if(rst)begin
            pc<=32'b0;
        end
        else if(en) begin
            pc<=pc_next;
        end 
    end


endmodule
