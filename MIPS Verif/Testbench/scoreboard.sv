//bug design beq, sare la o adresa care nu e in range
//bug legat de start, flow-ul 0/1 programul inca ruleaza
// testat un registru care nu exista
// Define-uri + refactorizare cod (done it)
// Finalizare testare instructiuni I si J + LW/SW
// Tabelul cu bug-uri + snippet cu bug-uri
//Default case pt orice alta instructiune !! -> bug de verificare + beq/j bug 
`define R_Opcode 6'h00
`define ADD 6'b100000
`define SUB 6'b100010
`define AND 6'b100100
`define OR 6'b100101
`define SLT 6'b101010
`define ADDI_Opcode 6'h8
`define ANDI_Opcode 6'h10
`define LW_Opcode 6'h23
`define SW_Opcode 6'h2b
`define J_Opcode 6'h2
`define BEQ_Opcode 6'h4

class scoreboard; 

  mailbox mon2scb;

  reg [31:0] regs [0:31];
  reg [31:0] pc;
  logic [31:0] instr_mem;
  logic [7:0] memOut [0:1023];

  integer offset = 0;

  function new(mailbox mon2scb); 
    this.mon2scb = mon2scb;
    foreach(regs[i]) regs[i] = 32'b0;
    pc = 32'b0;
  endfunction

  task run();
    myStruct str;    
    forever
      begin
        mon2scb.get(str);

        if(str.tx.start == 1)
          begin

            //Checking PC //ASK FOR JUMP

            pc = pc + 4;
            if(str.tx.jump)
              begin
                pc = str.tx.instr[25:0] << 2;
              end
            else if(str.tx.pc != pc) 
              begin
                $error("Wrong PC value ! PC_mips: 0x%0h | PC_scb: 0x%0h", str.tx.pc, pc);
              end

            instr_mem = {str.mem[offset], str.mem[offset+1], str.mem[offset+2], str.mem[offset+3]};
            //$display("Aici: 0x%0h Instr: 0x%0h", instr_mem[31:26], instr_mem);
            offset = offset + 4;

            //$display("HERE: %0x0h %d", instr_mem, z);
            if((instr_mem[31:26] == `R_Opcode) && ({str.tx.regDst,str.tx.jump,str.tx.branch,str.tx.memRead,str.tx.memToReg,str.tx.memWrite,str.tx.ALUSrc,str.tx.regWrite,str.tx.ALUOp} != {1'b1 ,1'b0,1'b0  ,1'b0   ,1'b0    ,1'b0    ,1'b0  ,1'b1    ,2'b10}))
              begin
                begin
                  if((instr_mem[5:0] == `ADD) )//ADD
                    begin
                      regs[instr_mem[15:11]] = regs[instr_mem[25:21]] + regs[instr_mem[20:16]];
                      if(regs[instr_mem[15:11]] != str.tx.regs[str.tx.instr[15:11]]) 
                        begin
                          $error("Wrong R-TYPE Add ! mips: 0x%0h, scb: 0x%0h", str.tx.regs[str.tx.instr[15:11]], regs[str.tx.instr[15:11]]);
                        end
                    end
                  else if (str.tx.instr[5:0] == `SUB) //SUB
                    begin
                      regs[instr_mem[15:11]] = regs[instr_mem[25:21]] - regs[instr_mem[20:16]];
                      if(regs[instr_mem[15:11]] != str.tx.regs[str.tx.instr[15:11]]) 
                        begin
                          $error("Wrong R-TYPE Sub ! mips: 0x%0h, scb: 0x%0h", str.tx.regs[str.tx.instr[15:11]], regs[str.tx.instr[15:11]]);
                        end
                    end
                  else if (str.tx.instr[5:0] == `AND) //AND
                    begin
                      regs[instr_mem[15:11]] = regs[instr_mem[25:21]] & regs[instr_mem[20:16]];
                      if(regs[instr_mem[15:11]] != str.tx.regs[str.tx.instr[15:11]]) 
                        begin
                          $error("Wrong R-TYPE And ! mips: 0x%0h, scb: 0x%0h", str.tx.regs[str.tx.instr[15:11]], regs[str.tx.instr[15:11]]);
                        end
                    end
                  else if (str.tx.instr[5:0] == `OR) //OR
                    begin
                      regs[instr_mem[15:11]] = regs[instr_mem[25:21]] | regs[instr_mem[20:16]];
                      if(regs[instr_mem[15:11]] != str.tx.regs[str.tx.instr[15:11]]) 
                        begin
                          $error("Wrong R-TYPE Or ! mips: 0x%0h, scb: 0x%0h", str.tx.regs[str.tx.instr[15:11]], regs[str.tx.instr[15:11]]);
                        end
                    end
                  else if (str.tx.instr[5:0] == `SLT) //SLT
                    begin
                      regs[instr_mem[15:11]] = regs[instr_mem[25:21]] < regs[instr_mem[20:16]] ? 1 : 0;
                      if(regs[instr_mem[15:11]] != str.tx.regs[str.tx.instr[15:11]]) 
                        begin
                          $error("Wrong R-TYPE Slt ! mips: 0x%0h, scb: 0x%0h", str.tx.regs[str.tx.instr[15:11]], regs[str.tx.instr[15:11]]);
                        end
                    end
                end
              end
            else if ((instr_mem[31:26] == `ADDI_Opcode) && ({str.tx.regDst,str.tx.jump,str.tx.branch,str.tx.memRead,str.tx.memToReg,str.tx.memWrite,str.tx.ALUSrc,str.tx.regWrite,str.tx.ALUOp} != {1'b0 ,1'b0,1'b0  ,1'b0   ,1'b0    ,1'b0    ,1'b1  ,1'b1    ,2'b00})) //ADDI
              begin
                regs[instr_mem[20:16]] = regs[instr_mem[25:21]] + {{16{instr_mem[15]}},instr_mem[15:0]};
                if(regs[instr_mem[20:16]] != str.tx.regs[str.tx.instr[20:16]]) 
                  begin
                    $error("Wrong I-TYPE Addi ! mips: 0x%0h, scb: 0x%0h", str.tx.regs[str.tx.instr[20:16]], regs[instr_mem[20:16]]);
                  end
              end
            else if ((instr_mem[31:26] == `ANDI_Opcode) && ({str.tx.regDst,str.tx.jump,str.tx.branch,str.tx.memRead,str.tx.memToReg,str.tx.memWrite,str.tx.ALUSrc,str.tx.regWrite,str.tx.ALUOp} != {1'b0 ,1'b0,1'b1  ,1'b0   ,1'b0    ,1'b0    ,1'b0  ,1'b0    ,2'b01})) //ANDI
              begin
                //$display("here1 0x%0h 0x%0h", regs[instr_mem[25:21]], str.tx.regs[str.tx.instr[25:21]]);
                //$display ("here2 0x%0h 0x%0h", {{16{instr_mem[15]}},instr_mem[15:0]}, {{16{str.tx.instr[15]}},str.tx.instr[15:0]});
                //$display(regs);
                //$display(str.tx.regs);

                regs[instr_mem[20:16]] = regs[instr_mem[25:21]] & {{16{instr_mem[15]}},instr_mem[15:0]};
                if(regs[instr_mem[20:16]] != str.tx.regs[str.tx.instr[20:16]]) 
                  begin
                    $error("Wrong I-TYPE Andi ! mips: 0x%0h, scb: 0x%0h", str.tx.regs[str.tx.instr[20:16]], regs[instr_mem[20:16]]);
                  end
              end
            else if ((instr_mem[31:26] == `LW_Opcode) && ({str.tx.regDst,str.tx.jump,str.tx.branch,str.tx.memRead,str.tx.memToReg,str.tx.memWrite,str.tx.ALUSrc,str.tx.regWrite,str.tx.ALUOp} != {1'b0 ,1'b0,1'b0  ,1'b1   ,1'b1    ,1'b0    ,1'b1  ,1'b1    ,2'b00}))//LW
              begin
                regs[instr_mem[20:16]] = memOut[instr_mem[25:21] + {{16{instr_mem[15]}},instr_mem[15:0]}];
                if(regs[instr_mem[20:16]] != str.tx.regs[str.tx.instr[20:16]]) 
                  begin
                    $error("Wrong I-TYPE LW ! mips: 0x%0h, scb: 0x%0h", str.tx.regs[str.tx.instr[20:16]], regs[instr_mem[20:16]]);
                  end
              end
            else if ((instr_mem[31:26] == `SW_Opcode) && ({str.tx.regDst,str.tx.jump,str.tx.branch,str.tx.memRead,str.tx.memToReg,str.tx.memWrite,str.tx.ALUSrc,str.tx.regWrite,str.tx.ALUOp} != {1'b0 ,1'b0,1'b0  ,1'b0   ,1'b0    ,1'b1    ,1'b1  ,1'b0    ,2'b00})) //SW
              begin
                memOut[instr_mem[25:21] + {{16{instr_mem[15]}},instr_mem[15:0]}] = regs[instr_mem[20:16]];
                if(memOut[instr_mem[25:21] + {{16{instr_mem[15]}},instr_mem[15:0]}] != str.tx.memOut[str.tx.instr[25:21] + {{16{str.tx.instr[15]}},str.tx.instr[15:0]}]) 
                  begin
                    $error("Wrong I-TYPE SW ! mips: 0x%0h, scb: 0x%0h", str.tx.memOut[str.tx.instr[25:21] + {{16{str.tx.instr[15]}},str.tx.instr[15:0]}], memOut[instr_mem[25:21] + {{16{instr_mem[15]}},instr_mem[15:0]}]);
                  end
              end
            else if ((instr_mem[31:26] == `J_Opcode) && ({str.tx.regDst,str.tx.jump,str.tx.branch,str.tx.memRead,str.tx.memToReg,str.tx.memWrite,str.tx.ALUSrc,str.tx.regWrite,str.tx.ALUOp} != {1'b0 ,1'b1,1'b0  ,1'b0   ,1'b0    ,1'b0    ,1'b0  ,1'b0    ,2'b00})) //J
              begin
                if(str.tx.instr[25:0] > 26'h3FFFFFF)
                  begin
                    $error("Wrong J-TYPE J ! mips: 0x%0h, scb: 0x%0h, 0x%0h", str.tx.instr[25:21], instr_mem[25:21],str.tx.instr[15:0]);
                  end
              end
            else if ((instr_mem[31:26] == `BEQ_Opcode) && ({str.tx.regDst,str.tx.jump,str.tx.branch,str.tx.memRead,str.tx.memToReg,str.tx.memWrite,str.tx.ALUSrc,str.tx.regWrite,str.tx.ALUOp} != {1'b0 ,1'b0,1'b1  ,1'b0   ,1'b0    ,1'b0    ,1'b0  ,1'b0    ,2'b01}))//BEQ
              begin
                //$display("Here: 0x%0h , 0x%0h" , (str.tx.pc + str.tx.instr[15:0] * 4), (pc + instr_mem[15:0] * 4));
                if((((str.tx.pc + str.tx.instr[15:0] * 4) != (pc + instr_mem[15:0] * 4))) && (str.tx.instr[15:0] > 16'hFFFF))
                  begin
                    $error("Wrong I-TYPE BEQ ! mips: 0x%0h, scb: 0x%0h", (str.tx.pc + str.tx.instr[15:0] * 4), (pc + instr_mem[15:0] * 4));
                  end
              end
          end
        else
          begin
            $error("Wrong Start value ! Start: 0x%0h", str.tx.start);
          end

        //$display(str.mem);
      end
  endtask

endclass