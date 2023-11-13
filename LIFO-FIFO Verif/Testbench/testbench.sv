`include "inputInterface.sv"
`include "outputInterface.sv"
`include "test.sv"


module top_tb;
  
  bit clk, reset;
  
  //Interfaces
  
  //Input
  inputSignals inputType(clk, reset);
  //Output
  outputSignals outputType(clk, reset);
  
  //Test
  test test(inputType, outputType);

  top #(.DinLENGTH(32), .LIFO_Size(4), .WIDTH(4)) DFF (
    .clk(inputType.clk),
    .reset(inputType.reset),
    .chip_en_buf(inputType.chip_en_buf),
    .chip_en_lifo(inputType.chip_en_lifo),
    .chip_en_fifo(inputType.chip_en_fifo),
    .din(inputType.din),
    .addr(inputType.addr),
    .r_w(inputType.r_w),
    .valid(inputType.valid),
    .opcode(inputType.opcode),
    .dout(outputType.dout),
    .full(outputType.full),
    .empty(outputType.empty)
  );
    
  initial begin
    clk = 1'b0;
    forever
      #5 clk = ~clk;
  end
  
  initial
    begin
      #0 reset = 1'b1; 
      #10 reset = 1'b0; 
 
      //#40 reset = 1'b1; //BUFF_RS CASE D
      //#60 reset = 1'b0;
      
      //#130 reset = 1'b1; //LIFO_RS CASE E (SHOW #110/120/130)
      //#30 reset = 1'b0; //LIFO_RS CASE E
      
      //#120 reset = 1'b1; LIFO_RS3 CASE J
      //#15 reset = 1'b0;
    end
  
  initial
    begin
      $dumpvars(0,DFF);
      $dumpfile("dump.vcd");
    end
  
endmodule

/*module top_tb;
  
  reg clk, reset;
  reg chip_en_buf, chip_en_lifo, chip_en_fifo;
  reg [31:0] din;
  reg [7:0] addr;
  reg r_w, valid;
  reg [1:0] opcode;
  wire [31:0] dout;
  wire full, empty;
  
  top #(.DinLENGTH(32), .LIFO_Size(4), .WIDTH(8)) DFF (
    .clk(clk),
    .reset(reset),
    .chip_en_buf(chip_en_buf),
    .chip_en_lifo(chip_en_lifo),
    .chip_en_fifo(chip_en_fifo),
    .din(din),
    .addr(addr),
    .r_w(r_w),
    .valid(valid),
    .opcode(opcode),
    .dout(dout),
    .full(full),
    .empty(empty)
  );
  
  initial begin
    
    $dumpvars(0,DFF);
    $dumpfile("dump.vcd");
    
    clk = 1'b0;
    reset = 1'b1;
    chip_en_buf = 1'b0;
    chip_en_lifo = 1'b0;
    chip_en_fifo = 1'b0;
    addr = 8'h00;
    din = 32'hDEADBEEF;
    r_w = 1'b1;
    valid = 1'b1;
    opcode = 2'b00;
    
    #10;
    	reset = 1'b0;
    #20;
		din = 32'h12345678; addr = 8'h03;
    #20;
    	din = 32'hABBAABBA; addr = 8'h05;
    #20;
    	din = 32'h45632457; addr = 8'h04;
    #20;
    	r_w = 1'b0; chip_en_fifo = 1'b1; 
    #10;
    	opcode = 2'b01; din = 32'h00000000; addr = 8'h05;
    #10;
    	addr = 8'h03;
    #10;
    	addr = 8'h04;
    #10;
    	addr = 8'h00;
    #20;
    	opcode = 2'b10;
    #20;
	    chip_en_lifo = 1'b0; chip_en_fifo = 1'b1; 
	#10;
	    opcode = 2'b01; addr = 8'h05;
    #10;
    	addr = 8'h03;
    #10;
    	addr = 8'h04;
    #10;
    	addr = 8'h00;
    #10;
    	opcode = 2'b10;
    #50;
   	    chip_en_fifo = 1'b0; chip_en_buf = 1'b1; 
   	#10;
   	    din = 32'hACCAACCA;
    #10;
    	din = 32'h65342754;
    #10;
    	din = 32'h65342;
    #100;
    	$finish();
  end
  
  always #5 clk = ~clk;
  
endmodule*/