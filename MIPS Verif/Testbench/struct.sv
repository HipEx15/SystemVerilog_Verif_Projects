`include "transaction.sv"

typedef struct{
  rand transaction tx;
  reg [7:0] mem [0:1023];
} myStruct;