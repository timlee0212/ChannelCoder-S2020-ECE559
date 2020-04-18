module encoder_top_parallel(
	input clock, reset, cbs_ready, cbs_blocksize, cbs_fifo_empty, int_ready,
	input[7:0] cbs_din, int_din,
	output[7:0] xk_out, zk_out, zk_prime_out,
	output cbs_fifo_rreq, out_valid,
	output [2:0] d_state
);

reg block_size;
	
wire switch, record_en, delay_ren, delay_wen, counter_en, reset_or_cbs_ready, clear_output;
wire ready;

wire cbs_data_being_input;
wire cbs_ready_guarded, cbs_blocksize_guarded;
wire[7:0] cbs_din_guarded;

assign reset_or_cbs_ready = reset | cbs_ready_guarded;

wire tail_en, tail_mode;
wire [2:0] state;
assign d_state = state;

always @(posedge clock, posedge reset, posedge cbs_ready_guarded) begin
	if (reset | cbs_ready_guarded) begin
		block_size <= 1'b0;
	end
	else begin
		if (record_en) begin
			block_size <= cbs_blocksize_guarded;
		end
	end
end


assign cbs_fifo_rreq = (ready | record_en | cbs_data_being_input) & ~cbs_fifo_empty & ~reset;
assign cbs_ready_guarded = cbs_fifo_rreq ? cbs_ready : 1'b0;
assign cbs_blocksize_guarded = cbs_fifo_rreq ? cbs_blocksize : 1'b0;
assign cbs_din_guarded = cbs_fifo_rreq ? cbs_din : 8'b0;

/*
always @(posedge clock) begin
	if (ready) begin
		if (~cbs_fifo_empty) begin
			rreq_enc_fifo <= 1'b1;
		end
		else begin
			rreq_enc_fifo <= 1'b0;
		end
	end
	else begin
		rreq_enc_fifo <= 1'b0;
	end
end
*/

my_counter counter(
	.clk(clock), .en(counter_en), .mode(block_size), .clr(reset_or_cbs_ready),
	.switch(switch));

wire [2:0] q1, q2;
reg[7:0] xk_reg, zk_reg, zk_p_reg;
wire[7:0] xk_reg_in, zk_reg_in, zk_p_reg_in;
//wire[7:0] xk_intermed, zk_intermed, zk_p_intermed;
wire[7:0] delay_out, delay_out_mux;
wire enc_en;
assign delay_out_mux = enc_en ? delay_out : 8'b00000000;

always @(posedge clock, posedge reset, posedge cbs_ready_guarded, posedge clear_output) begin
	if (reset | cbs_ready_guarded | clear_output) begin
		xk_reg <= 1'b0;
		zk_reg <= 1'b0;
		zk_p_reg <= 1'b0;
	end
	else begin
		xk_reg <= xk_reg_in;
		zk_reg <= zk_reg_in;
		zk_p_reg <= zk_p_reg_in;
	end
end

encoder_parallel en1(
	.b(delay_out_mux), .clock(clock), .reset(reset_or_cbs_ready), .en(enc_en),
	.zk(zk_reg_in), .xk(xk_reg_in), .q(q1));

encoder_parallel en2(
	.b(int_din), .clock(clock), .reset(reset_or_cbs_ready), .en(enc_en),
	.zk(zk_p_reg_in), .xk(), .q(q2));

delay del(.clock(clock), .aclr(reset_or_cbs_ready), .data_in(cbs_din_guarded),
 .data_write(delay_wen), .data_read(delay_ren), .counter_mode(block_size),
 .data_out(delay_out), .full_6144(), .usedw(), .actual_fifo_we(cbs_data_being_input));

fsm my_fsm(
	.aclr(reset), .clock(clock), .cbs_ready(cbs_ready_guarded), .int_ready(int_ready), .counter(switch),
	.record_en(record_en), .delay_ren(delay_ren), .delay_wen(delay_wen),
	.counter_en(counter_en), .tail_en(tail_en), .tail_mode(tail_mode), 
	.state(state), .enc_en(enc_en), .ready(ready), .out_valid(out_valid), .clear_output(clear_output)); 

tailBitsGenerator_parallel mytail(
	.q0(q1[0]), .q1(q1[1]), .q2(q1[2]), .q0_prime(q2[0]), .q1_prime(q2[1]), 
	.q2_prime(q2[2]), .xk_in(xk_reg), .zk_in(zk_reg), .zk_prime_in(zk_p_reg),
	.tail_bit_regs_enable(tail_en), .tail_bit_mode(tail_mode), .clock(clock),
	.reset(reset_or_cbs_ready),
	.xk_out(xk_out), .zk_out(zk_out), .zk_prime_out(zk_prime_out));

endmodule
