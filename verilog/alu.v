module alu(op1, op2, a, b, out);
	
	//inputs
	
	input [2:0] op1;
	input [2:0] op2;
	input [15:0] a;
	input [15:0] b;
	
	//outputs
	output reg[15:0] out;
	
	always @ (*)
	begin
		case (op1)
			3'b000:	out = a + b;
			3'b001:	out = a+16'b1+(~b);
			3'b010:	out = a & b;
			3'b011:	out = a | b;
			3'b100:	out = a ^ b;
			3'b111:	begin
							case (op2)
								3'b000:	out = (~b);
								3'b001:	out = b;
								3'b010:	out = b + 16'b1;
								3'b011:	out = b - 16'b1;
							default:	out = 16'b0;
							endcase
						end
			default: out = a;
			endcase
	end
	
endmodule