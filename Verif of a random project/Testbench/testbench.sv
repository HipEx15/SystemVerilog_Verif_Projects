`include "env.sv"

module testbench();

  
  reg clk,enable;
  
  reg [31:0] tt;
  
  MIPS chip(clk,enable);
  interfata intf(clk,
                 enable,
                 chip.im.mem,
                 chip.rg.inReg,
                 chip.dm.mem,
                 chip.instruction,
                 chip.pcin,
                 chip.muxDataOut,
                 chip.RegDst,
                 chip.Jump,
                 chip.Branch,
                 chip.MemRead,
                 chip.MemtoReg,
                 chip.MemWrite,
                 chip.ALUSrc,
                 chip.RegWrite,
                 chip.zero);
  
  environment env=new(intf);
  
  
  integer i;
  
  initial
    begin
      clk=1'b0;
      forever #5 clk=~clk;
    end
  
  initial
    begin
      enable=1;

    end
  
  initial begin
    fork
      env.run();
    join_none
  end
  
  initial begin 
    
  end
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
    #450
    $finish;
  end
endmodule