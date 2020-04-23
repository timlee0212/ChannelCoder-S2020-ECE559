module cb_seg(
    input wire clk,
    input wire reset,
    input wire[7:0] tb_in,
    input wire wreq_data,        //Write Request of the Input TB buffer
    input wire[11:0] tb_size_in,  
    input wire wreq_size,
    //TODO: A signal from Transfer Layer to initilize the computation?

    //Control Signals
//    output wire filling,
//    output wire crc,
//    output wire start,
    //output wire stop,

//    output wire cb_size,  //1-bit 2 possible size
//    output wire[7:0] cb_data   //Serial Data Output

	 //Interleaver FIFO Ports
	 input wire rreq_itl_fifo,
	 output wire[10:0] q_itl_fifo, //{data[7:0], size, start, tf_end}
	 output wire empty_itl_fifo,
	 
	 //Encoder FIFO Ports
	 input wire rreq_enc_fifo,
	 output wire[9:0] q_enc_fifo,  //{data[7:0], size, start}
	 output wire empty_enc_fifo
	 
	 //Debug
	 //output wire[19:0] size_fifo_out
);

wire[7:0] data_fifo_out;
wire data_fifo_rd, data_fifo_empty, size_fifo_rd, size_fifo_empty;

wire start, cb_size, tf_end;
wire[7:0] cb_data;

wire wreq_itl_fifo, wreq_enc_fifo;

wire[1:0] crc_shift_mux_sel;

wire[13:0] size_fifo_data;

wire[7:0] padding_mux_out;

wire[23:0] crc_out;
wire[7:0] crc_shift_mux_out;
wire padding_mux_sel, crc_mux_sel, crc_init, crc_ena_com;

//assign size_fifo_out = size_fifo_data;

//Data Path
mux_ip	padding_mux (
	.data0x ( 8'h00 ),
	.data1x ( data_fifo_out ),
	.sel ( padding_mux_sel ),
	.result ( padding_mux_out )
	);

mux_ip	crc_mux (
	.data0x ( padding_mux_out ),
	.data1x ( crc_shift_mux_out ),
	.sel ( crc_mux_sel ),
	.result ( cb_data )
	);
	
crc_shift_mux	crc_shift_mux_inst (
	.data0x (crc_out[23:16]),
	.data1x (crc_out[15:8]),
	.data2x (crc_out[7:0]),
	.sel (crc_shift_mux_sel),
	.result (crc_shift_mux_out)
	);

	

fifo_tb	data_fifo (
	.clock ( clk),
	.aclr(reset),
	.data ( tb_in ),
	.rdreq ( data_fifo_rd ),
	.wrreq ( wreq_data ),
	.empty ( data_fifo_empty ),
	.q ( data_fifo_out )
	);

crc24 crc_mod(
    .clk(clk),
    .reset(reset),
    .init(crc_init),
    .en_com(crc_ena_com),
    .d_in(padding_mux_out),
    //.nen_shift(crc_nshift),

    .crc_out(crc_out)
);

fifo_11bits	itl_fifo_inst (
	.aclr (reset),
	.clock (clk),
	.data ({cb_data, cb_size, start, tf_end}),
	.rdreq (rreq_itl_fifo),
	.wrreq (wreq_itl_fifo),
	.empty (empty_itl_fifo),
	.full (),		//Assume it won't be full
	.q (q_itl_fifo)
);

fifo_10bits	enc_fifo_inst (
	.aclr (reset),
	.clock (clk),
	.data ({cb_data, cb_size, start}),
	.rdreq (rreq_enc_fifo),
	.wrreq (wreq_enc_fifo),
	.empty (empty_enc_fifo),
	.full (),
	.q (q_enc_fifo)
	);


data_fsm datapath_control_unit(
    .clk(clk),
    .reset(reset),

	.empty_data_fifo(data_fifo_empty),
	.empty_size_fifo(size_fifo_empty),

	.size(size_fifo_data),
	
	.crc_shift_sel(crc_shift_mux_sel),
	.mux_fill(padding_mux_sel),
	.mux_crc(crc_mux_sel),

    .init_crc(crc_init),
	.ena_crc(crc_ena_com),
    //.nshift_crc(crc_nshift),

	.read_data_fifo(data_fifo_rd),
	.read_size_fifo(size_fifo_rd),

	.block_size(cb_size),
	
	.wreq_itl_fifo(wreq_itl_fifo),
	.wreq_enc_fifo(wreq_enc_fifo),

	.start(start),
	.tf_end(tf_end),
	.filling(),
	//.stop(stop),
	.crc()
);

//Block Size Computation

CRC_size  cb_size_computation(
	.aclr(reset),
	.clk(clk),
	.w(wreq_size),
	.inputSize(tb_size_in),
	.r_out(size_fifo_rd),
	.empty_out(size_fifo_empty),
	.data_out(size_fifo_data)
);


endmodule