/*
MULTMODE_in[0]<=configuration_input;
MULTMODE_in[1]<=MULTMODE_in[0];
//MULTMODE_in=2'b00, this time the multiplier is normal 27*18
//MULTMODE_in=2'b01, this time the multiplier is convert floating-point to fixed-point
//MULTMODE_in=2'b10, this time the multiplier is MAC based on the INT8 format
*/
`timescale 1ns/100ps
module multiplier_stream_in(
input   clk,
output  [1:0]  MULTMODE_out,
input configuration_input,
input configuration_enable,
output configuration_output
); 
parameter input_freezed = 1'b1;
reg   [1:0]  MULTMODE_in                      ;
always@(posedge clk)begin
		if (configuration_enable)begin
            MULTMODE_in[0]<=configuration_input;
            MULTMODE_in[1]<=MULTMODE_in[0];
		end
        
	end
assign configuration_output = MULTMODE_in[1];
assign MULTMODE_out = MULTMODE_in;
endmodule