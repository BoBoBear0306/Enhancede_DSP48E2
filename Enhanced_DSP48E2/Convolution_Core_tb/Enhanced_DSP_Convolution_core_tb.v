`timescale 1 ns / 100 ps   
module Enhanced_DSP_Convolution_core_tb ();

/*******************************************************
*		Simulation Hyper parameters
*******************************************************/
parameter start_of_loading_configuration_bits = 2;
parameter reset_clock_period_counter = 2;
parameter simulation_start_clock_guard = 10;

parameter test_repeat_multiplier = 10000;
parameter test_repeat_mac = 10000;
parameter test_repeat_xor = 10000;
parameter test_repeat_pattern_detection = 10000;
parameter test_repeat_SIMD_ADDSUB = 10000;

integer Error_counter;
integer fscanf_output;
/*******************************************************
*		Clock generator 
*******************************************************/
	reg clk;
	initial begin
		clk = 0;
		forever #5 clk = ~clk;
	end
	
/*******************************************************
*		Loading Bit Stream file on configurable bits 
*******************************************************/
	
	parameter configurationbits_size = 207;
	// source of this lines: http://verilogcodes.blogspot.com/2017/11/file-reading-and-writingline-by-line-in.html
	// Great source http://www.angelfire.com/in/verilogfaq/pli.html
	// file identifier
    integer file_bitsream; 
	// string reader
	reg [100*8-1:0] string;

	integer i, j;
	
	reg [47:0] temp; 
	integer temp_size;
	reg [configurationbits_size-1:0] configurationbits_0;
	reg [configurationbits_size-1:0] configurationbits_1;
	// read bit stream file for Enhanced DSP48E2 core 0 and core 4
	initial begin
		file_bitsream=$fopen("enhanced_dsp_bitstream_0.txt","r"); 
		fscanf_output = $fscanf(file_bitsream,"%s\n",string); 
		fscanf_output = $fscanf(file_bitsream,"%s\n",string); 
		fscanf_output = $fscanf(file_bitsream,"%s\n",string); 
		fscanf_output = $fscanf(file_bitsream,"%s\n",string); 
		fscanf_output = $fscanf(file_bitsream,"%s\n",string); 	
		
		temp_size = 0;
		
		while (! $feof(file_bitsream)) begin

			fscanf_output = $fscanf(file_bitsream,"%s\n",string); 
			fscanf_output = $fscanf(file_bitsream,"%d\n",temp_size); 
			fscanf_output = $fscanf(file_bitsream,"%b\n",temp); 
	
			for (j = 0; j < temp_size; j = j + 1) begin
				configurationbits_0 = {configurationbits_0[configurationbits_size-2:0], temp[0]};
				temp = {1'b0,temp[47:1]};
			end
			temp_size = 0;
		end 
		
		$fclose(file_bitsream);
	end  
	// read bit stream file for Enhanced DSP48E2 core 1 core 2 and core 3  
    initial begin
		file_bitsream=$fopen("enhanced_dsp_bitstream_1.txt","r"); 
		fscanf_output = $fscanf(file_bitsream,"%s\n",string); 
		fscanf_output = $fscanf(file_bitsream,"%s\n",string); 
		fscanf_output = $fscanf(file_bitsream,"%s\n",string); 
		fscanf_output = $fscanf(file_bitsream,"%s\n",string); 
		fscanf_output = $fscanf(file_bitsream,"%s\n",string); 	
		
		temp_size = 0;
		
		while (! $feof(file_bitsream)) begin

			fscanf_output = $fscanf(file_bitsream,"%s\n",string); 
			fscanf_output = $fscanf(file_bitsream,"%d\n",temp_size); 
			fscanf_output = $fscanf(file_bitsream,"%b\n",temp); 
	
			for (j = 0; j < temp_size; j = j + 1) begin
				configurationbits_1 = {configurationbits_1[configurationbits_size-2:0], temp[0]};
				temp = {1'b0,temp[47:1]};
			end
			temp_size = 0;
		end 
		
		$fclose(file_bitsream);
	end    
	// streaming the configuration bits at 2th clock over 210 clock periods
	reg configuration_input_0;//enhanced_dsp_convolution_core_0 and core_4 configuration inupt
	reg configuration_input_1;//enhanced_dsp_convolution_core_1 core_2 and core_3 configuration inupt

	reg configuration_enable;
	initial begin
		configuration_input_0 = 1'b0;
		configuration_input_0 = 1'b0;
		configuration_enable = 1'b0;
		
		repeat (start_of_loading_configuration_bits) begin @(posedge(clk)); end

		configuration_enable = 1'b1;
		configuration_input_0 = configurationbits_0[0];
		configuration_input_1 = configurationbits_1[0];
		for (i = 0; i < configurationbits_size-1; i = i + 1) begin
			@(posedge clk)
			configurationbits_0 = {1'b0, configurationbits_0[configurationbits_size-1:1]};
			configuration_input_0 = configurationbits_0[0];
			configurationbits_1 = {1'b0, configurationbits_1[configurationbits_size-1:1]};
			configuration_input_1 = configurationbits_1[0];
		end
		
		@(posedge clk)
		configuration_enable = 1'b0;
	end
		
/*******************************************************
*		DSP inputs 
*******************************************************/
// core 0 inputs	
	reg signed [29:0] A_0;
	reg signed [17:0] B_0;
	reg signed [47:0] C_0;
	reg signed [26:0] D_0;
	
	reg [29:0] ACIN_0;
	reg [17:0] BCIN_0;
	reg [47:0] PCIN_0;
	reg CARRYCASCIN;
	
	reg [8:0] OPMODE_in_0;
	reg [3:0] ALUMODE_in;
	reg [2:0] CARRYINSEL_in;
	reg CARRYIN;
	reg [4:0] INMODE_in;
// core 1 inputs	
	reg signed [29:0] A_1;
	reg signed [17:0] B_1;
	reg signed [47:0] C_1;
	reg signed [26:0] D_1;
	
	reg [29:0] ACIN_1;
	reg [17:0] BCIN_1;
	reg [8:0] OPMODE_in_1;
// core 2 inputs	
	reg signed [29:0] A_2;
	reg signed [17:0] B_2;
	reg signed [26:0] D_2;
	reg signed [29:0] A_2_old;
	reg signed [17:0] B_2_old;
	reg signed [26:0] D_2_old;
	reg [8:0] OPMODE_in_2;

	reg [29:0] ACIN_2;
	reg [17:0] BCIN_2;
	
// core 3 inputs	
	reg signed [29:0] A_3;
	reg signed [17:0] B_3;
	reg signed [47:0] C_3;
	reg signed [26:0] D_3;
	
	reg [29:0] ACIN_3;
	reg [17:0] BCIN_3;
	reg [8:0] OPMODE_in_3;
// core 4 inputs	
	reg signed [29:0] A_4;
	reg signed [17:0] B_4;
	reg signed [47:0] C_4;
	reg signed [26:0] D_4;
	
	reg [29:0] ACIN_4;
	reg [17:0] BCIN_4;
	reg [47:0] PCIN_4;
	reg [8:0] OPMODE_in_4;
	
	

/*******************************************************
*		MAC reg 
*******************************************************/
		reg         [17:0]   a0             ;
		reg         [17:0]   a1             ;
		reg         [17:0]   a2             ;
		reg         [17:0]   a3             ;
		reg         [17:0]   a4             ;
		reg         [17:0]   a5             ;
		reg         [17:0]   a6             ;
		reg         [17:0]   a7             ;
		reg         [17:0]   a8             ;
		reg         [17:0]   b0             ;
		reg         [17:0]   b1             ;
		reg         [17:0]   b2             ;
		reg         [17:0]   b3             ;
		reg         [17:0]   b4             ;
		reg         [17:0]   b5             ;
		reg         [17:0]   b6             ;
		reg         [17:0]   b7             ;
		reg         [17:0]   b8             ;
		reg         [ 7:0]   w0             ;
		reg         [ 7:0]   w1             ;
		reg         [ 7:0]   w2             ;
		reg         [ 7:0]   w3             ;
		reg         [ 7:0]   w4             ;
		reg         [ 7:0]   w5             ;
		reg         [ 7:0]   w6             ;
		reg         [ 7:0]   w7             ;
		reg         [ 7:0]   w8             ;
        
		reg         [23:0]   int_result_0_0        ;
        reg         [23:0]   int_result_1_0        ;
        reg         [23:0]   int_result_2_0        ;
        reg         [23:0]   int_result_3_0        ;
        reg         [23:0]   int_result_4_0        ;
        reg         [23:0]   int_result_5_0        ;
        reg         [23:0]   int_result_6_0        ;
		reg         [23:0]   int_result_7_0        ;
		reg         [23:0]   int_result_8_0        ;
		reg         [23:0]   int_result_0_1        ;
        reg         [23:0]   int_result_1_1        ;
        reg         [23:0]   int_result_2_1        ;
        reg         [23:0]   int_result_3_1        ;
		reg         [23:0]   int_result_4_1        ;
        reg         [23:0]   int_result_5_1        ;
        reg         [23:0]   int_result_6_1        ;
		reg         [23:0]   int_result_7_1        ;
		reg         [23:0]   int_result_8_1        ;
        reg         [23:0]   sum_int_0           ;
        reg         [23:0]   sum_int_1           ;
		reg			[47:0]   real_result         ;
	initial begin
		Error_counter = 0;
		
		// initial values after initial reset and configuring 
		///////////////////////////////////////////////
		repeat (start_of_loading_configuration_bits + configurationbits_size + reset_clock_period_counter+simulation_start_clock_guard) begin @(posedge(clk)); end
		
		A_0 = 30'b11_1111_1111_1111_1111_1111_1111_1111;
		B_0 = 18'b00_0000_0000_0000_0000;
		C_0 = 48'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000;
		D_0 = 27'b000_0000_0000_0000_0000_0000_0000;
		
		ACIN_0 = 30'b00_0000_0000_0000_0000_0000_0000_0000;
		BCIN_0 = 18'b00_0000_0000_0000_0000;
		PCIN_0 = 48'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000;

		A_1 = 30'b11_1111_1111_1111_1111_1111_1111_1111;
		B_1 = 18'b00_0000_0000_0000_0000;
		C_1 = 48'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000;
		D_1 = 27'b000_0000_0000_0000_0000_0000_0000;
		
		ACIN_1 = 30'b00_0000_0000_0000_0000_0000_0000_0000;
		BCIN_1 = 18'b00_0000_0000_0000_0000;

		A_2_old = 30'b11_1111_1111_1111_1111_1111_1111_1111;
		B_2_old = 18'b00_0000_0000_0000_0000;
		D_2_old = 27'b000_0000_0000_0000_0000_0000_0000;
		A_2 = 30'b11_1111_1111_1111_1111_1111_1111_1111;
		B_2 = 18'b00_0000_0000_0000_0000;
		D_2 = 27'b000_0000_0000_0000_0000_0000_0000;
		ACIN_2 = 30'b00_0000_0000_0000_0000_0000_0000_0000;
		BCIN_2 = 18'b00_0000_0000_0000_0000;

		A_3 = 30'b11_1111_1111_1111_1111_1111_1111_1111;
		B_3 = 18'b00_0000_0000_0000_0000;
		C_3 = 48'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000;
		D_3 = 27'b000_0000_0000_0000_0000_0000_0000;

		ACIN_3 = 30'b00_0000_0000_0000_0000_0000_0000_0000;
		BCIN_3 = 18'b00_0000_0000_0000_0000;

		A_4 = 30'b11_1111_1111_1111_1111_1111_1111_1111;
		B_4 = 18'b00_0000_0000_0000_0000;
		C_4 = 48'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000;
		D_4 = 27'b000_0000_0000_0000_0000_0000_0000;

		ACIN_4 = 30'b00_0000_0000_0000_0000_0000_0000_0000;
		BCIN_4 = 18'b00_0000_0000_0000_0000;
		PCIN_4 = 48'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000;

		
		CARRYCASCIN = 0;
		
		//OPMODE_in = 9'b0_0010_0111;
		OPMODE_in_0 = 9'b0_0000_0101;
		OPMODE_in_1 = 9'b0_0000_0101;
		OPMODE_in_2 = 9'b0_0000_0101;
		OPMODE_in_3 = 9'b0_0000_0101;
		OPMODE_in_4 = 9'b0_0000_0101;
		ALUMODE_in = 4'b0000;
		CARRYINSEL_in = 3'b000;
		
		CARRYIN = 1'b0;
		INMODE_in = 5'b0_0000;
		
		// test signed multipliers
		///////////////////////////////////////////////
		$display("Testing Started: test signed MAC");	
		OPMODE_in_0 = 9'b0_0000_0101;
		OPMODE_in_1 = 9'b0_0001_0101;
		OPMODE_in_2 = 9'b1_1001_0101;
		OPMODE_in_3 = 9'b0_0001_0101;
		OPMODE_in_4 = 9'b0_0000_0101;
		ALUMODE_in = 4'b0000;
		CARRYINSEL_in = 3'b000;
		
		CARRYIN = 1'b0;
		INMODE_in = 5'b0_0000;
		
		repeat (test_repeat_multiplier) begin
			
			@(posedge(clk));
			A_0 = $random;
			B_0 = $random;
			D_0 = $random;
			A_1 = $random;
			B_1 = $random;
			D_1 = $random;
			A_2_old = $random;
			B_2_old = $random;
			D_2_old = $random;
			A_3 = $random;
			B_3 = $random;
			D_3 = $random;
			A_4 = $random;
			A_4[8:0]=0;
			B_4 = $random;
			B_4[8:0]=0;
			D_4 = $random;
			D_4[8:0]=0;
			@(posedge(clk));
			A_2 = A_2_old;
			B_2 = B_2_old;
			D_2 = D_2_old;
			

			a0=  {{10{A_0[7]}},A_0[7:0]}           ;
        	a1=  {{10{A_0[16]}},A_0[16:9]}           ;
        	b1=  {{10{A_0[25]}},A_0[25:18]}           ;
        	w0=  B_0[7:0]            ;
        	w1=  B_0[16:9]           ;
       		b0=  {{10{D_0[7]}},D_0[7:0]};

			a2=  {{10{A_1[7]}},A_1[7:0]}           ;
        	a3=  {{10{A_1[16]}},A_1[16:9]}           ;
        	b3=  {{10{A_1[25]}},A_1[25:18]}           ;
        	w2=  B_1[7:0]            ;
        	w3=  B_1[16:9]           ;
       		b2=  {{10{D_1[7]}},D_1[7:0]};

			a4=  {{10{A_2[7]}},A_2[7:0]}           ;
        	a5=  {{10{A_2[16]}},A_2[16:9]}           ;
        	b5=  {{10{A_2[25]}},A_2[25:18]}           ;
        	w4=  B_2[7:0]            ;
        	w5=  B_2[16:9]           ;
       		b4=  {{10{D_2[7]}},D_2[7:0]};

			a6=  {{10{A_3[7]}},A_3[7:0]}           ;
        	a7=  {{10{A_3[16]}},A_3[16:9]}           ;
        	b7=  {{10{A_3[25]}},A_3[25:18]}           ;
        	w6=  B_3[7:0]            ;
        	w7=  B_3[16:9]           ;
       		b6=  {{10{D_3[7]}},D_3[7:0]};

	
        	a8=  {{10{A_4[16]}},A_4[16:9]}           ;
        	b8=  {{10{A_4[25]}},A_4[25:18]}          ;
        	w8=  B_4[16:9]           ;
       		


			@(posedge(clk));
			@(posedge(clk));
			@(posedge(clk));
			@(posedge(clk));
			@(posedge(clk));
			@(posedge(clk));
			#1
			int_result_0_0= $signed(a0)* $signed(w0)      ;
			int_result_1_0= $signed(a1)* $signed(w1)      ;
			int_result_2_0= $signed(a2)* $signed(w2)      ;
			int_result_3_0= $signed(a3)* $signed(w3)      ;
			int_result_4_0= $signed(a4)* $signed(w4)      ;
			int_result_5_0= $signed(a5)* $signed(w5)      ;
			int_result_6_0= $signed(a6)* $signed(w6)      ;
			int_result_7_0= $signed(a7)* $signed(w7)      ;
			int_result_8_0= $signed(a8)* $signed(w8)      ;

			int_result_0_1= $signed(b0)* $signed(w0)      ;
			int_result_1_1= $signed(b1)* $signed(w1)      ;
			int_result_2_1= $signed(b2)* $signed(w2)      ;
			int_result_3_1= $signed(b3)* $signed(w3)      ;
			int_result_4_1= $signed(b4)* $signed(w4)      ;
			int_result_5_1= $signed(b5)* $signed(w5)      ;
			int_result_6_1= $signed(b6)* $signed(w6)      ;
			int_result_7_1= $signed(b7)* $signed(w7)      ;
			int_result_8_1= $signed(b8)* $signed(w8)      ;


        	sum_int_0=int_result_0_0+int_result_1_0+int_result_2_0+int_result_3_0+int_result_4_0+int_result_5_0+int_result_6_0+int_result_7_0+int_result_8_0;
        	sum_int_1=int_result_0_1+int_result_1_1+int_result_2_1+int_result_3_1+int_result_4_1+int_result_5_1+int_result_6_1+int_result_7_1+int_result_8_1;
			real_result={sum_int_1,sum_int_0};
			if  (real_result != Sum) begin
				//$display("Error: \tA = %d, B = %d, P = %d", A, B, P);
				Error_counter = Error_counter + 1;
			end else begin
				//$display("Correct: \tA = %d, B = %d, P = %d", A, B, P);
			end 
		end
		@(posedge(clk));
		@(posedge(clk));
		$finish();
	end
	
	
	
	reg CEB1_0;
	reg CEB2_0;		
	reg CEA1_0;
	reg CEA2_0;
	reg CEAD_0;
	reg CED_0;
	reg CEC_0;
	reg CEP_0;
	reg CEM_0;
	reg CECARRYIN_0;
	reg CEALUMODE_0;		
	reg CECTRL_0;
	reg CEINMODE_0;

	reg CEB1_1;
	reg CEB2_1;		
	reg CEA1_1;
	reg CEA2_1;
	reg CEAD_1;
	reg CED_1;
	reg CEC_1;
	reg CEP_1;
	reg CEM_1;
	reg CECARRYIN_1;
	reg CEALUMODE_1;		
	reg CECTRL_1;
	reg CEINMODE_1;
	
	initial begin
		CEB1_0 = 1'b0;
		CEB2_0 = 1'b1;		
		CEA1_0 = 1'b0;
		CEA2_0 = 1'b1;
		CEAD_0 = 1'b1;
		CED_0 = 1'b0;
		CEC_0 = 1'b0;
		CEP_0 = 1'b1;
		CEM_0 = 1'b1;
		CECARRYIN_0 = 1'b0;
		CEALUMODE_0 = 1'b0;		
		CECTRL_0 = 1'b0;
		CEINMODE_0 = 1'b0;

		CEB1_1 = 1'b1;
		CEB2_1 = 1'b1;		
		CEA1_1 = 1'b1;
		CEA2_1 = 1'b1;
		CEAD_1 = 1'b1;
		CED_1 = 1'b1;
		CEC_1 = 1'b0;
		CEP_1 = 1'b1;
		CEM_1 = 1'b1;
		CECARRYIN_1 = 1'b0;
		CEALUMODE_1 = 1'b0;		
		CECTRL_1 = 1'b0;
		CEINMODE_1 = 1'b0;
	end
	
	
	
	reg RSTCTRL;
	reg RSTALUMODE;
	reg RSTD;
	reg RSTC;
	reg RSTB;
	reg RSTA;
	reg RSTP;
	reg RSTM;	
	reg RSTALLCARRYIN;
	reg RSTINMODE;	
	
	// first 10 clock reset is active
	initial begin
		RSTCTRL = 1'b1;
		RSTALUMODE = 1'b1;
		RSTD = 1'b1;
		RSTC = 1'b1;
		RSTB = 1'b1;
		RSTA = 1'b1;
		RSTP = 1'b1;
		RSTM = 1'b1;	
		RSTALLCARRYIN = 1'b1;
		RSTINMODE = 1'b1;
		
		repeat (start_of_loading_configuration_bits + configurationbits_size + reset_clock_period_counter) begin @(posedge(clk)); end
		
		RSTCTRL = 1'b0;
		RSTALUMODE = 1'b0;
		RSTD = 1'b0;
		RSTC = 1'b0;
		RSTB = 1'b0;
		RSTA = 1'b0;
		RSTP = 1'b0;
		RSTM = 1'b0;	
		RSTALLCARRYIN = 1'b0;
		RSTINMODE = 1'b0;
	end

/*******************************************************
*		DSP outputs 
*******************************************************/
//core 0
	wire signed [29:0] ACOUT_0;
	wire signed [17:0] BCOUT_0;
	wire signed [47:0] PCOUT_0;
	
	wire signed [47:0] P_0;
	
	wire [3:0] CARRYOUT_0;
	wire CARRYCASCOUT_0;	
	wire MULTSIGNOUT_0;
	
	wire PATTERNDETECT_0;		
	wire PATTERNBDETECT_0;
	
	wire OVERFLOW_0;
	wire UNDERFLOW_0;		
	
	wire [7:0] XOROUT_0;
//core 1
	wire signed [29:0] ACOUT_1;
	wire signed [17:0] BCOUT_1;
	wire signed [47:0] PCOUT_1;
	
	wire signed [47:0] P_1;
	
	wire [3:0] CARRYOUT_1;
	wire CARRYCASCOUT_1;	
	wire MULTSIGNOUT_1;
	
	wire PATTERNDETECT_1;		
	wire PATTERNBDETECT_1;
	
	wire OVERFLOW_1;
	wire UNDERFLOW_1;		
	
	wire [7:0] XOROUT_1;
//core 2
	wire signed [29:0] ACOUT_2;
	wire signed [17:0] BCOUT_2;
	wire signed [47:0] PCOUT_2;
	
	wire signed [47:0] Sum;//P_2
	
	wire [3:0] CARRYOUT_2;
	wire CARRYCASCOUT_2;	
	wire MULTSIGNOUT_2;
	
	wire PATTERNDETECT_2;		
	wire PATTERNBDETECT_2;
	
	wire OVERFLOW_2;
	wire UNDERFLOW_2;		
	
	wire [7:0] XOROUT_2;
//core 3
	wire signed [29:0] ACOUT_3;
	wire signed [17:0] BCOUT_3;
	wire signed [47:0] PCOUT_3;
	
	wire signed [47:0] P_3;
	
	wire [3:0] CARRYOUT_3;
	wire CARRYCASCOUT_3;	
	wire MULTSIGNOUT_3;
	
	wire PATTERNDETECT_3;		
	wire PATTERNBDETECT_3;
	
	wire OVERFLOW_3;
	wire UNDERFLOW_3;		
	
	wire [7:0] XOROUT_3;
//core 4
	wire signed [29:0] ACOUT_4;
	wire signed [17:0] BCOUT_4;
	wire signed [47:0] PCOUT_4;
	
	wire signed [47:0] P_4;
	
	wire [3:0] CARRYOUT_4;
	wire CARRYCASCOUT_4;	
	wire MULTSIGNOUT_4;
	
	wire PATTERNDETECT_4;		
	wire PATTERNBDETECT_4;
	
	wire OVERFLOW_4;
	wire UNDERFLOW_4;		
	
	wire [7:0] XOROUT_4;
/*******************************************************
*		DSP instantiating  
*******************************************************/

	DSP DSP_inst_0(
		.clk(clk),		
		
		.A(A_0),
		.B(B_0),
		.C(C_0),
		.D(D_0),
		
		.OPMODE_in(OPMODE_in_0),
		.ALUMODE_in(ALUMODE_in),
		.CARRYINSEL_in(CARRYINSEL_in),	
		
		.CARRYIN(CARRYIN),
		.INMODE_in(INMODE_in),
		
		.CEB1(CEB1_0),
		.CEB2(CEB2_0),		
		.CEA1(CEA1_0),
		.CEA2(CEA2_0),
		.CEAD(CEAD_0),
		.CED(CED_0),
		.CEC(CEC_0),
		.CEP(CEP_0),
		.CEM(CEM_0),
		.CECARRYIN(CECARRYIN_0),
		.CEALUMODE(CEALUMODE_0),		
		.CECTRL(CECTRL_0),
		.CEINMODE(CEINMODE_0),	
		
		.RSTCTRL(RSTCTRL),
		.RSTALUMODE(RSTALUMODE),
		.RSTD(RSTD),
		.RSTC(RSTC),
		.RSTB(RSTB),
		.RSTA(RSTA),
		.RSTP(RSTP),
		.RSTM(RSTM),				
		.RSTALLCARRYIN(RSTALLCARRYIN),
		.RSTINMODE(RSTINMODE),	
			
		.ACIN(ACIN_0),
		.BCIN(BCIN_0),
		.PCIN(PCIN_0),
		.CARRYCASCIN(CARRYCASCIN),
		
		// Outputs
		.ACOUT(ACOUT_0),
		.BCOUT(BCOUT_0),
		.PCOUT(PCOUT_0),
		
		.P(P_0),	
		
		.CARRYOUT(CARRYOUT_0),			
		.CARRYCASCOUT(CARRYCASCOUT_0),	
		.MULTSIGNOUT(MULTSIGNOUT_0),
		
		.PATTERNDETECT(PATTERNDETECT_0),		
		.PATTERNBDETECT(PATTERNBDETECT_0),
		
		.OVERFLOW(OVERFLOW_0),			
		.UNDERFLOW(UNDERFLOW_0),		
		
		.XOROUT(XOROUT_0),		
		
		// End of Outputs
		.configuration_input(configuration_input_0),
		.configuration_enable(configuration_enable)
	); 
	DSP DSP_inst_1(
		.clk(clk),		
		
		.A(A_1),
		.B(B_1),
		.C(C_1),
		.D(D_1),
		
		.OPMODE_in(OPMODE_in_1),
		.ALUMODE_in(ALUMODE_in),
		.CARRYINSEL_in(CARRYINSEL_in),	
		
		.CARRYIN(CARRYIN),
		.INMODE_in(INMODE_in),
		
		.CEB1(CEB1_1),
		.CEB2(CEB2_1),		
		.CEA1(CEA1_1),
		.CEA2(CEA2_1),
		.CEAD(CEAD_1),
		.CED(CED_1),
		.CEC(CEC_1),
		.CEP(CEP_1),
		.CEM(CEM_1),
		.CECARRYIN(CECARRYIN_1),
		.CEALUMODE(CEALUMODE_1),		
		.CECTRL(CECTRL_1),
		.CEINMODE(CEINMODE_1),	
		
		.RSTCTRL(RSTCTRL),
		.RSTALUMODE(RSTALUMODE),
		.RSTD(RSTD),
		.RSTC(RSTC),
		.RSTB(RSTB),
		.RSTA(RSTA),
		.RSTP(RSTP),
		.RSTM(RSTM),				
		.RSTALLCARRYIN(RSTALLCARRYIN),
		.RSTINMODE(RSTINMODE),	
			
		.ACIN(ACIN_1),
		.BCIN(BCIN_1),
		.PCIN(PCOUT_0),
		.CARRYCASCIN(CARRYCASCIN),
		
		// Outputs
		.ACOUT(ACOUT_1),
		.BCOUT(BCOUT_1),
		.PCOUT(PCOUT_1),
		
		.P(P_1),	
		
		.CARRYOUT(CARRYOUT_1),			
		.CARRYCASCOUT(CARRYCASCOUT_1),	
		.MULTSIGNOUT(MULTSIGNOUT_1),
		
		.PATTERNDETECT(PATTERNDETECT_1),		
		.PATTERNBDETECT(PATTERNBDETECT_1),
		
		.OVERFLOW(OVERFLOW_1),			
		.UNDERFLOW(UNDERFLOW_1),		
		
		.XOROUT(XOROUT_1),		
		
		// End of Outputs
		.configuration_input(configuration_input_1),
		.configuration_enable(configuration_enable)
	);  
 
DSP DSP_inst_2(
		.clk(clk),		
		
		.A(A_2),
		.B(B_2),
		.C(P_1),
		.D(D_2),
		
		.OPMODE_in(OPMODE_in_2),
		.ALUMODE_in(ALUMODE_in),
		.CARRYINSEL_in(CARRYINSEL_in),	
		
		.CARRYIN(CARRYIN),
		.INMODE_in(INMODE_in),
		
		.CEB1(CEB1_1),
		.CEB2(CEB2_1),		
		.CEA1(CEA1_1),
		.CEA2(CEA2_1),
		.CEAD(CEAD_1),
		.CED(CED_1),
		.CEC(CEC_1),
		.CEP(CEP_1),
		.CEM(CEM_1),
		.CECARRYIN(CECARRYIN_1),
		.CEALUMODE(CEALUMODE_1),		
		.CECTRL(CECTRL_1),
		.CEINMODE(CEINMODE_1),	
		
		.RSTCTRL(RSTCTRL),
		.RSTALUMODE(RSTALUMODE),
		.RSTD(RSTD),
		.RSTC(RSTC),
		.RSTB(RSTB),
		.RSTA(RSTA),
		.RSTP(RSTP),
		.RSTM(RSTM),				
		.RSTALLCARRYIN(RSTALLCARRYIN),
		.RSTINMODE(RSTINMODE),	
			
		.ACIN(ACIN_2),
		.BCIN(BCIN_2),
		.PCIN(PCOUT_3),
		.CARRYCASCIN(CARRYCASCIN),
		
		// Outputs
		.ACOUT(ACOUT_2),
		.BCOUT(BCOUT_2),
		.PCOUT(PCOUT_2),
		
		.P(Sum),	
		
		.CARRYOUT(CARRYOUT_2),			
		.CARRYCASCOUT(CARRYCASCOUT_2),	
		.MULTSIGNOUT(MULTSIGNOUT_2),
		
		.PATTERNDETECT(PATTERNDETECT_2),		
		.PATTERNBDETECT(PATTERNBDETECT_2),
		
		.OVERFLOW(OVERFLOW_2),			
		.UNDERFLOW(UNDERFLOW_2),		
		
		.XOROUT(XOROUT_4),		
		
		// End of Outputs
		.configuration_input(configuration_input_1),
		.configuration_enable(configuration_enable)
	);  
DSP DSP_inst_3(
		.clk(clk),		
		
		.A(A_3),
		.B(B_3),
		.C(C_3),
		.D(D_3),
		
		.OPMODE_in(OPMODE_in_3),
		.ALUMODE_in(ALUMODE_in),
		.CARRYINSEL_in(CARRYINSEL_in),	
		
		.CARRYIN(CARRYIN),
		.INMODE_in(INMODE_in),
		
		.CEB1(CEB1_1),
		.CEB2(CEB2_1),		
		.CEA1(CEA1_1),
		.CEA2(CEA2_1),
		.CEAD(CEAD_1),
		.CED(CED_1),
		.CEC(CEC_1),
		.CEP(CEP_1),
		.CEM(CEM_1),
		.CECARRYIN(CECARRYIN_1),
		.CEALUMODE(CEALUMODE_1),		
		.CECTRL(CECTRL_1),
		.CEINMODE(CEINMODE_1),	
		
		.RSTCTRL(RSTCTRL),
		.RSTALUMODE(RSTALUMODE),
		.RSTD(RSTD),
		.RSTC(RSTC),
		.RSTB(RSTB),
		.RSTA(RSTA),
		.RSTP(RSTP),
		.RSTM(RSTM),				
		.RSTALLCARRYIN(RSTALLCARRYIN),
		.RSTINMODE(RSTINMODE),	
			
		.ACIN(ACIN_3),
		.BCIN(BCIN_3),
		.PCIN(PCOUT_4),
		.CARRYCASCIN(CARRYCASCIN),
		
		// Outputs
		.ACOUT(ACOUT_3),
		.BCOUT(BCOUT_3),
		.PCOUT(PCOUT_3),
		
		.P(P_3),	
		
		.CARRYOUT(CARRYOUT_3),			
		.CARRYCASCOUT(CARRYCASCOUT_3),	
		.MULTSIGNOUT(MULTSIGNOUT_3),
		
		.PATTERNDETECT(PATTERNDETECT_3),		
		.PATTERNBDETECT(PATTERNBDETECT_3),
		
		.OVERFLOW(OVERFLOW_3),			
		.UNDERFLOW(UNDERFLOW_3),		
		
		.XOROUT(XOROUT_1),		
		
		// End of Outputs
		.configuration_input(configuration_input_1),
		.configuration_enable(configuration_enable)
	);  
DSP DSP_inst_4(
		.clk(clk),		
		
		.A(A_4),
		.B(B_4),
		.C(C_4),
		.D(D_4),
		
		.OPMODE_in(OPMODE_in_4),
		.ALUMODE_in(ALUMODE_in),
		.CARRYINSEL_in(CARRYINSEL_in),	
		
		.CARRYIN(CARRYIN),
		.INMODE_in(INMODE_in),
		
		.CEB1(CEB1_0),
		.CEB2(CEB2_0),		
		.CEA1(CEA1_0),
		.CEA2(CEA2_0),
		.CEAD(CEAD_0),
		.CED(CED_0),
		.CEC(CEC_0),
		.CEP(CEP_0),
		.CEM(CEM_0),
		.CECARRYIN(CECARRYIN_0),
		.CEALUMODE(CEALUMODE_0),		
		.CECTRL(CECTRL_0),
		.CEINMODE(CEINMODE_0),	
		
		.RSTCTRL(RSTCTRL),
		.RSTALUMODE(RSTALUMODE),
		.RSTD(RSTD),
		.RSTC(RSTC),
		.RSTB(RSTB),
		.RSTA(RSTA),
		.RSTP(RSTP),
		.RSTM(RSTM),				
		.RSTALLCARRYIN(RSTALLCARRYIN),
		.RSTINMODE(RSTINMODE),	
			
		.ACIN(ACIN_4),
		.BCIN(BCIN_4),
		.PCIN(PCIN_4),
		.CARRYCASCIN(CARRYCASCIN),
		
		// Outputs
		.ACOUT(ACOUT_4),
		.BCOUT(BCOUT_4),
		.PCOUT(PCOUT_4),
		
		.P(P_4),	
		
		.CARRYOUT(CARRYOUT_4),			
		.CARRYCASCOUT(CARRYCASCOUT_4),	
		.MULTSIGNOUT(MULTSIGNOUT_4),
		
		.PATTERNDETECT(PATTERNDETECT_4),		
		.PATTERNBDETECT(PATTERNBDETECT_4),
		
		.OVERFLOW(OVERFLOW_4),			
		.UNDERFLOW(UNDERFLOW_4),		
		
		.XOROUT(XOROUT_4),		
		
		// End of Outputs
		.configuration_input(configuration_input_0),
		.configuration_enable(configuration_enable)
	); 
	
endmodule
