`timescale 1 ns / 100 ps 
/*
mode_control =2'b00 this is the standard mode, the finally output is A[26:0]*B[17:0]
mode_control =2'b01 this time is small floating-point mode，by using one-hoting encoding scheme, 
					the input is {9'b0,sfp1,sfp0}and {9'b0,sfp3,sfp2},(sfp is ExMy, x<=4,y<=4)
					the finally output is {int2*int3,int0*int1}(intx is converted from sfpx)
mode_control =2'b10 this time is small fixed-point mode，the input is{a2,a1,a0}and {a3,w1,w0}，
					the finally result={w0a3+w1a2,w0a0+w1a1}

if mode_control=shifter,then sfp input format is a={9'b0,sfp1,sfp0} b={9'b0,sfp3,sfp2}
if mode_control=mode_8x8,then int8 input format is a={a3,a1,a0} b={a2,w1,w0}

mant_to_one_hot_point: one-hot point generation module, input is mantissa, output is one-hot, 
for example, if mantissa is 0000, then output is 17'h0
if mantissa is 0001, then output is 17'h1
...
if mantissa is 1111, then output is 17'h4000.
the reason why the output of the mant_to_one_hot_point module is 17-bit is that the complement multiplier is 18*8-bit, 
except the MSB, the other 17-bit is used to represent mantissa based on the one-hoting point.

complement_mult_18_8: 2's complement multiply module, which can implement 18*8-bit complement multiplication
*/  
module Multiplier_xilinx (

		input                     clk          ,
		input                     reset        ,
        input            [1:0]    mode_control ,
		input            [26:0]   a            ,
		input            [26:0]   b            ,
		output reg       [47:0]   result1      ,
        output reg       [47:0]   result2      
 	); 

//**********************define parameter**********************//
parameter  complement_mult   =2'b00;
parameter  shifter           =2'b01;
parameter  mode_8x8          =2'b10;
parameter  C_shifted_number  =48   ;
//**********************define reg***************************//
reg [26:0] a_reg            ;
reg [26:0] b_reg            ;
reg [ 1:0] mode_control_reg ;

//signal of the sub-multiplier
reg [ 3:0] S_mode_control_A ;
reg [ 3:0] S_mode_control_B ;

//complement mult input 
reg [6:0] A_0;
reg [6:0] A_1;
reg [6:0] A_2;
reg [6:0] A_3;

reg [16:0] B_0;
reg [16:0] B_1;
reg [16:0] B_2;
reg [16:0] B_3;
// mult out C_x after shift 
reg [C_shifted_number-1:0] C_0_shifted;
reg [C_shifted_number-1:0] C_1_shifted;
reg [C_shifted_number-1:0] C_2_shifted;
reg [C_shifted_number-1:0] C_3_shifted;
//sfp converter based on one-hoting encoding scheme
wire [16:0] shift_number_0;
wire [16:0] shift_number_1;
wire [16:0] shift_number_2;
wire [16:0] shift_number_3;
//**********************define wire**********************//
//mult output
wire [25:0] C_0;
wire [25:0] C_1;
wire [25:0] C_2;
wire [25:0] C_3;
  
always @ (posedge clk) begin
	if (reset) begin
		a_reg <= 0;
   	 	b_reg <= 0;
     	mode_control_reg<=0;	 
	end
	else begin 
		a_reg <= a;
   	 	b_reg <= b;
     	mode_control_reg<=mode_control;
	end
end
mant_to_one_hot_point #(
.   DATA_WIDTH     (17)    
)u_P0_mant_to_one_hot_point_9(
.               mant(a_reg[7:4])    ,
.      one_hot_point(shift_number_0)  
);
mant_to_one_hot_point #(
.   DATA_WIDTH     (17)    
)u_P1_mant_to_one_hot_point_9(
.               mant(a_reg[16:13])    ,
.      one_hot_point(shift_number_1)  
);
mant_to_one_hot_point #(
.   DATA_WIDTH     (17)    
)u_P2_mant_to_one_hot_point_9(
.               mant(b_reg[7:4])    ,
.      one_hot_point(shift_number_2)  
);
mant_to_one_hot_point #(
.   DATA_WIDTH     (17)    
)u_P4_mant_to_one_hot_point_9(
.               mant(b_reg[16:13])    ,
.      one_hot_point(shift_number_3)  
);
// to assign the input to sub multipliers 
always @(*) begin
	case (mode_control_reg)
		complement_mult: begin
            S_mode_control_A={{a_reg[26]},{1'b0},{1'b0},{1'b0}};
            S_mode_control_B={{b_reg[17]},{b_reg[17]},{b_reg[17]},{b_reg[17]}};
			A_0 = a_reg[6:0]  ;
			A_1 = a_reg[13:7] ;
			A_2 = a_reg[20:14]  ;
			A_3 = {a_reg[26],a_reg[26:21]} ;
			
			B_0 = b_reg[16:0];
			B_1 = b_reg[16:0];
			B_2 = b_reg[16:0];
			B_3 = b_reg[16:0];
		end
		shifter: begin
            S_mode_control_A=4'b0000;   
            S_mode_control_B=4'b0000;   
			A_0 = {{2'b0},{1'b1},a_reg[3:0] } ;
			A_1 = {{2'b0},{1'b1},a_reg[12:9]} ;
			A_2 = {{2'b0},{1'b1},b_reg[3:0] } ;
			A_3 = {{2'b0},{1'b1},b_reg[12:9]} ;
            
			B_0 = {shift_number_0};
			B_1 = {shift_number_1};
			B_2 = {shift_number_2};
			B_3 = {shift_number_3};
           
		end
        mode_8x8: begin
			S_mode_control_A={{a_reg[25]},{b_reg[25]},{a_reg[16]},{a_reg[7]}};
            S_mode_control_B={{b_reg[16]},{b_reg[7]},{b_reg[16]},{b_reg[7]}};
            A_0 = a_reg[6:0] ;
			A_1 = a_reg[15:9];
			A_2 = b_reg[24:18];
			A_3 = a_reg[24:18];

			B_0 = {{10{b_reg[7]}},b_reg[6:0]};
			B_1 = {{10{b_reg[16]}},b_reg[15:9]};
			B_2 = {{10{b_reg[7]}},b_reg[6:0]};
			B_3 = {{10{b_reg[16]}},b_reg[15:9]};  
		end
        default: begin
            S_mode_control_A={{1'b0},{1'b0},{1'b0},{1'b0}};
            S_mode_control_B={{1'b0},{1'b0},{1'b0},{1'b0}};
			A_0 = 9'b0;
			A_1 = 9'b0;
			A_2 = 9'b0;
			A_3 = 9'b0;

			B_0 = 9'b0 ;
			B_1 = 9'b0 ;
			B_2 = 9'b0;
			B_3 = 9'b0;
        end
	endcase
end    
//get partial mult product 

complement_mult_18_8 #(
.   DATA_WIDTH_A(7),
.   DATA_WIDTH_B(17)
) u_P0( .clk(clk),
	    .reset(reset),
		. A     (A_0),
		. B     (B_0),
		. A_sign(S_mode_control_A[0]),
		. B_sign(S_mode_control_B[0]),
		. C     (C_0)
	);
complement_mult_18_8 #(
.   DATA_WIDTH_A(7),
.   DATA_WIDTH_B(17)
) u_P1( .clk(clk),
	    .reset(reset),
		. A     (A_1),
		. B     (B_1),
		. A_sign(S_mode_control_A[1]),
		. B_sign(S_mode_control_B[1]),
		. C     (C_1)
	);
complement_mult_18_8 #(
.   DATA_WIDTH_A(7),
.   DATA_WIDTH_B(17)
) u_P2( .clk(clk),
	    .reset(reset),
		. A     (A_2),
		. B     (B_2),
		. A_sign(S_mode_control_A[2]),
		. B_sign(S_mode_control_B[2]),
		. C     (C_2)
	);
    complement_mult_18_8 #(
.   DATA_WIDTH_A(7),
.   DATA_WIDTH_B(17)
) u_P3( .clk(clk),
	    .reset(reset),
		. A     (A_3),
		. B     (B_3),
		. A_sign(S_mode_control_A[3]),
		. B_sign(S_mode_control_B[3]),
		. C     (C_3)
	);
    
always @(*) begin
	case (mode_control_reg)
		complement_mult: begin
			C_0_shifted = {{22{C_0[25]}}, C_0};
			C_1_shifted = {{15{C_1[25]}}, {C_1}, {7'b0}};
			C_2_shifted = {{8{C_2[25]}},{C_2},{14'b0}};
			C_3_shifted = {{C_3[25]},{C_3}, {21'b0}};
		end
		shifter: begin
			C_0_shifted = {{24'b0},{C_0[23:0]^{24{a_reg[8]}}}};
			C_1_shifted = {{24'b0},{C_1[23:0]^{24{a_reg[17]}}}};
			C_2_shifted = {{C_2[23:0]^{24{b_reg[8]}}},{24'b0}}; 
			C_3_shifted = {{C_3[23:0]^{24{b_reg[17]}}},{24'b0} }; 
		end
        mode_8x8: begin
			C_0_shifted = {{24'b0},{C_0[23:0]} };
			C_1_shifted = {{24'b0},{C_1[23:0]} };
			C_2_shifted = {{C_2[23:0]},{24'b0}};
			C_3_shifted = {{C_3[23:0]},{24'b0}};
		end
        default: begin
            C_0_shifted = {48'b0};
			C_1_shifted = {48'b0};
			C_2_shifted = {48'b0};
			C_3_shifted = {48'b0};
        end
	endcase
end    

//get output result1 and result2 to WXYZ multpliexer
reg [47:0]  result1_temp    ;
reg [47:0]  result2_temp    ;
always @ (*) begin
result1_temp [7:0]  =C_0_shifted[3:0]+C_1_shifted[3:0]+C_2_shifted[3:0]+C_3_shifted[3:0];
result1[7:0]=result1_temp[7:0];

result2_temp [3:0]  =4'b0;
result2_temp [11:4] =C_0_shifted[7:4]+C_1_shifted[7:4]+C_2_shifted[7:4]+C_3_shifted[7:4];
result2[11:0]=result2_temp[11:0];

result1_temp [15:8] =C_0_shifted[11:8]+C_1_shifted[11:8]+C_2_shifted[11:8]+C_3_shifted[11:8];
result1[15:8]=result1_temp[15:8];


result2_temp [19:12] =C_0_shifted[15:12]+C_1_shifted[15:12]+C_2_shifted[15:12]+C_3_shifted[15:12];
result2[19:12]=result2_temp[19:12];

result1_temp [23:16] =C_0_shifted[19:16]+C_1_shifted[19:16]+C_2_shifted[19:16]+C_3_shifted[19:16];
result1[23:16]=result1_temp[23:16];

result2_temp [27:20] =C_0_shifted[23:20]+C_1_shifted[23:20]+C_2_shifted[23:20]+C_3_shifted[23:20];
result2[23:20]=result2_temp[23:20];
result2[24]	=result2_temp[24]&(~(mode_control_reg[0]^mode_control_reg[1]));
result2[25]	=result2_temp[25]&(~(mode_control_reg[0]^mode_control_reg[1]));

result2[27:26]=result2_temp[27:26];

result1_temp [31:24] =C_0_shifted[27:24]+C_1_shifted[27:24]+C_2_shifted[27:24]+C_3_shifted[27:24];
result1[31:24]=result1_temp[31:24];

result2_temp [35:28] =C_0_shifted[31:28]+C_1_shifted[31:28]+C_2_shifted[31:28]+C_3_shifted[31:28];
result2[35:28]=result2_temp[35:28];
      
result1_temp [39:32] =C_0_shifted[35:32]+C_1_shifted[35:32]+C_2_shifted[35:32]+C_3_shifted[35:32];
result1[39:32]=result1_temp[39:32];

result2_temp [43:36] =C_0_shifted[39:36]+C_1_shifted[39:36]+C_2_shifted[39:36]+C_3_shifted[39:36];
result2[43:36]=result2_temp[43:36];

result1_temp [47:40] =C_0_shifted[43:40]+C_1_shifted[43:40]+C_2_shifted[43:40]+C_3_shifted[43:40];
result1[47:40]=result1_temp[47:40];

result2_temp [47:44] =C_0_shifted[47:44]+C_1_shifted[47:44]+C_2_shifted[47:44]+C_3_shifted[47:44];
result2[47:44]=result2_temp[47:44];
end     
endmodule