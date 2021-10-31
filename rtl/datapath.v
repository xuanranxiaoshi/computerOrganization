`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/05/08 15:33:33
// Design Name: 
// Module Name: datapath
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


module datapath(
input wire clk,rst,
input wire [31:0] Inst,                                     //指令信号
input wire [31:0] mem_data,                                 //数据储存器读出数据
input wire jump,regwriteM,regwriteW,regwriteE,regdst,alusrc,branch,branchE,branchM,memtoregE,memtoregW,memtoregM,
input wire [2:0] Alucontrol,                                //控制信号
output wire [31:0] alu_result_Me,	                        //alu运算结果
output wire [31:0] WriteData_Me,	                        //数据储存器写入数据
output wire [31:0] pc_addr, 	                            //PC指针
output wire [31:0] Inst_De                                  //译码阶段保存指令
//test
// output wire [31:0] pc_next
//output wire pcsrc,
//output wire zero,
//output wire [31:0] rd1_De,rd2_De,imm_extend,alu_srcB,pc_branch,pc_jump,pc_plus4,pc_branch_next,imm_sl2
    );

wire [31:0] pc_plus4;                                        //pc+4之后的输入信号
wire [31:0] rd1_De,rd2_De;                                  //寄存器堆输出数据信号
wire [31:0] imm_extend;                                     //立即数扩展信号
wire [31:0] alu_srcB;                                       //alu b端口的操作数
wire [31:0] wd3;                                            //regfile写入数据
wire [4:0]  wa3;                                            //regfile写入数据的地址
wire [31:0] imm_sl2;                                        //立即数左移两位后的结果
wire [31:0] ins_sl2;                                        //指令左移两位后的结果
wire [31:0] pc_branch;                                      //分支指令计算后得到PC地址
wire [31:0] pc_branch_next;                                 //分支指令计算后的地址与pc+4选择后的地址
wire [31:0] pc_next;                                        //下一条指令的pc地址
wire zero;                                                  //alu运算结果是否为零判断信号
wire pcsrc;                                                 //分支指令pc控制信号
wire [31:0] pc_jump;                                        //jump 指令跳转pc

wire [31:0] pc_branchE,pc_branchM;                          // 分支跳转的地址在各个流水线级上的值

//流水线cpu  
wire [31:0] pc_plus4_De,pc_plus4_Ex,pc_plus4_Me;                           //流水线中传输的pc+4
wire [31:0] rd1_Ex,rd2_Ex;                                     //执行阶段保存的寄存器读出的数据       
//wire [4:0]  rs_De,rs_Ex,rt_De,rt_Ex,,rd_De,rd_Ex;              //执行阶段保存目标寄存器序号信号
wire [4:0] rs_De, rs_Ex, rt_De, rt_Ex, rd_De, rd_Ex;
wire [31:0] imm_extend_Ex;                                     //执行阶段保存立即数拓展数
wire [31:0] alu_result,alu_result_Wb;                          //alu的直接计算结果
wire zero_Me;                                                 
wire [31:0] mem_data_Wb;                                       //内存读入的数据进行存储
wire [4:0] wa3_Ex,wa3_Me,wa3_Wb;
wire [1:0] forwardAE,forwardBE;                                //数据前推选择器控制信号
wire [31:0] rd1,rd2;                                           //实行前推后寄存器读取出的数据

wire stallF,stallD;
wire flushD,flushE;                                                //流水线暂停刷新控制信号
// wire forwardAD,forwardBD;                                      //分支判断提前产生的数据冒险控制信号
// wire [31:0] srcaD,srcbD;                                       //分支判断来源
// wire equalD;                                                   //是否相等

wire pred_takeD,pred_takeE,pred_takeM;                              // 分支预测预测的预测结果
wire branch_takeE,branch_takeM;                                    // 访存阶段计算得到此前分支指令是否跳转的结果
wire predict_wrong;                                                // 分支指令是否预测错误
wire [31:0] pc_next_correct;                                       // 分支预测矫正的PC值 
wire [31:0] pc_next_common;                                        // 正常情况下pc的下一个值    

//mux2 for pc_branch_next
mux2 #(32) mux_pc(
.a(pc_branch),
.b(pc_plus4),
.s(pcsrc),                                                     //pcsrc
.y(pc_branch_next)
);

//left shift 2 for pc_jump imm
sl2 sl2_jump(
.a(Inst_De),
.y(ins_sl2)
);


assign pc_jump = {pc_plus4[31:28],ins_sl2[27:0]};

//mux2 for pc_next
mux2 #(32) mux_pc_jump(
.a(pc_jump),                                                  //pc+4的高4加上，指令低26位左移两位
.b(pc_branch_next),
.s(jump),                           
.y(pc_next_common)
);

// 这里需要再添加一个对矫正地址和正常地址的选择
mux2 #(32) mux_pc_next(
.a(pc_next_correct),                                                  //pc+4的高4加上，指令低26位左移两位
.b(pc_next_common),
.s(predict_wrong),                           
.y(pc_next)
);


/**
这里PC的值在分支错误的时候应该怎么处理呢？
应该不用单独处理，下一个周期的正确值将覆盖错误的值
**/
// pc
pc pc(
.clk(clk),
.rst(rst),
.en(~stallF),
.pc_next(pc_next),
.pc(pc_addr)
);

//pc+4
adder pc_plus4_4(
.a(pc_addr),
.b(32'd4),
.y(pc_plus4)
);


// the Flop for Decode stage 
flopenrc #(32) r1  (.clk(clk),.rst(rst),.en(~stallD),.clear(flushD),.d(Inst),.q(Inst_De));
flopenrc #(32) r2  (.clk(clk),.rst(rst),.en(~stallD),.clear(flushD),.d(pc_plus4),.q(pc_plus4_De));




//regfile
regfile regfile(
.clk(clk),
.we3(regwriteW),                        //regwrite                 
.ra1(rs_De),                            //rs
.ra2(rt_De),                            //rt
.wa3(wa3),                              //lw:rt   r_type: rd
.wd3(wd3),
.rd1(rd1_De),
.rd2(rd2_De)
);


//pcsrcD
// assign pcsrc = equalD & branch;
// 即相当于equalD的计算结果被预测结果直接替代，同时在执行阶段进行计算
assign pcsrc = pred_takeD & branch;


//segnext

signext signext(
.a(Inst_De[15:0]),
.y(imm_extend)
);


//left shift 2 for pc_branch imm
sl2 sl2(
.a(imm_extend),
.y(imm_sl2)
);

//pc_branch =pc+4 + (sign_ext imm <<2 )
adder pc_branch_m(
.a(pc_plus4_De),
.b(imm_sl2),
.y(pc_branch)
);


//mux2 for srcaD
//mux2 #(32) forwardamux(.a(alu_result_Me),.b(rd1_De),.s(forwardAD),.y(srcaD));
//mux2 #(32) forwardbmux(.a(alu_result_Me),.b(rd2_De),.s(forwardBD),.y(srcbD));

// 取消译码阶段的比较器
//eqcmp cmp (.a(srcaD),.b(srcbD),.y(equalD));

//这里取消之后应对pc的更新进行修改


assign rt_De = Inst_De[20:16];
assign rd_De = Inst_De[15:11];
assign rs_De = Inst_De[25:21];

//the Flop for Excute stage
flopenrc #(32) r21  (.clk(clk),.rst(rst),.en(1'b1),.clear(flushE),.d(rd1_De),.q(rd1_Ex));             //寄存器读取数据存储
flopenrc #(32) r22  (.clk(clk),.rst(rst),.en(1'b1),.clear(flushE),.d(rd2_De),.q(rd2_Ex));
flopenrc #(5) r23  (.clk(clk),.rst(rst),.en(1'b1),.clear(flushE),.d(rt_De),.q(rt_Ex));               
flopenrc #(5) r24  (.clk(clk),.rst(rst),.en(1'b1),.clear(flushE),.d(rd_De),.q(rd_Ex));                //目标寄存器序号存储
flopenrc #(5) r27  (.clk(clk),.rst(rst),.en(1'b1),.clear(flushE),.d(rs_De),.q(rs_Ex));
flopenrc #(32) r25  (.clk(clk),.rst(rst),.en(1'b1),.clear(flushE),.d(pc_plus4_De),.q(pc_plus4_Ex));   //pc+4 执行阶段
flopenrc #(32) r26  (.clk(clk),.rst(rst),.en(1'b1),.clear(flushE),.d(imm_extend),.q(imm_extend_Ex));  //立即数拓展
flopenrc #(1) r28  (.clk(clk),.rst(rst),.en(1'b1),.clear(flushE),.d(pred_takeD),.q(pred_takeE));       //预测结果
flopenrc #(32) r29  (.clk(clk),.rst(rst),.en(1'b1),.clear(flushE),.d(pc_branch),.q(pc_branchE));      //执行阶段得到的分支指令传入


//mux3 for SrcAe
mux3 #(32) srcA_sel(
	.d0(rd1_Ex),
    .d1(wd3),
    .d2(alu_result_Me),
	.s(forwardAE),
	.y(rd1)
    );

//mux3 for SrcBe
mux3 #(32) srcB_sel(
	.d0(rd2_Ex),
    .d1(wd3),
    .d2(alu_result_Me),
	.s(forwardBE),
	.y(rd2)
    );



//mux2 for alu_srcB
mux2 #(32) mux_alu_srcb(
.a(imm_extend_Ex),
.b(rd2),
.s(alusrc),                         //alusrc
.y(alu_srcB)
);

//ALU
ALU alu(
.OP(Alucontrol),                    //alu_control
.A(rd1),
.B(alu_srcB),                       //立即数：imm_extend;  r_type: rd2
.Y(alu_result),
.Zero(zero),
.overflow()                         //暂时不考虑
);

// 在执行阶段计算正确的跳转信号
assign branch_takeE = zero & branchE;




// mux2 for wa3, write addr port of regfile
mux2 #(5) mux_wa3(
.a(rd_Ex),
.b(rt_Ex),
.s(regdst),                         
.y(wa3_Ex)
);



// the Flop for Memory stage
flopenrc #(32) r31  (.clk(clk),.rst(rst),.en(1'b1),.clear(1'b0),.d(alu_result),.q(alu_result_Me));              //Alu 计算结果数据
flopenrc #(1)  r32  (.clk(clk),.rst(rst),.en(1'b1),.clear(1'b0),.d(zero),.q(zero_Me));                          //Alu zero 数据
flopenrc #(32) r33  (.clk(clk),.rst(rst),.en(1'b1),.clear(1'b0),.d(rd2),.q(WriteData_Me));
flopenrc #(5)  r35  (.clk(clk),.rst(rst),.en(1'b1),.clear(1'b0),.d(wa3_Ex),.q(wa3_Me));                         //目标寄存器序号存储
flopenrc #(32) r36  (.clk(clk),.rst(rst),.en(1'b1),.clear(1'b0),.d(pc_plus4_Ex),.q(pc_plus4_Me));             //pc+4 访存阶段
flopenrc #(1) r34  (.clk(clk),.rst(rst),.en(1'b1),.clear(1'b0),.d(branch_takeE),.q(branch_takeM));            //将执行阶段计算得到跳转结果传入下一级
flopenrc #(1) r37  (.clk(clk),.rst(rst),.en(1'b1),.clear(1'b0),.d(pred_takeE),.q(pred_takeM));                //预测结果
flopenrc #(32) r38  (.clk(clk),.rst(rst),.en(1'b1),.clear(1'b0),.d(pc_branchE),.q(pc_branchM));               //分支跳转地址

/**
在访存阶段，对分支预测结果进行检验修正
判断是否出现错误，将结果传入harzard模块，控制流水线的刷新和暂停
PC值更新：
    该跳但是没有跳的话，将pc_branch 传到取值阶段
    不该跳转，却跳了，将pc+8(延迟槽的原因) 传到取值阶段
实现方式：选择相应的地址，传入取值阶段，然后在取值阶段原有的部分再添加一个2选1选择器
    
**/
assign predict_wrong = (pred_takeM^branch_takeM) & branchM ;

// 先获得pc + 8
wire [31:0] pc_plus_8;
adder pc_plus8_8(
.a(pc_plus4_Me),
.b(32'd4),
.y(pc_plus_8)
);
// 根据之前预测的结果选择纠正pc值
mux2 #(32) mux_correct(
.a(pc_plus_8),
.b(pc_branchM),
.s(pred_takeM),                         
.y(pc_next_correct)
);

// the Flop for WriteBack stage 
flopenrc #(32) r41  (.clk(clk),.rst(rst),.en(1'b1),.clear(1'b0),.d(alu_result_Me),.q(alu_result_Wb));
flopenrc #(32) r42  (.clk(clk),.rst(rst),.en(1'b1),.clear(1'b0),.d(mem_data),.q(mem_data_Wb));
flopenrc #(5)  r43  (.clk(clk),.rst(rst),.en(1'b1),.clear(1'b0),.d(wa3_Me),.q(wa3_Wb)); 


assign wa3 = wa3_Wb;

// mux2 for wd3, write data port of regfile
mux2 #(32) mux_wd3(
.a(mem_data_Wb),
.b(alu_result_Wb),
.s(memtoregW),                       
.y(wd3)
);


hazard Hazard(
.rsD(rs_De),
.rtD(rt_De),
.rsE(rs_Ex),
.rtE(rt_Ex),
.writeregM(wa3_Me),
.writeregW(wa3_Wb),
.writeregE(wa3_Ex),   
.regwriteM(regwriteM),
.regwriteW(regwriteW),
.regwriteE(regwriteE),
.memtoregE(memtoregE), 
.memtoregM(memtoregM),                    
.forwardAE(forwardAE),
.forwardBE(forwardBE),
.stallF(stallF),
.stallD(stallD),
.flushD(flushD),
.flushE(flushE),
.predict_wrongM(predict_wrong)
//.forwardAD(forwardAD),
//.forwardBD(forwardBD)
    );


/**
原来的分支预测是将数据前推到译码阶段判断分支方向和获得跳转地址，采用分支预测则不用在译码阶段获得准确的结果，所以需要进行一下方面的改进：
1. 取消前推的旁路
2. 取消译码阶段的比较器
3. 在执行阶段判断跳转的结果--> 引入执行阶段branch信号，利用zero信号，得到正确的跳转情况保存到下一个周期
4. 修改预测错误的刷新措施 --> 需要分类讨论正确的地址
        如果应该跳转，但是没跳转：分支指令的地址需要从执行阶段保存下来
        如果不应该跳却跳了，正确地址直接是PC+8(!考虑延迟槽指令)
   
**/

// 添加分支预测模块
branch_predict bp( .clk(clk),.rst(rst),.flushD(flushD),.stallD(stallD),
                   .pcF(pc_plus4),.pcM(pc_plus4_Me),.branchM(branchM),.branchD(branch),
                   .actual_takeM(branch_takeM),
                   .pred_takeD(pred_takeD)
);




endmodule
