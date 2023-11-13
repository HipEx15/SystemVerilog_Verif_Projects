`include "monitor.sv"

//Added defines

`define R_OPCODE 6'h00
`define J_OPCODE 6'h2
`define ADDI_OPCODE 6'h8
`define ANDI_OPCODE 6'h10
`define LW_OPCODE 6'h23
`define SW_OPCODE 6'h2b
`define J_OPCODE 6'h2
`define BEQ_OPCODE 6'h4

`define ADD 6'b100000
`define SUB 6'b100010
`define AND 6'b100100
`define OR 6'b100101
`define SLT 6'b101010
`define XOR 6'h26


class scoreboard;

  mailbox mon_to_sb;
  reg [31:0] regMem[0:31], regMemOld[0:31];
  reg [7:0] dataMem [0:1023], dataMemOld[0:1023]; //Modified from 31 to 1023 (BOTH)
  reg [31:0] result,pc=0,instr,instrOld,pcOld,resultOld;
  reg [7:0] instrMem[0:1023]; ////Modified from 63 to 1023
  reg written=0;
  reg regDst,jump,branch,memRead,memWrite,aluSrc,regWrite,aluZero,memToReg;
  reg regDstOld,jumpOld,branchOld,memReadOld,memWriteOld,aluSrcOld,regWriteOld,aluZeroOld,memToRegOld;
  transactionV tr;

  function new(mailbox mb);
    mon_to_sb=mb;
    foreach(regMem[i])
      regMem[i]=0;
    foreach(dataMem[i])
      dataMem[i]=0;
  endfunction

  task run;
    forever
      begin
        mon_to_sb.get(tr);
        //checkStart_PC(tr, pc);

        //---------------------ADDED---------------------------

        if(tr.enable == 0)
          begin
            $error("%0t [SCOREBOARD] Wrong Start value ! Start: 0x%0h", $time ,tr.enable);
          end

        //----------------------------------------------------

        else if(tr.enable) //Redundant
          begin
            if(!written)
              begin
                written<=1;
                instrMem=tr.instrMem;
              end
            dataMemOld=tr.dataMem;
            regMemOld=tr.regMem;

            //pc = pc + 4;
            //---------------------ADDED---------------------------

            pc = pc + 4;
            if(tr.pc != pc) 
              begin
                $error("%0t [SCOREBOARD] Wrong PC value ! PC_mips: 0x%0h | PC_scb: 0x%0h", $time, tr.pc, pc);
              end
            instr={instrMem[pc+3],instrMem[pc+2],instrMem[pc+1],instrMem[pc]};


            //----------------------------------------------------

            if(instr[31:26]==`R_OPCODE)
              begin
                ExecuteRType(tr);
              end
            else if(instr[31:26]==`J_OPCODE)
              begin
                ExecuteJ(tr, instr);
              end
            else if (instr[31:26] inside {`ADDI_OPCODE, `ANDI_OPCODE, `LW_OPCODE, `SW_OPCODE, `BEQ_OPCODE})
              begin
                ExecuteIType(tr, pc, instr);
              end
            else
              begin
                defaultCase();
              end


            /*$display("-----------------------------------------------------------------------------------------------------------------------------------------------------------");
            $display("%0t [SCOREBOARD] Scoreboard: \t MOMENTUL ACTUAL", $time);
            CompareResult(tr.instrOut ,instr, tr.pc, pc, tr.result, result  ,tr.regDst ,regDst ,tr.jump ,jump ,tr.branch, branch ,tr.memRead ,memRead ,tr.memWrite ,memWrite ,tr.aluSrc ,aluSrc ,tr.regWrite ,regWrite ,tr.aluZero ,aluZero,tr.memToReg,memToReg,tr.dataMem,dataMem,tr.regMem,regMem);
            $display("-----------------------------------------------------------------------------------------------------------------------------------------------------------");*/


            /*if(written)
              begin
                $display("-----------------------------------------------------------------------------------------------------------------------------------------------------------");
                $display("%0t [SCOREBOARD] Scoreboard: \t MOMENTUL T-1", $time);
                CompareResult(instrOld ,instr, pcOld, pc, resultOld, result  ,regDstOld ,regDst ,jumpOld ,jump ,branchOld,branch ,memReadOld ,memRead ,memWriteOld ,memWrite ,aluSrcOld ,aluSrc ,regWriteOld ,regWrite ,aluZeroOld ,aluZero,memToRegOld,memToReg,dataMemOld,dataMem,regMemOld,regMem);
                $display("-----------------------------------------------------------------------------------------------------------------------------------------------------------\n\n");
              end*/


            pcOld=tr.pc;
            resultOld=tr.result;
            instrOld=tr.instrOut;
            regDstOld=tr.regDst;
            jumpOld=tr.jump;
            branchOld=tr.branch;
            memReadOld=tr.memRead;
            memWriteOld=tr.memWrite;
            aluSrcOld=tr.aluSrc;
            regWriteOld=tr.regWrite;
            aluZeroOld=tr.aluZero;
            memToRegOld=tr.memToReg;
          end
      end
  endtask


  //TO DO => REMOVE COMPARERESULT, ADD FOR EACH CASE


  /*function void CompareResult(reg [31:0] instr0,instr1,pc0,pc1,result0,result1,
                              reg regDst0,regDst1,jump0,jump1,branch0,branch1,memRead0,memRead1,memWrite0,memWrite1,aluSrc0,aluSrc1,regWrite0,regWrite1,aluZero0,aluZero1,memToReg0,memToReg1,
                              reg [7:0] dataMem0[0:1023], dataMem1[0:1023],
                              reg [31:0] regMem0[0:31], regMem1[0:31]
                             ); //Modified dataMem from 31 to 1023


    if(instr0!=instr1 || pc0!=pc1 || result0!=result1 || regDst0!=regDst1 || jump0!=jump1 || branch0!=branch1 || memRead0!=memRead1 || memWrite0!=memWrite1 || aluSrc0!=aluSrc1 || regWrite0!=regWrite1 || aluZero0!=aluZero1 || dataMem0 != dataMem1 || regMem0 != regMem1)
      begin
        $display("\tFAILED instruction: %h %h pc: %h %h result: %h %h\n",instr0,instr1,pc0,pc1,result0,result1,$time);
        $display("\tDataMem\n\t",dataMem0);
        $display("\t",dataMem1);
        $display("\tRegMem\n\t",regMem0);
        $display("\t",regMem1);
        $display("\t regDst0:%h regDst1:%h jump0:%h jump1:%h branch0:%h branch1:%h memRead0:%h memRead1:%h memWrite0:%h memWrite1:%h aluSrc0:%h aluSrc1:%h regWrite0:%h regWrite1:%h aluZero0:%h aluZero1:%h memToReg0:%h memToReg1:%h",regDst0,regDst1,jump0,jump1,branch0,branch1,memRead0,memRead1,memWrite0,memWrite1,aluSrc0,aluSrc1,regWrite0,regWrite1,aluZero0,aluZero1,memToReg0,memToReg1);
      end
    else
      $display("\tPASSED %h %h\n",instr0,instr1,$time);


  endfunction*/

  function void ExecuteRType(transactionV tx);

    reg [4:0] rt=instr[20:16],rs=instr[25:21],rd=instr[15:11];

    regWrite=1;
    regDst=1;
    aluSrc=0;
    branch=0;
    memWrite=0;
    memToReg=0;
    memRead=0;
    jump=0;

    $display("%0t [SCOREBOARD] Scoreboard: Executin R type instruction instr:%h",$time, instr);
    case(instr[5:0])

      `ADD: //add
        begin
          result=regMem[rs]+regMem[rt];
          regMem[rd]=result;

          $display("-----------------------------------------------------------------------------------------------------------------------------------------------------------");
          $display("%0t [SCOREBOARD] Scoreboard: ADD operation result:%h",$time, result);

          if(tx.regMem[tx.instrOut[15:11]] != result) 
            begin
              $error("Wrong R-TYPE Add ! mips: 0x%0h, scb: 0x%0h", tx.regMem[tx.instrOut[15:11]], result);
            end
          $display("-----------------------------------------------------------------------------------------------------------------------------------------------------------");

        end

      `AND: //and
        begin
          result=regMem[rs]&regMem[rt];
          regMem[rd]=result;

          $display("-----------------------------------------------------------------------------------------------------------------------------------------------------------");
          $display("%0t [SCOREBOARD] Scoreboard: AND operation result:%h",$time, result);

          if(tx.regMem[tx.instrOut[15:11]] != result) 
            begin
              $error("Wrong R-TYPE And ! mips: 0x%0h, scb: 0x%0h", tx.regMem[tx.instrOut[15:11]], result);
            end
          $display("-----------------------------------------------------------------------------------------------------------------------------------------------------------");
        end

      `OR: //or
        begin
          result=regMem[rs]|regMem[rt];
          regMem[rd]=result;

          $display("-----------------------------------------------------------------------------------------------------------------------------------------------------------");
          $display("%0t [SCOREBOARD] Scoreboard: OR operation result:%h",$time, result);

          if(tx.regMem[tx.instrOut[15:11]] != result) 
            begin
              $error("Wrong R-TYPE Or ! mips: 0x%0h, scb: 0x%0h", tx.regMem[tx.instrOut[15:11]], result);
            end
          $display("-----------------------------------------------------------------------------------------------------------------------------------------------------------");
        end

      `SUB: //sub
        begin
          result=regMem[rs]-regMem[rt];
          regMem[rd]=result;

          $display("-----------------------------------------------------------------------------------------------------------------------------------------------------------");
          $display("%0t [SCOREBOARD] Scoreboard: SUB operation result:%h",$time, result);

          if(tx.regMem[tx.instrOut[15:11]] != result) 
            begin
              $error("Wrong R-TYPE Sub ! mips: 0x%0h, scb: 0x%0h", tx.regMem[tx.instrOut[15:11]], result);
            end
          $display("-----------------------------------------------------------------------------------------------------------------------------------------------------------");
        end

      `XOR: //xor
        begin
          result=regMem[rs]^regMem[rt];
          regMem[rd]=result;

          $display("-----------------------------------------------------------------------------------------------------------------------------------------------------------");
          $display("%0t [SCOREBOARD] Scoreboard: XOR operation result:%h",$time, result);

          if(tx.regMem[tx.instrOut[15:11]] != result) 
            begin
              $error("Wrong R-TYPE Xor ! mips: 0x%0h, scb: 0x%0h", tx.regMem[tx.instrOut[15:11]], result);
            end
          $display("-----------------------------------------------------------------------------------------------------------------------------------------------------------");
        end

      `SLT: //slt
        begin
          result=regMem[rs]<regMem[rt];
          regMem[rd]=result;

          $display("-----------------------------------------------------------------------------------------------------------------------------------------------------------");
          $display("%0t [SCOREBOARD] Scoreboard: SLT operation result:%h",$time, result);

          if(tx.regMem[tx.instrOut[15:11]] != result) 
            begin
              $error("Wrong R-TYPE Slt ! mips: 0x%0h, scb: 0x%0h", tx.regMem[tx.instrOut[15:11]], result);
            end
          $display("-----------------------------------------------------------------------------------------------------------------------------------------------------------");
        end

    endcase
    aluZero=(result==0);

  endfunction

  function void ExecuteIType(transactionV tx, ref reg [31:0] pc, ref reg [31:0] instr);

    reg [4:0] rt=instr[20:16],rs=instr[25:21];
    reg [31:0] imm={{16{instr[15]}},instr[15:0]};

    $display("%0t [SCOREBOARD] Scoreboard: Executing I type instruction instr:%h %h",$time, instr,instr[31:26]);

    case(instr[31:26])

      `ADDI_OPCODE: //ADDI
        begin
          result=regMem[rs]+imm;

          $display("-----------------------------------------------------------------------------------------------------------------------------------------------------------");
          $display("%0t [SCOREBOARD] Scoreboard: ADDI operation result:%h",$time,result);
          regMem[rt]=result;

          if(tx.result != result) 
            begin
              $error("Wrong I-TYPE Addi ! mips: 0x%0h, scb: 0x%0h", tx.result, result);
            end

          $display("-----------------------------------------------------------------------------------------------------------------------------------------------------------");

          regWrite=1;
          regDst=0;
          aluSrc=1;
          branch=0;
          memWrite=0;
          memToReg=0;
          memRead=0;
          jump=0;
          aluZero=(result==0);

        end


      `BEQ_OPCODE: //BEQ
        begin
          result=regMem[rt]-regMem[rs];
          aluZero=(result==0) ? 1:0;
          if(aluZero)
            begin
              pc=pc+imm*4;
              $display("ZERO YES YES YES");
            end

          $display("-----------------------------------------------------------------------------------------------------------------------------------------------------------");
          $display("%0t [SCOREBOARD] Scoreboard: BEQ operation result:%h pc:%h",$time, result, pc);

          if(((tx.pc + tx.instrOut[15:0] * 4) != (pc + instr[15:0] * 4)))
            begin
              $error("Wrong I-TYPE BEQ ! mips: 0x%0h, scb: 0x%0h", (tx.pc + tx.instrOut[15:0] * 4), (pc + instr[15:0] * 4));
            end
          $display("-----------------------------------------------------------------------------------------------------------------------------------------------------------");

          regWrite=0;
          regDst=0;
          aluSrc=0;
          branch=1;
          jump=0;
          memWrite=0;
          memToReg=0;
          memRead=0;
        end

      `SW_OPCODE: //SW
        begin
          dataMem[regMem[rs]+imm]=regMem[rt];
          result=0;

          $display("-----------------------------------------------------------------------------------------------------------------------------------------------------------");
          $display("%0t [SCOREBOARD] Scoreboard: SW operation result:%h pc:%h",$time, result,pc);

          if(tx.dataMem[tx.instrOut[25:21] + {{16{tx.instrOut[15]}},tx.instrOut[15:0]}] != dataMem[regMem[rs]+imm])
            begin
              $error("Wrong I-TYPE SW ! mips: 0x%0h, scb: 0x%0h", tx.regMem[tx.instrOut[20:16]], result);
            end

          $display("-----------------------------------------------------------------------------------------------------------------------------------------------------------");
          regWrite=0;
          regDst=0;
          aluSrc=1;
          branch=0;
          jump=0;
          memWrite=1;
          memToReg=0;
          memRead=0;
        end

      `LW_OPCODE: //LW
        begin
          result=dataMem[regMem[rs]+imm];
          regMem[rt]=result;

          $display("-----------------------------------------------------------------------------------------------------------------------------------------------------------");
          $display("%0t [SCOREBOARD] Scoreboard: LW operation result:%h pc:%h", $time,result,pc);

          if(tx.regMem[tx.instrOut[20:16]] != result) 
            begin
              $error("Wrong I-TYPE LW ! mips: 0x%0h, scb: 0x%0h", tx.regMem[tx.instrOut[20:16]], result);
            end
          $display("-----------------------------------------------------------------------------------------------------------------------------------------------------------");

          regWrite=1;
          regDst=0;
          aluSrc=1;
          branch=0;
          jump=0;
          memWrite=0;
          memToReg=1;
          memRead=1;
        end

    endcase

  endfunction

  function void ExecuteJ(transactionV tx, ref reg [31:0] instr);

    $display("-----------------------------------------------------------------------------------------------------------------------------------------------------------");

    $display("%0t [SCOREBOARD] Scoreboard: JUMP operatio %h",$time, instr);

    if(tx.instrOut[25:0] > 26'h3FFFFFF)
      begin
        $error("Wrong J-TYPE J ! mips: 0x%0h, scb: 0x%0h", tx.instrOut[25:21], instr[25:21]);
      end

    $display("-----------------------------------------------------------------------------------------------------------------------------------------------------------");


    regWrite=0;
    regDst=0;
    aluSrc=0;
    branch=0;
    jump=1;
    memWrite=0;
    memToReg=0;
    memRead=0;
    aluZero=0;
    //pc={pc[31:28],instr[25:0],2'b0};
    pc = instr[25:0] << 2;
  endfunction

  //Added verification for Enable and PC + Default case

  /*function void checkStart_PC(transactionV tx, ref reg [31:0] pc);
    if(tx.enable == 0)
      begin
        $error("%0t [SCOREBOARD] Wrong Start value ! Start: 0x%0h", $time ,tx.enable);
      end
    else 
      begin
        pc = pc + 4;
        if(tx.jump)
          begin
            pc = tx.result[25:0] << 2;
          end
        else if(tx.pc != pc) 
          begin
            $error("%0t [SCOREBOARD] Wrong PC value ! PC_mips: 0x%0h | PC_scb: 0x%0h", $time, tx.pc, pc);
          end
      end
  endfunction*/

  function void defaultCase();
    $display("%0t [SCOREBOARD] Unknown instruction", $time);
    regWrite=0;
    regDst='bz;
    aluSrc='bz;
    branch=0;
    jump='bz;
    memWrite=0;
    memToReg=0;
    memRead=0;
    result = 0;
  endfunction

endclass