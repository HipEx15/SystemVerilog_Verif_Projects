interface inputSignals(input logic clk, input logic reset);
  
  logic chip_en_buf;
  logic chip_en_lifo;
  logic chip_en_fifo;
  logic [31:0] din;
  logic [3:0] addr;
  logic r_w;
  logic valid;
  logic [1:0] opcode;
  
  modport inputType(input chip_en_buf, chip_en_lifo, chip_en_fifo, din, addr, r_w, valid, opcode);
  
endinterface