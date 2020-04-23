module interleaver_fsm_new(clk,reset,block_size,next_state_w,state_w,CRC_start,CRC_END,ready,done,p1mode_w,p2mode_w,ctr1_re_w,ctr2_re_w,ctr1_en_w,ctr2_en_w,ram1_we_w,ram2_we_w,ctr1_finish,ctr2_finish,ctr1_blk,ctr2_blk);
		input clk, reset;
		input block_size;
		input CRC_start;
		input CRC_END; //CRC_END signal can be ignored, system will work if its always 0, leave it here just in case we need it in the future
		input ctr1_finish;
		input ctr2_finish;
		output[3:0] state_w,next_state_w;
		output p1mode_w,p2mode_w,ctr1_re_w,ctr2_re_w,ctr1_en_w,ctr2_en_w,ram1_we_w,ram2_we_w;
		output reg ctr1_blk,ctr2_blk;
		output ready;
		output done;
		


reg[3:0] next_state,current_state;
reg w_reset,r_reset,output_mux,write_enable;
reg p1mode,p2mode,ctr1_re,ctr2_re,ctr1_en,ctr2_en,ram1_we,ram2_we;
wire[15:0] ctr1_counter,ctr2_counter;
reg ready_r, done_r;
initial begin
	current_state = 4'b0000;
	ready_r = 1'b0;
	done_r = 1'b0;
	p1mode = 1'b0;
	p2mode = 1'b0;
	ctr1_re= 1'b0;
	ctr2_re= 1'b0;
	ctr1_en= 1'b0;
	ctr2_en= 1'b0;
	ram1_we=1'b0;
	ram2_we=1'b0;
	ctr1_blk=1'b0;
	ctr2_blk=1'b0;
