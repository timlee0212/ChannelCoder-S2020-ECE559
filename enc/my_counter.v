module my_counter(
	input clk, en, mode, clr,
	output switch, count_valid);

wire [12:0] out;
	
counter_enc count(
	.aclr(clr),
	.clock(clk),
	.cnt_en(en),
	.q(out));
	
//Constant is Serial: BLOCK_SIZE-1, Parallel: (BLOCK_SIZE / 8) - 1
// -1 because want the switch to close on the last cycle of actual data not first cycle of tail bits

//assign switch = (mode & (out == 6)) | (~mode & (out == 767));
assign switch = (~mode & (out == 131)) | (mode & (out == 767));
assign count_valid = (out > 4);

endmodule 
