class transaction;
  
  rand bit chip_en_buf;
  rand bit chip_en_lifo;
  rand bit chip_en_fifo;
  rand bit [31:0] din;
  bit [3:0] addr;
  rand bit r_w;
  rand bit valid;
  rand bit [1:0] opcode;
  
  bit [31:0] dout;
  bit full;
  bit empty;
  
  //Constraints for address
  
  constraint c_addr {
    addr inside {[0:3]};
  };
  
  //Constraints for opcode
  
  constraint c_opcode {
    opcode inside {[0:3]};
  };
  
  //Constraints for modes
  
  constraint c_chip_en_buf {
    chip_en_buf == 1 -> chip_en_lifo != 1 && chip_en_fifo != 1;
  };
  
  constraint c_chip_en_lifo {
    chip_en_lifo == 1 -> chip_en_buf != 1 && chip_en_fifo != 1;
  };
  
  constraint c_chip_en_fifo {
    chip_en_fifo == 1 -> chip_en_lifo != 1 && chip_en_buf != 1;
  };
  
  function void print(string tag="");
    $display("Time: %0t | Tag: %s  \n--INPUT--\n Buff: 0x%0h | LIFO: 0x%0h | FIFO: 0x%0h | Data_in: 0x%0h | Addr: 0x%0h | RW: 0x%0h | Valid: 0x%0h | Opcode: 0x%0h \n--OUTPUT--\n Data_out: 0x%0h | Full: 0x%0h | Empty: 0x%0h", $time, tag, chip_en_buf, chip_en_lifo, chip_en_fifo, din, addr, r_w, valid, opcode, dout, full, empty);
  endfunction
  
endclass