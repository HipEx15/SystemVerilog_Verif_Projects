`include "struct.sv"

`define READFROMFILE 35

class generator;

  rand myStruct str;
  int tx_count, offset_instr = 0, offset_mem = 0;
  event ended;

  //Memory
  reg [7:0] mem_temp [0:1023];

  mailbox gen2driv;

  function new(mailbox gen2driv);
    this.gen2driv = gen2driv;
    $readmemb("instM.txt", mem_temp);
    for(int i=0; i < `READFROMFILE; i++)
      begin
        {str.mem[offset_mem+3],str.mem[offset_mem+2],str.mem[offset_mem+1],str.mem[offset_mem]} = {mem_temp[offset_mem], mem_temp[offset_mem+1], mem_temp[offset_mem+2], mem_temp[offset_mem+3]};
        offset_mem = offset_mem + 4;
      end
  endfunction

  task run();
    $display("-------------------------------");
    for(int i=0; i < tx_count; ++i)
      begin
        str.tx = new();

        if(i < `READFROMFILE)
          begin
            str.tx.start = 1;
            str.tx.instr = {mem_temp[offset_instr+3], mem_temp[offset_instr+2], mem_temp[offset_instr+1], mem_temp[offset_instr]};
            offset_instr = offset_instr + 4;
          end
        else if( i >= 35 && i < 37)
          begin
            str.tx.start = 0;
            randomize(str.tx.instr);
          end
        else if( i >= 37 && i < 38)
          begin
            str.tx.start = 1;
            str.tx.instr = 32'h025388FF;
          end
        else if( i >= 38 && i < 39)
          begin
            str.tx.start = 1;
            str.tx.instr = 32'h110900FF;
          end
        else if( i >= 39 && i < 40)
          begin
            str.tx.start = 1;
            str.tx.instr = 32'h1FFFFFFF;
          end
        else if( i >= 40 && i < 44)
          begin
            str.tx.start = 1;
            str.tx.instr = 32'h110900FF;
          end
        else
          begin
            str.tx.start = 1;
            randomize(str.tx.instr);

            //$display("%0x0h", str.tx.instr);
			
            str.mem[offset_mem+3] = str.tx.instr[31:24];
            str.mem[offset_mem+2] = str.tx.instr[23:16];
            str.mem[offset_mem+1] = str.tx.instr[15:8];
            str.mem[offset_mem] = str.tx.instr[7:0];

            //$display("%0x0h", str.mem[z+3]);
            //$display(str.mem);
            offset_mem = offset_mem + 4;
          end
        //str.tx.print("[Generator]");
        gen2driv.put(str);
      end
    -> ended;
    $display("-------------------------------");
  endtask

endclass