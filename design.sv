
`define READ 1'b0
`define WRITE 1'b1

`timescale 1ns/10ps


//R + opcode  + counter
`define RNT0 9'b000000000
`define RNT1 9'b000000001
`define RNT2 9'b000000010
`define RT0 9'b100000000
`define RT1 9'b100000001
`define RT2 9'b100000010
`define D0T4 12'b000000000100
`define D0T5 12'b000000000101
`define D1T4 12'b000100000100
`define D1T5 12'b000100000101
`define D2T4 12'b001000000100
`define D2T5 12'b001000000101
`define D3T4 12'b001100000100
`define D3T5 12'b001100000101
`define D4T4 12'b010000000100
`define D5T4 12'b010100000100
`define D5T5 12'b010100000101
`define D6T4 12'b011000000100
`define D6T5 12'b011000000101
`define D6T6 12'b011000000110
`define D7T3 12'b011100000011

//R + opcode + I + counter + IR[11:0]
`define pB11 25'b0111100000011100000000000
`define pB10 25'b0111100000011010000000000
`define pB9 25'b0111100000011001000000000
`define pB8 25'b0111100000011000100000000
`define pB7 25'b0111100000011000010000000
`define pB6 25'b0111100000011000001000000

`define rB11 25'b0111000000011100000000000
`define rB10 25'b0111000000011010000000000
`define rB9 25'b0111000000011001000000000
`define rB8 25'b0111000000011000100000000
`define rB7 25'b0111000000011000010000000
`define rB6 25'b0111000000011000001000000
`define rB5 25'b0111000000011000000100000
`define rB4 25'b0111000000011000000010000
`define rB3 25'b0111000000011000000001000
`define rB2 25'b0111000000011000000000100
`define rB1 25'b0111000000011000000000010
`define rB0 25'b0111000000011000000000000

//MUX result 
`define PCSELECT 3'b010
`define ARSELECT 3'b001
`define DRSELECT 3'b011
`define ACSELECT 3'b100
`define IRSELECT 3'b101
`define TRSELECT 3'b110
`define MEMSELECT 3'b111

//INR, CLR, LD 
`define TRUE 1'b1
`define FALSE 1'b0

`define D7 3'b111


