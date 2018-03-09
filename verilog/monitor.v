module monitor(inputdata,clk,ground,display);
	
	input [15:0] inputdata;
	input clk;
	reg[1:0] count;
	
	reg[25:0]  clk1;	
	
	
	output reg[3:0] ground;
	
	reg [3:0] ground_int;
	initial ground_int=4'b0011;
	output reg[6:0] display;
	
	always @(posedge clk)
	begin
	clk1<=clk1+1;
	end
	
	always @ (posedge clk1[15])
	begin
	
	if  (count == 2'b00)
		ground <=  4'b0001;
	if  (count == 2'b01)
		ground <=  4'b0010;	
	if  (count == 2'b10)
		ground <=  4'b0100;
	if  (count == 2'b11)
		ground <=  4'b1000;
		
	count <= count + 1;	
	end
	
	always @ (*)
	begin
	data[0] = inputdata[15:12];
	data[3] = inputdata[11:8];
	data[2] = inputdata[7:4];
	data[1] = inputdata[3:0];
	end		
	
	reg[7:0] data[3:0];
	always @ (*)
	case (data[count])
	   //format g-f-cc-a-b
		//			e-d-cc-c-DP
		4'b0000: display = 7'b1000000;
		4'b0001:	display = 7'b1110110;
		4'b0010:	display = 7'b0100001;
		4'b0011:	display = 7'b0100100;
		4'b0100:	display = 7'b0010110;
		4'b0101:	display = 7'b0001100;
		4'b0110:	display = 7'b0001000;
		4'b0111:	display = 7'b1100110;
		4'b1000:	display = 7'b0000000;
		4'b1001:	display = 7'b0000110;
		4'b1010:	display = 7'b0000010;
		4'b1011:	display = 7'b0011000;
		4'b1100:	display = 7'b1001001;
		4'b1101:	display = 7'b0110000;
		4'b1110:	display = 7'b0001001;
		4'b1111:	display = 7'b0001011;
		default: display = 7'b1111111;
	endcase

	
endmodule 