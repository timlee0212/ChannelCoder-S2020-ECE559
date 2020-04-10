module encoder_parallel(
	input[7:0] b,
	input clock, reset, en,
	output[7:0] zk, xk,
	output[2:0] q);

reg[2:0] dffs;

//Intermediate wires
wire a, c, d, e, f;
//Initial values of dffs
wire[2:0] q_in, q_out;

always @(posedge clock, posedge reset) begin
	if (reset) begin
		dffs <= 3'b0;
	end
	else begin
		if (en) begin
			dffs[2] <= q_out[2];
			dffs[1] <= q_out[1];
			dffs[0] <= q_out[0];
		end
	end
end

assign q_in = dffs;
assign q = dffs;

assign a = q_in[0] ^ q_in[1];
assign c = b[1] ^ b[2] ^ b[3];
assign d = b[2] ^ b[3] ^ b[4];
assign e = b[4] ^ b[5] ^ b[6];
assign f = q_in[2] ^ b[0] ^ b[1];

assign zk[0] = a ^ b[0];
assign zk[1] = a ^ f;
assign zk[2] = q_in[0] ^ f ^ b[2];
assign zk[3] = q_in[2] ^ b[0] ^ c;
assign zk[4] = q_in[1] ^ b[1] ^ d;
assign zk[5] = q_in[0] ^ d ^ b[5];
assign zk[6] = q_in[1] ^ q_in[2] ^ b[0] ^ b[3] ^ e;
assign zk[7] = a ^ b[1] ^ e ^ b[7];

assign q_out[0] = q_in[0] ^ d ^ b[6];
assign q_out[1] = q_in[1] ^ c ^ b[5];
assign q_out[2] = f ^ b[2] ^ b[4];

endmodule
