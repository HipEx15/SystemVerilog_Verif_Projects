class monitorInput;
  
  virtual inputSignals i_vif;
  mailbox mon_in2scb;
  
  function new(virtual inputSignals i_vif, mailbox mon_in2scb);
    this.i_vif = i_vif;
    this.mon_in2scb = mon_in2scb;
  endfunction
  
  task run();
    $display("[ MONITOR_IN ] ****** MONITOR_IN STARTED ******");
    //$display("T = %0t ns: [Monitor] starting... ", $time);   
    forever 
      begin
      
        transaction tx = new();
        @(posedge i_vif.clk);
        tx.chip_en_buf = i_vif.chip_en_buf;
        tx.chip_en_lifo = i_vif.chip_en_lifo;
        tx.chip_en_fifo = i_vif.chip_en_fifo;
        tx.din = i_vif.din;
        tx.addr = i_vif.addr;
        tx.r_w = i_vif.r_w;
        tx.valid = i_vif.valid;
        tx.opcode = i_vif.opcode;
        
        //tx.print("[MONITOR INPUT]\n");
        mon_in2scb.put(tx);
      end
    $display("[ MONITOR_IN ] ****** MONITOR_IN ENDED ******");    
  endtask
  
endclass