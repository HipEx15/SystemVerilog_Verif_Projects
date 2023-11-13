`include "generator.sv"
`include "interface.sv"


class driver;

  mailbox gen_to_drv;
  virtual interfata intf;


  function new(mailbox mb,virtual interfata intf);

    gen_to_drv=mb;
    this.intf=intf;

  endfunction


  task run();

    transaction tr;

    forever 
      @(posedge intf.clk)
        begin
          gen_to_drv.get(tr);
          intf.instrMem=tr.instrMem;
        end


  endtask


endclass