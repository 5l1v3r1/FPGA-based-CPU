module board(button,display,clk,grounds,display2,grounds2,ps2d,ps2c,display3,grounds3);
	
	input clk;
	input button;
	
	input ps2d, ps2c;
	
	output wire[6:0] display;
	output wire[3:0] grounds;
	output wire[6:0] display2;
	output wire[3:0] grounds2;
	output wire[6:0] display3;
	output wire[3:0] grounds3;
	
	
	reg[15:0] memmory[511:0];
   initial $readmemh("RAM.hex",memmory);

	
	
	reg [47:0] klavye;
	
	
	wire [15:0] pc;
	wire [15:0] outdata2;
	wire [15:0] data_out;
	reg [15:0] data_in;
	wire [11:0] address;
	wire memwrt;
	wire [2:0]intsignal;
	wire ack;
	reg   counter;
	wire rx_done_tick;
	wire [7:0] dout;
	wire reset;
	wire INTT;
	wire timeclear;
	wire [15:0] countsec;
	wire intack;
	
	assign  timeclear= (address == 12'b000011111111);
	
	cpu cpu1(.clk(clk),.int(intsignal),.dataout(data_out),.datain(data_in), .address(address),.outdata(pc),.outdata2(outdata2),.memwrt(memwrt),.intack(intack));
		
	monitor mon1(pc,clk, grounds, display);
	
	monitor mon2( outdata2, clk, grounds2, display2);
	
	monitor mon3(klavye[31:16], clk, grounds3, display3);
	
	ps2_rx myps2(clk, 1'b0, ps2d, ps2c, rx_done_tick, dout);
	
	
	timer mytimer(clk, countsec,INTT,timeclear);
	
	
	
	
	always @ (*)
	begin
		if(intack)
		begin
			data_in =(INTT == 1'b1) ? 16'h0000 : ((counter == 1'b1) ? 16'h0001 :16'h111 );
			//data_in = 16'h0bbb+data_in;
			data_in = memmory[16'h0bbb+data_in];
		end
		else if (address == 12'b000011111110)
		begin
			data_in = klavye[31:16];
		end
		else if (address == 12'b000011111111)
			data_in = countsec;
			
		else
			data_in = memmory[address];
	end
   
	
	always @(posedge clk)
		begin
			
			if (memwrt)
				memmory[address]<=data_out;
			
		end
	
	
	reg [2:0] int_signal_real;
		
	always @ (address,counter)
	begin
		if(address == 12'b000011111110)
			int_signal_real = 3'b001;
		else if(int_signal_real != 3'b110)
			int_signal_real = {INTT| counter,counter,INTT};
	end
 
	assign intsignal= int_signal_real;
	always @(negedge rx_done_tick)
	begin
    counter=counter + 1'b1;
	 klavye = klavye << 8 ;
	 klavye = klavye+dout;
	 
	 
   end
	
endmodule