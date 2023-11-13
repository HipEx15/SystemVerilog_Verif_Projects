`include "env.sv"

program test(mips_if var_if);
  environment env;
  
  initial begin
    env = new(var_if);
    env.gen.tx_count = 50;
    env.run();
  end
endprogram