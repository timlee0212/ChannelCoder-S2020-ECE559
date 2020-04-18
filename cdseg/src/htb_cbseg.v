module mem_tb_cb_seg(
	input wire reset,
	input wire clk,
	input wire test_start,
	
	output wire test_good,
	output wire test_end,
	
	//Debug Port for logic analyzer
	output wire[7:0] data,
	output wire size,
	output wire start,
	output wire crc,
	output wire filling
);
wire[7:0] in_data;
wire in_size, in_start;
wire wreq_data, wreq_size;
wire [7:0] data_in;
wire[15:0] size_in;

assign data = in_data;
assign size = in_size;
assign start = in_start;

cb_seg test_obj(
    .clk(clk),
    .reset(reset),
    .tb_in(data_in),
    .wreq_data(wreq_data),        //Write Request of the Input TB buffer
    .tb_size_in(size_in),  
    .wreq_size(wreq_size),

    .filling(filling),
    .crc(crc),
    .start(in_start),

    .cb_size(in_size),  //1-bit 2 possible size
    .cb_data(in_data)   //Serial Data Output
);

write_ctl writer(
	.reset(reset),
	.clk(clk),
	.test_start(test_start),
	
	.data_in(data_in),
	.wreq_size(wreq_size),
	.wreq_data(wreq_data),
	.size(size_in)
);

read_ctl reader(
	.reset(reset),
	.clk(clk),
	.start(in_start),
	.data(in_data),
	.size(in_size),
	
	.test_good(test_good),
	.test_end(test_end)
);

endmodule



module write_ctl(
	input wire reset,
	input wire clk,
	input wire test_start,
	
	output reg wreq_size,
	output reg wreq_data,
	output wire[7:0] data_in,
	output reg[15:0] size
);

//FSM State Encoding
//Following the Quartus Encoding Scheme
parameter IDLE			=	6'b000000,
			 WRITE_SIZE	=	6'b000011,
			 WAIT_MEM	=	6'b000101,	//ROM Has 2 cycles delay. Add a extra state for that delay
			 WRITE_DATA	=	6'b001001,
			 WRITE_FIN1	=	6'b010001,
			 WRITE_FIN2	= 	6'b100001;

reg[15:0] cnt_write_in;
reg cnt_write_en, cnt_write_load;
reg[5:0] state_reg, next_state;

wire[15:0] cnt_write_q;

counter_16bits	cnt_write (
	.aclr ( reset),
	.clock ( clk ),
	.cnt_en ( cnt_write_en ),
	.data ( cnt_write_in ),
	.sload ( cnt_write_load ),
	.q ( cnt_write_q )
	);

//ROM
test_input	test_input_inst (
	.aclr (reset),
	.address (cnt_write_q),
	.clock (clk),
	.q (data_in)
);
	
