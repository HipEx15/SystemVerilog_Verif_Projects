module Buffer #(parameter DinLENGTH = 32) (
    input clk,
    input [DinLENGTH-1:0] din1, din2,
    input [1:0] mode,
    output reg [DinLENGTH-1:0] dout
    );
    
    always @(posedge clk) begin
        dout <= (mode == BUFFER) ? din1 : din2;
    end
    
endmodule