//counter
module Counter(clk,I,R,DR,opcode,out);
  input clk;
  input I,R;
  input [15:0] DR;
  input wire [2:0] opcode;
  output[7:0] out;
  reg [25:0] compare;
  reg [7:0] temp; //time Register
  
  initial begin
    temp = 8'b0;
  end

  always @(posedge clk) begin #1
    if(compare ==`RT2 || compare == `D0T5 || compare ==`D1T5 || 
       compare == `D2T5 || compare == `D3T5 || compare == `D4T4 || 
       compare == `D5T5)
      temp = 8'b0;
    else if(compare == `D7T3) begin
      if(I)
        temp = 8'b0;
      else 
        temp = 8'b0;
      $monitor("%b",temp);
    end else if(compare == `D6T6) begin
      if(DR == 15'b0)
        temp = 8'b0;
    end else 
      temp = temp +1;//increment
  end
  
  always @(temp or R or opcode or I) begin 
    if(temp <= 2)
      compare = {R,temp};
    else
      compare = {R,opcode,temp};
  end
  assign out = temp;
endmodule

//MUX
module MUX(AROUTBUS,
           PCOUTBUS,
           DROUTBUS,
           ACOUTBUS,
           IROUTBUS,
           TROUTBUS,
           MOUTBUS,
           MAINBUS,
           R,count,I,opcode,SELECT,ir);
  
  input [15:0] AROUTBUS;
  input [15:0] PCOUTBUS;
  input [15:0] DROUTBUS;
  input [15:0] ACOUTBUS;
  input [15:0] IROUTBUS;
  input [15:0] TROUTBUS;
  input [15:0] MOUTBUS;
  reg [15:0] tempR;
  output [15:0] MAINBUS;
  
  input R;
  input [7:0] count;
  input I;
  input [11:0] ir;
  input wire[2:0] opcode;
  output wire[2:0] SELECT;
  reg [2:0] temp; //select number;
  reg [25:0] compare;
  
  initial begin
    temp = 3'b010;
  end
  
  always @(compare) begin
    if(compare == `RNT0 || compare == `RT0 || compare == `D5T4)
      temp = 3'b010;
    else if(compare == `D4T4 || compare == `D5T5)
      temp = 3'b001;
    else if(compare == `D2T5 || compare == `D6T6)
      temp = 3'b011;
    else if(compare == `D3T4 || compare == `pB10)
      temp = 3'b100;
    else if(compare == `RNT2)
      temp = 3'b101;
    else if(compare == `RT1)
      temp = 3'b110;
    else if(compare == `RNT1 || compare == `D0T4 || compare == `D1T4 || compare == `D1T4 || compare == `D2T4)
      temp = 3'b111;
    else if(opcode != `D7)
      if(I)
        temp = 3'b111;
  end
    
  always @(temp or compare or PCOUTBUS or ACOUTBUS or IROUTBUS or DROUTBUS or TROUTBUS or MOUTBUS or AROUTBUS) begin
      if(temp == `PCSELECT) begin
        tempR = PCOUTBUS;
      end else if(temp == `ACSELECT)
        tempR = ACOUTBUS;
      else if(temp == `IRSELECT)
        tempR = IROUTBUS;
      else if(temp == `DRSELECT)
        tempR = DROUTBUS;
      else if(temp == `TRSELECT)
        tempR = TROUTBUS;
      else if(temp == `MEMSELECT)
        tempR = MOUTBUS;
      else if(temp == `ARSELECT)
        tempR = AROUTBUS;
  end 
  
  //counter change then compare change
  always @(count or R or opcode or count) begin 
    if(count <= 2)
      compare = {R,count};
    else
      compare = {R,opcode,count};
  end
  
  assign MAINBUS = tempR;
  assign SELECT = temp; //wire <- reg

endmodule

//pc
module PC(clk,LD,INR,CLR,count,SELECT,inAddr,outAddr);
  input LD;
  input clk;
  input INR;
  input CLR;
  input [7:0] count;
  input [2:0] SELECT;
  input wire [15:0] inAddr;
  output [15:0] outAddr;
  reg [15:0] temp; //tempAddr;
  reg [11:0] pc;
  
  initial begin
    pc = 11'b0;
  end
  
  always @(INR or CLR or LD) begin 
    if(INR) begin
      pc = pc+1; //pc increment
    end else if(CLR) begin
      pc = 11'b0; //pc clear
    end else if(LD) begin
      pc = inAddr[11:0]; //pc load
    end
  end
  
  assign outAddr = pc;
endmodule

//IR
module IR(clk,irLD,count,SELECT,inAddr,outAddr);
  input clk;
  input irLD;
  reg irLd;
  input [7:0] count;
  input [2:0] SELECT;
  input [15:0] inAddr;
  output [15:0] outAddr;
  reg [15:0] IR;
  reg [15:0] temp;
  
  always @(irLD) begin #2
    if(irLD) begin
      IR = inAddr; //IR load
    end
  end
  
  assign outAddr = IR;
  
endmodule
    
//AR register
module AR(clk,arLD,arCLR,arINR,
          count,SELECT,
          inAddr,outAddr);
  input clk;
  input arLD;
  input arCLR;
  input arINR;
  input [2:0] SELECT;
  input [7:0] count;
  output [11:0] pcAddr;
  input [15:0] inAddr;
  output [15:0] outAddr;
  reg [15:0] AR;
  
  always @(arLD or arINR or arCLR) begin #2;
    if(arLD)
      AR = inAddr;
    else if(arINR)
      AR = AR +1;
    else if(arCLR)
      AR = 11'b0;
  end
  assign outAddr = AR;
endmodule

//memory
module Memory(clk,read,write,AR,inAddr,outAddr);
  input read;
  input clk;
  input write;
  input [11:0] inAddr;
  input [11:0] AR;
  output wire[15:0] outAddr;
  reg [15:0] temp;
  reg [15:0] mem[0:1000];

  always @(posedge clk) begin
    #4;
    if(read) begin
      temp = mem[AR];
    end
    if(write) begin
      mem[AR] = inAddr;
      temp = mem[AR];
    end
  end
  assign outAddr = temp;
endmodule

//Controller
//Increment, clear, load result of each register
module Controller(clk,DR,
                  pcINR,pcCLR,pcLD,
                  count,SELECT,R,RW,IR
                 ,arLD,arCLR,arINR,
                 Read,Write,
                 irLD
                 ,AC,E
                 ,IENW,FGO,FGI
                 ,FGIW,FGOW);

  input E;
  input clk;
  input IEN;
  input FGI;
  input FGO;
  input [15:0] AC;
  input [15:0] DR;
  input [15:0] IR;
  output wire pcCLR;
  reg pcCLr;
  output wire pcINR;
  reg pcINr;
  output wire pcLD;
  reg pcLd;
  
  reg [7:0]timeTemp;
  
  //input values
  input [7:0] count;
  input [2:0] SELECT;
  input R;
  reg [25:0] compare;
  
  always @(count or R) begin 
    if(count <=2)
      compare = {R,count};
    else if(IR[14:12] == `D7)
      compare = {R,IR[14:12],IR[15],count,IR[11:0]};
    else
      compare = {R,IR[14:12],count};
  end
  
  //PC LD,CLR, INR assign 
  always @(compare or count) begin 
    if(compare == `RT1)
      pcCLr = `TRUE;
    else if(compare == `RNT1 || compare == `RT2) begin
      pcINr = `TRUE;
    end else if(DR == 15'b0) begin
      if(compare == `D6T6)
        pcINr = `TRUE;
    end else if(compare == `rB3 || compare == `rB4) begin
      if(AC[15])
        pcINr = `TRUE;
      else 
        pcINr = `TRUE;
    end else if(AC == 15'b0) begin
      if(compare == `rB2)
        pcINr = `TRUE;
    end else if(!E) begin
      if(compare == `rB1)
        pcINr = `TRUE;
    end else if(compare == `pB9) begin
      if(FGI)
        pcINr = `TRUE;
    end else if(compare == `pB8) begin
      if(FGO)
        pcINr = `TRUE;
    end else if(compare == `D4T4 || compare == `D5T5) begin
      pcLd = `TRUE;
    end
  end
  
  //count compare before time then control increment,clera,load
  always @(count) begin 
    timeTemp <= count;
    if(timeTemp != count) begin
      pcINr = `FALSE;
      pcCLr = `FALSE;
      pcLd = `FALSE;
      arLd = `FALSE;
      arCLr = `FALSE;
      mr = `FALSE;
      mw = `FALSE;
      irLd =`FALSE;
      arINr = `FALSE;
    end
  end
  
  assign pcINR = pcINr;
  assign pcCLR = pcCLr;
  assign pcLD = pcLd;

  //AR register
  output arLD;
  reg arLd;
  output arCLR;
  reg arCLr;
  output arINR;
  reg arINr;
  
  always @(count or compare) begin
    if(compare == `RNT0 || compare == `RNT2)
      arLd = `TRUE;
    else if(IR[15]) begin
      if(count == 8'b00000011)
        arLd = `TRUE;
    end else if(compare == `RT0)
      arCLr = `TRUE;
    else if(compare ==`D5T4)
      arINr = `TRUE;
  end
  
  assign arLD = arLd;
  assign arCLR = arCLr;
  assign arINR = arINr;
  
  //memory read, write
  output Read;
  reg mr;
  output Write;
  reg mw;
  
  always @(count or compare) begin
    if(compare == `RNT1 || compare == `D0T4 || compare == `D1T4 
      || compare == `D2T4 || compare == `D2T4 || compare == `D6T4
      )
      mr = `TRUE;
    else if(IR[15]) begin
      if(count == 8'b00000011)
        mr = `TRUE;
    end else if(compare == `RT1 || compare == `D3T5 || compare == `D5T4 || compare == `D6T6)
      mw = `TRUE;
  end
  
  assign Read = mr;
  assign Write = mw;
  
  
  //IR load
  output irLD;
  reg irLd;
  
  always @(count or compare) begin #10;
    if(compare == `RNT1) begin
      irLd = `TRUE;
    end
  end
  
  assign irLD = irLd;
  
  //IEN
  output IENW;
  reg IENw;
  
  always @(count or compare) begin
    if(compare == `pB6)
      IENw = `FALSE;
    else if(compare == `pB7)
      IENw = `TRUE;
  end
  
  assign IENW = IENw;
  
  //R register
  output RW;
  reg Rw;
  
  always @(count or compare) begin
    if(compare == `RT2)
      Rw = `FALSE;
  end
  
  assign RW = Rw;
  
  //FGI, FGO
  
  output FGIW;
  reg FGIw;
  output FGOW;
  reg FGOw;
  
  always @(count or compare) begin
    if(compare == `pB11)
      FGIw = `FALSE;
    else if(compare == `pB10)
      FGOw = `FALSE;
  end
  
  assign FGIW =FGIw;
  assign FGOW = FGOw;
  
  
endmodule

//Decode
//role of ALU and AC,DR register
module Decode(clk,IR,R,count,
              MAINBUS,MAINBUSO,
              ACAddr, ACAddrO,
              DRAddr,DRAddrO
             ,Write
             ,E,EOUT
             ,IENW);
  
  input [15:0] IR;
  input R;
  input clk;
  input [7:0] count;
  input [15:0] MAINBUS;
  output [15:0] MAINBUSO;
  input [15:0] ACAddr;
  output [15:0] ACAddrO;
  wire [15:0] NAC;
  input [15:0] DRAddr;
  output [15:0] DRAddrO;
  
  reg IEN;
  output IENW;
  
  
  //And result
  wire [15:0] ANR;
  input Write;
  
  //E register;
  input E;
  output EOUT;
  wire WE;
  
  //Shitf
  wire [15:0] shitfR;
  wire [15:0] shitfL;
  //sum
  wire[11:0] sum;
  
  reg [2:0] opcode;
  reg [11:0] instr;
  reg I;
  reg [25:0] compare;
  reg [15:0] DRR;
  reg [15:0] ACR;
  reg e;
  initial begin
    ACR = 15'b0;
  end
  
  reg [11:0] temp;
  
  Complement com(ACR,E,NAC,WE);
  AND ad(DRR,ACR,ANR);
  ADD AD(DRR,ACR,sum,WE);
  ShiftR sr(ACR,E,WE,shitfR);
  ShiftL sl(ACR,E,WE,shitfL);
  
  always @(WE) begin
    e =WE;
  end
  
  always @(count or compare or R or I or opcode) begin  #5;
    I = IR[15];
    opcode = IR[14:12];
    //check opcode
    if(opcode != `D7) begin
      compare = {R,opcode,count};
    case(compare)
      //AND
      `D0T4:DRR = MAINBUS[11:0];
      `D0T5:ACR = ANR;
      //ADD
      `D1T4:DRR = MAINBUS[11:0];
      `D1T5: begin 
        ACR = sum; 
        e = WE;
      end
      //LDA
      `D2T4:DRR = MAINBUS[11:0];
      `D2T5:ACR = DRR;
      //STA
      `D3T4:DRR =ACR;
      `D3T5:temp = DRR;
      //BUN
      `D4T4:temp =MAINBUS[11:0];
      //ISZ
      `D6T4: DRR = MAINBUS[11:0]; 
      `D6T5: DRR = DRR+1;
      `D6T6: temp = DRR; 
    endcase
    end else begin
        compare = {R,opcode,IR[15],count,IR[11:0]};
      if(!I) begin //rB
        case(compare)
          `rB11:ACR = 15'b0;
          `rB10:e = `FALSE;
          `rB9: ACR = NAC;
          `rB8: e = WE;
          `rB7: ACR = shitfR;
          `rB6: ACR = shitfL;
          `rB5:ACR = ACR+1;
        endcase
      end else begin
        case(compare) //pB
          `pB6:IEN = `FALSE;
          `pB7:IEN = `TRUE; 
        endcase
      end
    end
  end
  
  assign IENW = IEN;
  assign MAINBUSO[11:0] = temp;
  assign DRAddrO = DRR;
  assign ACAddrO = ACR;
  assign EOUT = e;
endmodule

//Complement
module Complement(inAddr,inE,outAddr,outE);
  input [15:0] inAddr;
  input inE;
  output [15:0] outAddr;
  output outE;
  
  assign outE = ~inE;
  assign outAddr = ~inAddr;
endmodule


//Shift Left
module ShiftL(AC,E,outE,outAddr);
  input [15:0] AC;
  input E;
  wire [16:0] temp;
  wire tempE;
  output outE;
  output [15:0] outAddr;
 
  assign tempE = temp[16];
  assign outE = tempE;
  assign temp = AC << 1;
  assign outAddr = {temp[15:1],tempE};
  
endmodule

          
//Shitf Right
module ShiftR(AC,E,outE,outAddr);
  input [15:0] AC;
  input E;
  wire [16:0] temp;
  wire tempE;
  output outE;
  output [15:0] outAddr;

  assign tempE = AC[0];
  assign outE = tempE;
  assign temp = AC >> 1;
  assign outAddr = {tempE,temp[14:0]};
  
endmodule

//S register
module S(clk,IR,R,count,outS);
  input clk;
  input [15:0] IR;
  input [7:0] count;
  input R;
  output outS;
  reg [25:0] compare;
  reg s;
  
  always @(*) begin
    compare = {R,IR[14:12],IR[15],count,IR[11:0]};
    if(compare == `rB0)
      s = `FALSE;
  end
  
  assign outS = s;
endmodule

//Full Adder
module FA(cout,sum,cin,A,D);
  output cout;
  output sum;
  input cin;
  input A;
  input D;
  
  assign {cout,sum} = cin + A + D;
endmodule
  
//ADD
module ADD(DR,AC,outSum,outE);
  input [15:0] DR;
  input [15:0] AC;
  wire [12:0] sum;
  wire [12:0] cout;
  output [11:0] outSum;
  output outE;
  reg cin;
  
  initial begin
    cin = 1'b0;
  end
  
  FA a0(cout[0],sum[0],cin,DR[0],AC[0]);
  FA a1(cout[1],sum[1],cout[0],DR[1],AC[1]);
  FA a2(cout[2],sum[2],cout[1],DR[2],AC[2]);
  FA a3(cout[3],sum[3],cout[2],DR[3],AC[3]);
  FA a4(cout[4],sum[4],cout[3],DR[4],AC[4]);
  FA a5(cout[5],sum[5],cout[4],DR[5],AC[5]);
  FA a6(cout[6],sum[6],cout[5],DR[6],AC[6]);
  FA a7(cout[7],sum[7],cout[6],DR[7],AC[7]);
  FA a8(cout[8],sum[8],cout[7],DR[8],AC[8]);
  FA a9(cout[9],sum[9],cout[8],DR[9],AC[9]);
  FA a10(cout[10],sum[10],cout[9],DR[10],AC[10]);
  FA a11(cout[11],sum[11],cout[10],DR[11],AC[11]);
  
  
  assign outE = cout[11];
  assign outSum = sum[11:0];
 
endmodule

//AND 
module AND(DR,AC,outAddr);
  input [15:0] DR;
  input [15:0] AC;
  output [15:0] outAddr;
  
  and(outAddr[15],DR[15],AC[15]);
  and(outAddr[14],DR[14],AC[14]);
  and(outAddr[13],DR[13],AC[13]);
  and(outAddr[12],DR[12],AC[12]);
  and(outAddr[11],DR[11],AC[11]);
  and(outAddr[10],DR[10],AC[10]);
  and(outAddr[9],DR[9],AC[9]);
  and(outAddr[8],DR[8],AC[8]);
  and(outAddr[7],DR[7],AC[7]);
  and(outAddr[6],DR[6],AC[6]);
  and(outAddr[5],DR[5],AC[5]);
  and(outAddr[4],DR[4],AC[4]);
  and(outAddr[3],DR[3],AC[3]);
  and(outAddr[2],DR[2],AC[2]);
  and(outAddr[1],DR[1],AC[1]);
  and(outAddr[0],DR[0],AC[0]);
  
endmodule

