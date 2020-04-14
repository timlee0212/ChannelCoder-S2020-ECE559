module tailBitsGenerator_parallel(
	input[7:0] xk_in, zk_in, zk_prime_in,
	input q0, q1, q2, q0_prime, q1_prime, q2_prime, 
	tail_bit_regs_enable, tail_bit_mode, clock, reset,
	output[7:0] xk_out, zk_out, zk_prime_out);
	
	reg[11:0] tail_bit_regs;
	
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
	
	wire[7:0] tail_to_mux_xk, tail_to_mux_zk, tail_to_mux_zk_prime;
	assign tail_to_mux_xk[0] = tail_bit_regs[0];
	assign tail_to_mux_xk[1] = tail_bit_regs[5];
	assign tail_to_mux_xk[2] = tail_bit_regs[2];
	assign tail_to_mux_xk[3] = tail_bit_regs[7];
	assign tail_to_mux_zk[0] = tail_bit_regs[1];
	assign tail_to_mux_zk[1] = tail_bit_regs[8];
	assign tail_to_mux_zk[2] = tail_bit_regs[3];
	assign tail_to_mux_zk[3] = tail_bit_regs[10];
	assign tail_to_mux_zk_prime[0] = tail_bit_regs[4];
	assign tail_to_mux_zk_prime[1] = tail_bit_regs[9];
	assign tail_to_mux_zk_prime[2] = tail_bit_regs[6];
	assign tail_to_mux_zk_prime[3] = tail_bit_regs[11];
	assign tail_to_mux_xk[7:4] = 4'b0;
	assign tail_to_mux_zk[7:4] = 4'b0;
	assign tail_to_mux_zk_prime[7:4] = 4'b0;
	
	assign xk_out = tail_bit_mode ? tail_to_mux_xk : xk_in;
	assign zk_out = tail_bit_mode ? tail_to_mux_zk : zk_in;
	assign zk_prime_out = tail_bit_mode ? tail_to_mux_zk_prime : zk_prime_in;
	
endmodule
