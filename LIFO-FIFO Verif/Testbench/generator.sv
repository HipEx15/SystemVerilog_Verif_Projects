`include "transaction.sv"

//CASE B
//Pentru a ajusta dimensiunea stivei de la 8 la oricare alta dimensiune dorita, trebuie sa specificam dimensiunea in prealabil, practic inainte de a rula codul efectiv. Altfel spus inainte de a ajunge la runtime. SystemVerilog nu permite modificarea parametrilor in timpul runtime-ului, deoarece acest lucru poate duce la aparitia unor erori, cum ar fi conflicte intre variabile cu acelasi nume sau pierderea de date.

typedef enum {FIFO_LIFO, FIFO_BUFF9, BUFF_RS, LIFO_RS, LIFO_BUFF, LIFO_FIFO, SIM_LIFO, FIFO_BUFF, LIFO_RS3, STACK_FIFO} scenarios;

class generator;


  scenarios scenario;
  rand transaction tx;
  int tx_count;
  event ended;

  //Work in progress
  mailbox gen2driv;

  function new(mailbox gen2driv);
    this.gen2driv = gen2driv;
  endfunction

  task run();
    $display("[ GENERATOR ] ****** GENERATOR STARTED ******");
    for(int i=0; i < tx_count; ++i)
      begin
        tx = new();
        case(scenario)
          FIFO_LIFO: // CASE A
            begin
              if (i < 4)
                begin
                  tx.opcode = 0;

                  tx.chip_en_fifo = 0;
                  tx.chip_en_lifo = 0;
                  tx.chip_en_buf = 0;

                  tx.valid = 1;
                  tx.r_w = 1;
                end
              else if (i >= 4 && i < 9)
                begin
                  tx.opcode = 1;

                  tx.chip_en_fifo = 1;
                  tx.chip_en_lifo = 0;
                  tx.chip_en_buf = 0;

                  tx.valid = 1;
                  tx.r_w = 0;
                end
              else if (i >= 9 && i < 11)
                begin
                  tx.opcode = 2;

                  tx.chip_en_fifo = 1;
                  tx.chip_en_lifo = 0;
                  tx.chip_en_buf = 0;

                  tx.valid = 1;
                  tx.r_w = 0;
                end
              else if (i >= 11)
                begin
                  tx.opcode = 2;

                  tx.chip_en_fifo = 0;
                  tx.chip_en_lifo = 1;
                  tx.chip_en_buf = 0;

                  tx.valid = 1;
                  tx.r_w = 0;
                end
              randomize(tx.din);
              tx.addr = i%4;
              assert(tx);
              //$display("T=%0t Loop: %0d/%0d create next item", $time, i+1, tx_count);
              //tx.print("");
              gen2driv.put(tx);
            end

          FIFO_BUFF9: // CASE C
            begin
              if (i < 8)
                begin
                  tx.opcode = 0;

                  tx.chip_en_fifo = 0;
                  tx.chip_en_lifo = 0;
                  tx.chip_en_buf = 0;

                  tx.valid = 1;
                  tx.r_w = 1;
                end
              else if (i >= 8 && i < 11)
                begin
                  tx.opcode = 1;

                  tx.chip_en_fifo = 0;
                  tx.chip_en_lifo = 0;
                  tx.chip_en_buf = 1;

                  tx.valid = 1;
                  tx.r_w = 1;
                end
              else if (i >= 11 && i < 19)
                begin
                  tx.opcode = 1;

                  tx.chip_en_fifo = 0;
                  tx.chip_en_lifo = 1;
                  tx.chip_en_buf = 0;

                  tx.valid = 1;
                  tx.r_w = 0;
                end
              else if (i >= 19)
                begin
                  tx.opcode = 2;

                  tx.chip_en_fifo = 0;
                  tx.chip_en_lifo = 1;
                  tx.chip_en_buf = 0;

                  tx.valid = 1;
                  tx.r_w = 0;
                end
              randomize(tx.din);
              tx.addr = i%8;
              assert(tx);
              //$display("T=%0t Loop: %0d/%0d create next item", $time, i+1, tx_count);
              //tx.print("");
              gen2driv.put(tx);
            end	

          BUFF_RS:// CASE D
            begin
              tx.opcode = 0;

              tx.chip_en_fifo = 0;
              tx.chip_en_lifo = 0;
              tx.chip_en_buf = 1;

              tx.valid = 1;
              tx.r_w = 1;

              randomize(tx.din);
              tx.addr = i%4;
              assert(tx);
              //$display("T=%0t Loop: %0d/%0d create next item", $time, i+1, tx_count);
              //tx.print("");
              gen2driv.put(tx);
            end

          LIFO_RS: //CASE E
            begin
              if (i < 4)
                begin
                  tx.opcode = 0;

                  tx.chip_en_fifo = 0;
                  tx.chip_en_lifo = 0;
                  tx.chip_en_buf = 0;

                  tx.valid = 1;
                  tx.r_w = 1;
                end
              else if (i >= 4 && i < 9)
                begin
                  tx.opcode = 1;

                  tx.chip_en_fifo = 0;
                  tx.chip_en_lifo = 1;
                  tx.chip_en_buf = 0;

                  tx.valid = 1;
                  tx.r_w = 0;
                end
              else if (i >= 9)
                begin
                  tx.opcode = 2;

                  tx.chip_en_fifo = 0;
                  tx.chip_en_lifo = 1;
                  tx.chip_en_buf = 0;

                  tx.valid = 1;
                  tx.r_w = 0;
                end
              randomize(tx.din);
              tx.addr = i%4;
              assert(tx);
              //$display("T=%0t Loop: %0d/%0d create next item", $time, i+1, tx_count);
              //tx.print("");
              gen2driv.put(tx);
            end

          LIFO_BUFF: //CASE F
            begin
              if (i < 4)
                begin
                  tx.opcode = 0;

                  tx.chip_en_fifo = 0;
                  tx.chip_en_lifo = 0;
                  tx.chip_en_buf = 0;

                  tx.valid = 1;
                  tx.r_w = 1;
                end
              else if (i >= 4 && i < 9)
                begin
                  tx.opcode = 1;

                  tx.chip_en_fifo = 0;
                  tx.chip_en_lifo = 1;
                  tx.chip_en_buf = 0;

                  tx.valid = 1;
                  tx.r_w = 0;
                end
              else if (i >= 9 && i < 13)
                begin
                  tx.opcode = 2;

                  tx.chip_en_fifo = 0;
                  tx.chip_en_lifo = 1;
                  tx.chip_en_buf = 0;

                  tx.valid = 1;
                  tx.r_w = 0;
                end
              else if (i >= 13)
                begin
                  tx.opcode = 0;

                  tx.chip_en_fifo = 0;
                  tx.chip_en_lifo = 0;
                  tx.chip_en_buf = 1;

                  tx.valid = 1;
                  tx.r_w = 0;
                end
              randomize(tx.din);
              tx.addr = i%4;
              assert(tx);
              //$display("T=%0t Loop: %0d/%0d create next item", $time, i+1, tx_count);
              //tx.print("");
              gen2driv.put(tx);
            end

          SIM_LIFO: //CASE H
            begin
              if (i < 4)
                begin
                  tx.opcode = 0;

                  tx.chip_en_fifo = 0;
                  tx.chip_en_lifo = 0;
                  tx.chip_en_buf = 0;

                  tx.valid = 1;
                  tx.r_w = 1;
                end
              else if (i >= 4 && i < 9)
                begin
                  tx.opcode = 1;

                  tx.chip_en_fifo = 0;
                  tx.chip_en_lifo = 1;
                  tx.chip_en_buf = 0;

                  tx.valid = 1;
                  tx.r_w = 0;
                end
              else if (i >= 9)
                begin
                  tx.opcode = 2;

                  tx.chip_en_fifo = 0;
                  tx.chip_en_lifo = 1;
                  tx.chip_en_buf = 0;

                  tx.valid = 1;
                  tx.r_w = 0;
                end

              randomize(tx.din);
              tx.addr = i%4;
              assert(tx);
              //$display("T=%0t Loop: %0d/%0d create next item", $time, i+1, tx_count);
              //tx.print("");
              gen2driv.put(tx);
            end

          FIFO_BUFF: //CASE I
            begin
              if (i < 4)
                begin
                  tx.opcode = 0;

                  tx.chip_en_fifo = 0;
                  tx.chip_en_lifo = 0;
                  tx.chip_en_buf = 0;

                  tx.valid = 1;
                  tx.r_w = 1;
                end
              else if (i >= 4 && i < 9)
                begin
                  tx.opcode = 1;

                  tx.chip_en_fifo = 1;
                  tx.chip_en_lifo = 0;
                  tx.chip_en_buf = 0;

                  tx.valid = 1;
                  tx.r_w = 0;
                end
              else if (i >= 9 && i < 13)
                begin
                  tx.opcode = 2;

                  tx.chip_en_fifo = 1;
                  tx.chip_en_lifo = 0;
                  tx.chip_en_buf = 0;

                  tx.valid = 1;
                  tx.r_w = 0;
                end
              else if (i >= 13)
                begin
                  tx.opcode = 0;

                  tx.chip_en_fifo = 0;
                  tx.chip_en_lifo = 0;
                  tx.chip_en_buf = 1;

                  tx.valid = 1;
                  tx.r_w = 0;
                end
              randomize(tx.din);
              tx.addr = i%4;
              assert(tx);
              //$display("T=%0t Loop: %0d/%0d create next item", $time, i+1, tx_count);
              //tx.print("");
              gen2driv.put(tx);
            end

          LIFO_RS3: // CASE J
            begin
              if (i < 4)
                begin
                  tx.opcode = 0;

                  tx.chip_en_fifo = 0;
                  tx.chip_en_lifo = 0;
                  tx.chip_en_buf = 0;

                  tx.valid = 1;
                  tx.r_w = 1;
                end
              else if (i >= 4 && i < 8)
                begin
                  tx.opcode = 1;

                  tx.chip_en_fifo = 0;
                  tx.chip_en_lifo = 1;
                  tx.chip_en_buf = 0;

                  tx.valid = 1;
                  tx.r_w = 0;
                end
              else if (i >= 8)
                begin
                  tx.opcode = 2;

                  tx.chip_en_fifo = 0;
                  tx.chip_en_lifo = 1;
                  tx.chip_en_buf = 0;

                  tx.valid = 1;
                  tx.r_w = 0;
                end

              randomize(tx.din);
              tx.addr = i%4;
              assert(tx);
              //$display("T=%0t Loop: %0d/%0d create next item", $time, i+1, tx_count);
              //tx.print("");
              gen2driv.put(tx);
            end
          
          LIFO_FIFO:
            begin
              if (i < 4)
                begin
                  tx.opcode = 0;

                  tx.chip_en_fifo = 0;
                  tx.chip_en_lifo = 0;
                  tx.chip_en_buf = 0;

                  tx.valid = 1;
                  tx.r_w = 1;
                end
              else if (i >= 4 && i < 9)
                begin
                  tx.opcode = 1;

                  tx.chip_en_fifo = 0;
                  tx.chip_en_lifo = 1;
                  tx.chip_en_buf = 0;

                  tx.valid = 1;
                  tx.r_w = 0;
                end
              else if (i >= 9 && i < 11)
                begin
                  tx.opcode = 2;

                  tx.chip_en_fifo = 0;
                  tx.chip_en_lifo = 1;
                  tx.chip_en_buf = 0;

                  tx.valid = 1;
                  tx.r_w = 0;
                end
              else if (i >= 11)
                begin
                  tx.opcode = 2;

                  tx.chip_en_fifo = 1;
                  tx.chip_en_lifo = 0;
                  tx.chip_en_buf = 0;

                  tx.valid = 1;
                  tx.r_w = 0;
                end
              randomize(tx.din);
              tx.addr = i%4;
              assert(tx);
              //$display("T=%0t Loop: %0d/%0d create next item", $time, i+1, tx_count);
              //tx.print("");
              gen2driv.put(tx);
            end

          STACK_FIFO:
            begin
              if (i < 4)
                begin
                  tx.opcode = 0;

                  tx.chip_en_fifo = 0;
                  tx.chip_en_lifo = 0;
                  tx.chip_en_buf = 0;

                  tx.valid = 1;
                  tx.r_w = 1;
                end
              else if (i >= 4 && i < 9)
                begin
                  tx.opcode = 1;

                  tx.chip_en_fifo = 1;
                  tx.chip_en_lifo = 0;
                  tx.chip_en_buf = 0;

                  tx.valid = 1;
                  tx.r_w = 0;
                end
              else if (i >= 9 && i < 13)
                begin
                  tx.opcode = 0;

                  tx.chip_en_fifo = 0;
                  tx.chip_en_lifo = 0;
                  tx.chip_en_buf = 1;

                  tx.valid = 1;
                  tx.r_w = 0;
                end
              else if (i >= 13)
                begin
                  tx.opcode = 2;

                  tx.chip_en_fifo = 0;
                  tx.chip_en_lifo = 1;
                  tx.chip_en_buf = 0;

                  tx.valid = 1;
                  tx.r_w = 0;
                end
              randomize(tx.din);
              tx.addr = i%4;
              assert(tx);
              //$display("T=%0t Loop: %0d/%0d create next item", $time, i+1, tx_count);
              //tx.print("");
              gen2driv.put(tx);
            end
        endcase
      end
    -> ended;
    $display("[ GENERATOR ] ****** GENERATOR ENDED ******");
  endtask

endclass