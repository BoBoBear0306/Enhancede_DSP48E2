`timescale 1 ns / 100 ps  
module Multiplier_xilinx_tb;

		reg                  clk                ;
        reg                  rst                ;
        reg         [1 :0]   mode_control       ;
		reg         [26:0]   a                  ;
		reg         [26:0]   b                  ;
        reg         [17:0]   b_initial          ;
		wire        [47:0]   result1            ;
        wire        [47:0]   result2            ;
        reg signed  [47:0]   real_result        ;
        reg signed  [47:0]   module_result      ; 
/**************************shift need variable************************************/
        reg         [23:0]  sfp_to_int0        ;
        reg         [23:0]  sfp_to_int1        ;
        reg         [23:0]  sfp_to_int2        ;
        reg         [23:0]  sfp_to_int3        ;
        reg         [23:0]  sfp_int_result0     ;
        reg         [23:0]  sfp_int_result1     ;
 /*************************** int * int ***************************************************/     
        reg         [17:0]   int_0             ;
        reg         [17:0]   int_1             ;
        reg         [17:0]   int_2             ;
        reg         [ 7:0]   int_3             ;
        reg         [ 7:0]   int_4             ;
        reg         [17:0]   int_5             ;
        
        reg         [23:0]   int_result_0        ;
        reg         [23:0]   int_result_1        ;
        reg         [23:0]   int_result_2        ;
        reg         [23:0]   int_result_3        ;
        reg         [23:0]   sum_int_0           ;
        reg         [23:0]   sum_int_1           ;
        
        
        
parameter test_max_counter = 5000;
integer counter                  ;
integer Error_counter            ;

initial  begin
clk = 0;
rst = 0;
forever #5 clk= ~clk;
end 

initial begin
    Error_counter = 0;
     //check mode:complement mult 27*18 
    for (counter = 0; counter < test_max_counter; counter = counter + 1) begin 
		@(posedge clk);
		a = $random;
		b = $random;
        b_initial=b[17:0] ;
		mode_control=2'b0;
        assign module_result = result1+result2;
		#1
        real_result = $signed(a) * $signed(b_initial);
        
		if (real_result != module_result) begin
			Error_counter = Error_counter + 1;
		end
	end
    //check mode: sfp to int 
   
    Error_counter = 0; 
    for (counter = 0; counter < test_max_counter; counter = counter + 1) begin 
		@(posedge clk);
		a = $random;
        a[26:18]=9'b0;
		b = $random;
		case (a[7:4 ])  
                4'd0 : sfp_to_int0={24'b0^({24{a[8]}})};
                4'd1 : sfp_to_int0={{{{19'b0},{1'b1},{a[3:0]}       }^({24{a[8]}})}};
                4'd2 : sfp_to_int0={{{{18'b0},{1'b1},{a[3:0]},{1'b0}}^({24{a[8]}})}};
                4'd3 : sfp_to_int0={{{{17'b0},{1'b1},{a[3:0]},{2'b0}}^({24{a[8]}})}};
                4'd4 : sfp_to_int0={{{{16'b0},{1'b1},{a[3:0]},{3'b0}}^({24{a[8]}})}};
                4'd5 : sfp_to_int0={{{{15'b0},{1'b1},{a[3:0]},{4'b0}}^({24{a[8]}})}};
                4'd6 : sfp_to_int0={{{{14'b0},{1'b1},{a[3:0]},{5'b0}}^({24{a[8]}})}};
                4'd7 : sfp_to_int0={{{{13'b0} ,{1'b1},{a[3:0]},{6'b0}}^({24{a[8]}})}};
                4'd8 : sfp_to_int0={{{{12'b0} ,{1'b1},{a[3:0]},{7'b0}}^({24{a[8]}})}};
                4'd9 : sfp_to_int0={{{{11'b0} ,{1'b1},{a[3:0]},{8'b0}}^({24{a[8]}})}};
                4'd10: sfp_to_int0={{{{10'b0} ,{1'b1},{a[3:0]},{9'b0}}^({24{a[8]}})}};
                4'd11: sfp_to_int0={{{{9'b0} ,{1'b1},{a[3:0]},{10'b0}}^({24{a[8]}})}};
                4'd12: sfp_to_int0={{{{8'b0} ,{1'b1},{a[3:0]},{11'b0}}^({24{a[8]}})}};
                4'd13: sfp_to_int0={{{{7'b0} ,{1'b1},{a[3:0]},{12'b0}}^({24{a[8]}})}};
                4'd14: sfp_to_int0={{{{6'b0} ,{1'b1},{a[3:0]},{13'b0}}^({24{a[8]}})}};
                4'd15: sfp_to_int0={{{{5'b0} ,{1'b1},{a[3:0]},{14'b0}}^({24{a[8]}})}};    
        endcase
        case (a[16 :13 ])  
                4'd0 : sfp_to_int1={24'b0^({24{a[17]}})};
                4'd1 : sfp_to_int1={{{{19'b0},{1'b1},{a[12:9]}       }^({24{a[17]}})}};
                4'd2 : sfp_to_int1={{{{18'b0},{1'b1},{a[12:9]},{1'b0}}^({24{a[17]}})}};
                4'd3 : sfp_to_int1={{{{17'b0},{1'b1},{a[12:9]},{2'b0}}^({24{a[17]}})}};
                4'd4 : sfp_to_int1={{{{16'b0},{1'b1},{a[12:9]},{3'b0}}^({24{a[17]}})}};
                4'd5 : sfp_to_int1={{{{15'b0},{1'b1},{a[12:9]},{4'b0}}^({24{a[17]}})}};
                4'd6 : sfp_to_int1={{{{14'b0},{1'b1},{a[12:9]},{5'b0}}^({24{a[17]}})}};
                4'd7 : sfp_to_int1={{{{13'b0} ,{1'b1},{a[12:9]},{6'b0}}^({24{a[17]}})}};
                4'd8 : sfp_to_int1={{{{12'b0} ,{1'b1},{a[12:9]},{7'b0}}^({24{a[17]}})}};
                4'd9 : sfp_to_int1={{{{11'b0} ,{1'b1},{a[12:9]},{8'b0}}^({24{a[17]}})}};
                4'd10: sfp_to_int1={{{{10'b0} ,{1'b1},{a[12:9]},{9'b0}}^({24{a[17]}})}};
                4'd11: sfp_to_int1={{{{9'b0} ,{1'b1},{a[12:9]},{10'b0}}^({24{a[17]}})}};
                4'd12: sfp_to_int1={{{{8'b0} ,{1'b1},{a[12:9]},{11'b0}}^({24{a[17]}})}};
                4'd13: sfp_to_int1={{{{7'b0} ,{1'b1},{a[12:9]},{12'b0}}^({24{a[17]}})}};
                4'd14: sfp_to_int1={{{{6'b0} ,{1'b1},{a[12:9]},{13'b0}}^({24{a[17]}})}};
                4'd15: sfp_to_int1={{{{5'b0} ,{1'b1},{a[12:9]},{14'b0}}^({24{a[17]}})}};   
            
        endcase
      
        case (b[7:4 ])  
                4'd0 : sfp_to_int2={24'b0^({24{b[8]}})};
                4'd1 : sfp_to_int2={{{{19'b0},{1'b1},{b[3:0]}       }^({24{b[8]}})}};
                4'd2 : sfp_to_int2={{{{18'b0},{1'b1},{b[3:0]},{1'b0}}^({24{b[8]}})}};
                4'd3 : sfp_to_int2={{{{17'b0},{1'b1},{b[3:0]},{2'b0}}^({24{b[8]}})}};
                4'd4 : sfp_to_int2={{{{16'b0},{1'b1},{b[3:0]},{3'b0}}^({24{b[8]}})}};
                4'd5 : sfp_to_int2={{{{15'b0},{1'b1},{b[3:0]},{4'b0}}^({24{b[8]}})}};
                4'd6 : sfp_to_int2={{{{14'b0},{1'b1},{b[3:0]},{5'b0}}^({24{b[8]}})}};
                4'd7 : sfp_to_int2={{{{13'b0},{1'b1},{b[3:0]},{6'b0}}^({24{b[8]}})}};
                4'd8 : sfp_to_int2={{{{12'b0},{1'b1},{b[3:0]},{7'b0}}^({24{b[8]}})}};
                4'd9 : sfp_to_int2={{{{11'b0},{1'b1},{b[3:0]},{8'b0}}^({24{b[8]}})}};
                4'd10: sfp_to_int2={{{{10'b0},{1'b1},{b[3:0]},{9'b0}}^({24{b[8]}})}};
                4'd11: sfp_to_int2={{{{9'b0} ,{1'b1},{b[3:0]},{10'b0}}^({24{b[8]}})}};
                4'd12: sfp_to_int2={{{{8'b0} ,{1'b1},{b[3:0]},{11'b0}}^({24{b[8]}})}};
                4'd13: sfp_to_int2={{{{7'b0} ,{1'b1},{b[3:0]},{12'b0}}^({24{b[8]}})}};
                4'd14: sfp_to_int2={{{{6'b0} ,{1'b1},{b[3:0]},{13'b0}}^({24{b[8]}})}};
                4'd15: sfp_to_int2={{{{5'b0} ,{1'b1},{b[3:0]},{14'b0}}^({24{b[8]}})}};    
            
        endcase
        case (b[16 :13])  
                4'd0 : sfp_to_int3={24'b0^({24{b[17]}})};
                4'd1 : sfp_to_int3={{{{19'b0},{1'b1},{b[12:9]}       }^({24{b[17]}})}};
                4'd2 : sfp_to_int3={{{{18'b0},{1'b1},{b[12:9]},{1'b0}}^({24{b[17]}})}};
                4'd3 : sfp_to_int3={{{{17'b0},{1'b1},{b[12:9]},{2'b0}}^({24{b[17]}})}};
                4'd4 : sfp_to_int3={{{{16'b0},{1'b1},{b[12:9]},{3'b0}}^({24{b[17]}})}};
                4'd5 : sfp_to_int3={{{{15'b0},{1'b1},{b[12:9]},{4'b0}}^({24{b[17]}})}};
                4'd6 : sfp_to_int3={{{{14'b0},{1'b1},{b[12:9]},{5'b0}}^({24{b[17]}})}};
                4'd7 : sfp_to_int3={{{{13'b0} ,{1'b1},{b[12:9]},{6'b0}}^({24{b[17]}})}};
                4'd8 : sfp_to_int3={{{{12'b0} ,{1'b1},{b[12:9]},{7'b0}}^({24{b[17]}})}};
                4'd9 : sfp_to_int3={{{{11'b0} ,{1'b1},{b[12:9]},{8'b0}}^({24{b[17]}})}};
                4'd10: sfp_to_int3={{{{10'b0} ,{1'b1},{b[12:9]},{9'b0}}^({24{b[17]}})}};
                4'd11: sfp_to_int3={{{{9'b0} ,{1'b1},{b[12:9]},{10'b0}}^({24{b[17]}})}};
                4'd12: sfp_to_int3={{{{8'b0} ,{1'b1},{b[12:9]},{11'b0}}^({24{b[17]}})}};
                4'd13: sfp_to_int3={{{{7'b0} ,{1'b1},{b[12:9]},{12'b0}}^({24{b[17]}})}};
                4'd14: sfp_to_int3={{{{6'b0} ,{1'b1},{b[12:9]},{13'b0}}^({24{b[17]}})}};
                4'd15: sfp_to_int3={{{{5'b0} ,{1'b1},{b[12:9]},{14'b0}}^({24{b[17]}})}};   
            
        endcase
        
        sfp_int_result0=sfp_to_int0+sfp_to_int1;
		sfp_int_result1=sfp_to_int2+sfp_to_int3;
		mode_control=2'b01;
        assign module_result ={result1[47:24]+result2[47:24],result1[23:0]+result2[23:0]};
        #1
        
		
		real_result ={sfp_int_result1,sfp_int_result0};
		if (real_result != module_result) begin
			Error_counter = Error_counter + 1;
		end
	end
    
    Error_counter = 0;
     //check mode:int * int 
    for (counter = 0; counter < test_max_counter; counter = counter + 1) begin 
		@(posedge clk);
		a = $random;
		b = $random;
		mode_control=2'b10;
        int_0=  {{10{a[7]}},a[7:0]}           ;
        int_1=  {{10{a[16]}},a[16:9]}           ;
        int_2=  {{10{a[25]}},a[25:18]}           ;
        
        int_3=  b[7:0]            ;
        int_4=  b[16:9]           ;
        int_5=  {{10{b[25]}},b[25:18]}          ;
      
        int_result_0 = $signed(int_3)* $signed(int_0)     ;
        int_result_1 = $signed(int_4)* $signed(int_1)      ;
        int_result_2 = $signed(int_3)* $signed(int_5)      ;
        int_result_3 = $signed(int_4)* $signed(int_2)      ;
        sum_int_0=int_result_0+int_result_1;
        sum_int_1=int_result_2+int_result_3;

        assign module_result= {result1[47:24]+result2[47:24],result1[23:0]+result2[23:0]};
		#1
		real_result = {sum_int_1,sum_int_0};
        
        
		if (real_result != module_result) begin
			Error_counter = Error_counter + 1;
		end
	end    
    @(posedge(clk));
	@(posedge(clk));
	$finish();
   
  
end

          
Multiplier_xilinx u0_Multiplier_xilinx_inst(

		.   clk          (clk          ),
        .   reset        (rst          ),
        .   mode_control (mode_control ),
		.   a            (a            ),
		.   b            (b            ),
		.   result1      (result1      ),
        .   result2      (result2      )
 	); 








        
endmodule