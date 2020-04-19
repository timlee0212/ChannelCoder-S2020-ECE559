module data_fsm(
    input wire clk,
    input wire reset,

	input wire empty_data_fifo,
	input wire empty_size_fifo,

	input wire[19:0] size,

	output reg mux_fill,
	output reg mux_crc,

	output reg init_crc,
	output reg ena_crc,
	output reg nshift_crc,

	output reg read_data_fifo,
	output reg read_size_fifo,
	
	output reg wreq_itl_fifo,
	output reg wreq_enc_fifo,

	output reg block_size,

	output reg start,
	output reg filling,
	//output reg stop,
	output reg crc
);

//FSM State Encoding
//Following the Quartus Encoding Scheme
parameter IDLE			=	9'b000000000,
			 READ_REQ	=	9'b000000011,
			 READ_SIZE	=	9'b000000101,
			 LOAD_SIZE	=	9'b000001001,
			 SEND_SIZE	=  9'b000010001,
			 FILLING		=	9'b000100001,
			 READ_DATA	=	9'b001000001,
			 OUT_CRC		=	9'b010000001,
			 NEXT_BLOCK	=	9'b100000001;
			 

reg[8:0] state_reg, next_state;

reg[15:0] cnt_fl_in, cnt_cb_in;
wire[15:0] cnt_fl_q, cnt_cb_q;

reg cnt_fl_en, cnt_fl_load, cnt_cb_en, cnt_cb_load;

reg req_crc_in, req_crc_load, req_crc_en;
wire req_crc_q;

reg cm_load, cm_en, cp_load, cp_en;
reg[1:0] cm_in, cp_in;
wire[1:0] cm_q, cp_q;

//Instination IPs
counter_16bits	cnt_fill (
	.aclr ( reset),
	.clock ( clk ),
	.cnt_en ( cnt_fl_en ),
	.data ( cnt_fl_in ),
	.sload ( cnt_fl_load ),
	.q ( cnt_fl_q )
	);
	
counter_16bits	cnt_cb (
	.aclr ( reset),
	.clock ( clk ),
	.cnt_en ( cnt_cb_en ),
	.data ( cnt_cb_in ),
	.sload ( cnt_cb_load ),
	.q ( cnt_cb_q )
	);
	
register_1bit	req_crc (
	.aclr (reset),
	.clock (clk),
	.data (req_crc_in),
	.enable (req_crc_en),
	.load ( req_crc_load),
	.q (req_crc_q)
	);

register_2bits	cm (
	.aclr (reset),
	.clock (clk),
	.data (cm_in),
	.enable (cm_en),
	.load ( cm_load),
	.q (cm_q)
	);

register_2bits	cp (
	.aclr (reset),
	.clock (clk),
	.data (cp_in),
	.enable (cp_en),
	.load (cp_load),
	.q (cp_q)
	);

//Update State Register
always@(posedge clk or posedge reset) begin
	if (reset==1) state_reg <= IDLE; 
	else state_reg <= next_state;
end

