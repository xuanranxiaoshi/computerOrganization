`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/05/27 20:27:07
// Design Name: 
// Module Name: inst_tb
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


module inst_tb(
    );

reg clk,inst_ena=1'b1;
reg [31:0] pc=32'b0;
wire [31:0] Inst;

always #5 clk=~clk;
always @(posedge clk) begin
    pc = pc +4;
end

initial begin
    clk =1'b0;
end

inst_ram inst_ram (
  .clka(clk),                     // input wire clka
  .ena(inst_ena),                 // input wire ena
  .wea(4'b0000),                  // input wire [3 : 0] wea	当前环境只读不写
  .addra(pc[11:2]),                // input wire [7 : 0] addra   字寻址
  .dina(32'b0),                   // input wire [31 : 0] dina  当前环境只读不写
  .douta(Inst)                    // output wire [31 : 0] douta
);


endmodule
