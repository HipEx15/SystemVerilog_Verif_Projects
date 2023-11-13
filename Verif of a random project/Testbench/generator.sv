`include "transaction.sv"

class generator;
  
  mailbox gen_to_drv;
  reg [7:0] instrMem[0:1023]; //Modified from 63 to 1023
  
  function new(mailbox mb);
    
    gen_to_drv=mb;
    $readmemb("instM.txt",instrMem);
    
  endfunction
  
  //Generator input !!
  // BUG verif pc (incrementare dupa asignare)
  // BUG verif JUMP (nu foloeste pc-ul creat)
  // BUG verif Enable
  // BUG instr = xxx => flag-uri sunt pe 0 (ar fi trebuit sa fie x)
  
  task run();
    
    transaction tr=new();
    
    tr=new();
    tr.instrMem=instrMem;
    gen_to_drv.put(tr);
    
    
  endtask
  
  
endclass