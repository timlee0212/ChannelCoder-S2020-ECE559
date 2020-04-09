module my_counter(
	input clk, en, mode, clr,
	output switch, count_valid);

wire [12:0] out;
	
counter_enc count(
	.aclr(clr),
	.clock(clk),
	.cnt_en(en),
	.q(out));
	
//Constant is BLOCK_SIZE-1
// -1 because want the switch to close on the last cycle of actual data not first cycle of tail bits

assign switch = (~mode & (out == 1055)) | (mode & (out == 6143));
assign count_valid = (out > 4);
//assign switch = (mode & (out == 63)) | (~mode & (out == 6143));
//assign switch = (mode & (out == 3)) | (~mode & (out == 7));

endmodule 
