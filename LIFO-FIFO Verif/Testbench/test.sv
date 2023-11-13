`include "env.sv"

program test(inputSignals i_intf, outputSignals o_intf);
  environment env;
  
  initial begin
    env = new(i_intf, o_intf);
    env.gen.tx_count = 26; //16
    env.gen.scenario = LIFO_FIFO;
    env.run();
  end
endprogram