// Code your testbench here
// or browse Examples
`timescale 1ns/10ps

`define TRUE 1'b1
`define FALSE 1'b0


module test1();

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
    #600 $finish;
  end

  //fgi, fgo , IEN
  reg FGI;
  wire FGIW;
  reg FGO;
  wire FGOW;
  
  reg IEN;
  wire IENW;
  
  //16bit counter reg,wire
  reg [7:0] COUNT;
  wire[7:0] CIN;
  wire[7:0] COUT;
  
  //R register
  reg R;
  wire RW;
  
  //E register
  reg E;
  wire EOUT;
  reg clk,reset;
 
  //IR register
  reg[15:0] IR;
  wire[15:0] IROUTBUS;
  wire irLD;
  
  //BUS inbus is load, outbus is select 
  wire[15:0] MAINBUS;
  wire[15:0] MAINBUSO;
  reg [15:0] mainTemp;
  
  //MUX SELECT
  wire[2:0] SELECT;
  reg[3:0] Rselect;
  
  //PC register
  reg[15:0] PCR;
  wire[15:0] PCOUTBUS;
  wire pcINR;
  wire pcCLR;
  wire pcLD;
  
  //AR register
  reg[11:0] AR;
  wire[15:0] AROUTBUS;
  wire[15:0] ARINBUS;
  wire arINR;
  wire arCLR;
  wire arLD;
  
  //memory
  wire Read;
  wire Write;
  wire [15:0] MOUTBUS;
  wire [15:0] mem;
  
  //DR register
  reg [15:0] DR;
  wire[15:0] DROUTBUS;
  wire[15:0] DRINBUS;
  
  //AC register
  reg[15:0] AC;
  wire[15:0] ACOUTBUS;
  wire[15:0] ACINBUS;
  
  //TR register
  reg[15:0] TR;
  wire [15:0] TROUTBUS;
  wire trLD;
  
  //S
  reg S;
  wire SOUT;
  
  initial begin
    R = 1'b0;
    E = 1'b0;
    clk = 1'b0;
    IEN = 1'b0;
    IR = 16'b0;
  end
 
  assign CIN = 8'b0; //initial counter
  assign RW = R;
      
  always begin
    #10 clk = ~clk;
    DR =DROUTBUS;
    PCR = PCOUTBUS;
    AC = ACOUTBUS;
    E = EOUT;
    S = SOUT;
    IEN = IENW;
  end
      
  // assign 
  Controller ct(clk,DR,
                pcINR,pcCLR,pcLD,
                COUT,SELECT,R,RW,IR,
                arLD,arCLR,arINR,
               Read,Write
               ,irLD
               ,AC,E
               ,IENW,FGO,FGI
               ,FGIW,FGOW);
  //16bit counter
  Counter c(clk,IR[15],R,DR,IR[14:12],COUT);
  
  //registers
  Memory memory(clk,Read,Write,AR[11:0],MAINBUS[11:0],MOUTBUS);
  MUX m(AROUTBUS,
        PCOUTBUS,
        DROUTBUS,
        ACOUTBUS,
        IROUTBUS,
        TROUTBUS,
        MOUTBUS,
        MAINBUS,
        R,COUT,IR[15],IR[14:12],SELECT,IR[11:0]);
   
  Decode decode(clk,IR,R,COUT,
                MAINBUS,MAINBUSO,
                ACINBUS,ACOUTBUS,
                DRINBUS,DROUTBUS
               ,Write
               ,E,EOUT
               ,IENW); 
  //register
  PC pc(clk,pcLD,pcINR,pcCLR,COUT,SELECT,MAINBUS,PCOUTBUS);
  AR ar(clk,arLD,arCLR,arINR,COUT,SELECT,MAINBUS,AROUTBUS);
  IR ir(clk,irLD,COUT,SELECT,MOUTBUS,IROUTBUS);
  S s(clk,IR,R,COUT,SOUT);
  
  //load, clear, write 
  always @(pcLD or arLD or arINR or irLD or Write) begin #3;
    if(pcLD)
      PCR = MAINBUS[11:0];
    else if(arLD || Write) 
      AR = MAINBUS[11:0];
    else if(irLD)
      IR = MAINBUS;
  end
  
  integer i;
  initial begin
    for(i = 0 ; i < 1000 ; i= i+1) //memeory clear
      memory.mem[i] = 16'b0;
    
    $readmemb("test2.txt",memory.mem);
    
   //#190 for(i =0 ; i< 20 ; i = i+1)
     // $display("%b",memory.mem[i]);
  end
endmodule


