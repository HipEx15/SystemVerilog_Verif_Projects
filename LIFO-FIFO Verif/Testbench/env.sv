`include "generator.sv"
`include "driver.sv"
`include "monitorInput.sv"
`include "monitorOutput.sv"
`include "scoreboard.sv"

class environment;

  generator gen;
  driver driv;
  monitorInput mon_in;
  monitorOutput mon_out;
  scoreboard scb;
  
  mailbox gen2driv;
  mailbox mon_in2scb;
  mailbox mon_out2scb;
  
  virtual inputSignals i_vif;
  virtual outputSignals o_vif;
  
  function new(virtual inputSignals i_vif, virtual outputSignals o_vif);
    this.i_vif = i_vif;
    this.o_vif = o_vif;
    
    //Creating mailboxes
    
    gen2driv = new();
    mon_in2scb = new();
    mon_out2scb = new();
    
    //Wiring
    
    gen = new(gen2driv);
    driv = new(i_vif, gen2driv);
    mon_in = new(i_vif, mon_in2scb);
    mon_out = new(o_vif, mon_out2scb, i_vif);
    scb = new(mon_in2scb, mon_out2scb, i_vif);

  endfunction
  
  task pre_test();
    driv.reset();
  endtask
  
  task test();
    fork
      gen.run();
      driv.run();
      mon_in.run();
      mon_out.run();
      scb.run();
    join_any
  endtask
  
  task post_test;
    wait(gen.ended.triggered);
    wait(gen.tx_count == driv.counter);
  endtask
  
  task run;
    pre_test();
    test();
    post_test();
        
    //while (1);
    $display ("TOTAL OF %0d transactions has been sent, of which %0d are valid (valid_in high)", gen.tx_count, driv.counter);
  endtask
  
endclass