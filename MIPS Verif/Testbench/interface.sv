interface mips_if(input logic clk);

  //Scoreboard
  logic [7:0] mem [0:1023];

  //Input
  logic start;
  logic [31:0] instr;

  //Output
  logic regDst, jump, branch, memRead, memToReg, memWrite, ALUSrc, regWrite;
  logic [1:0] ALUOp;
  
  logic [31:0] regs [0:31];
  logic [31:0] pc;
  logic [7:0] memOut [0:1023];

endinterface