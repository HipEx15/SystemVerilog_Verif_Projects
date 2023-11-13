class monitorOutput;
  
  virtual outputSignals o_vif; 
  virtual inputSignals i_vif;
  
  mailbox mon_out2scb;

  function new(virtual outputSignals o_vif, mailbox mon_out2scb, virtual inputSignals i_vif);
    this.o_vif = o_vif;
    this.i_vif = i_vif;
    this.mon_out2scb = mon_out2scb;
  endfunction
  
  task run();
    $display("[ MONITOR_OUT ] ****** MONITOR_OUT STARTED ******");
    //$display("T = %0t ns: [Monitor] starting... ", $time);   
    forever 
      begin
      
        transaction tx = new();

        @(posedge i_vif.clk);
        if(!i_vif.r_w)
          begin
            tx.dout = o_vif.dout;
            tx.full = o_vif.full;
            tx.empty = o_vif.empty;
          end
        else if(i_vif.r_w)
          begin
            tx.full = o_vif.full;
            tx.empty = o_vif.empty;
          end
        //$display("0x%0h |0x%0h | 0x%0h | 0x%0h", i_vif.r_w, o_vif.dout, o_vif.full, o_vif.empty);
        //tx.print("[MONITOR OUTPUT]\n");
        mon_out2scb.put(tx);
      end
    $display("[ MONITOR_OUT ] ****** MONITOR_OUT ENDED ******");    
  endtask
  
endclass