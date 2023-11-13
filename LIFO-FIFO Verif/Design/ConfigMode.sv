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