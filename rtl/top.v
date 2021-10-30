`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/07 13:50:53
// Design Name: 
// Module Name: top
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


module top(
	input wire clk,rst,
  output wire [31:0] mem_wdata,alu_result,
  output wire data_ram_wea
  //output wire [31:0] Inst,
  //test
  //output wire [31:0] pc_next
  // output wire pcsrc,jump,branch,zero,
  // output wire [2:0] Alucontrol,
  //output wire [31:0] rd1,rd2,imm_extend,alu_srcB,pc_branch,pc_jump,pc_plus4,pc_branch_next,imm_sl2
    );


	wire inst_ena, data_ram_ena;	  //指令存储器，数据存储器使能信号
  wire [31:0] mem_data;			      //数据储存器读出数据

	// wire data_ram_wea;				      //数据储存器写使能信号
  // wire [31:0] alu_result;			    //alu运算结果
  // wire [31:0] mem_wdata;			  //数据储存器写入数据
	wire [31:0] pc;					        //PC指针
	wire [31:0] Inst;				        //指令数据
	
   	

//mips: datapath + comtroller
mips mips(
.clk(clk),
.rst(rst),
.Inst(Inst),
.mem_data(mem_data),	
.inst_ena(inst_ena),
.data_ram_ena(data_ram_ena),	
.data_ram_wea(data_ram_wea),				
.alu_result(alu_result),			
.mem_wdata(mem_wdata),
.pc(pc)

// test
// .pc_next(pc_next)
// .pcsrc(pcsrc),
// .jump(jump),
// .branch(branch),
// .zero(zero),
// .Alucontrol(Alucontrol),
// .rd1(rd1),
// .rd2(rd2),
// .imm_extend(imm_extend),
// .alu_srcB(alu_srcB),
// .pc_branch(pc_branch),
// .pc_jump(pc_jump),
// .pc_plus4(pc_plus4),
// .pc_branch_next(pc_branch_next),
// .imm_sl2(imm_sl2)
);


// inst_mem
inst_ram inst_ram (
  .clka(~clk),                    // input wire clka
  .ena(inst_ena),                 // input wire ena
  .wea(4'b0000),                  // input wire [3 : 0] wea	当前环境只读不写
  .addra(pc[11:2]),                // input wire [7 : 0] addra   字寻址
  .dina(32'b0),                   // input wire [31 : 0] dina  当前环境只读不写
  .douta(Inst)                    // output wire [31 : 0] douta
);

// data_mem
data_ram data_ram (
  .clka(~clk),                    // input wire clka
  .ena(data_ram_ena),             // input wire ena, 使能信号
  .wea({4{data_ram_wea}}),        // input wire [3 : 0] wea, 写使能信号,要写入时为1，4个信号是因为是按字节写入
  .addra(alu_result[11:2]),       // input wire [9 : 0] addra
  .dina(mem_wdata),               // input wire [31 : 0] dina
  .douta(mem_data)                // output wire [31 : 0] douta
);


endmodule
