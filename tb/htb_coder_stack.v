 module mem_tb_coder_stack(
	input wire reset,
	input wire clk,
	input wire test_start,
	
	output wire test_good,
	output wire test_end,
	
	//Debug Port for logic analyzer
	output wire[7:0] xk_out,
	output wire[7:0] zk_out,
	output wire[7:0] zk_p_out,
	output wire out_valid			//For the trigger
);
wire[7:0] in_xk, in_zk, in_zk_p;
wire[7:0] data_in;
wire wreq_data, wreq_size;
wire[11:0] size_in;

wire valid;

assign out_valid = valid;

assign xk_out = in_xk;
assign zk_out = in_zk;
assign zk_p_out = in_zk_p;

coder_stack_top test_obj(
    .clk(clk),
    .reset(reset),
    .tb_in(data_in),
    .wreq_data(wreq_data),        //Write Request of the Input TB buffer
    .tb_size_in(size_in),  
    .wreq_size(wreq_size),

	 .xk_out(in_xk), 
	 .zk_out(in_zk), 
	 .zk_prime_out(in_zk_p), 
	 .out_valid(valid)
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
	.valid(valid),
	//.start(in_start),
	.xk(in_xk),
	.zk(in_zk),
	.zk_p(in_zk_p),
	//.size(in_size),
	
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
	output reg[11:0] size
);

//FSM State Encoding
//Following the Quartus Encoding Scheme
parameter IDLE			=	6'b000000,
			 WRITE_SIZE	=	6'b000011,
			 WAIT_MEM	=	6'b000101,	//ROM Has 2 cycles delay. Add a extra state for that delay
			 WRITE_DATA	=	6'b001001,
			 WRITE_FIN1	=	6'b010001,
			 WRITE_FIN2	= 	6'b100001;

reg[9:0] cnt_write_in;
reg cnt_write_en, cnt_write_load;
reg[5:0] state_reg, next_state;

wire[9:0] cnt_write_q;

