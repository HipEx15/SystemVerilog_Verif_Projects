`include "scoreboard.sv"

class agent;
  
  mailbox gen_to_drv;
  mailbox mon_to_sb;
  virtual interfata intf;
  
  generator gen;
  driver drv;
  monitor mon;
  
  
  function new(mailbox mb,virtual interfata inn);
    gen_to_drv=new();
    mon_to_sb=mb;
    intf=inn;
    
    gen=new(gen_to_drv);
    drv=new(gen_to_drv,intf);
    mon=new(mon_to_sb,intf);
  endfunction
  
  
  task run;
    fork
      gen.run();
      drv.run();
      mon.run();
    join_none
  endtask
  
endclass