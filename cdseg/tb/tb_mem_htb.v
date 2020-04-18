`timescale 1ns/1ps
module tb_mem_htb();
reg clk, reset, test_start;

wire filling, crc, start, size;
wire[7:0] data;
wire test_good, test_end;

mem_tb_cb_seg test_obj(
	.reset(reset),
	.clk(clk),
	.test_start(test_start),
	
	.test_good(test_good),
	.test_end(test_end),
	
	//Debug Port for logic analyzer
	.data(data),
	.size(size),
	.start(start),
	.crc(crc),
	.filling(filling)
);

//Clock Generator
initial clk=1'b0;
always #5 clk=~clk;

//Power-on Reset
initial
begin
		reset = 1'b1;
#20 	reset = 1'b0;
end


initial
begin	
#150 test_start = 1'b1;
#30 test_start = 1'b0;
end

endmodule