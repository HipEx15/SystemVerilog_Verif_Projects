`include "agent.sv"

class environment;
  
  mailbox mon_to_sb;
  
  scoreboard sb;
  agent a;
  
  virtual interfata intf;
  
  function new(virtual interfata inn);
    
    mon_to_sb=new();
    intf=inn;
    
    sb=new(mon_to_sb);
    a=new(mon_to_sb,intf);
    
  endfunction
    
  task run;
    
    fork
      sb.run();
      a.run();
    join_none
    
  endtask
  
  
endclass