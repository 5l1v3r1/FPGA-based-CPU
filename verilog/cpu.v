module cpu(clk,int,dataout,datain,address,outdata,outdata2,memwrt,intack);
  input clk;
  input wire[2:0] int;
  input  wire[15:0] datain;
  output wire[15:0] outdata;
  output wire[15:0] outdata2;
  output reg[15:0] dataout;
  output reg[11:0] address;
  output memwrt;
  output wire intack;

  reg[11:0] pc;
  reg[11:0] ir;
  reg[4:0] state;
  reg[15:0] registerbank[7:0];
  
  wire[15:0] result;
  wire zeroresult;
  /*
  always @ (*)
  begin
		outdata2 = registerbank[5];
		outdata = {state[3:0],pc};
  end
  */
  assign outdata2 =registerbank[5];
  assign outdata =registerbank[4];
  //ALU
  alu alu1(ir[11:9],ir[8:6], registerbank[ir[8:6]], registerbank[ir[5:3]], result);
  
  assign zeroresult = ~|result;
  
    localparam   FETCH=5'b00000,
            LDI=5'b00001,
            LD=5'b00010,
            ST=5'b00011,
            JZ=5'b00100,
            JMP=5'b00101,
            ALU=5'b00111,
            PUSH=5'b01000,    
            POP1=5'b01001,
            POP2=5'b01010,
            CALL=5'b01011,
            RET1=5'b01100,
            RET2=5'b01101,
            CLI=5'b01110,
            STI= 5'b01111,
            IRET=5'b10000,
            IRET2=5'b10001,
            IRET3=5'b10010,
            INT= 5'b10011,
            INT1= 5'b10100,
            INT2= 5'b10101;
      
  
  assign memwrt=(state==ST | state==PUSH | state==CALL | state==INT | state==INT1);
    
  always @ (*)
  case(state)
    FETCH:  address=pc;
    LDI:    address=pc;
    LD:    address=registerbank[ir[5:3]][11:0];
    ST:    address=registerbank[ir[5:3]][11:0];
	 PUSH:  address=registerbank[7];
	 POP2:  address=registerbank[7];
	 INT:	  address=registerbank[7];
	 INT1:  address=registerbank[7];
	 //INT2:  address=16'h0bbb+datain;
	 IRET2:  address=registerbank[7];
	 IRET3: address=registerbank[7];
    default:address=12'b101010101010;
  endcase
  
  wire [15:0] dataout_1, dataout_2, dataout_3;
  assign dataout_1 = registerbank[ir[8:6]];
  assign dataout_2 = registerbank[6];
  assign dataout_3 = {4'b000,pc};
  
  always @ (*)
  begin
		case(state)
			ST: dataout = dataout_1;
			INT: dataout = dataout_2;
			INT1: dataout = dataout_3;
			PUSH: dataout = dataout_1;
		endcase
	
  end
  
  
  //assign dataout = registerbank[ir[8:6]];
  assign intack = (state==INT2);
  
  always @(posedge clk)
  begin
    case(state)
      FETCH:begin
            pc<=pc+1;
            ir<=datain[11:0];
				if (datain[15:12]==4'b1101 )//0xd000
					state<=5'b1111;//sti
				else if (datain[15:12]==4'b1100 )//0xc000
					state<=5'b1110;//cli
				else if (datain[15:12]==4'b1110 )//0xe000
					state<=5'b10000;//iret
				else
					state<=datain[15:12];
					
          end
      LDI:  begin
            registerbank[ir[2:0]]<=datain;
            pc=pc+1;
				if (registerbank[6][1]==1'b1 & int[2]==1'b1)
					state<=INT;
				else
					state<=FETCH;
          end
      LD:  begin
            registerbank[ir[2:0]]<=datain;
            if (registerbank[6][1]==1'b1 & int[2]==1'b1)
					state<=INT;
				else
					state<=FETCH;
          end
      ST:  begin
            //state<=FETCH;
            if (registerbank[6][1]==1'b1 & int[2]==1'b1)
					state<=INT;
				else
					state<=FETCH;
          end
      JZ:  begin
            //state<=FETCH;  
            if(registerbank[6][0])
              pc<=pc+ir;
				if (registerbank[6][1]==1'b1 & int[2]==1'b1)
					state<=INT;
				else
					state<=FETCH;
          end
      JMP:  begin
            pc<=pc+ir;
            //state<=FETCH;
				if (registerbank[6][1]==1'b1 & int[2]==1'b1)
					state<=INT;
				else
					state<=FETCH;		
          end
      ALU:  begin
            //state<=FETCH;
            registerbank[ir[2:0]]<=result;
            registerbank[6][0]<=zeroresult;
				
				if (registerbank[6][1]==1'b1 & int[2]==1'b1)
					state<=INT;
				else
					state<=FETCH;
          end
      PUSH:  begin
            //state<=FETCH;
            registerbank[7]<=registerbank[7]-16'h1;
            //dataout<=registerbank[ir[8:6]];
				if (registerbank[6][1]==1'b1 & int[2]==1'b1)
					state<=INT;
				else
					state<=FETCH;
          end
      POP1:  begin
            state<=POP2;
            registerbank[7]<=registerbank[7]+16'h1;
          end
      POP2:  begin
            //state<=FETCH;
            registerbank[ir[2:0]]<=datain;
				if (registerbank[6][1]==1'b1 & int[2]==1'b1)
					state<=INT;
				else
					state<=FETCH;
          end
      CALL:  begin
            //state<=FETCH;
            registerbank[7]<=registerbank[7]-16'h1;
            pc<=pc+ir;
				
				if (registerbank[6][1]==1'b1 & int[2]==1'b1)
					state<=INT;
				else
					state<=FETCH;
					
          end
      RET1:  begin
            state<=RET2;
            registerbank[7]<=registerbank[7]+16'h1;    
          end
      RET2:  begin
            //state<=FETCH;
            pc<=datain;
				
				if (registerbank[6][1]==1'b1 & int[2]==1'b1)
					state<=INT;
				else
					state<=FETCH;
					
          end  
			 
		INT:	begin	
					//memmory[registerbank[7]]=registerbank[6];	DONE
					registerbank[7]<=registerbank[7]-16'h1;
					state<=INT1;	
					end
		INT1:	begin
					//memmory[registerbank[7]]<={4'b0000,pc};	DONE
					registerbank[7]<=registerbank[7]-16'h1;
					state<=INT2;
					registerbank[6]= {registerbank[6][15:2], 1'b0, registerbank[6][0]};
					end
		INT2:	begin
					state<=FETCH;
					//pc<=16'hbbb+int[1];
					pc<=datain;
				end	
		CLI:  begin
            state<=FETCH;
            registerbank[6]= {registerbank[6][15:2], 1'b0, registerbank[6][0]};
					end
		STI:  begin
            state<=FETCH;
            registerbank[6]= {registerbank[6][15:2], 1'b1, registerbank[6][0]};
					end
		IRET: begin
            registerbank[7] = registerbank[7] + 16'b1;
            state<=IRET2;
					end
		IRET2:begin
            //pc = memmory[registerbank[7][11:0]];
				pc<=datain;
            registerbank[7] = registerbank[7] + 16'b1;
            state<=IRET3;
				end
		IRET3:  begin
            //registerbank[6]=memmory[registerbank[7]];
				registerbank[6]=datain;
            state<=FETCH;
          end
      
    endcase
  end

endmodule