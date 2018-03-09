module timer(clk,countsec,INT,clr);
  
  input clk;
  input wire clr;
  output reg[15:0] countsec;
  output reg INT;
  reg [25:0] slow_clk;
  
  always @ (posedge clk)
     if (slow_clk == 26'd50000000) begin
        countsec <= countsec + 8'b1;
        slow_clk <= 0;
		  INT=1'b1;
     end
     else begin
        slow_clk <= slow_clk + 1'b1;
     
	  
	   if (clr)
			INT = 1'b0;
		else
			INT = INT;
	  
     end
endmodule