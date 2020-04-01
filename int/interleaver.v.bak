module interleaver (data_in, clk, reset, CRC_start, CRC_blocksize, CRC_end, data_out, data_ready,
                    done, next_state, state, counter1_done, counter1_reset, count1, pi1_small_value);
	input data_in;
	input clk, reset;
	input CRC_start, CRC_blocksize, CRC_end; // control signals
	
	output data_out;
	output data_ready, done; // control signals
	
	output [3:0] state, next_state;
	wire p1mode, p2mode; // 0 for reading, 1 for writing
	wire counter1_reset, counter2_reset; // local resets (will still be triggered on global reset)
	wire counter1_enable, counter2_enable;
	wire ram1_we, ram2_we; // RAM write enables
	output counter1_done, counter1_reset;
	wire counter1_done, counter2_done; // asserted when counters have reached their targets
	wire p1blocksize, p2blocksize; // 0 for small, 1 for large
	wire fsm_ready; // need to delay this ready signal by one clock cycle
	interleaver_fsm FSM (clk, reset, CRC_blocksize, next_state, state, CRC_start, data_in, CRC_end, fsm_ready,
	                     done, p1mode, p2mode, counter1_reset, counter2_reset, counter1_enable,
								counter2_enable, ram1_we, ram2_we, counter1_done, counter2_done, p1blocksize, p2blocksize);
	dff ready_delay (fsm_ready, clk, ~reset, 1'b1, data_ready);
	
	output [12:0] count1;
	wire [12:0] count1;
	counter_wrapper1 counter_wrapper1_inst (counter1_enable, p1blocksize, clk, counter1_reset, count1, counter1_done);
	
	wire [12:0] pi1_small_value;
	output [12:0] pi1_small_value;
	pi1_small pi1_small_inst (count1, ~clk, pi1_small_value);
	
	wire [12:0] pi1_large_value;
	pi1_large pi1_large_inst (count1, ~clk, pi1_large_value);
	
	
	wire [12:0] count2;
	counter_wrapper2 counter_wrapper2_inst (counter2_enable, p2blocksize, clk, counter2_reset, count2, counter2_done);
	
	wire [12:0] pi2_small_value;
	pi2_small pi2_small_inst (count2, ~clk, pi2_small_value);
	
	wire [12:0] pi2_large_value;
	pi2_large pi2_large_inst (count2, ~clk, pi2_large_value);
	
	// pi1 mux
	wire [12:0] pi1_value;
	assign pi1_value = (p1blocksize) ? (pi1_large_value) : (pi1_small_value);
	
	// pi2 mux
	wire [12:0] pi2_value;
	assign pi2_value = (p2blocksize) ? (pi2_large_value) : (pi2_small_value);
	
	// RAMs
	// clocked on the negative edge for now -- to discuss
	// read enable always high for now
	
	// similarl to the delay on the ready signal, we need to delay the data by one cycle
	wire delayed_data_in1, delayed_data_in2;
	dff data_delay1 (data_in, clk, ~reset, 1'b1, delayed_data_in1);
	dff data_delay2 (delayed_data_in1, clk, ~reset, 1'b1, delayed_data_in2);
	
	wire ram1_out;
	RAM1 RAM1_inst (reset, clk, delayed_data_in2, pi1_value, 1'b1, count1, ram1_we, ram1_out);
	
	wire ram2_out;
	RAM2 RAM2_inst (reset, clk, delayed_data_in2, pi2_value, 1'b1, count2, ram2_we, ram2_out);
	
	// final output mux
	// when p1mode is 1, side 1 is writing, so send data from ram 1
	// when p1mode is 0, either side 2 is writing, or we don't have valid data, so we can 
	// just send ram 2 and not assert data_ready if it's not valid data
	assign data_out = (p1mode) ? (ram1_out) : (ram2_out);
endmodule