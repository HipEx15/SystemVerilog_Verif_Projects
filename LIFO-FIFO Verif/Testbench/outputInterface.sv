interface outputSignals(input logic clk, input logic reset);
  
  logic [31:0] dout;
  logic full;
  logic empty;
  
  modport outputType(output dout, full, empty);
  
endinterface