class scoreboard;

  localparam DIMMENSION = 4; //8 CASE C

  virtual inputSignals i_vif;

  mailbox mon_in2scb;
  mailbox mon_out2scb; 

  reg [31:0] Memory [0 : DIMMENSION - 1];
  reg [31:0] FILO [0 : DIMMENSION - 1];

  integer head, tail, size;

  reg [31:0] memOutput;

  function new(mailbox mon_in2scb, mailbox mon_out2scb,   virtual inputSignals i_vif);

    this.i_vif = i_vif;
    this.mon_in2scb = mon_in2scb;
    this.mon_out2scb = mon_out2scb;

    head = 0;
    tail = 0;
    size = 0;

    for(int i = 0; i < DIMMENSION; i = i + 1) begin
      Memory[i] = 0;
      FILO[i] = 0;
    end

  endfunction //new()

  task run();
    transaction tx_in, tx_out;

    forever begin

      /*$display("%s %0t","\nSTART", $time);
      for(int bus_point = 0; bus_point < DIMMENSION; bus_point = bus_point + 1)      		
        $display("%0xh", FILO[bus_point]);
      $display("%s","STOP\n");*/


      //Getting values from monitors
      mon_in2scb.get(tx_in);
      mon_out2scb.get(tx_out);

      if(tx_in.valid == 1)
        begin
          if(tx_in.r_w == 1)
            begin
              Memory[tx_in.addr] = tx_in.din;
            end
          else
            begin
              memOutput = Memory[tx_in.addr];
            end
        end
      if(i_vif.reset == 1)
        begin
          if(tx_in.din != tx_out.dout)
            begin
              $error("Reset -> Data mismatch");
            end
        end
      else
        begin
          if((tx_in.chip_en_buf == 1) && (tx_in.chip_en_lifo == 0) && (tx_in.chip_en_fifo == 0)) // BUFFER
            begin
              if(memOutput != tx_out.dout)
                begin
                  $error("Buffer -> Data mismatch");
                end
            end
          else if(tx_in.opcode == 1) // PUSH
            begin
              if(size != DIMMENSION)
                begin
                  FILO[tail] = memOutput;
                  tail = (tail + 1) % DIMMENSION;
                  size = size + 1;
                  //FULL FLAG
                  if((size == DIMMENSION - 1) && (tx_out.full == 0))
                    begin
                      $error("Write FIFO/LIFO - Full flag mismatch");
                      $display("Time: %0t Actual: %0d Expected: %0d", $time, tx_out.full, 1);
                    end

                  //EMPTY FLAG
                  if(tx_out.empty != 0)
                    begin
                      $error("Write FIFO/LIFO - Empty flag mismatch");
                      $display("Time: %0t Actual: %0d Expected: %0d", $time, tx_out.empty, 0);
                    end        
                end
            end
          else if (tx_in.opcode == 2) begin // POP
            if((tx_in.chip_en_fifo == 1) && (tx_in.chip_en_lifo == 0)) //FIFO
              begin
                if(size != 0)
                  begin
                    if(tx_out.dout != FILO[head])
                      begin
                        $error("Read LIFO - Data mismatch");
                        $display("Time: %0t Actual: %0h Expected: %0h", $time, tx_out.dout, FILO[head]);
                      end
                    FILO[head] = 0;
                    head = (head + 1) % DIMMENSION;
                    size = size - 1;

                    /*$display("Monitor: F: %h E: %h", FILO[head], tx_out.dout);

                    $display("%s %0t","\nLIFO\nSTART", $time);
                    for(int bus_point = 0; bus_point < DIMMENSION; bus_point = bus_point + 1)      		
                      $display("%0xh", FILO[bus_point]);
                    $display("%s","STOP\n");	*/

                    //FULL FLAG
                    if(tx_out.full != 0)
                      begin
                        $error("Read LIFO - Full flag mismatch");
                        $display("Time: %0t Actual: %0d Expected: %0d", $time, tx_out.full, 0);
                      end

                    //EMPTY FLAG
                    if(size == 1 && tx_out.empty == 0)
                      begin
                        $error("Read LIFO - Empty flag mismatch");              
                        $display("Time: %0t Actual: %0d Expected: %0d", $time, tx_out.empty, 1);
                      end
                  end
              end
            else if((tx_in.chip_en_lifo == 1) && (tx_in.chip_en_fifo == 0)) //LIFO
              begin
                if(size != 0)
                  begin
                    if(tail == 0)
                      begin
                        tail = DIMMENSION - 1;
                        if(tx_out.dout != FILO[DIMMENSION - 1])
                          begin
                            $error("Read FIFO - Data mismatch");
                            $display("Time: %0t Actual: %0h Expected: %0h", $time, tx_out.dout, FILO[DIMMENSION - 1]);
                          end
                        FILO[DIMMENSION - 1] = 0;
                      end
                    else
                      begin
                        if(tx_out.dout != FILO[tail - 1])
                          begin
                            $error("Read FIFO - Data mismatch");
                            $display("Time: %0t Actual: %0h Expected: %0h", $time, tx_out.dout, FILO[tail - 1]);

                          end
                        FILO[tail - 1] = 0;
                        tail = (tail - 1) % DIMMENSION;
                      end

                    /*$display("Monitor: F: %h E: %h", memOutput, tx_out.dout);

                    $display("%s %0t","\nLIFO\nSTART", $time);
                    for(int bus_point = 0; bus_point < DIMMENSION; bus_point = bus_point + 1)      		
                      $display("%0xh", FILO[bus_point]);
                    $display("%s","STOP\n");*/	

                    size = size - 1;

                    //FULL FLAG
                    if(tx_out.full != 0)
                      begin
                        $error("Read FIFO - Full flag mismatch");
                        $display("Time: %0t Actual: %0d Expected: %0d", $time, tx_out.full, 0);
                      end
                    //EMPTY FLAG
                    if(size == 1 && tx_out.empty == 0)
                      begin
                        $error("Read FIFO - Empty flag mismatch");
                        $display("Time: %0t Actual: %0d Expected: %0d", $time, tx_out.empty, 1);
                      end
                  end
              end
          end
        end
    end
  endtask //

endclass //scoreboard