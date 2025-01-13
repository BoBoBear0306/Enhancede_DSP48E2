`timescale 1 ns / 100 ps  
module complement_mult_18_8 #(
parameter   DATA_WIDTH_A=7,
parameter   DATA_WIDTH_B=17

)(		input clk,
		input reset,
		input [DATA_WIDTH_A-1:0] A,
		input [DATA_WIDTH_B-1:0] B,
		input A_sign,
		input B_sign,
		output  [DATA_WIDTH_A+DATA_WIDTH_B+1:0] C
	);



// to support both signed and unsigned multiplication
// sign extension regarding extra sign identifier
wire A_extended_level0_0;
wire B_extended_level0_0;
assign A_extended_level0_0 = A_sign;
assign B_extended_level0_0 = B_sign;


reg signed [DATA_WIDTH_A+DATA_WIDTH_B+1:0] C_temp;
always @ (*) begin
	 C_temp = $signed({{A_extended_level0_0},{A}}) * $signed({{B_extended_level0_0},{B}});
end

assign C = C_temp;


endmodule
