`include "driver.sv"
`include "transactionV.sv"

class monitor;

  mailbox mon_to_sb;
  virtual interfata intf;

  function new(mailbox mb,virtual interfata in);

    mon_to_sb=mb;
    intf=in;

  endfunction

  task run;

    forever
      begin
        transactionV tr=new();
        @(negedge intf.clk)
        begin
          $display("[INFO] Monitor");
          if(intf.enable)
            begin
              if(intf.instrOut[31:26]==6'b0)
                $display("\t R type instruction: %h",intf.instrOut);
            end
          tr.instrOut=intf.instrOut;
          tr.enable=intf.enable;
          tr.pc=intf.pc;
          tr.instrMem=intf.instrMem;
          tr.regDst=intf.regDst;
          tr.jump=intf.jump;
          tr.branch=intf.branch;
          tr.memRead=intf.memRead;
          tr.memToReg=intf.memToReg;
          tr.memWrite=intf.memWrite;
          tr.aluSrc=intf.aluSrc;
          tr.regWrite=intf.regWrite;
          tr.aluZero=intf.aluZero;
          tr.result=intf.result;
          tr.regMem=intf.regMem;
          tr.dataMem=intf.dataMem;
          mon_to_sb.put(tr);
        end
      end

  endtask


endclass