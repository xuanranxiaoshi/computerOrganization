`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/05/06 23:53:11
// Design Name: 
// Module Name: ALU_control
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


module ALU_control(
input wire [5:0] funct,
input wire [1:0] Aluop,
output wire [2:0] Alucontrol
    );
    assign Alucontrol = (Aluop == 2'b00) ? 3'b010: //lw sw 指令
                         (Aluop == 2'b01) ? 3'b110: //beq 指令
                         (Aluop == 2'b10) ?
                                            (funct == 6'b100000) ? 3'b010 : //add 指令
                                            (funct == 6'b100010) ? 3'b110 : //sub 指令
                                            (funct == 6'b100100) ? 3'b000 : //and 指令
                                            (funct == 6'b100101) ? 3'b001 : //or 指令
                                            (funct == 6'b101010) ? 3'b111 : //slt 指令
                                            3'b000:3'b000;
                                            
        
endmodule
