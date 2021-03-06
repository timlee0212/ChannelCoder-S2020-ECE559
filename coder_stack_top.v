module coder_stack_top(
	input clk, reset, wreq_data, wreq_size,
	input [7:0] tb_in,
	input [11:0] tb_size_in,
	output [7:0] xk_out, zk_out, zk_prime_out,
	output out_valid
	);

// enc
wire cbs_ready, cbs_blocksize;
wire [7:0] cbs_din;
wire int_ready;
wire [7:0] int_din;
wire enc_ready;

// int
wire int_start_in, int_blksize_in,int_end_in;
wire [7:0] int_data_in, data_out;
wire data_ready, done;

// cbseg
wire rreq_itl_fifo;
wire rreq_enc_fifo;
wire empty_itl_fifo, empty_enc_fifo;
wire [10:0] q_itl_fifo;
wire [9:0] q_enc_fifo;

// connecting int-enc ports
assign int_din = data_out;
assign int_ready = data_ready;

// connecting cbseg-enc ports
assign cbs_ready = q_enc_fifo[0];
assign cbs_blocksize = q_enc_fifo[1];
assign cbs_din = q_enc_fifo[9:2];

//interleaver input signals
assign int_data_in = q_itl_fifo[10:3];
assign int_start_in = q_itl_fifo[1];
assign int_blksize_in = q_itl_fifo[2];
assign int_end_in = q_itl_fifo[0];

cb_seg my_cb_seg(
    clk,
    reset,
    tb_in,
    wreq_data,        //Write Request of the Input TB buffer
    tb_size_in,  
    wreq_size,

	 rreq_itl_fifo,
	 q_itl_fifo, //{data[7:0], size, start, tf_end}
	 empty_itl_fifo,
	 
	 rreq_enc_fifo,
	 q_enc_fifo,  //{data[7:0], size, start}
	 empty_enc_fifo
);

/*
interleaver my_int
	(clk, reset,
	int_data_in, int_start_in, int_blksize_in, empty_itl_fifo,
	data_out, data_ready, done,rreq_itl_fifo);
*/

//fake_interleaver my_int
//	(clk, reset, cbs_ready, data_ready, data_out);
//	
interleaver my_int
	(clk, reset, 
	int_start_in, int_blksize_in, int_end_in, data_ready, done, int_data_in, data_out,empty_itl_fifo,rreq_itl_fifo);
						  
encoder_top_parallel my_enc(
	.clock(clk), .reset(reset), .cbs_ready(cbs_ready), .cbs_blocksize(cbs_blocksize), .cbs_fifo_empty(empty_enc_fifo), .int_ready(int_ready),
	.cbs_din(cbs_din), .int_din(int_din),
	.xk_out(xk_out), .zk_out(zk_out), .zk_prime_out(zk_prime_out), .cbs_fifo_rreq(rreq_enc_fifo), .out_valid(out_valid)
	);

endmodule 