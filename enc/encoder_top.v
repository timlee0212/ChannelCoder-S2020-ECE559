module encoder_top(
	input clock, reset, cbs_ready, cbs_blocksize, cbs_fifo_empty, int_ready,
	input cbs_din, int_din,
	output xk_out, zk_out, zk_prime_out, cbs_fifo_rreq,
	output [2:0] d_state);

reg block_size;
	
wire switch, record_en, delay_ren, delay_wen, counter_en, reset_or_cbs_ready;
wire ready;
assign reset_or_cbs_ready = reset | cbs_ready;

wire tail_en, tail_mode, tail_counter, close_switch, tail_counter_enable;
wire [2:0] state;

assign d_state = state;

always @(posedge clock, posedge reset, posedge cbs_ready) begin
	if (reset | cbs_ready) begin
		block_size <= 1'b0;
	end
	else begin
		if (record_en) begin
			block_size <= cbs_blocksize;
		end
	end
end

assign cbs_fifo_rreq = /*ready &*/ ~cbs_fifo_empty;
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
reg xk_reg, zk_reg, zk_p_reg;
wire xk_reg_in, zk_reg_in, zk_p_reg_in;
wire delay_out, delay_out_mux;
wire enc_en;
assign delay_out_mux = enc_en ? delay_out : 1'b0;

always @(posedge clock, posedge reset, posedge cbs_ready) begin
	if (reset | cbs_ready) begin
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

encoder en1(
	.serial_in(delay_out_mux), .switch(close_switch), .clock(clock), .reset(reset_or_cbs_ready), .en(enc_en),
	.zk(zk_reg_in), .xk(xk_reg_in), .q(q1));

encoder en2(
	.serial_in(int_din), .switch(close_switch), .clock(clock), .reset(reset_or_cbs_ready), .en(enc_en),
	.zk(zk_p_reg_in), .xk(), .q(q2));

delay del(.clock(clock), .aclr(reset_or_cbs_ready), .data_in(cbs_din),
 .data_write(delay_wen), .data_read(delay_ren), .counter_mode(block_size),
 .data_out(delay_out), .full_6144(), .usedw());
 

fsm my_fsm(
	.aclr(reset), .clock(clock), .cbs_ready(cbs_ready), .int_ready(int_ready), 
	.counter(switch), .tail_counter(tail_counter),
	.record_en(record_en), .delay_ren(delay_ren), .delay_wen(delay_wen),
	.counter_en(counter_en), .close_switch(close_switch), .tail_en(tail_en), .tail_mode(tail_mode), 
	.state(state), .enc_en(enc_en), .tail_counter_enable(tail_counter_enable), .ready(ready));
	
tailBitsGenerator mytail(
	.q0(q1[0]), .q1(q1[1]), .q2(q1[2]), .q0_prime(q2[0]), .q1_prime(q2[1]), 
	.q2_prime(q2[2]), .xk_in(xk_reg), .zk_in(zk_reg), .zk_prime_in(zk_p_reg),
	.tail_bit_regs_enable(tail_en), .tail_bit_mode(tail_mode), .tail_counter_enable(tail_counter_enable), .clock(clock),
	.reset(reset_or_cbs_ready),
	.xk_out(xk_out), .zk_out(zk_out), .zk_prime_out(zk_prime_out), 
	.tail_bit_done(tail_counter));
	
endmodule 