end 
 
 always @(posedge clk or posedge reset) begin
	if(reset) begin
		current_state <= 4'b0000;
	
	end
	else begin
	if((current_state!=next_state)||(current_state == 4'b0000))begin
		ctr1_re <= 1'b1;
		ctr2_re <= 1'b1;
	end
	else begin
		ctr1_re <= 1'b0;
		ctr2_re <= 1'b0;
	end
	current_state <= next_state;
		
	end
end

always @(current_state,CRC_start,block_size,ctr1_finish,ctr2_finish,CRC_END) begin
	case(current_state)
		4'b0000: begin
			p1mode = 1'b0;
			p2mode = 1'b0;
			ctr1_en= 1'b0;
			ctr2_en= 1'b0;
			ram1_we=1'b0;
			ram2_we=1'b0;
			ctr1_blk=1'b0;
			ctr2_blk=1'b0;
			//ctr1_re <= 1'b1;
			//ctr2_re <= 1'b1;
			ready_r=1'b0;
			done_r = 1'b0;
			if(CRC_start)begin
				next_state<=4'b1001;
			end
			else begin
				next_state <= 4'b0000;
			end
		end
		4'b1001: begin //without thisone, large blk is working 
			p1mode = 1'b0;
			p2mode = 1'b0;
			ctr1_en= 1'b0;
			ctr2_en= 1'b0;
			ram1_we=1'b0;
			ram2_we=1'b0;
			ctr1_blk=1'b0;
			ctr2_blk=1'b0;
			//wait for something .... go back to 0000
			next_state<=4'b0001;
			ready_r=1'b0;
			done_r = 1'b0;
		end
		4'b0001: begin
			p1mode = 1'b0;
			p2mode = 1'b0;
			ctr1_en= 1'b1;
			ctr2_en= 1'b0;
			ram1_we=1'b1;
			ram2_we=1'b0;
			ctr1_blk=1'b0;
			ctr2_blk=1'b0;
			ready_r=1'b0;
			done_r = 1'b0;
			if(CRC_END & ctr1_finish) begin
				next_state<=4'b0111;
			end
			else begin
				if(ctr1_finish & block_size) begin
					next_state<=4'b0010;
				end
				else begin
					next_state<=4'b0001;
				end
			end
		end
		4'b0010: begin
			p1mode = 1'b1;
			p2mode = 1'b0;
			ctr1_en= 1'b1;
			ctr2_en= 1'b1;
			ram1_we=1'b0;
			ram2_we=1'b1;
			ctr1_blk=1'b0;
			ctr2_blk=1'b1;
			ready_r=1'b1;
			done_r = 1'b0;
			if(ctr1_finish)begin
				ready_r = 1'b0;
			end
			else begin	
				ready_r=1'b1;
			end
			if(CRC_END &ctr2_finish)begin
				next_state<=4'b1011;
				//ctr1_re <=1'b1;
				//ctr2_re <=1'b1;
			end
			else begin
				if(ctr2_finish & block_size) begin
					next_state<=4'b0011;
				end
				else begin
					next_state <=4'b0010;
				end
			
			end
		end
		
		4'b1011: begin
			p1mode = 1'b0;
			p2mode = 1'b0;
			ctr1_en= 1'b0;
			ctr2_en= 1'b0;
			ram1_we=1'b0;
			ram2_we=1'b0;
			ctr1_blk=1'b0;
			ctr2_blk=1'b0;
			//wait for something .... go back to 0000
			next_state<=4'b0101;
			ready_r=1'b0;
			done_r = 1'b0;
		end
		
		4'b0011: begin
			p1mode = 1'b0;
			p2mode = 1'b1;
			ctr1_en= 1'b1;
			ctr2_en= 1'b1;
			ram1_we=1'b1;
			ram2_we=1'b0;
			ctr1_blk=1'b1;
			ctr2_blk=1'b1;
			ready_r=1'b1;
			done_r = 1'b0;
			if(CRC_END && ctr2_finish)begin
				next_state<=4'b0110;
			end
			else begin
				if(ctr2_finish & block_size) begin
					next_state<=4'b0100;
				end
				else begin
					next_state <=4'b0011;
				end
			end
		end
		4'b0100: begin
			p1mode = 1'b1;
			p2mode = 1'b0;
			ctr1_en= 1'b1;
			ctr2_en= 1'b1;
			ram1_we=1'b0;
			ram2_we=1'b1;
			ctr1_blk=1'b1;
			ctr2_blk=1'b1;
			ready_r=1'b1;
			done_r = 1'b0;
			if(CRC_END && ctr2_finish)begin
				next_state<=4'b0101;
			end
			else begin
				if(ctr2_finish & block_size) begin
					next_state<=4'b0011;
				end
				else begin
					next_state <=4'b0100;
				end
			
			end
		end
		4'b0101: begin
			p1mode = 1'b0;
			p2mode = 1'b1;
			ctr1_en= 1'b0;
			ctr2_en= 1'b1;
			ram1_we=1'b0;
			ram2_we=1'b0;
			ctr1_blk=1'b0;
			ctr2_blk=1'b1;
			ready_r=1'b1;
			done_r = 1'b0;
			if(ctr2_finish)begin
				next_state <=4'b1000;
				ready_r=1'b0;
			end
			else begin
				next_state<=4'b0101;
			end
		end
		4'b0110: begin
			p1mode = 1'b1;
			p2mode = 1'b0;
			ctr1_en= 1'b1;
			ctr2_en= 1'b0;
			ram1_we=1'b0;
			ram2_we=1'b0;
			ctr1_blk=1'b1;
			ctr2_blk=1'b0;
			ready_r=1'b1;
			done_r = 1'b0;
			if(ctr2_finish)begin
				next_state <=4'b1000;
				ready_r=1'b0;
			end
			else begin
				next_state<=4'b0110;
			end
		end
		4'b0111: begin
			p1mode = 1'b1;
			p2mode = 1'b0;
			ctr1_en= 1'b1;
			ctr2_en= 1'b0;
			ram1_we=1'b0;
			ram2_we=1'b0;
			ctr1_blk=1'b0;
			ctr2_blk=1'b0;
			ready_r=1'b1;
			done_r = 1'b0;
			if(ctr1_finish)begin
				next_state <=4'b1000;
				ready_r=1'b0;
			end
			else begin
				next_state<=4'b0111;
			end
		end
		4'b1000: begin
			p1mode = 1'b0;
			p2mode = 1'b0;
			ctr1_en= 1'b0;
			ctr2_en= 1'b0;
			ram1_we=1'b0;
			ram2_we=1'b0;
			ctr1_blk=1'b0;
			ctr2_blk=1'b0;
			//wait for something .... go back to 0000
			next_state<=4'b1010;
			ready_r=1'b0;
			done_r = 1'b1;
		end
		4'b1010: begin
			p1mode = 1'b0;
			p2mode = 1'b0;
			ctr1_en= 1'b0;
			ctr2_en= 1'b0;
			ram1_we=1'b0;
			ram2_we=1'b0;
			ctr1_blk=1'b0;
			ctr2_blk=1'b0;
			//wait for something .... go back to 0000
			next_state<=4'b0000;
			ready_r=1'b0;
			done_r = 1'b1;
		end
		
	endcase
end
assign done = done_r;
assign ready = ready_r;
assign p1mode_w = p1mode;
assign p2mode_w = p2mode;
assign ctr1_re_w = ctr1_re;
assign ctr2_re_w = ctr2_re;
assign ctr1_en_w = ctr1_en;
assign ctr2_en_w = ctr2_en;
dff data_delay2 (ram1_we, clk, ~reset, 1'b1, ram1_we_w);
//assign ram1_we_w = ram1_we;
assign ram2_we_w = ram2_we;
assign state_w = current_state;
assign next_state_w = next_state;
endmodule