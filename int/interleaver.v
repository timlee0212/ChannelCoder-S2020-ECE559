//module interleaver (data_in, clk, reset, CRC_start, CRC_blocksize, CRC_end, data_out, data_ready2,
//                    done, offset,state,next_state,data_in_port,r2_out,r1_out,p1mode_w,r1_wetest,count1_test,pi1_value_test,pi2_value_test,count2_test,counter1_reset);//, next_state, state, counter1_done, counter1_reset, count1,pi1_small_value, pi1_value_test,target1,target2,counter2_done,counter2_reset);
module interleaver (clk,reset,CRC_start, CRC_blocksize, CRC_end, data_ready1, done,data_in,data_out,empty_itl_fifo,rreq_itl_fifo);
	
	input[7:0] data_in;
	input clk, reset,empty_itl_fifo;
	input CRC_start, CRC_blocksize, CRC_end; // control signals
	//input [2:0] offset;
	
	output[7:0] data_out;//,data_in_port,r2_out,r1_out,p1mode_w,r1_wetest;
	output done,rreq_itl_fifo;//,counter1_reset; // control signals
	output data_ready1;
	// debug signals
	wire [3:0] state, next_state;
	wire p1mode, p2mode; // 0 for reading, 1 for writing
	wire counter1_reset, counter2_reset; // local resets (will still be triggered on global reset)
	wire counter1_enable, counter2_enable;
	wire ram1_we, ram2_we; // RAM write enables
	wire counter1_done, counter2_done; // asserted when counters have reached their targets
	wire p1blocksize, p2blocksize; // 0 for small, 1 for large
	wire fsm_ready; // need to delay this ready signal by one clock cycle
	
	assign rreq_itl_fifo = ~empty_itl_fifo;
	interleaver_fsm_new FSM (clk, reset, CRC_blocksize, next_state, state, CRC_start, CRC_end, fsm_ready,
	                     done, p1mode, p2mode, counter1_reset, counter2_reset, counter1_enable,
								counter2_enable, ram1_we, ram2_we, counter1_done, counter2_done, p1blocksize, p2blocksize);
	wire data_ready2;
	
	dff ready_delay (fsm_ready, clk, ~reset, 1'b1, data_ready1);
	dff ready_delay1 (data_ready1, clk, ~reset, 1'b1, data_ready2);
	
	
	wire [12:0] count1/*,count1_bit1,count1_bit2,count1_bit3,count1_bit4,count1_bit5,count1_bit6,count1_bit7*/;
	counter_wrapper1 counter_wrapper1_inst (counter1_enable, p1blocksize, clk, counter1_reset, count1, counter1_done);
	
	wire [12:0] pi1_small_value0,pi1_small_value1,pi1_small_value2,pi1_small_value3,pi1_small_value4,pi1_small_value5,pi1_small_value6,pi1_small_value7;
	wire [12:0] pi1_large_value0,pi1_large_value1,pi1_large_value2,pi1_large_value3,pi1_large_value4,pi1_large_value5,pi1_large_value6,pi1_large_value7;
	wire [12:0] pi1_value0,pi1_value1,pi1_value2,pi1_value3,pi1_value4,pi1_value5,pi1_value6,pi1_value7;
	pi1_small_bit0 pi1_small_inst0(count1[12:3],~clk,pi1_small_value0);
	pi1_small_bit1 pi1_small_inst1(count1[12:3],~clk,pi1_small_value1);
	pi1_small_bit2 pi1_small_inst2(count1[12:3],~clk,pi1_small_value2);
	pi1_small_bit3 pi1_small_inst3(count1[12:3],~clk,pi1_small_value3);
	pi1_small_bit4 pi1_small_inst4(count1[12:3],~clk,pi1_small_value4);
	pi1_small_bit5 pi1_small_inst5(count1[12:3],~clk,pi1_small_value5);
	pi1_small_bit6 pi1_small_inst6(count1[12:3],~clk,pi1_small_value6);
	pi1_small_bit7 pi1_small_inst7(count1[12:3],~clk,pi1_small_value7);
	
	pi1_large_bit0 pi1_large_inst0(count1[12:3], ~clk, pi1_large_value0);
	pi1_large_bit1 pi1_large_inst1(count1[12:3], ~clk, pi1_large_value1);
	pi1_large_bit2 pi1_large_inst2(count1[12:3], ~clk, pi1_large_value2);
	pi1_large_bit3 pi1_large_inst3(count1[12:3], ~clk, pi1_large_value3);
	pi1_large_bit4 pi1_large_inst4(count1[12:3], ~clk, pi1_large_value4);
	pi1_large_bit5 pi1_large_inst5(count1[12:3], ~clk, pi1_large_value5);
	pi1_large_bit6 pi1_large_inst6(count1[12:3], ~clk, pi1_large_value6);
	pi1_large_bit7 pi1_large_inst7(count1[12:3], ~clk, pi1_large_value7);
	
	assign pi1_value0 = (p1blocksize) ? (pi1_large_value0) : (pi1_small_value0);
	assign pi1_value1 = (p1blocksize) ? (pi1_large_value1) : (pi1_small_value1);
	assign pi1_value2 = (p1blocksize) ? (pi1_large_value2) : (pi1_small_value2);
	assign pi1_value3 = (p1blocksize) ? (pi1_large_value3) : (pi1_small_value3);
	assign pi1_value4 = (p1blocksize) ? (pi1_large_value4) : (pi1_small_value4);
	assign pi1_value5 = (p1blocksize) ? (pi1_large_value5) : (pi1_small_value5);
	assign pi1_value6 = (p1blocksize) ? (pi1_large_value6) : (pi1_small_value6);
	assign pi1_value7 = (p1blocksize) ? (pi1_large_value7) : (pi1_small_value7);


	
	wire [12:0] count2/*,count2_bit1,count2_bit2,count2_bit3,count2_bit4,count2_bit5,count2_bit6,count2_bit7*/;
	wire [12:0] pi2_large_value0,pi2_large_value1,pi2_large_value2,pi2_large_value3,pi2_large_value4,pi2_large_value5,pi2_large_value6,pi2_large_value7;
	wire [12:0] pi2_small_value0,pi2_small_value1,pi2_small_value2,pi2_small_value3,pi2_small_value4,pi2_small_value5,pi2_small_value6,pi2_small_value7;
	wire [12:0] pi2_value0,pi2_value1,pi2_value2,pi2_value3,pi2_value4,pi2_value5,pi2_value6,pi2_value7;
	counter_wrapper2 counter_wrapper2_inst (counter2_enable, p2blocksize, clk, counter2_reset, count2, counter2_done);
	
	pi1_small_bit0 pi2_small_inst0(count2[12:3],~clk,pi2_small_value0);
	pi1_small_bit1 pi2_small_inst1(count2[12:3],~clk,pi2_small_value1);
	pi1_small_bit2 pi2_small_inst2(count2[12:3],~clk,pi2_small_value2);
	pi1_small_bit3 pi2_small_inst3(count2[12:3],~clk,pi2_small_value3);
	pi1_small_bit4 pi2_small_inst4(count2[12:3],~clk,pi2_small_value4);
	pi1_small_bit5 pi2_small_inst5(count2[12:3],~clk,pi2_small_value5);
	pi1_small_bit6 pi2_small_inst6(count2[12:3],~clk,pi2_small_value6);
	pi1_small_bit7 pi2_small_inst7(count2[12:3],~clk,pi2_small_value7);
	
	pi1_large_bit0 pi2_large_inst0(count2[12:3], ~clk, pi2_large_value0);
	pi1_large_bit1 pi2_large_inst1(count2[12:3], ~clk, pi2_large_value1);
	pi1_large_bit2 pi2_large_inst2(count2[12:3], ~clk, pi2_large_value2);
	pi1_large_bit3 pi2_large_inst3(count2[12:3], ~clk, pi2_large_value3);
	pi1_large_bit4 pi2_large_inst4(count2[12:3], ~clk, pi2_large_value4);
	pi1_large_bit5 pi2_large_inst5(count2[12:3], ~clk, pi2_large_value5);
	pi1_large_bit6 pi2_large_inst6(count2[12:3], ~clk, pi2_large_value6);
	pi1_large_bit7 pi2_large_inst7(count2[12:3], ~clk, pi2_large_value7);
	
	assign pi2_value0 = (p2blocksize) ? (pi2_large_value0) : (pi2_small_value0);
	assign pi2_value1 = (p2blocksize) ? (pi2_large_value1) : (pi2_small_value1);
	assign pi2_value2 = (p2blocksize) ? (pi2_large_value2) : (pi2_small_value2);
	assign pi2_value3 = (p2blocksize) ? (pi2_large_value3) : (pi2_small_value3);
	assign pi2_value4 = (p2blocksize) ? (pi2_large_value4) : (pi2_small_value4);
	assign pi2_value5 = (p2blocksize) ? (pi2_large_value5) : (pi2_small_value5);
	assign pi2_value6 = (p2blocksize) ? (pi2_large_value6) : (pi2_small_value6);
	assign pi2_value7 = (p2blocksize) ? (pi2_large_value7) : (pi2_small_value7);
	

	// pi1 mux
	wire [12:0] pi1_value;

	// pi2 mux
	wire [12:0] pi2_value;

	// RAMs
	// clocked on the negative edge for now -- to discuss
	// read enable always high for now
	
	// similarl to the delay on the ready signal, we need to delay the data by one cycle
	wire[7:0] delayed_data_in1,delayed_data_in2;
	dff data_delay10(data_in[0], clk, ~reset, 1'b1, delayed_data_in1[0]);
	dff data_delay11(data_in[1], clk, ~reset, 1'b1, delayed_data_in1[1]);
	dff data_delay12(data_in[2], clk, ~reset, 1'b1, delayed_data_in1[2]);
	dff data_delay13(data_in[3], clk, ~reset, 1'b1, delayed_data_in1[3]);
	dff data_delay14(data_in[4], clk, ~reset, 1'b1, delayed_data_in1[4]);
	dff data_delay15(data_in[5], clk, ~reset, 1'b1, delayed_data_in1[5]);
	dff data_delay16(data_in[6], clk, ~reset, 1'b1, delayed_data_in1[6]);
	dff data_delay17(data_in[7], clk, ~reset, 1'b1, delayed_data_in1[7]);
	
	dff data_delay20(delayed_data_in1[0], clk, ~reset, 1'b1, delayed_data_in2[0]);
	dff data_delay21(delayed_data_in1[1], clk, ~reset, 1'b1, delayed_data_in2[1]);
	dff data_delay22(delayed_data_in1[2], clk, ~reset, 1'b1, delayed_data_in2[2]);
	dff data_delay23(delayed_data_in1[3], clk, ~reset, 1'b1, delayed_data_in2[3]);
	dff data_delay24(delayed_data_in1[4], clk, ~reset, 1'b1, delayed_data_in2[4]);
	dff data_delay25(delayed_data_in1[5], clk, ~reset, 1'b1, delayed_data_in2[5]);
	dff data_delay26(delayed_data_in1[6], clk, ~reset, 1'b1, delayed_data_in2[6]);
	dff data_delay27(delayed_data_in1[7], clk, ~reset, 1'b1, delayed_data_in2[7]);
	//dff data_delay2 (delayed_data_in1, clk, ~reset, 1'b1, delayed_data_in2);
	
	//wire[7:0] ram1_out;
	//RAM1 RAM1_inst (reset, clk, delayed_data_in1, pi1_value, 1'b1, count1, ram1_we, ram1_out);

	wire[12:0] pi1_bit0, pi1_bit1, pi1_bit2, pi1_bit3, pi1_bit4, pi1_bit5, pi1_bit6, pi1_bit7,
				  pi2_bit0, pi2_bit1, pi2_bit2, pi2_bit3, pi2_bit4, pi2_bit5, pi2_bit6, pi2_bit7;
	wire ram1_bit0_out,ram1_bit1_out,ram1_bit2_out,ram1_bit3_out,ram1_bit4_out,ram1_bit5_out,ram1_bit6_out,ram1_bit7_out,
		  ram2_bit0_out,ram2_bit1_out,ram2_bit2_out,ram2_bit3_out,ram2_bit4_out,ram2_bit5_out,ram2_bit6_out,ram2_bit7_out;
		  
	assign pi1_bit0 = pi1_value0;
	assign pi1_bit1 = pi1_value7;
	assign pi1_bit2 = (p1blocksize)? pi1_value6:pi1_value2;
	assign pi1_bit3 = (p1blocksize)? pi1_value5:pi1_value1;
	assign pi1_bit4 = pi1_value4;
	assign pi1_bit5 = pi1_value3;
	assign pi1_bit6 = (p1blocksize)? pi1_value2:pi1_value6;
	assign pi1_bit7 = (p1blocksize)? pi1_value1:pi1_value5;
	
	assign pi2_bit0 = pi2_value0;
	assign pi2_bit1 = pi2_value7;
	assign pi2_bit2 = (p2blocksize)? pi2_value6:pi2_value2;
	assign pi2_bit3 = (p2blocksize)? pi2_value5:pi2_value1;
	assign pi2_bit4 = pi2_value4;
	assign pi2_bit5 = pi2_value3;
	assign pi2_bit6 = (p2blocksize)? pi2_value2:pi2_value6;
	assign pi2_bit7 = (p2blocksize)? pi2_value1:pi2_value5;

	
	bit_ram ram1_bit0(reset,clk,delayed_data_in1[0],pi1_bit0[12:3], 1'b1,count1[12:3],ram1_we,ram1_bit0_out);
	bit_ram ram1_bit1(reset,clk,delayed_data_in1[1],pi1_bit1[12:3], 1'b1,count1[12:3],ram1_we,ram1_bit1_out);
	bit_ram ram1_bit2(reset,clk,delayed_data_in1[2],pi1_bit2[12:3], 1'b1,count1[12:3],ram1_we,ram1_bit2_out);
	bit_ram ram1_bit3(reset,clk,delayed_data_in1[3],pi1_bit3[12:3], 1'b1,count1[12:3],ram1_we,ram1_bit3_out);
	bit_ram ram1_bit4(reset,clk,delayed_data_in1[4],pi1_bit4[12:3], 1'b1,count1[12:3],ram1_we,ram1_bit4_out);
	bit_ram ram1_bit5(reset,clk,delayed_data_in1[5],pi1_bit5[12:3], 1'b1,count1[12:3],ram1_we,ram1_bit5_out);
	bit_ram ram1_bit6(reset,clk,delayed_data_in1[6],pi1_bit6[12:3], 1'b1,count1[12:3],ram1_we,ram1_bit6_out);
	bit_ram ram1_bit7(reset,clk,delayed_data_in1[7],pi1_bit7[12:3], 1'b1,count1[12:3],ram1_we,ram1_bit7_out);
	
	bit_ram ram2_bit0(reset,clk,delayed_data_in1[0],pi2_bit0[12:3], 1'b1,count2[12:3],ram2_we,ram2_bit0_out);
	bit_ram ram2_bit1(reset,clk,delayed_data_in1[1],pi2_bit1[12:3], 1'b1,count2[12:3],ram2_we,ram2_bit1_out);
	bit_ram ram2_bit2(reset,clk,delayed_data_in1[2],pi2_bit2[12:3], 1'b1,count2[12:3],ram2_we,ram2_bit2_out);
	bit_ram ram2_bit3(reset,clk,delayed_data_in1[3],pi2_bit3[12:3], 1'b1,count2[12:3],ram2_we,ram2_bit3_out);
	bit_ram ram2_bit4(reset,clk,delayed_data_in1[4],pi2_bit4[12:3], 1'b1,count2[12:3],ram2_we,ram2_bit4_out);
	bit_ram ram2_bit5(reset,clk,delayed_data_in1[5],pi2_bit5[12:3], 1'b1,count2[12:3],ram2_we,ram2_bit5_out);
	bit_ram ram2_bit6(reset,clk,delayed_data_in1[6],pi2_bit6[12:3], 1'b1,count2[12:3],ram2_we,ram2_bit6_out);
	bit_ram ram2_bit7(reset,clk,delayed_data_in1[7],pi2_bit7[12:3], 1'b1,count2[12:3],ram2_we,ram2_bit7_out);

	// final output mux
	// when p1mode is 1, side 1 is writing, so send data from ram 1
	// when p1mode is 0, either side 2 is writing, or we don't have valid data, so we can 
	// just send ram 2 and not assert data_ready if it's not valid data
	
	wire real_ram1_out0,real_ram1_out1,real_ram1_out2,real_ram1_out3,real_ram1_out4,real_ram1_out5,real_ram1_out6,real_ram1_out7,
		  real_ram2_out0,real_ram2_out1,real_ram2_out2,real_ram2_out3,real_ram2_out4,real_ram2_out5,real_ram2_out6,real_ram2_out7;
	assign real_ram1_out0 = ram1_bit0_out;
	assign real_ram1_out1 = (p1blocksize) ? ram1_bit7_out:ram1_bit3_out;
	assign real_ram1_out2 = (p1blocksize) ? ram1_bit6_out:ram1_bit2_out;
	assign real_ram1_out3 = (p1blocksize) ? ram1_bit5_out:ram1_bit5_out;
	assign real_ram1_out4 = ram1_bit4_out;
	assign real_ram1_out5 = (p1blocksize) ? ram1_bit3_out:ram1_bit7_out;
	assign real_ram1_out6 = (p1blocksize) ? ram1_bit2_out:ram1_bit6_out;
	assign real_ram1_out7 = (p1blocksize) ? ram1_bit1_out:ram1_bit1_out;
	
	assign real_ram2_out0 = ram2_bit0_out;
	assign real_ram2_out1 = (p2blocksize) ? ram2_bit7_out:ram2_bit3_out;
	assign real_ram2_out2 = (p2blocksize) ? ram2_bit6_out:ram2_bit2_out;
	assign real_ram2_out3 = (p2blocksize) ? ram2_bit5_out:ram2_bit5_out;
	assign real_ram2_out4 = ram2_bit4_out;
	assign real_ram2_out5 = (p2blocksize) ? ram2_bit3_out:ram2_bit7_out;
	assign real_ram2_out6 = (p2blocksize) ? ram2_bit2_out:ram2_bit6_out;
	assign real_ram2_out7 = (p2blocksize) ? ram2_bit1_out:ram2_bit1_out;
	
	assign data_out[0] = (p1mode) ? (real_ram1_out0) : (real_ram2_out0);
	assign data_out[1] = (p1mode) ? (real_ram1_out1) : (real_ram2_out1);
	assign data_out[2] = (p1mode) ? (real_ram1_out2) : (real_ram2_out2);
	assign data_out[3] = (p1mode) ? (real_ram1_out3) : (real_ram2_out3);
	assign data_out[4] = (p1mode) ? (real_ram1_out4) : (real_ram2_out4);
	assign data_out[5] = (p1mode) ? (real_ram1_out5) : (real_ram2_out5);
	assign data_out[6] = (p1mode) ? (real_ram1_out6) : (real_ram2_out6);
	assign data_out[7] = (p1mode) ? (real_ram1_out7) : (real_ram2_out7);
endmodule