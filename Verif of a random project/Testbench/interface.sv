interface interfata(input logic clk,enable,
                    output logic [7:0]instrMem [0:1023], //Modified from 63 to 1023
                    input logic [31:0] regMem [0:31],
                    input logic [7:0] dataMem[0:1023], //Modified from 31 to 1023
                    input logic [31:0] instrOut,pc,result,
                    input logic regDst,jump,branch,memRead,memToReg,memWrite,aluSrc,regWrite,aluZero
                   );
  
endinterface