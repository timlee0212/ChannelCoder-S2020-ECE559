module cb_seg(
    input wire clk,
    input wire reset,
    input wire tb_in,
    input wire wreq_data,        //Write Request of the Input TB buffer
    input wire[15:0] tb_size_in,  
    input wire wreq_size,
    //TODO: A signal from Transfer Layer to initilize the computation?

    //Control Signals
    output wire filling,
    output wire crc,
    output wire start,
    //output wire stop,

    output wire cb_size,  //1-bit 2 possible size
    output wire cb_data   //Serial Data Output

	 //Interleaver FIFO Ports
//	 input wire rreq_itl_fifo,
//	 output wire[4:0] q_itl_fifo, //{data, size, start}
//	 output wire empty_itl_fifo,
//	 
//	 //Encoder FIFO Ports
//	 input wire rreq_enc_fifo,
//	 output wire[2:0] q_enc_fifo,  //{data, size, start, crc, filling}
//	 output wire empty_enc_fifo
	 
	 //Debug
	 //output wire[19:0] size_fifo_out
);

wire data_fifo_out;
wire data_fifo_rd, data_fifo_empty, size_fifo_rd, size_fifo_empty;
//
//wire start, crc, filling, cb_size, cb_data;
wire wreq_itl_fifo, wreq_enc_fifo;

wire[19:0] size_fifo_data;

wire padding_mux_out;
wire[23:0] crc_out;
wire padding_mux_sel, crc_mux_sel, crc_init, crc_ena_com, crc_nshift;

//assign size_fifo_out = size_fifo_data;

//Data Path
mux_ip	padding_mux (
	.data0 ( 1'b0 ),
	.data1 ( data_fifo_out ),
	.sel ( padding_mux_sel ),
	.result ( padding_mux_out )
	);

mux_ip	crc_mux (
	.data0 ( padding_mux_out ),
	.data1 ( crc_out[0] ),
	.sel ( crc_mux_sel ),
	.result ( cb_data )
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
    .nen_shift(crc_nshift),

    .crc_out(crc_out)
);

//itl_fifo	itl_fifo_inst (
//	.aclr (reset),
//	.clock (clk),
//	.data ({cb_data, cb_size, start, crc, filling}),
//	.rdreq (rreq_itl_fifo),
//	.wrreq (wreq_itl_fifo),
//	.empty (empty_itl_fifo),
//	.full (),		//Assume it won't be full
//	.q (q_itl_fifo)
//);
//
//enc_fifo	enc_fifo_inst (
//	.aclr (reset),
//	.clock (clk),
//	.data ({cb_data, cb_size, start}),
//	.rdreq (rreq_enc_fifo),
//	.wrreq (wreq_enc_fifo),
//	.empty (empty_enc_fifo),
//	.full (),
//	.q (q_enc_fifo)
//	);


data_fsm datapath_control_unit(
    .clk(clk),
    .reset(reset),

	.empty_data_fifo(data_fifo_empty),
	.empty_size_fifo(size_fifo_empty),

	.size(size_fifo_data),

	.mux_fill(padding_mux_sel),
	.mux_crc(crc_mux_sel),

    .init_crc(crc_init),
	.ena_crc(crc_ena_com),
    .nshift_crc(crc_nshift),

	.read_data_fifo(data_fifo_rd),
	.read_size_fifo(size_fifo_rd),

	.block_size(cb_size),
	
	.wreq_itl_fifo(wreq_itl_fifo),
	.wreq_enc_fifo(wreq_enc_fifo),

	.start(start),
	.filling(filling),
	//.stop(stop),
	.crc(crc)
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