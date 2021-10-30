`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/05/08 20:28:03
// Design Name: 
// Module Name: Main_Decoder
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


module Main_Decoder(
input wire [5:0] op,
// output wire jump,regwrite,regdst,alusrc,branch,memWrite,memtoReg,memen,
output reg [7:0] sigs,
output wire [1:0] aluop
    );

reg [1:0]aluop_reg;
// reg [7:0]sigs;


// assign {jump,regwrite,regdst,alusrc,branch,memWrite,memtoReg,memen} = sigs;
assign aluop = aluop_reg;

always @(*) begin
    case (op)
        6'b000000:begin
            sigs=8'b01100000;
            aluop_reg=2'b10;
        end
        6'b100011:begin
           sigs=8'b01010011;
           aluop_reg=2'b00; 
        end
        6'b101011:begin
            sigs=8'b00010101;
            aluop_reg=2'b00;
        end
        6'b000100:begin
           sigs=8'b00001000;
           aluop_reg=2'b01; 
        end
        6'b001000:begin
            sigs=8'b01010000;
            aluop_reg=2'b00;
        end
        6'b000010:begin
            sigs=8'b10000000;
            aluop_reg=2'b00;
        end
        default: begin
            sigs=8'b00000000;
            aluop_reg=2'b00;
        end
    endcase
    
end

endmodule
