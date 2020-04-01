module coder_stack(
	input clk, reset, tb_in, wreq_data, tb_size_in, wreq_size,
	output xk_out, zk_out, zk_prime_out
	);

// enc
wire cbs_ready, cbs_blocksize, cbs_din;
wire int_ready, int_din;
wire enc_ready;

// int
wire data_in, CRC_start, CRC_blocksize;
wire data_out, data_ready, done;

// cbseg
reg rreq_itl_fifo, rreq_enc_fifo;
wire empty_itl_fifo, empty_enc_fifo;
wire [4:0] q_itl_fifo;
wire [2:0] q_enc_fifo;

// connecting int-enc ports
assign int_din = data_out;
assign int_ready = done;

// connecting cbseg-enc ports
always @(posedge clk) begin
	if (enc_ready) begin
		if (~empty_enc_fifo) begin
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
assign cbs_ready = q_enc_fifo[0];
assign cbs_blocksize = q_enc_fifo[1];
assign cbs_din = q_enc_fifo[2];

// connecting cbseg-int - TBD!!
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
	(data_in, clk, reset, CRC_start, CRC_blocksize, data_out, data_ready,
                    done);
						  
encoder_top my_enc(
	clk, reset, cbs_ready, cbs_blocksize, int_ready,
	cbs_din, int_din,
	xk_out, zk_out, zk_prime_out, enc_ready);

endmodule 