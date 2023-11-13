class driver;

  int counter = 0;
  virtual mips_if var_if;
  mailbox gen2driv;

  function new(virtual mips_if var_if, mailbox gen2driv);
    this.var_if = var_if; 
    this.gen2driv = gen2driv;
  endfunction

  task run();
    forever 
      begin
        myStruct str;
        gen2driv.get(str);
        @(posedge var_if.clk);
        var_if.start = str.tx.start;
        var_if.instr = str.tx.instr;
        var_if.mem = str.mem;
        counter++;
        //str.tx.print("[Driver]");
        //$display("%0x0h", str.tx.instr);
        //$display(var_if.mem);

      end
  endtask

endclass