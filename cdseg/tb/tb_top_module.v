`timescale 1ns/1ps
module tb_cb_seg();
reg clk, reset, tb_in, wreq_tb, wreq_size;

reg[15:0] tb_size_in;

wire filling, crc, start, stop, cb_size, cb_data;

cb_seg test_obj(
    .clk(clk),
    .reset(reset),
    .tb_in(tb_in),
    .wreq_data(wreq_tb),
    .tb_size_in(tb_size_in),  
    .wreq_size(wreq_size),

    .filling(filling),
    .crc(crc),
    .start(start),
    .stop(stop),
    .cb_size(cb_size),
    .cb_data(cb_data) 
);

integer length;

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
	wreq_size = 1'b0;
	wreq_tb = 1'b0;
	tb_size_in = 16'h0;
	tb_in = 1'b0;
	length = $random % 12240;
end

initial
begin
#50	wreq_size = 1'b1;
		tb_size_in = length;
#15	wreq_size = 1'b0;
#15	wreq_tb = 1'b1;


//Input Block Data
//#10 tb_in = 1‘b0;
//#10 tb_in = 1‘b0;
//#10 tb_in = 1‘b0;
//#10 tb_in = 1‘b0;
//#10 tb_in = 1‘b0;

repeat(length) #10 tb_in = $random;
end



endmodule