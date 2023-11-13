class driver;
  
  virtual inputSignals i_vif;
  event ended;
  mailbox gen2driv;
  
  int counter = 0;
  
  function new(virtual inputSignals i_vif, mailbox gen2driv);
    this.i_vif = i_vif;
    this.gen2driv = gen2driv;
  endfunction
  
  task reset();
    wait(i_vif.reset);
    $display("[ DRIVER ] ****** RESET STARTED ******");
	i_vif.chip_en_buf <= 0;
    i_vif.chip_en_lifo <= 0;
    i_vif.chip_en_fifo <= 0;
    i_vif.din <= 0;
    i_vif.addr <= 0;
    i_vif.r_w <= 0;
    i_vif.valid <= 0;
    i_vif.opcode <= 0;
    wait(!i_vif.reset);
    $display("[ DRIVER ] ****** RESET ENDED ******");
  endtask
  
  task run();
    $display("[ DRIVER ] ****** DRIVER STARTED ******");
    forever 
      begin
        transaction tx;
        //$display ("T = %0t [DRIVER] waiting for item ...", $time);
        gen2driv.get(tx);
        //tx.print("DRIVER\n");

        @(posedge i_vif.clk);
        counter++;
        i_vif.chip_en_buf <= tx.chip_en_buf;
        i_vif.chip_en_lifo <= tx.chip_en_lifo;
        i_vif.chip_en_fifo <= tx.chip_en_fifo;
        i_vif.din <= tx.din;
        i_vif.addr <= tx.addr;
        i_vif.r_w <= tx.r_w;
        i_vif.valid <= tx.valid;
        i_vif.opcode <= tx.opcode;
        
        //$display("Buff: 0x%0h | LIFO: 0x%0h | FIFO: 0x%0h | Data_in: 0x%0h | Addr: 0x%0h | RW: 0x%0h | Valid: 0x%0h | Opcode: 0x%0h", i_vif.chip_en_buf, i_vif.chip_en_lifo, i_vif.chip_en_fifo, i_vif.din, i_vif.addr, i_vif.r_w,i_vif. valid, i_vif.opcode);
        
        //->ended;
    end
    $display("[ DRIVER ] ****** DRIVER ENDED ******");
  endtask
  
endclass