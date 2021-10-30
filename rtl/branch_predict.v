`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/10/30 18:14:39
// Design Name: 
// Module Name: branch_predict
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


module branch_predict (
    input wire clk, rst,        // 传入的时钟和复位信号
    
    input wire flushD,          // 传入的译码阶段的流水线刷新指令
    input wire stallD,          // 传入的译码阶段的流水线暂停指令

    input wire [31:0] pcF,      // 取值阶段的指令
    input wire [31:0] pcM,      // 访存阶段的指令

    input wire branchM,         // M阶段是否是分支指令 --> 这里需要传入的话，流水线需要添加数据
    input wire actual_takeM,    // 实际是否跳转 --> 在执行阶段判断得到的实际跳转结果

    //output wire branchD,        // 译码阶段是否是跳转指令
    input wire branchD,         // 这里原来是作为输出，但是在实验四中，controller 部分已经实现了该判断，直接输入即可  

    output wire pred_takeD      // 预测是否跳转
);
    wire pred_takeF;
    reg pred_takeF_r;
    //assign branchD =            //判断译码阶段是否是分支指令

// 定义参数
    parameter Strongly_not_taken = 2'b00, Weakly_not_taken = 2'b01, Weakly_taken = 2'b11, Strongly_taken = 2'b10;   // 两位饱和计数器的状态定义
    parameter PHT_DEPTH = 6;    // 用来索引 PHT 的位数
    parameter BHT_DEPTH = 10;   // 用来索引 BHT 的位数

// 
    reg [5:0] BHT [(1<<BHT_DEPTH)-1 : 0];   // 创建 BHT 储存堆
    reg [1:0] PHT [(1<<PHT_DEPTH)-1:0];     // 创建 PHT 存储堆
    
    integer i,j;
    // 创建索引变量
    wire [(PHT_DEPTH-1):0] PHT_index;   
    wire [(BHT_DEPTH-1):0] BHT_index;
    wire [(PHT_DEPTH-1):0] BHR_value;

// ---------------------------------------预测逻辑---------------------------------------

    assign BHT_index = pcF[11:2];       // 根据 pcF 的 11:2 位索引 BHT    
    assign BHR_value = BHT[BHT_index];  
    assign PHT_index = BHR_value;       // 根据 BHT 的索引值直接索引 PHT

    assign pred_takeF = PHT[PHT_index][1];      // 在取指阶段预测是否会跳转，并经过流水线传递给译码阶段。

    /**
        上面步骤是在取值阶段进行，根据PC的11:2位去查询对应历史，对分支方向进行预测。
        注意，此时是假设取值得到的PC的指令都是分支指令。
        分支方向的预测结果需要在译码阶段才会使用，因此需要通过寄存器保存，传到下一个周期。
    **/
        // --------------------------pipeline------------------------------
            always @(posedge clk) begin
                if(rst | flushD) begin
                    pred_takeF_r <= 0;
                end
                else if(~stallD) begin
                    pred_takeF_r <= pred_takeF;
                end
            end

            // 采用实验四中写好的寄存器对上部分代码进行等价处理
            // todo

        // --------------------------pipeline------------------------------

// ---------------------------------------预测逻辑---------------------------------------


// ---------------------------------------BHT初始化以及更新---------------------------------------
    wire [(PHT_DEPTH-1):0] update_PHT_index;
    wire [(BHT_DEPTH-1):0] update_BHT_index;
    wire [(PHT_DEPTH-1):0] update_BHR_value;

    assign update_BHT_index = pcM[11:2];     
    assign update_BHT_value = BHT[update_BHT_index];  
    assign update_PHT_index = update_BHR_value;

    always@(posedge clk) begin
        if(rst) begin
            for(j = 0; j < (1<<BHT_DEPTH); j=j+1) begin
                BHT[j] <= 0;
            end
        end
        // 如果访存阶段是分支指令的话，结合实际跳转结果对 BHT 进行更新
        else if(branchM) begin
            // 如果跳转的话，对应表项的值左移一位并最低位置1
            if(actual_takeM) begin
                BHT[update_BHT_index] = (update_BHT_value<<1) + 1;
            end
            // 如果没有跳转，对应表项的值左移一位即可（最低位默认置0）
            else begin
                BHT[update_BHT_index] = (update_BHT_value<<1);
            end
        end
    end
// ---------------------------------------BHT初始化以及更新---------------------------------------


// ---------------------------------------PHT初始化以及更新---------------------------------------
    always @(posedge clk) begin
        if(rst) begin
            for(i = 0; i < (1<<PHT_DEPTH); i=i+1) begin
                PHT[i] <= Weakly_taken;     // 默认跳转
            end
        end
        else begin
            case(PHT[update_PHT_index])
                Strongly_not_taken: begin
                    if(actual_takeM) PHT[update_PHT_index] = Weakly_not_taken;
                end
                Weakly_not_taken: begin
                    if(actual_takeM) PHT[update_PHT_index] = Weakly_taken;
                    else PHT[update_PHT_index] = Strongly_not_taken;
                end
                Weakly_taken: begin
                    if(actual_takeM) PHT[update_PHT_index] = Strongly_taken;
                    else PHT[update_PHT_index] = Weakly_not_taken;
                end
                Strongly_taken: begin
                    if(~actual_takeM) PHT[update_PHT_index] = Weakly_taken;
                end
            endcase 
        end
    end
// ---------------------------------------PHT初始化以及更新---------------------------------------

    // 译码阶段输出最终的预测结果
    assign pred_takeD = branchD & pred_takeF_r;  
endmodule
