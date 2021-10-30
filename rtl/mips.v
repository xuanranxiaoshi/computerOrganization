`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/07 10:58:03
// Design Name: 
// Module Name: mips
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 包括数据通路和控制器
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module mips(
	input wire clk,rst,
	input wire [31:0] Inst,					//指令数据
	input wire [31:0] mem_data,				//数据储存器读出数据
	output wire inst_ena, data_ram_ena,		//ram使能信号
	output wire data_ram_wea,				//数据储存器写使能信号
	output wire [31:0] alu_result,			//alu运算结果
	output wire [31:0] mem_wdata,			//数据储存器写入数据
	output wire [31:0] pc					//PC指针
	//test
	//output wire [31:0] pc_next
	// output wire pcsrc,jump,branch,zero,
	// output wire [2:0] Alucontrol,
	// output wire [31:0] rd1,rd2,imm_extend,alu_srcB,pc_branch,pc_jump,pc_plus4,pc_branch_next,imm_sl2
    );

	wire jump,regwriteM,regwriteW,regwriteE,regdst,alusrc,branch,branchE,branchM,memtoregW,memtoregE,memtoregM;
	wire [2:0] Alucontrol;
	wire [31:0] Inst_De;

	assign inst_ena = 1'b1;				//在不考虑其他情况下，cpu一直在读取指令;
	

	controller c(
		.clk(clk),
		.rst(rst),
		.Inst(Inst_De),
		.jump(jump),
		.regwriteM(regwriteM),
		.regwriteW(regwriteW),
		.regwriteE(regwriteE),
		.regdst(regdst),
		.alusrc(alusrc),
		.branch(branch),
		.branchM(branchM),
		.branchE(branchE),
		.memWrite(data_ram_wea),
		.memtoregW(memtoregW),
		.memtoregM(memtoregM),
		.memtoregE(memtoregE),
		.memen(data_ram_ena),			//数据储存器使能信号，当指令涉及到数据储存器时才有效
		.Alucontrol(Alucontrol)						
		);





	datapath dp(
		.clk(clk),
		.rst(rst),
		.Inst(Inst),
		.mem_data(mem_data),
		.alu_result_Me(alu_result),			//alu运算结果
		.WriteData_Me(mem_wdata),		    //数据储存器写入数据
		.pc_addr(pc),						//PC指针
		.Inst_De(Inst_De),
		.jump(jump),
		.regwriteM(regwriteM),
		.regwriteW(regwriteW),
		.regwriteE(regwriteE),
		.regdst(regdst),
		.alusrc(alusrc),
		.branch(branch),
		.branchE(branchE),
		.branchM(branchM),
		.memtoregW(memtoregW),
		.memtoregE(memtoregE),
		.memtoregM(memtoregM),
		.Alucontrol(Alucontrol)
		// .pc_next(pc_next)
		// .pcsrc(pcsrc),
		// .zero(zero),
		// .rd1_De(rd1),
		// .rd2_De(rd2),
		// .imm_extend(imm_extend),
		// .alu_srcB(alu_srcB),
		// .pc_branch(pc_branch),
		// .pc_jump(pc_jump),
		// .pc_plus4(pc_plus4),
		// .pc_branch_next(pc_branch_next),
		// .imm_sl2(imm_sl2)
		);
	
endmodule