counter_10bits	cnt_write (
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
		WRITE_DATA: if(cnt_write_q==10'h000) next_state <= WRITE_FIN1;
						else next_state <= WRITE_DATA;
		WRITE_FIN1: next_state <= WRITE_FIN2;
		WRITE_FIN2: next_state <= IDLE;
		default:	next_state <= IDLE;
	endcase
end

always@(*) begin
wreq_size 		=		1'b0;
wreq_data 		= 	1'b0;
size				=		10'h0;
cnt_write_en	=		1'b0;
cnt_write_in	=		10'h0;
cnt_write_load	=		1'b0;

	case(state_reg)
		IDLE: begin
			cnt_write_in  	= 10'd877;
			cnt_write_load =1'b1;		
		end
		WRITE_SIZE: begin 
			size				= 12'd878;
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
	input wire valid,
	input wire[7:0] xk,
	input wire[7:0] zk,
	input wire[7:0] zk_p,
	
	output wire test_good,
	output reg test_end
);

parameter IDLE 		= 7'b0000000,
			 LOAD_SIZE	= 7'b0000011,
			 WAIT_REG1	= 7'b0000101,
			 WAIT_REG2	= 7'b0001001,
			 READ_LARGE	= 7'b0010001,
			 //READ_SMALL	= 8'b00100001,
			 WAIT_F1		= 7'b0100001,
			 WAIT_F2		= 7'b1000001;

reg[9:0] cnt_read_in;
reg cnt_read_en, cnt_read_load;
reg[6:0] state_reg, next_state;

wire[9:0] cnt_read_q;

wire[23:0] ref_s, ref_l;

reg buf_load, buf_in;


reg tg_load, tg_in, sw_load, sw_in;
wire tg_q, buf_size, sw_q;

wire[23:0] d_xk, d_zk, d_zk_p;

assign test_good = tg_q;

counter_10bits	cnt_read(
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
	
register_1bit	reg_switch (
	.aclr (reset),
	.clock (clk),
	.data (sw_in),
	.enable (sw_load),
	.load (sw_load),
	.q (sw_q)
	);
	

//3 Cycles Delay since the valid signal is presented at the same time with output
delay3	delay3_xk (
	.aclr (reset),
	.clock (clk),
	.data ({xk, d_xk[23:8]}),
	.q (d_xk),
	.load(1'b1)
);

delay3	delay3_zk (
	.aclr (reset),
	.clock (clk),
	.data({zk, d_zk[23:8]}),
	.q (d_zk),
	.load(1'b1)
);

delay3	delay3_zk_p (
	.aclr (reset),
	.clock (clk),
	.data ({zk_p, d_zk_p[23:8]}),
	.q (d_zk_p),
	.load(1'b1)
);

	
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
	
//Avoid Redundant Logic Description
wire correct_s;
wire[7:0] cr_s_xk, cr_s_zk, cr_s_zk_p;
wire acr_s_xk, acr_s_zk, acr_s_zk_p;

assign cr_s_xk = ref_s[23:16] ^~ d_xk[7:0];
assign cr_s_zk = ref_s[15:8] ^~ d_zk[7:0];
assign cr_s_zk_p = ref_s[7:0] ^~ d_zk_p[7:0];

and(acr_s_xk, cr_s_xk[0], cr_s_xk[1], cr_s_xk[2], cr_s_xk[3], cr_s_xk[4], cr_s_xk[5], cr_s_xk[6], cr_s_xk[7]);
and(acr_s_zk, cr_s_zk[0], cr_s_zk[1], cr_s_zk[2], cr_s_zk[3], cr_s_zk[4], cr_s_zk[5], cr_s_zk[6], cr_s_zk[7]);
and(acr_s_zk_p, cr_s_zk_p[0], cr_s_zk_p[1], cr_s_zk_p[2], cr_s_zk_p[3], cr_s_zk_p[4], cr_s_zk_p[5], cr_s_zk_p[6], cr_s_zk_p[7]);
and(correct_s, acr_s_xk, acr_s_zk, acr_s_zk_p);

//Avoid Redundant Logic Description
wire correct_l;
wire[7:0] cr_l_xk, cr_l_zk, cr_l_zk_p;
wire acr_l_xk, acr_l_zk, acr_l_zk_p;

assign cr_l_xk = ref_l[23:16] ^~ d_xk[7:0];
assign cr_l_zk = ref_l[15:8] ^~ d_zk[7:0];
assign cr_l_zk_p = ref_l[7:0] ^~ d_zk_p[7:0];

and(acr_l_xk, cr_l_xk[0], cr_l_xk[1], cr_l_xk[2], cr_l_xk[3], cr_l_xk[4], cr_l_xk[5], cr_l_xk[6], cr_l_xk[7]);
and(acr_l_zk, cr_l_zk[0], cr_l_zk[1], cr_l_zk[2], cr_l_zk[3], cr_l_zk[4], cr_l_zk[5], cr_l_zk[6], cr_l_zk[7]);
and(acr_l_zk_p, cr_l_zk_p[0], cr_l_zk_p[1], cr_l_zk_p[2], cr_l_zk_p[3], cr_l_zk_p[4], cr_l_zk_p[5], cr_l_zk_p[6], cr_l_zk_p[7]);
and(correct_l, acr_l_xk, acr_l_zk, acr_l_zk_p);



always@(posedge clk or posedge reset) begin
	if(reset==1'b1) state_reg <= IDLE;
	else state_reg <= next_state;
end

always@(*) begin
	case(state_reg)
		IDLE: if(valid==1'b1) next_state <=WAIT_REG1;
				else next_state <= IDLE;
		
		LOAD_SIZE: next_state <= WAIT_REG1;
		WAIT_REG1: next_state <= WAIT_REG2;
		WAIT_REG2: next_state <= READ_LARGE;
		READ_LARGE: if(cnt_read_q==10'h0000) next_state <= WAIT_F1;
						else next_state <= READ_LARGE;
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
cnt_read_in		<=		10'h0;
cnt_read_load	<=		1'b0;
sw_in				<= 	1'b0;
sw_load			<= 	1'b0;

	case(state_reg)
		IDLE: begin
			tg_in 	<= 1'b1;
			tg_load	<= 1'b1;
			cnt_read_in 	<= (sw_q ? 10'd 768 : 10'd132);
			cnt_read_load	<= 1'b1;
			cnt_read_en <= 1'b0;
		end
		WAIT_REG1: begin
			cnt_read_en <= 1'b1;
		end
		WAIT_REG2: begin
			cnt_read_en <= 1'b1;
		end
		READ_LARGE: begin
			tg_in <= tg_q & (sw_q ? correct_l : correct_s);
			tg_load <= 1'b1;
			cnt_read_en <= 1'b1;
		end
		WAIT_F1: begin
			tg_in <= tg_q & (sw_q ? correct_l : correct_s);
			tg_load <= 1'b1;
		end
		WAIT_F2: begin
			tg_in <= tg_q & (sw_q ? correct_l : correct_s);
			tg_load <= 1'b1;
			test_end <= 1'b1;
			sw_in <= ~sw_q;
			sw_load <= 1'b1;
		end
	endcase

end
endmodule

