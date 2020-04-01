module tailBitsGenerator(
	input q0, q1, q2, q0_prime, q1_prime, q2_prime, xk_in, zk_in, zk_prime_in,
	tail_bit_regs_enable, tail_bit_mode, tail_counter_enable, clock, reset,
	output xk_out, zk_out, zk_prime_out, tail_bit_done);
	
	reg[11:0] tail_bit_regs;
	wire[2:0] tail_bit_mux_out, data_from_encoder, output_mux_out;
	wire[2:0] tail_bit_mux_in_0, tail_bit_mux_in_1, tail_bit_mux_in_2, tail_bit_mux_in_3;
	wire[1:0] tail_bit_mux_select;

	//Tail bit generation logic
	always @(posedge clock, posedge reset) begin
		if (reset) begin
			tail_bit_regs <= 12'b0;
		end
		else if (tail_bit_regs_enable) begin
			tail_bit_regs[0] <= q1 ^ q2; //xk
			tail_bit_regs[1] <= q0 ^ q2; //zk
			tail_bit_regs[2] <= q1_prime ^ q2_prime; //xk_prime
			tail_bit_regs[3] <= q0_prime ^ q2_prime; //zk_prime
			tail_bit_regs[4] <= q0 ^ q1; //xk+1
			tail_bit_regs[5] <= q1; //zk+1
			tail_bit_regs[6] <= q0_prime ^ q1_prime; //xk+1_prime
			tail_bit_regs[7] <= q1_prime; //zk+1_prime
			tail_bit_regs[8] <= q0; //xk+2
			tail_bit_regs[9] <= q0; //zk+2
			tail_bit_regs[10] <= q0_prime; //xk+2_prime
			tail_bit_regs[11] <= q0_prime; //zk+2_prime
		end
	end
	
	//Tail bit selection
	assign tail_bit_mux_in_0[0] = tail_bit_regs[0];
	assign tail_bit_mux_in_0[1] = tail_bit_regs[1];
	assign tail_bit_mux_in_0[2] = tail_bit_regs[4];
	assign tail_bit_mux_in_1[0] = tail_bit_regs[5];
	assign tail_bit_mux_in_1[1] = tail_bit_regs[8];
	assign tail_bit_mux_in_1[2] = tail_bit_regs[9];
	assign tail_bit_mux_in_2[0] = tail_bit_regs[2];
	assign tail_bit_mux_in_2[1] = tail_bit_regs[3];
	assign tail_bit_mux_in_2[2] = tail_bit_regs[6];
	assign tail_bit_mux_in_3[0] = tail_bit_regs[7];
	assign tail_bit_mux_in_3[1] = tail_bit_regs[10];
	assign tail_bit_mux_in_3[2] = tail_bit_regs[11];
	
	counter4 counter(reset, clock, tail_counter_enable, tail_bit_mux_select);
	
	//Compare to 2, not 3 because of extra open_switch state
	compare_2bit comparator(tail_bit_mux_select, 2'b10, tail_bit_done);
	
	mux_4to1_3wide tail_bit_mux(
		tail_bit_mux_in_0, tail_bit_mux_in_1, tail_bit_mux_in_2, tail_bit_mux_in_3,
		tail_bit_mux_select, tail_bit_mux_out);	
	
	//Output bit selection
	assign data_from_encoder[0] = xk_in;
	assign data_from_encoder[1] = zk_in;
	assign data_from_encoder[2] = zk_prime_in;
	
	mux_2to1_3wide output_mux(data_from_encoder, tail_bit_mux_out, tail_bit_mode, output_mux_out);
	
	assign xk_out = output_mux_out[0];
	assign zk_out = output_mux_out[1];
	assign zk_prime_out = output_mux_out[2];
endmodule
	
	
	