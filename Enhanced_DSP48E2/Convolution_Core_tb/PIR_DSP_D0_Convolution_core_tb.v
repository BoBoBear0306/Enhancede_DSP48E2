`timescale 1 ns / 100 ps   
module PIR_DSP_D0_Convoultion_Core_tb ();

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
	
	parameter configurationbits_size = 209;
	// source of this lines: http://verilogcodes.blogspot.com/2017/11/file-reading-and-writingline-by-line-in.html
	// Great source http://www.angelfire.com/in/verilogfaq/pli.html
	// file identifier
    integer file_bitsream; 
	// string reader
	reg [100*8-1:0] string;

	integer i, j;
	
	reg [47:0] temp; 
	integer temp_size;
	reg [configurationbits_size-1:0] configurationbits;
	// read bit stream file for Enhanced DSP48E2 core 0 and core 4
	initial begin
		file_bitsream=$fopen("PIR_DSP_D0_bitstream_0.txt","r"); 
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
				configurationbits = {configurationbits[configurationbits_size-2:0], temp[0]};
				temp = {1'b0,temp[47:1]};
			end
			temp_size = 0;
		end 
		
		$fclose(file_bitsream);
	end   
    
	// streaming the configuration bits at 2th clock over 210 clock periods
	reg configuration_input;//enhanced_dsp_convolution_core_0 and core_4 configuration inupt

	reg configuration_enable;
	initial begin
		configuration_input = 1'b0;
		configuration_enable = 1'b0;
		
		repeat (start_of_loading_configuration_bits) begin @(posedge(clk)); end

		configuration_enable = 1'b1;
		configuration_input = configurationbits[0];
		for (i = 0; i < configurationbits_size-1; i = i + 1) begin
			@(posedge clk)
			configurationbits = {1'b0, configurationbits[configurationbits_size-1:1]};
			configuration_input = configurationbits[0];
		end
		
		@(posedge clk)
		configuration_enable = 1'b0;
	end
		
		
/*******************************************************
*		DSP inputs 
*******************************************************/
	
	reg signed [29:0] A_0;
	reg signed [17:0] B_0;
	reg signed [47:0] C_0;
	reg signed [26:0] D_0;
	reg signed [29:0] A_1;
	reg signed [17:0] B_1;
	reg signed [47:0] C_1;
	reg signed [26:0] D_1;
	reg signed [29:0] A_1_old;
	reg signed [17:0] B_1_old;
	reg signed [47:0] C_1_old;
	reg signed [26:0] D_1_old;
	reg signed [29:0] A_2;
	reg signed [17:0] B_2;
	reg signed [47:0] C_2;
	reg signed [26:0] D_2;
	reg signed [29:0] A_2_old;
	reg signed [17:0] B_2_old;
	reg signed [47:0] C_2_old;
	reg signed [26:0] D_2_old;
	reg signed [29:0] A_2_old_1;
	reg signed [17:0] B_2_old_1;
	reg signed [47:0] C_2_old_1;
	reg signed [26:0] D_2_old_1;
	reg [3:0]MULTMODE_in;

	reg [29:0] ACIN_0;
	reg [17:0] BCIN_0;
	reg [47:0] PCIN_0;
	reg [29:0] ACIN_1;
	reg [17:0] BCIN_1;
	reg [29:0] ACIN_2;
	reg [17:0] BCIN_2;



	
	reg CARRYCASCIN;
	
	reg [8:0] OPMODE_in;
	reg [3:0] ALUMODE_in;
	reg [2:0] CARRYINSEL_in;
	
	reg CARRYIN;
	reg [4:0] INMODE_in;
	/******************************************************
	//MAC reg
	*****************************************************/
		reg         [10:0]   a0             ;
		reg         [10:0]   a1             ;
		reg         [10:0]   a2             ;
		reg         [10:0]   a3             ;
		reg         [10:0]   a4             ;
		reg         [10:0]   a5             ;
		reg         [10:0]   a6             ;
		reg         [10:0]   a7             ;
		reg         [10:0]   a8             ;
		reg         [10:0]   b0             ;
		reg         [10:0]   b1             ;
		reg         [10:0]   b2             ;
		reg         [10:0]   b3             ;
		reg         [10:0]   b4             ;
		reg         [10:0]   b5             ;
		reg         [10:0]   b6             ;
		reg         [10:0]   b7             ;
		reg         [10:0]   b8             ;
		reg         [10:0]   w00             ;
		reg         [10:0]   w10             ;
		reg         [10:0]   w20             ;
		reg         [10:0]   w30             ;
		reg         [10:0]   w40             ;
		reg         [10:0]   w50             ;
		reg         [10:0]   w60             ;
		reg         [10:0]   w70             ;
		reg         [10:0]   w80             ;

		reg         [10:0]   w01             ;
		reg         [10:0]   w11             ;
		reg         [10:0]   w21             ;
		reg         [10:0]   w31             ;
		reg         [10:0]   w41             ;
		reg         [10:0]   w51             ;
		reg         [10:0]   w61             ;
		reg         [10:0]   w71             ;
		reg         [10:0]   w81             ;
        
		reg         [17:0]   int_result_0_0        ;
        reg         [17:0]   int_result_1_0        ;
        reg         [17:0]   int_result_2_0        ;
        reg         [17:0]   int_result_3_0        ;
        reg         [17:0]   int_result_4_0        ;
        reg         [17:0]   int_result_5_0        ;
        reg         [17:0]   int_result_6_0        ;
		reg         [17:0]   int_result_7_0        ;
		reg         [17:0]   int_result_8_0        ;
		reg         [17:0]   int_result_0_1        ;
        reg         [17:0]   int_result_1_1        ;
        reg         [17:0]   int_result_2_1        ;
        reg         [17:0]   int_result_3_1        ;
		reg         [17:0]   int_result_4_1        ;
        reg         [17:0]   int_result_5_1        ;
        reg         [17:0]   int_result_6_1        ;
		reg         [17:0]   int_result_7_1        ;
		reg         [17:0]   int_result_8_1        ;
        reg         [17:0]   sum_int_0           ;
        reg         [17:0]   sum_int_1           ;
		reg			[47:0]   real_result         ;
		reg			[47:0]   module_result         ;

	initial begin
		Error_counter = 0;
		
		// initial values after initial reset and configuring 
		///////////////////////////////////////////////
		repeat (start_of_loading_configuration_bits + configurationbits_size + reset_clock_period_counter+simulation_start_clock_guard) begin @(posedge(clk)); end
		MULTMODE_in= 4'b0000;
		A_0 = 30'b11_1111_1111_1111_1111_1111_1111_1110;
		B_0 = 18'b00_0000_0000_0000_0100;
		C_0 = 48'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0010;
		D_0 = 27'b000_0000_0000_0000_0000_0000_0010;
		ACIN_0 = 30'b00_0000_0000_0000_0000_0000_0000_0000;
		BCIN_0 = 18'b00_0000_0000_0000_0000;
		PCIN_0 = 48'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000;
		A_1 = 30'b00_0000_0000_0000_0000_0000_0000_0000;
		B_1 = 18'b00_0000_0000_0000_0000;
		C_1 = 48'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000;
		D_1 = 27'b000_0000_0000_0000_0000_0000_0000;
		A_1_old = 30'b00_0000_0000_0000_0000_0000_0000_0000;
		B_1_old = 18'b00_0000_0000_0000_0000;
		C_1_old = 48'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000;
		D_1_old = 27'b000_0000_0000_0000_0000_0000_0000;
		ACIN_1 = 30'b00_0000_0000_0000_0000_0000_0000_0000;
		BCIN_1 = 18'b00_0000_0000_0000_0000;
		A_2 = 30'b00_0000_0000_0000_0000_0000_0000_0000;
		B_2 = 18'b00_0000_0000_0000_0000;
		C_2 = 48'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000;
		D_2 = 27'b000_0000_0000_0000_0000_0000_0000;
		A_2_old = 30'b00_0000_0000_0000_0000_0000_0000_0000;
		B_2_old = 18'b00_0000_0000_0000_0000;
		C_2_old = 48'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000;
		D_2_old = 27'b000_0000_0000_0000_0000_0000_0000;
		A_2_old_1 = 30'b00_0000_0000_0000_0000_0000_0000_0000;
		B_2_old_1 = 18'b00_0000_0000_0000_0000;
		C_2_old_1 = 48'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000;
		D_2_old_1 = 27'b000_0000_0000_0000_0000_0000_0000;
		ACIN_2 = 30'b00_0000_0000_0000_0000_0000_0000_0000;
		BCIN_2 = 18'b00_0000_0000_0000_0000;
		
		

		CARRYCASCIN = 0;
		
		//OPMODE_in = 9'b0_0010_0111;
		OPMODE_in = 9'b0_0001_0101;
		ALUMODE_in = 4'b0000;
		CARRYINSEL_in = 3'b000;
		
		CARRYIN = 1'b0;
		INMODE_in = 5'b0_0000;
		

		// test signed MAC
		///////////////////////////////////////////////
		$display("Testing Started: test signed MAC");				
		MULTMODE_in= 4'b0100;
		OPMODE_in = 9'b0_0001_0101;
		ALUMODE_in = 4'b0000;
		CARRYINSEL_in = 3'b000;
		INMODE_in = 5'b0_0000;
			
		repeat (test_repeat_mac) begin
			
			// source to learn random https://stackoverflow.com/questions/34011576/generating-random-numbers-in-verilog
			A_0=$random;
			B_0=$random;
			C_0=$random;
			D_0=$random;
			A_1_old=$random;
			B_1_old=$random;
			C_1_old=$random;
			D_1_old=$random;
			A_2_old_1=$random;
			B_2_old_1=$random;
			C_2_old_1=$random;
			D_2_old_1=$random;
			@(posedge(clk));
			A_1=A_1_old;
			B_1=B_1_old;
			C_1=C_1_old;
			D_1=D_1_old;
			A_2_old=A_2_old_1;
			B_2_old=B_2_old_1;
			C_2_old=C_2_old_1;
			D_2_old=D_2_old_1;
			@(posedge(clk));
			A_2=A_2_old;
			B_2=B_2_old;
			C_2=C_2_old;
			D_2=D_2_old;
			@(posedge(clk));
			@(posedge(clk));
			@(posedge(clk));
			@(posedge(clk));
			@(posedge(clk));
			#1
			a0={1'b0,A_0[8:0]};
			a1={1'b0,A_0[17:9]};
			a2={1'b0,A_0[26:18]};
			a3={1'b0,A_1[8:0]};
			a4={1'b0,A_1[17:9]};
			a5={1'b0,A_1[26:18]};
			a6={1'b0,A_2[8:0]};
			a7={1'b0,A_2[17:9]};
			a8={1'b0,A_2[26:18]};

			b0={1'b0,D_0[8:0]};
			b1={1'b0,D_0[17:9]};
			b2={1'b0,D_0[26:18]};
			b3={1'b0,D_1[8:0]};
			b4={1'b0,D_1[17:9]};
			b5={1'b0,D_1[26:18]};
			b6={1'b0,D_2[8:0]};
			b7={1'b0,D_2[17:9]};
			b8={1'b0,D_2[26:18]};

			w00={1'b0,B_0[8:0]};
			w10={1'b0,B_0[17:9]};
			w20={1'b0,C_0[8:0]};
			w30={1'b0,B_1[8:0]};
			w40={1'b0,B_1[17:9]};
			w50={1'b0,C_1[8:0]};
			w60={1'b0,B_2[8:0]};
			w70={1'b0,B_2[17:9]};
			w80={1'b0,C_2[8:0]};

			w01={1'b0,C_0[17:9]};
			w11={1'b0,C_0[26:18]};
			w21={1'b0,C_0[35:27]};
			w31={1'b0,C_1[17:9]};
			w41={1'b0,C_1[26:18]};
			w51={1'b0,C_1[35:27]};
			w61={1'b0,C_2[17:9]};
			w71={1'b0,C_2[26:18]};
			w81={1'b0,C_2[35:27]};

			int_result_0_0=$signed(a0)* $signed(w00)      ;
			int_result_1_0=$signed(a1)* $signed(w10)      ;
			int_result_2_0=$signed(a2)* $signed(w20)      ;
			int_result_3_0=$signed(a3)* $signed(w30)      ;
			int_result_4_0=$signed(a4)* $signed(w40)      ;
			int_result_5_0=$signed(a5)* $signed(w50)      ;
			int_result_6_0=$signed(a6)* $signed(w60)      ;
			int_result_7_0=$signed(a7)* $signed(w70)      ;
			int_result_8_0=$signed(a8)* $signed(w80)      ;
			int_result_0_1=$signed(b0)* $signed(w01)      ;
			int_result_1_1=$signed(b1)* $signed(w11)      ;
			int_result_2_1=$signed(b2)* $signed(w21)      ;
			int_result_3_1=$signed(b3)* $signed(w31)      ;
			int_result_4_1=$signed(b4)* $signed(w41)      ;
			int_result_5_1=$signed(b5)* $signed(w51)      ;
			int_result_6_1=$signed(b6)* $signed(w61)      ;
			int_result_7_1=$signed(b7)* $signed(w71)      ;
			int_result_8_1=$signed(b8)* $signed(w81)      ;
			sum_int_0=int_result_0_0+int_result_1_0+int_result_2_0+int_result_3_0+int_result_4_0+int_result_5_0+int_result_6_0+int_result_7_0+int_result_8_0;
			sum_int_1=int_result_0_1+int_result_1_1+int_result_2_1+int_result_3_1+int_result_4_1+int_result_5_1+int_result_6_1+int_result_7_1+int_result_8_1;
			real_result={3'b0,sum_int_1,sum_int_0,9'b0};
			module_result={3'b0,P_2[44:9],9'b0};
			if  (real_result!=module_result ) begin
				Error_counter = Error_counter + 1;
			end else begin
				//$display("Correct: \tA = %d, B = %d, P_old= %d,  sum= %d, P = %d", A, B, P_old, ((A * B) + P_old), P);
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
	reg CEMULTMODE_0;

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
	reg CEMULTMODE_1;
	
	initial begin
		CEB1_0 = 1'b0;
		CEB2_0 = 1'b1;		
		CEA1_0 = 1'b0;
		CEA2_0 = 1'b1;
		CEAD_0 = 1'b0;
		CED_0 = 1'b1;
		CEC_0 = 1'b1;
		CEP_0 = 1'b1;
		CEM_0 = 1'b1;
		CECARRYIN_0 = 1'b0;
		CEALUMODE_0 = 1'b0;		
		CECTRL_0 = 1'b0;
		CEINMODE_0 = 1'b0;
		CEMULTMODE_0= 1'b0;

		CEB1_1 = 1'b0;
		CEB2_1 = 1'b0;		
		CEA1_1 = 1'b0;
		CEA2_1 = 1'b0;
		CEAD_1 = 1'b0;
		CED_1 = 1'b0;
		CEC_1 = 1'b0;
		CEP_1 = 1'b1;
		CEM_1 = 1'b0;
		CECARRYIN_1 = 1'b0;
		CEALUMODE_1 = 1'b0;		
		CECTRL_1 = 1'b0;
		CEINMODE_1 = 1'b0;
		CEMULTMODE_1= 1'b0;
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
	reg RSTMULTMODE;
	
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
		RSTMULTMODE= 1'b1;
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
		RSTMULTMODE= 1'b0;
	end

/*******************************************************
*		DSP outputs 
*******************************************************/

	wire signed [29:0] ACOUT_0;
	wire signed [17:0] BCOUT_0;
	wire signed [47:0] PCOUT_0;
	wire signed [29:0] ACOUT_1;
	wire signed [17:0] BCOUT_1;
	wire signed [47:0] PCOUT_1;
	wire signed [29:0] ACOUT_2;
	wire signed [17:0] BCOUT_2;
	wire signed [47:0] PCOUT_2;

	
	wire signed [47:0] P_0;
	wire signed [3:0] P_SIMD_carry_0;
	wire signed [47:0] P_1;
	wire signed [3:0] P_SIMD_carry_1;
	wire signed [47:0] P_2;
	wire signed [3:0] P_SIMD_carry_2;
	

	wire CARRYCASCOUT_0;	
	wire MULTSIGNOUT_0;
	wire CARRYCASCOUT_1;	
	wire MULTSIGNOUT_1;
	wire CARRYCASCOUT_2;	
	wire MULTSIGNOUT_2;
	
	
	wire PATTERNDETECT_0;		
	wire PATTERNBDETECT_0;
	wire PATTERNDETECT_1;		
	wire PATTERNBDETECT_1;
	wire PATTERNDETECT_2;		
	wire PATTERNBDETECT_2;
	
	wire OVERFLOW_0;
	wire UNDERFLOW_0;
	wire OVERFLOW_1;
	wire UNDERFLOW_1;
	wire OVERFLOW_2;
	wire UNDERFLOW_2;


	wire [7:0] XOROUT_0;
	wire [7:0] XOROUT_1;
	wire [7:0] XOROUT_2;
	

	
/*******************************************************
*		DSP instantiating  
*******************************************************/

	DSP_proposed_MF0  DSP_proposed_MF0_inst_core0(
		.clk(clk),		
		
		.A(A_0),
		.B(B_0),
		.C(C_0),
		.D(D_0),
		
		.OPMODE_in(OPMODE_in),
		.ALUMODE_in(ALUMODE_in),
		.CARRYINSEL_in(CARRYINSEL_in),	
		
		.CARRYIN(CARRYIN),
		.INMODE_in(INMODE_in),
		.MULTMODE_in(MULTMODE_in),

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
		.CEMULTMODE(CEMULTMODE_0),	
		
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
		.RSTMULTMODE(RSTMULTMODE),	

		.ACIN(ACIN_0),
		.BCIN(BCIN_0),
		.PCIN(PCIN_0),
		.CARRYCASCIN(CARRYCASCIN_0),
		
		// Outputs
		.ACOUT(ACOUT_0),
		.BCOUT(BCOUT_0),
		.PCOUT(PCOUT_0),
		
		.P(P_0),	
		.P_SIMD_carry(P_SIMD_carry_0),

					
		.CARRYCASCOUT(CARRYCASCOUT_0),	
		.MULTSIGNOUT(MULTSIGNOUT_0),
		
		.PATTERNDETECT(PATTERNDETECT_0),		
		.PATTERNBDETECT(PATTERNBDETECT_0),
		
		.OVERFLOW(OVERFLOW_0),			
		.UNDERFLOW(UNDERFLOW_0),		
		
		.XOROUT(XOROUT_0),		
		
		// End of Outputs
		.configuration_input(configuration_input),
		.configuration_enable(configuration_enable)
	);  

	DSP_proposed_MF0 DSP_proposed_MF0_inst_core1(
		.clk(clk),		
		
		.A(A_1),
		.B(B_1),
		.C(C_1),
		.D(D_1),
		
		.OPMODE_in(OPMODE_in),
		.ALUMODE_in(ALUMODE_in),
		.CARRYINSEL_in(CARRYINSEL_in),	
		
		.CARRYIN(CARRYIN),
		.INMODE_in(INMODE_in),
		.MULTMODE_in(MULTMODE_in),

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
		.CEMULTMODE(CEMULTMODE_0),	
		
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
		.RSTMULTMODE(RSTMULTMODE),	

		.ACIN(ACIN_1),
		.BCIN(BCIN_1),
		.PCIN({PCOUT_0[47:9], 9'b0}),
		.CARRYCASCIN(CARRYCASCIN_1),
		
		// Outputs
		.ACOUT(ACOUT_1),
		.BCOUT(BCOUT_1),
		.PCOUT(PCOUT_1),
		
		.P(P_1),	
		.P_SIMD_carry(P_SIMD_carry_1),

					
		.CARRYCASCOUT(CARRYCASCOUT_1),	
		.MULTSIGNOUT(MULTSIGNOUT_1),
		
		.PATTERNDETECT(PATTERNDETECT_1),		
		.PATTERNBDETECT(PATTERNBDETECT_1),
		
		.OVERFLOW(OVERFLOW_1),			
		.UNDERFLOW(UNDERFLOW_1),		
		
		.XOROUT(XOROUT_1),		
		
		// End of Outputs
		.configuration_input(configuration_input),
		.configuration_enable(configuration_enable)
	);  

	DSP_proposed_MF0 DSP_proposed_MF0_inst_core2(
		.clk(clk),		
		
		.A(A_2),
		.B(B_2),
		.C(C_2),
		.D(D_2),
		
		.OPMODE_in(OPMODE_in),
		.ALUMODE_in(ALUMODE_in),
		.CARRYINSEL_in(CARRYINSEL_in),	
		
		.CARRYIN(CARRYIN),
		.INMODE_in(INMODE_in),
		.MULTMODE_in(MULTMODE_in),

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
		.CEMULTMODE(CEMULTMODE_0),	
		
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
		.RSTMULTMODE(RSTMULTMODE),	

		.ACIN(ACIN_2),
		.BCIN(BCIN_2),
		.PCIN({PCOUT_1[47:9], 9'b0}),
		.CARRYCASCIN(CARRYCASCIN_2),
		
		// Outputs
		.ACOUT(ACOUT_2),
		.BCOUT(BCOUT_2),
		.PCOUT(PCOUT_2),
		
		.P(P_2),	
		.P_SIMD_carry(P_SIMD_carry_2),

					
		.CARRYCASCOUT(CARRYCASCOUT_2),	
		.MULTSIGNOUT(MULTSIGNOUT_2),
		
		.PATTERNDETECT(PATTERNDETECT_2),		
		.PATTERNBDETECT(PATTERNBDETECT_2),
		
		.OVERFLOW(OVERFLOW_2),			
		.UNDERFLOW(UNDERFLOW_2),		
		
		.XOROUT(XOROUT_2),		
		
		// End of Outputs
		.configuration_input(configuration_input),
		.configuration_enable(configuration_enable)
	);  

	
	
endmodule
