class transactionV;
  
  //Initially bit => logic
  logic [31:0] instrOut,pc,result;
  logic [31:0] regMem [0:31];
  logic [7:0] dataMem [0:1023]; //Modified from 31 to 1023
  logic enable;
  logic [7:0] instrMem[0:1023]; //Modified from 63 to 1023
  logic regDst,jump,branch,memRead,memToReg,memWrite,aluSrc,regWrite,aluZero;
  
endclass