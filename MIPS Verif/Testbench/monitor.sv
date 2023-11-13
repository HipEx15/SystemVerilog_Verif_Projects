class monitor;

  virtual mips_if var_if;
  mailbox mon2scb;
  myStruct str;

  function new(virtual mips_if var_if, mailbox mon2scb);
    this.var_if = var_if;
    this.mon2scb = mon2scb;
  endfunction

  task run();
    forever 
      begin
        
        @(posedge var_if.clk);
        
        //$display("hehe: %0x0h",var_if.regDst);
        //$display(var_if.mem);
        str.mem = var_if.mem;
        str.tx = new();
        
        str.tx.instr = var_if.instr;
		str.tx.start = var_if.start;
            
        @(negedge var_if.clk);
        str.tx.regDst = var_if.regDst;
        str.tx.jump = var_if.jump;
        str.tx.branch = var_if.branch;
        str.tx.memRead = var_if.memRead;
        str.tx.memToReg = var_if.memToReg;
        str.tx.memWrite = var_if.memWrite;
        str.tx.ALUSrc = var_if.ALUSrc;
        str.tx.regWrite = var_if.regWrite;
        str.tx.ALUOp = var_if.ALUOp;
        
        str.tx.regs = var_if.regs;
        str.tx.pc = var_if.pc;
        str.tx.memOut = var_if.memOut;
        str.tx.print("[Monitor]");
        
        mon2scb.put(str);
      end
  endtask

endclass