//Next State Logic
always@(*) begin
	case(state_reg)
		IDLE:			if(empty_size_fifo==0) next_state <= READ_REQ;
						else next_state <= IDLE;
		READ_REQ:	next_state <= READ_SIZE;
						
		READ_SIZE:	next_state <= LOAD_SIZE;
		
		LOAD_SIZE:	next_state <= SEND_SIZE;
		
		SEND_SIZE:	if(cnt_fl_q == 16'h0000) next_state <= READ_DATA;
						else next_state <= FILLING;
						
		FILLING:		if(cnt_fl_q == 16'h0000) next_state <= READ_DATA;
						else next_state <= FILLING;
		
		READ_DATA:	if(req_crc_q==0 && cnt_cb_q==16'h0002) next_state <= NEXT_BLOCK;
						else if(req_crc_q==1 && cnt_cb_q == 16'h0019)	next_state <= OUT_CRC;
						else next_state <= READ_DATA;
		
		OUT_CRC:		if(cnt_cb_q == 16'h0002) next_state <= NEXT_BLOCK;
						else next_state <= OUT_CRC;
		
		NEXT_BLOCK:	if(cm_q == 2'b00 && cp_q == 2'b00) next_state <= IDLE;
						else next_state <= LOAD_SIZE;
		
		//For Robustness
		default:		next_state <= IDLE;
	endcase
end


//Moore&Mealy Output
always@(*) begin
				//Default Value, Avoid Latch
	mux_fill 	<= 	1'b1;			//Output Data By Default
	mux_crc 		<=		1'b0;			//Output Data By Default
	init_crc		<=		1'b0;
	ena_crc		<=		1'b0;
	nshift_crc 	<= 	1'b1;
	read_data_fifo <=	1'b0;
	read_size_fifo <= 1'b0;
	block_size	<=		1'b0;
	
	start			<= 	1'b0;
	filling		<= 	1'b0;
	//stop			<=		1'b0;
	crc			<=		1'b0;
	
	cnt_fl_in	<= 	16'h0000;
	cnt_cb_in	<=		16'h0000;
	cnt_fl_en	<=		1'b0;
	cnt_fl_load	<=		1'b0;
	cnt_cb_en	<=		1'b0;
	cnt_cb_load <=		1'b0;
	
	req_crc_in	<=		1'b0;
	req_crc_load<=		1'b0;
	req_crc_en	<=		1'b0;
	
	wreq_itl_fifo <= 	1'b1;
	wreq_enc_fifo <= 	1'b1;

	cm_in			<=		2'b00;
	cm_load		<=		1'b0;
	cm_en			<=		1'b0;
	cp_in			<=		2'b00;
	cp_load		<=		1'b0;
	cp_en			<=		1'b0;
	case(state_reg)
		IDLE:	begin
						init_crc <= 1'b1;
						ena_crc	<= 1'b1;
						req_crc_in	<=	1'b1;
						req_crc_load<=	1'b1;
						req_crc_en	<=	1'b1;
						wreq_itl_fifo <= 	1'b0;
						wreq_enc_fifo <= 	1'b0;
				end
						
		READ_REQ:	begin
						read_size_fifo <= 1'b1;
						wreq_itl_fifo <= 	1'b0;
						wreq_enc_fifo <= 	1'b0;
				end
		
		READ_SIZE:begin
						cm_in		<= size[17:16];
						cm_load 	<=	1'b1;
						cm_en		<=	1'b1;
		
						cp_in 	<= size[19:18];
						cp_load 	<=	1'b1;
						cp_en		<=	1'b1;
						
						cnt_fl_in<= size[15:0];
						cnt_fl_load<=		1'b1;
						
						if ((size[19:18]==2'b00 && size[17:16]== 2'b01) ||
							(size[19:18]==2'b01 && size[17:16]== 2'b00)) begin
							req_crc_in <= 1'b0;
							req_crc_en <= 1'b1;
							req_crc_load <= 1'b1;
						end
						
						wreq_itl_fifo <= 	1'b0;
						wreq_enc_fifo <= 	1'b0;
					end
		
		LOAD_SIZE:begin						
						
						//Decide According Number of Blocks
						if (cp_q == 2'b10 && cm_q == 2'b00) begin
							cp_in 	<= 2'b01;
							cp_load 	<=	1'b1;
							cp_en		<=	1'b1;
							
							cnt_cb_in 	<= 16'h1800;	//6144 bits
							cnt_cb_load	<=	1'b1;
						end
						else if(cp_q == 2'b01 && cm_q == 2'b00) begin
							cp_in 	<= 2'b00;
							cp_load 	<=	1'b1;
							cp_en		<=	1'b1;
							
							cnt_cb_in <= 16'h1800;	//6144 bits
							cnt_cb_load	<=	1'b1;
							
						end
						else if(cm_q == 2'b01) begin
							cm_in 	<= 2'b00;
							cm_load 	<=	1'b1;
							cm_en		<=	1'b1;
							
							cnt_cb_in <= 16'h0420;	//1056 bits
							cnt_cb_load	<=	1'b1;
						end
						start 	<= 1'b1;

					end
					
		SEND_SIZE: begin
						if(cnt_fl_q == 16'h0000) begin 
							read_data_fifo <=	1'b1;		//Pre-assert read request
						end
						else	begin 
							cnt_fl_en		<= 1'b1;
						end
						
						if(cnt_cb_q == 16'h1800)
							block_size <= 1'b1;
						else
							block_size <= 1'b0;
						
						cnt_cb_en<= 1'b1;
						nshift_crc <= 1'b1;
					end
						
		FILLING:	begin
						mux_fill <= 1'b0;
						mux_crc	<=	1'b0;
						filling 	<=	1'b1;
						ena_crc 	<= 1'b1;
						nshift_crc <= 1'b1;
						cnt_cb_en		<= 1'b1;
						if(cnt_fl_q == 16'h0000) 
						begin
							cnt_fl_en<= 1'b0;		//Aoid Underflow
							read_data_fifo <=	1'b1;		//Pre-assert read request
						end
						else cnt_fl_en<= 1'b1;
					end
		
		READ_DATA:begin
						mux_fill <= 1'b1;
						mux_crc	<=	1'b0;
						init_crc <= 1'b0;
						ena_crc 	<= 1'b1;
						nshift_crc <= 1'b1;
						cnt_cb_en	<=	1'b1;
						if((req_crc_q==0 && cnt_cb_q==16'h0001) 
							|| (req_crc_q==1 && cnt_cb_q == 16'h0019))
							read_data_fifo <=	1'b0;	
						else
							read_data_fifo <=	1'b1;
							
						//if(req_crc_q==1 && cnt_cb_q == 16'h0019) nshift_crc <= 1'b0;
					end
		
		OUT_CRC:	begin
						mux_fill <= 1'b1;
						mux_crc	<=	1'b1;
						init_crc <= 1'b0;
						ena_crc 	<= 1'b1;
						nshift_crc <= 1'b0;
						cnt_cb_en	<=	1'b1;
						crc		<= 1'b1;
					end
		
		NEXT_BLOCK:	begin
				if(req_crc_q==1) begin 
					mux_crc <= 1'b1;
					crc <= 1'b1; //For the last bit of CRC
				end
				//stop <= 1'b1;
				init_crc <= 1'b1;
				ena_crc 	<= 1'b1;
				end
	endcase
end

endmodule