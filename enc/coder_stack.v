module coder_stack(
	input clk, reset, tb_in, wreq_data, wreq_size,
	input [15:0] tb_size,
	output xk_out, zk_out, zk_prime_out,
	
	input d_int_ready,
	output [2:0] d_state,
	output [2:0] d_q_enc_fifo,
	output d_crc_enc_empty_fifo, d_rreq_enc_fifo, d_ready
	);
	
assign d_crc_enc_empty_fifo = empty_enc_fifo;
assign d_q_enc_fifo = q_enc_fifo;
assign d_rreq_enc_fifo = rreq_enc_fifo; //d_ready & ~empty_enc_fifo; 

// enc
wire cbs_ready, cbs_blocksize, cbs_din;
wire int_ready, int_din;
wire enc_ready;

// int
wire data_in, CRC_start, CRC_blocksize;
wire data_out, data_ready, done;

// cbseg
wire rreq_itl_fifo, rreq_enc_fifo;
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

// connecting cbseg-int - TBD!!

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
	(data_in, clk, reset, CRC_start, CRC_blocksize, data_out, data_ready,
                    done);
						  
encoder_top my_enc(
	.clock(clk), .reset(reset), .cbs_ready(cbs_ready), .cbs_blocksize(cbs_blocksize), .cbs_fifo_empty(empty_enc_fifo), .int_ready(d_int_ready),
	.cbs_din(cbs_din), .int_din(int_din),
	.xk_out(xk_out), .zk_out(zk_out), .zk_prime_out(zk_prime_out), .cbs_fifo_rreq(rreq_enc_fifo),
	
	.d_state(d_state),
	.d_ready(d_ready));

endmodule 