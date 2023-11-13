typedef enum {BUFFER, LIFO, FIFO, INVALID} mod;
typedef enum {NIMIC, PUSH, POP, PUSH_POP} operatie;

module ConfigMode(
    input clk,
    input chip_en_buf,
    input chip_en_fifo,
    input chip_en_lifo,
    output [1:0] mode
    );
    
    mod tipul;
    
    always @(posedge clk) begin
        if(chip_en_buf & ~chip_en_fifo & ~chip_en_lifo)
            tipul = BUFFER; // Buffer
        else if(~chip_en_buf & ~chip_en_fifo & chip_en_lifo)
            tipul = LIFO; // LIFO
        else if(~chip_en_buf & chip_en_fifo & ~chip_en_lifo)
            tipul = FIFO; // FIFO
        else
            tipul = INVALID; // Invalid mode
    end 
    
    assign mode = tipul;
          
endmodule

module Memorie #(parameter WIDTH = 8, DinLENGTH = 32)(
    input clk, reset, r_w, valid,
    input [DinLENGTH-1:0] din,
    input [WIDTH-1:0] addr, 
    output reg [DinLENGTH-1:0] dout
    );
    
    reg [DinLENGTH:0] bus [0:WIDTH-1];
    integer bus_point;
    
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
                                tail <= 32'h3;
                                dout <= mem[3];
                                mem[3] <= 32'b0;
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

module top #(parameter DinLENGTH = 32, LIFO_Size = 4, WIDTH = 8) (
    input clk, reset,
    input chip_en_buf, chip_en_lifo, chip_en_fifo,
    input [DinLENGTH-1:0] din,
    input [WIDTH-1:0] addr,
    input r_w, valid,
    input [1:0] opcode,
    output [DinLENGTH-1:0] dout,
    output full, empty
    );
    
    wire [1:0] mode;
    wire [DinLENGTH-1:0] dout_inter;
    wire [DinLENGTH-1:0] dout_lifo;
    
    ConfigMode configMode(clk, chip_en_buf, chip_en_lifo, chip_en_fifo, mode);
  	Memorie memorie(clk, reset, r_w, valid, din, addr, dout_inter);
    LIFO lifo(clk, reset, dout_inter, mode, opcode, dout_lifo, full, empty);
    Buffer buffer(clk, din, dout_lifo, mode, dout);
     
endmodule