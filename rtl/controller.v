`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/05/08 22:47:25
// Design Name: 
// Module Name: controller
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


module controller(
input wire clk,rst,
input wire [31:0] Inst,
output wire jump,regdst,alusrc,branch,memWrite,memtoregW,memtoregE,memtoregM,memen,regwriteM,regwriteW,regwriteE,branchM,branchE,
output wire [2:0] Alucontrol
    );



wire [1:0] Aluop;
wire [7:0] sigs_De;
wire [2:0] Alucontrol_De,Alucontrol_Ex;

wire [6:0] sigs_Ex;
wire [4:0] sigs_Me;
wire [1:0] sigs_Wb;

Main_Decoder Main_Decoder(
    .op(Inst[31:26]),
    .sigs(sigs_De),
    .aluop(Aluop)
);

ALU_control ALU_control(
    .funct(Inst[5:0]),
    .Aluop(Aluop),
    .Alucontrol(Alucontrol_De)
);

assign jump = sigs_De[7];
assign branch = sigs_De[3];

// Flop for control sigs in stage Excute
// regwrite,regdst,alusrc,branch,memWrite,memtoReg,memen
flopenrc #(7) r11  (.clk(clk),.rst(rst),.en(1'b1),.clear(1'b0),.d(sigs_De[6:0]),.q(sigs_Ex));
flopenrc #(3) r12  (.clk(clk),.rst(rst),.en(1'b1),.clear(1'b0),.d(Alucontrol_De),.q(Alucontrol_Ex));

//Excute 阶段用到的信号：Alucontrol alusrc regdst branchE
assign Alucontrol = Alucontrol_Ex;
assign alusrc = sigs_Ex[4];
assign regdst = sigs_Ex[5];
assign memtoregE = sigs_Ex[1];
assign regwriteE = sigs_Ex[6];
assign branchE = sigs_Ex[3];

// Flop for control sigs in stage Memeory 
flopenrc #(5) r21  (.clk(clk),.rst(rst),.en(1'b1),.clear(1'b0),.d({sigs_Ex[6],sigs_Ex[3:0]}),.q(sigs_Me));

// regwrite,branch,memWrite,memtoReg,memen
assign memWrite = sigs_Me[2];
assign memtoregM = sigs_Me[1];
assign memen = sigs_Me[0];
assign regwriteM = sigs_Me[4];
// 将访存阶段的branch指令导出
assign branchM = sigs_Me[3];

//Flop for control sigs in stage WriteBack
flopenrc #(2) r31  (.clk(clk),.rst(rst),.en(1'b1),.clear(1'b0),.d({sigs_Me[4],sigs_Me[1]}),.q(sigs_Wb));

// regwrite,memtoReg
assign regwriteW = sigs_Wb[1];
assign memtoregW  = sigs_Wb[0];

endmodule