always@(posedge clk or posedge reset) begin
	if(reset==1'b1) state_reg <= IDLE;
	else state_reg <= next_state;
end

always@(*) begin
	case(state_reg)
		IDLE: if(test_start==1'b1) next_state <=WRITE_SIZE;
				else next_state <= IDLE;
		WRITE_SIZE: next_state <= WAIT_MEM;
		WAIT_MEM: next_state <= WRITE_DATA;
		WRITE_DATA: if(cnt_write_q==16'h0000) next_state <= WRITE_FIN1;
						else next_state <= WRITE_DATA;
		WRITE_FIN1: next_state <= WRITE_FIN2;
		WRITE_FIN2: next_state <= IDLE;
		default:	next_state <= IDLE;
	endcase
end

always@(*) begin
wreq_size 		=		1'b0;
wreq_data 		= 	1'b0;
size				=		16'h0;
cnt_write_en	=		1'b0;
cnt_write_in	=		16'h0;
cnt_write_load	=		1'b0;

	case(state_reg)
		IDLE: begin
			cnt_write_in  	= 16'd0877;
			cnt_write_load =1'b1;		
		end
		WRITE_SIZE: begin 
			size				= 16'd0878;
			wreq_size		= 1'b1;
			cnt_write_en 	= 1'b1;
		end
		WAIT_MEM: begin
			cnt_write_en 	= 1'b1;
		end
		WRITE_DATA: begin
			wreq_data		= 1'b1;
			cnt_write_en 	= 1'b1;
		end
		WRITE_FIN1: wreq_data = 1'b1;
		WRITE_FIN2: wreq_data = 1'b1;
	endcase
end
endmodule


module read_ctl(
	input wire reset,
	input wire clk,
	input wire start,
	input wire size,
	input wire[7:0] data,
	
	output wire test_good,
	output reg test_end
);

parameter IDLE 		= 8'b00000000,
			 LOAD_SIZE	= 8'b00000011,
			 WAIT_REG1	= 8'b00000101,
			 WAIT_REG2	= 8'b00001001,
			 READ_LARGE	= 8'b00010001,
			 READ_SMALL	= 8'b00100001,
			 WAIT_F1		= 8'b01000001,
			 WAIT_F2		= 8'b10000001;

reg[15:0] cnt_read_in;
reg cnt_read_en, cnt_read_load;
reg[7:0] state_reg, next_state;

wire[15:0] cnt_read_q;

wire[7:0] ref_s, ref_l;

reg buf_load, buf_in;


reg tg_load, tg_in;
wire tg_q, buf_size;

assign test_good = tg_q;

counter_16bits	cnt_read(
	.aclr ( reset),
	.clock ( clk ),
	.cnt_en ( cnt_read_en ),
	.data ( cnt_read_in ),
	.sload ( cnt_read_load ),
	.q ( cnt_read_q )
);

register_1bit	reg_testgood (
	.aclr (reset),
	.clock (clk),
	.data (tg_in),
	.enable (tg_load),
	.load (tg_load),
	.q (tg_q)
	);
	
register_1bit	reg_size_buf (
	.aclr (reset),
	.clock (clk),
	.data (buf_in),
	.enable (buf_load),
	.load (buf_load),
	.q (buf_size)
	);

wire[7:0] d1_data, d2_data;
	
register_8bits	delay_1st (
	.aclr (reset),
	.clock (clk),
	.data (data),
	.enable (1'b1),
	.load (1'b1),
	.q (d1_data)
	);
	
register_8bits	delay_2nd (
	.aclr (reset),
	.clock (clk),
	.data (d1_data),
	.enable (1'b1),
	.load (1'b1),
	.q (d2_data)
	);

wire cmp_l, cmp_s;
wire[7:0] xnor_l, xnor_s;

assign xnor_l = d2_data ^~ ref_l;
assign xnor_s = d2_data ^~ ref_s;


and(cmp_l, xnor_l[0], xnor_l[1], xnor_l[2], xnor_l[3], xnor_l[4], xnor_l[5], xnor_l[6], xnor_l[7]);
and(cmp_s, xnor_s[0], xnor_s[1], xnor_s[2], xnor_s[3], xnor_s[4], xnor_s[5], xnor_s[6], xnor_s[7]);
//
//delay2	delay2_inst (
//	.aclr (reset),
//	.clock (clk),
//	.shiftin (data),
//	.q (d_data)
//);

	
ref_small	ref_small_block (
	.aclr (reset),
	.address (cnt_read_q[7:0]),
	.clock (clk),
	.q (ref_s)
	);
ref_large	ref_large_block (
	.aclr (reset),
	.address (cnt_read_q[9:0]),
	.clock (clk),
	.q (ref_l)
	);

always@(posedge clk or posedge reset) begin
	if(reset==1'b1) state_reg <= IDLE;
	else state_reg <= next_state;
end

always@(*) begin
	case(state_reg)
		IDLE: if(start==1'b1) next_state <=LOAD_SIZE;
				else next_state <= IDLE;
		
		LOAD_SIZE: next_state <= WAIT_REG1;
		WAIT_REG1: next_state <= WAIT_REG2;
		WAIT_REG2: if(buf_size==1'b1) next_state <= READ_LARGE;
					  else next_state <= READ_SMALL;
		READ_LARGE: if(cnt_read_q==16'h0000) next_state <= WAIT_F1;
						else next_state <= READ_LARGE;
		READ_SMALL: if(cnt_read_q==16'h0000) next_state <= WAIT_F1;
						else next_state <= READ_SMALL;
		WAIT_F1:	next_state <= WAIT_F2;
		WAIT_F2: next_state <= IDLE;
		default:	next_state <= IDLE;
	endcase
end

always@(*) begin
test_end			<= 	1'b0;
tg_in 			<= 	1'b1;
tg_load			<= 	1'b0;
cnt_read_en		<=		1'b0;
cnt_read_in		<=		16'h0;
cnt_read_load	<=		1'b0;
buf_load 		<= 	1'b0;
buf_in 			<= 	1'b0;

	case(state_reg)
		IDLE: begin
			tg_in 	<= 1'b1;
			tg_load	<= 1'b1;
			cnt_read_in 	<= 16'd0;
			cnt_read_load	<= 1'b1;
		end
		LOAD_SIZE: begin
			if(size==1'b1) begin
				cnt_read_in 	<= 16'd0767;
				cnt_read_load	<= 1'b1;
				buf_in			<= 1'b1;
			end
			else begin
				cnt_read_in 	<= 16'd0131;
				cnt_read_load	<= 1'b1;
				buf_in			<= 1'b0;
			end
			buf_load 		<= 1'b1;
			cnt_read_en <= 1'b1;
		end
		WAIT_REG1: begin
			cnt_read_en <= 1'b1;
		end
		WAIT_REG2: begin
			cnt_read_en <= 1'b1;
		end
		READ_LARGE: begin
			tg_in <= tg_q & cmp_l;
			tg_load <= 1'b1;
			cnt_read_en <= 1'b1;
		end
		READ_SMALL: begin
			tg_in <= tg_q & cmp_s;
			tg_load <= 1'b1;
			cnt_read_en <= 1'b1;
		end
		WAIT_F1: begin
			if(buf_size==1'b1)
				tg_in <= tg_q & cmp_l;
			else
				tg_in <= tg_q & cmp_s;
			tg_load <= 1'b1;
		end
		WAIT_F2: begin
			if(buf_size==1'b1) 
				tg_in <= tg_q & cmp_l;
			else
				tg_in <= tg_q & cmp_s;
			tg_load <= 1'b1;
			test_end <= 1'b1;
		end
	endcase

end
endmodule

