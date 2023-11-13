`include "generator.sv"
`include "driver.sv"
`include "monitor.sv"
`include "scoreboard.sv"

class environment;

  generator gen;
  driver driv;
  monitor mon;
  scoreboard scb;

  mailbox gen2driv;
  mailbox mon2scb;

  virtual mips_if var_if;

  function new(virtual mips_if var_if);
    this.var_if = var_if;

    //Creating mailboxes

    gen2driv = new();
    mon2scb = new();

    //Wiring

    gen = new(gen2driv);
    driv = new(var_if, gen2driv);
    mon = new(var_if, mon2scb);
    scb = new(mon2scb);

  endfunction

  task test();
    fork
      gen.run();
      driv.run();
      mon.run();
      scb.run();
    join_any
  endtask

  task post_test();
    wait(gen.ended.triggered);
    wait(gen.tx_count == driv.counter);
  endtask

  task run;
    test();
    post_test();
    //$finish;
  endtask

endclass