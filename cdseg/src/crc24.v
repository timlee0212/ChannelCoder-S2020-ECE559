module crc24(
    input wire clk,
    input wire reset,
    input wire init,
    input wire en_com,
    input wire[7:0] d_in,

    //input wire nen_shift,

    output wire[23:0] crc_out
);

reg[23:0] state_next;
wire[23:0] state_reg;

shiftreg	shiftreg_inst (
	.aclr ( reset ),
	.clock ( clk ),
	.data ( state_next ),
	.enable (en_com ),
	.load (en_com),
	.sset (init),
	.q (state_reg)
	);

always@(state_reg, d_in)
begin
		state_next[  0] = state_reg[ 16] ^ state_reg[ 17] ^ state_reg[ 18] ^ state_reg[ 19] ^ state_reg[ 20] ^ state_reg[ 21] ^ state_reg[ 22] ^ state_reg[ 23] ^ d_in[  0] ^ d_in[  1] ^ d_in[  2] ^ d_in[  3] ^ d_in[  4] ^ d_in[  5] ^ d_in[  6] ^ d_in[  7];
		state_next[  1] = state_reg[ 16] ^ d_in[  7];
		state_next[  2] = state_reg[ 17] ^ d_in[  6];
		state_next[  3] = state_reg[ 18] ^ d_in[  5];
		state_next[  4] = state_reg[ 19] ^ d_in[  4];
		state_next[  5] = state_reg[ 16] ^ state_reg[ 17] ^ state_reg[ 18] ^ state_reg[ 19] ^ state_reg[ 21] ^ state_reg[ 22] ^ state_reg[ 23] ^ d_in[  0] ^ d_in[  1] ^ d_in[  2] ^ d_in[  4] ^ d_in[  5] ^ d_in[  6] ^ d_in[  7];
		state_next[  6] = state_reg[ 16] ^ state_reg[ 21] ^ d_in[  2] ^ d_in[  7];
		state_next[  7] = state_reg[ 17] ^ state_reg[ 22] ^ d_in[  1] ^ d_in[  6];
		state_next[  8] = state_reg[  0] ^ state_reg[ 18] ^ state_reg[ 23] ^ d_in[  0] ^ d_in[  5];
		state_next[  9] = state_reg[  1] ^ state_reg[ 19] ^ d_in[  4];
		state_next[ 10] = state_reg[  2] ^ state_reg[ 20] ^ d_in[  3];
		state_next[ 11] = state_reg[  3] ^ state_reg[ 21] ^ d_in[  2];
		state_next[ 12] = state_reg[  4] ^ state_reg[ 22] ^ d_in[  1];
		state_next[ 13] = state_reg[  5] ^ state_reg[ 23] ^ d_in[  0];
		state_next[ 14] = state_reg[  6];
		state_next[ 15] = state_reg[  7];
		state_next[ 16] = state_reg[  8];
		state_next[ 17] = state_reg[  9];
		state_next[ 18] = state_reg[ 10];
		state_next[ 19] = state_reg[ 11];
		state_next[ 20] = state_reg[ 12];
		state_next[ 21] = state_reg[ 13];
		state_next[ 22] = state_reg[ 14];
		state_next[ 23] = state_reg[ 15] ^ state_reg[ 16] ^ state_reg[ 17] ^ state_reg[ 18] ^ state_reg[ 19] ^ state_reg[ 20] ^ state_reg[ 21] ^ state_reg[ 22] ^ state_reg[ 23]
					^ d_in[  0] ^ d_in[  1] ^ d_in[  2] ^ d_in[  3] ^ d_in[  4] ^ d_in[  5] ^ d_in[  6] ^ d_in[  7];

end

assign crc_out = state_reg;

endmodule