class transaction;

  //Input
  rand bit [31:0] instr;
  rand bit start;

  //Output
  //Control
  bit regDst, jump, branch, memRead, memToReg, memWrite, ALUSrc, regWrite;
  bit [1:0] ALUOp;

  logic [31:0] regs [0:31];
  logic [31:0] pc;
  logic [7:0] memOut [0:1023];

  constraint c_opcode {
    instr[31:26] inside {6'h0, 6'h8, 6'h4, 6'h23, 6'h2b, 6'h2};
  };

  function void print(string tag="");
    $display("-------------------------------");
    $display("Tag: %s", tag);
    $display("Time: %0t", $time);
    $display("Start: 0x%0h", start);
    $display("Instruction: 0x%0h", instr);
    $display("regDst: 0x%0h | jump: 0x%0h | branch: 0x%0h | memRead: 0x%0h | memToReg: 0x%0h | memWrite: 0x%0h | ALUSrc: 0x%0h | regWrite: 0x%0h | ALUOp: 0x%0h", regDst, jump, branch, memRead, memToReg, memWrite, ALUSrc, regWrite, ALUOp);
    $display("-------------------------------");

  endfunction

endclass