`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/05/27 22:58:37
// Design Name: 
// Module Name: hazard
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


module hazard(
    input wire [4:0] rsD,rtD,rsE,rtE,writeregM,writeregW,writeregE,       // 寄存器序号
    input wire regwriteM,regwriteW,regwriteE,                             // 寄存器写入信号
    input wire memtoregE,memtoregM,                                       // 内存数据写入寄存器控制信号
    input wire branchD,                                         // 分支指令
    output wire [1:0] forwardAE,forwardBE,                      // 前推数据选择信号
    output wire stallF,stallD,flushE,                           // 暂停刷新信号
    output wire forwardAD,forwardBD                            // 提前分支判断产生的数据冒险数据前推控制信号
    );

    assign forwardAE = ((rsE != 5'b0) & (rsE == writeregM) & regwriteM ) ? 2'b10:
            ((rsE != 5'b0) & (rsE == writeregW) & regwriteW ) ? 2'b01 : 2'b00;
    
    assign forwardBE = ((rtE != 5'b0) & (rtE == writeregM) & regwriteM) ? 2'b10:
            ((rtE != 5'b0) & (rtE == writeregW) & regwriteW) ? 2'b01 : 2'b00;

    assign forwardAD = (rsD != 5'b0) & (rsD == writeregM) & regwriteM;       //只将Memory阶段的数据进行了前推
    assign forwardBD = (rtD != 5'b0) & (rtD == writeregM) & regwriteM;       


    wire lwstall,branch_stall;

    assign lwstall = ((rsD == rtE) | (rtD == rtE)) & memtoregE;

    assign branch_stall = branchD & regwriteE &((writeregE==rsD) | (writeregE == rtD)) |
                        branchD & memtoregM &((writeregM == rsD) | (writeregM == rsD));

    assign stallF = lwstall | branch_stall;
    assign stallD = lwstall | branch_stall;
    assign flushE = lwstall | branch_stall;


endmodule
