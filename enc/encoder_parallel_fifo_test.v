module encoder_parallel_fifo_test(input clock, reset, int_ready, wrreq,
	input[9:0] fifo_in, input[7:0] int_din,
	output[7:0] xk_out, zk_out, zk_prime_out,
	output out_valid);
	
	wire rdreq, empty;
	wire[9:0] fifo_out;
	
	fifo_10 fifo(.aclr(reset), .clock(clock), .data(fifo_in), .rdreq(rdreq),
		.wrreq(wrreq), .empty(empty), .q(fifo_out));
		
	encoder_top_parallel top(.clock(clock), .reset(reset), 
		.cbs_ready(fifo_out[0]), .cbs_blocksize(fifo_out[1]), .cbs_fifo_empty(empty), .int_ready(int_ready),
		.cbs_din(fifo_out[9:2]), .int_din(int_din), .xk_out(xk_out), .zk_out(zk_out), .zk_prime_out(zk_prime_out),
		.cbs_fifo_rreq(rdreq), .out_valid(out_valid));

endmodule 