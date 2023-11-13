`include "interface.sv"
`include "test.sv"

module _mips();
  bit clk;
  bit start;

  //Interface

  mips_if var_if(clk);

  test test(var_if);

  MIPS mips(.clk(var_if.clk),.start(var_if.start));

  for (genvar offset = 0; offset < 50; offset = offset + 1) 
    begin
      assign mips.im.mem[offset*4 + 3] = var_if.instr[31:24];
      assign mips.im.mem[offset*4 + 2] = var_if.instr[23:16];
      assign mips.im.mem[offset*4 + 1] = var_if.instr[15:8];
      assign mips.im.mem[offset*4] =  var_if.instr[7:0];    
    end

  for(genvar offset = 0; offset < $size(mips.rg.inReg); offset = offset + 1)
    begin	
      assign var_if.regs[offset] = mips.rg.inReg[offset];
    end
  
  for(genvar offset = 0; offset < $size(mips.dm.mem); offset = offset + 1)
    begin	
    assign var_if.memOut[offset] = mips.dm.mem[offset];
  end

  assign var_if.start = mips.start;
  assign var_if.pc = mips.pcout;
  
  assign var_if.ALUOp = mips.ALUOp;
  assign var_if.regDst = mips.RegDst;
  assign var_if.jump = mips.Jump;
  assign var_if.branch = mips.Branch;
  assign var_if.memRead = mips.MemRead;
  assign var_if.memToReg = mips.MemtoReg;
  assign var_if.memWrite = mips.MemWrite;
  assign var_if.ALUSrc = mips.ALUSrc;
  assign var_if.regWrite = mips.RegWrite;

  //start e ca un reset/enable

  integer i;
  initial
    begin
      clk=1'b1;
      #5 clk= 1'b0;
      forever #5 clk = ~clk;
    end


  initial
    begin
      //$monitor("Instr: %0x0h", var_if.instr);
      $dumpfile("dump.vcd"); 
      $dumpvars(0,mips);
    end

endmodule