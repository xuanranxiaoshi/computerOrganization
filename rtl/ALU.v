`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/05/08 16:06:32
// Design Name: 
// Module Name: ALU
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


module ALU(
OP,A,B,Y,Zero,overflow
    );
input [2:0] OP;
input [31:0] A;
input [31:0] B;
output reg [31:0] Y;
output Zero;
output overflow;

assign overflow=1'b0;   //溢出检查，暂时置零

assign Zero = (Y==0);
always @(*)
begin
     case(OP)
     3'b010: Y = A + B;
     3'b110: Y = A - B;
     3'b000: Y = A & B;
     3'b001: Y = A | B;
     3'b100: Y = ~A;
     3'b111: Y = (A<B);
     default:Y = 0;
     endcase
end


endmodule
