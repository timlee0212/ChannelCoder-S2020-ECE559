module coder_stack_top(
	input clk, reset, tb_in, wreq_data, wreq_size,
	input [15:0] tb_size_in,
	output xk_out, zk_out, zk_prime_out
	);

// enc
wire cbs_ready, cbs_blocksize, cbs_din;
wire int_ready, int_din;
wire enc_ready;

// int
wire int_data_in, int_start_in, int_blksize_in;
wire data_out, data_ready, done;

// cbseg
reg rreq_itl_fifo;
wire rreq_enc_fifo;
wire empty_itl_fifo, empty_enc_fifo;
wire [4:0] q_itl_fifo;
wire [2:0] q_enc_fifo;

// connecting int-enc ports
assign int_din = data_out;
assign int_ready = done;

// connecting cbseg-enc ports
assign cbs_ready = q_enc_fifo[0];
assign cbs_blocksize = q_enc_fifo[1];
assign cbs_din = q_enc_fifo[2];

//interleaver input signals 
always @(posedge clk) begin
	if (int_ready) begin
		if (~empty_itl_fifo) begin
			rreq_itl_fifo <= 1'b1;
		end
		else begin
			rreq_itl_fifo <= 1'b0;
		end
	end
	else begin
		rreq_itl_fifo <= 1'b0;
	end
end
assign int_data_in = q_itl_fifo[4];
assign int_start_in = q_itl_fifo[2];
assign int_blksize_in = q_itl_fifo[3];

cb_seg my_cb_seg(
    clk,
    reset,
    tb_in,
    wreq_data,        //Write Request of the Input TB buffer
    tb_size_in,  
    wreq_size,

	 rreq_itl_fifo,
	 q_itl_fifo, //{data, size, start}
	 empty_itl_fifo,
	 
	 rreq_enc_fifo,
	 q_enc_fifo,  //{data, size, start, crc, filling}
	 empty_enc_fifo
);

interleaver my_int
	(clk, reset,
	int_data_in, int_start_in, int_blksize_in, 
	data_out, data_ready, done);
						  
encoder_top my_enc(
	.clock(clk), .reset(reset), .cbs_ready(cbs_ready), .cbs_blocksize(cbs_blocksize), .cbs_fifo_empty(empty_enc_fifo), .int_ready(int_ready),
	.cbs_din(cbs_din), .int_din(int_din),
	.xk_out(xk_out), .zk_out(zk_out), .zk_prime_out(zk_prime_out), .cbs_fifo_rreq(rreq_enc_fifo));

endmodule 