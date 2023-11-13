module LIFO #(parameter DinLENGTH = 32, LIFO_Size = 4) (
    input clk, reset,
    input [DinLENGTH-1:0] din,
    input [1:0] mode,
    input [1:0] opcode,
    output reg [DinLENGTH-1:0] dout,
    output reg full, empty
);

    reg [DinLENGTH-1:0] mem [0:LIFO_Size-1]; 
    integer head, tail, size;
  
   	//VERIFICATION ADDED
    /*always @(clk)
      begin
        $display("%s %0t","\nLIFO\nSTART", $time);
        for(int bus_point = 0; bus_point < 4; bus_point = bus_point + 1)      			
              $display("%0xh", mem[bus_point]);
        $display("%s","STOP\n");
        end*/

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            size <= 0;
            head <= 0;
            tail <= 0;
            full <= 0;
            empty <= 1;
        end else begin
            case (mode)          
                FIFO: begin // FIFO
                    case (opcode)
                      NIMIC, PUSH_POP: begin
                        end
                      PUSH: 
                        if (size != LIFO_Size) begin // PUSH FIFO
                            mem[tail] <= din;
                            tail <= (tail + 1) % LIFO_Size;
                            full <= (size == LIFO_Size - 1) ? 1 : 0;
                            size <= size + 1;
                            empty <= 0;
                        end
                      POP: 
                        if(size != 0) begin // POP FIFO
                            if(tail == 0) begin
                                tail <= LIFO_Size-1;
								dout <= mem[LIFO_Size-1];
                              	mem[LIFO_Size-1] <= 32'b0;
                            end else begin
                                dout <= mem[tail-1];
                                mem[tail-1] <= 32'b0;
                                tail <= (tail - 1) % LIFO_Size;
                            end
                            empty <= (size == 1) ? 1 : 0;
                            size <= size - 1;
                            full <= 0;
                        end
                    endcase
                end
                
                LIFO: begin // LIFO
                    case (opcode)
                        NIMIC, PUSH_POP: begin
                        end
                        PUSH:  // LIFO PUSH
                        if (size != LIFO_Size) begin 
                            mem[tail] <= din;
                            tail <= (tail + 1) % LIFO_Size;
                            full <= (size == LIFO_Size - 1) ? 1 : 0;
                            size <= size + 1;
                            empty <= 0;
                        end
                        POP:  // LIFO POP
                          if (size != 0) begin 
                            dout <= mem[head];
                            mem[head] <= 32'b0;
                            head <= (head + 1) % LIFO_Size;
                            empty <= (size == 1) ? 1 : 0;
                            size <= size - 1;
                            full <= 0;
                        end
                    endcase
                end 
            endcase               
        end
    end
endmodule