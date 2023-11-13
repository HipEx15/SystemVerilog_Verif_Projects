`include "ConfigMode.sv"
`include "Memorie.sv"
`include "LIFO.sv"
`include "Buffer.sv"

module top #(parameter DinLENGTH = 32, LIFO_Size = 4, WIDTH = 8) (
    input clk, reset,
    input chip_en_buf, chip_en_lifo, chip_en_fifo,
    input [DinLENGTH-1:0] din,
    input [WIDTH-1:0] addr,
    input r_w, valid,
    input [1:0] opcode,
    output [DinLENGTH-1:0] dout,
    output full, empty
    );
    
    wire [1:0] mode;
    wire [DinLENGTH-1:0] dout_inter;
    wire [DinLENGTH-1:0] dout_lifo;
    
    //Old BUG RTL
  	ConfigMode configMode(clk, chip_en_buf, chip_en_lifo, chip_en_fifo, mode);
  
  	//New
  	//ConfigMode configMode(clk, chip_en_buf, chip_en_fifo, chip_en_lifo, mode);
  
  	Memorie memorie(clk, reset, r_w, valid, din, addr, dout_inter);
    LIFO lifo(clk, reset, dout_inter, mode, opcode, dout_lifo, full, empty);
    Buffer buffer(clk, din, dout_lifo, mode, dout);
     
endmodule