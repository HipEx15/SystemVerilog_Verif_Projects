module Memorie #(parameter WIDTH = 4, DinLENGTH = 32)( //INITIAL WIDTH = 8
    input clk, reset, r_w, valid,
    input [DinLENGTH-1:0] din,
    input [WIDTH-1:0] addr, 
    output reg [DinLENGTH-1:0] dout
    );
    
    reg [DinLENGTH:0] bus [0:WIDTH-1];
    integer bus_point;
    
  	//VERIFICATION ADDED
  	/*always @(clk)
    begin
      $display("%s %0t","\nMEMORY\nSTART", $time);
      for(bus_point = 0; bus_point < WIDTH; bus_point = bus_point + 1)      				$display("%0xh", bus[bus_point]);
      $display("%s","STOP");
    end*/
  
    always @(posedge clk or posedge reset) begin
        if(reset) begin
            for(bus_point = 0; bus_point < WIDTH; bus_point = bus_point + 1) begin
                bus[bus_point] <= 0;
            end
            dout <= 0;
         end else begin
           	if(valid) begin
         		if(r_w) begin // R_w = 1 -> Write
                	bus[addr] <= din;
            	end else begin // R_W = 0 -> Pop
                	dout <= bus[addr];
            	end
            end
        end
    end    
endmodule