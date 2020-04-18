module fake_interleaver(
	input clk, reset, cbs_ready, 
	output data_ready, 
	output [7:0] data_out);
	
reg [20:0] counter = 0;
reg data_ready_reg = 0;
reg cbs_ready_latch = 0;
reg [7:0] data_out_reg = 0;
integer bit_counter = 0;

always @(posedge clk) begin
	if (reset) begin
		cbs_ready_latch <= 0;
	end
	else if (cbs_ready) begin
		cbs_ready_latch <= 1;
	end
end

always @(posedge clk) begin
	if (reset) begin
		counter <= 0;
	end
	else if (cbs_ready_latch) begin
		counter <= counter + 1;
	end
end

always @(posedge clk) begin
	if (reset) begin
		data_ready_reg <= 0;
	end
	else if (counter > 10) begin
		data_ready_reg <= 1;
	end
end

always @(posedge clk) begin
	if (reset) begin
		data_out_reg <= 0;
		bit_counter <= 0;
	end
	else begin
		if (data_ready) begin
			if (bit_counter==0) begin
				data_out_reg = 8'b01001100;
			end
			if (bit_counter==8) begin
				data_out_reg = 8'b10011000;
			end
			if (bit_counter==16) begin
				data_out_reg = 8'b00110000;
			end
			if (bit_counter==24) begin
				data_out_reg = 8'b01100000;
			end
			if (bit_counter==32) begin
				data_out_reg = 8'b11000001;
			end
			if (bit_counter==40) begin
				data_out_reg = 8'b10000011;
			end
			if (bit_counter==48) begin
				data_out_reg = 8'b00000110;
			end
			if (bit_counter==56) begin
				data_out_reg = 8'b00001101;
			end
			if (bit_counter==64) begin
				data_out_reg = 8'b00011011;
			end
			if (bit_counter==72) begin
				data_out_reg = 8'b00110111;
			end
			if (bit_counter==80) begin
				data_out_reg = 8'b01101111;
			end
			if (bit_counter==88) begin
				data_out_reg = 8'b11011111;
			end
			if (bit_counter==96) begin
				data_out_reg = 8'b10111110;
			end
			if (bit_counter==104) begin
				data_out_reg = 8'b01111100;
			end
			if (bit_counter==112) begin
				data_out_reg = 8'b11111000;
			end
			if (bit_counter==120) begin
				data_out_reg = 8'b11110000;
			end
			if (bit_counter==128) begin
				data_out_reg = 8'b11100000;
			end
			if (bit_counter==136) begin
				data_out_reg = 8'b11000001;
			end
			if (bit_counter==144) begin
				data_out_reg = 8'b10000011;
			end
			if (bit_counter==152) begin
				data_out_reg = 8'b00000110;
			end
			if (bit_counter==160) begin
				data_out_reg = 8'b00001101;
			end
			if (bit_counter==168) begin
				data_out_reg = 8'b00011010;
			end
			if (bit_counter==176) begin
				data_out_reg = 8'b00110101;
			end
			if (bit_counter==184) begin
				data_out_reg = 8'b01101010;
			end
			if (bit_counter==192) begin
				data_out_reg = 8'b11010101;
			end
			if (bit_counter==200) begin
				data_out_reg = 8'b10101011;
			end
			if (bit_counter==208) begin
				data_out_reg = 8'b01010110;
			end
			if (bit_counter==216) begin
				data_out_reg = 8'b10101101;
			end
			if (bit_counter==224) begin
				data_out_reg = 8'b01011010;
			end
			if (bit_counter==232) begin
				data_out_reg = 8'b10110100;
			end
			if (bit_counter==240) begin
				data_out_reg = 8'b01101000;
			end
			if (bit_counter==248) begin
				data_out_reg = 8'b11010000;
			end
			if (bit_counter==256) begin
				data_out_reg = 8'b10100000;
			end
			if (bit_counter==264) begin
				data_out_reg = 8'b01000000;
			end
			if (bit_counter==272) begin
				data_out_reg = 8'b10000000;
			end
			if (bit_counter==280) begin
				data_out_reg = 8'b00000000;
			end
			if (bit_counter==288) begin
				data_out_reg = 8'b00000001;
			end
			if (bit_counter==296) begin
				data_out_reg = 8'b00000011;
			end
			if (bit_counter==304) begin
				data_out_reg = 8'b00000111;
			end
			if (bit_counter==312) begin
				data_out_reg = 8'b00001111;
			end
			if (bit_counter==320) begin
				data_out_reg = 8'b00011110;
			end
			if (bit_counter==328) begin
				data_out_reg = 8'b00111100;
			end
			if (bit_counter==336) begin
				data_out_reg = 8'b01111000;
			end
			if (bit_counter==344) begin
				data_out_reg = 8'b11110001;
			end
			if (bit_counter==352) begin
				data_out_reg = 8'b11100011;
			end
			if (bit_counter==360) begin
				data_out_reg = 8'b11000111;
			end
			if (bit_counter==368) begin
				data_out_reg = 8'b10001111;
			end
			if (bit_counter==376) begin
				data_out_reg = 8'b00011111;
			end
			if (bit_counter==384) begin
				data_out_reg = 8'b00111110;
			end
			if (bit_counter==392) begin
				data_out_reg = 8'b01111101;
			end
			if (bit_counter==400) begin
				data_out_reg = 8'b11111011;
			end
			if (bit_counter==408) begin
				data_out_reg = 8'b11110111;
			end
			if (bit_counter==416) begin
				data_out_reg = 8'b11101111;
			end
			if (bit_counter==424) begin
				data_out_reg = 8'b11011111;
			end
			if (bit_counter==432) begin
				data_out_reg = 8'b10111110;
			end
			if (bit_counter==440) begin
				data_out_reg = 8'b01111100;
			end
			if (bit_counter==448) begin
				data_out_reg = 8'b11111000;
			end
			if (bit_counter==456) begin
				data_out_reg = 8'b11110000;
			end
			if (bit_counter==464) begin
				data_out_reg = 8'b11100000;
			end
			if (bit_counter==472) begin
				data_out_reg = 8'b11000000;
			end
			if (bit_counter==480) begin
				data_out_reg = 8'b10000001;
			end
			if (bit_counter==488) begin
				data_out_reg = 8'b00000011;
			end
			if (bit_counter==496) begin
				data_out_reg = 8'b00000111;
			end
			if (bit_counter==504) begin
				data_out_reg = 8'b00001111;
			end
			if (bit_counter==512) begin
				data_out_reg = 8'b00011110;
			end
			if (bit_counter==520) begin
				data_out_reg = 8'b00111101;
			end
			if (bit_counter==528) begin
				data_out_reg = 8'b01111010;
			end
			if (bit_counter==536) begin
				data_out_reg = 8'b11110100;
			end
			if (bit_counter==544) begin
				data_out_reg = 8'b11101001;
			end
			if (bit_counter==552) begin
				data_out_reg = 8'b11010010;
			end
			if (bit_counter==560) begin
				data_out_reg = 8'b10100101;
			end
			if (bit_counter==568) begin
				data_out_reg = 8'b01001011;
			end
			if (bit_counter==576) begin
				data_out_reg = 8'b10010110;
			end
			if (bit_counter==584) begin
				data_out_reg = 8'b00101100;
			end
			if (bit_counter==592) begin
				data_out_reg = 8'b01011001;
			end
			if (bit_counter==600) begin
				data_out_reg = 8'b10110011;
			end
			if (bit_counter==608) begin
				data_out_reg = 8'b01100111;
			end
			if (bit_counter==616) begin
				data_out_reg = 8'b11001110;
			end
			if (bit_counter==624) begin
				data_out_reg = 8'b10011101;
			end
			if (bit_counter==632) begin
				data_out_reg = 8'b00111011;
			end
			if (bit_counter==640) begin
				data_out_reg = 8'b01110111;
			end
			if (bit_counter==648) begin
				data_out_reg = 8'b11101111;
			end
			if (bit_counter==656) begin
				data_out_reg = 8'b11011111;
			end
			if (bit_counter==664) begin
				data_out_reg = 8'b10111111;
			end
			if (bit_counter==672) begin
				data_out_reg = 8'b01111110;
			end
			if (bit_counter==680) begin
				data_out_reg = 8'b11111101;
			end
			if (bit_counter==688) begin
				data_out_reg = 8'b11111011;
			end
			if (bit_counter==696) begin
				data_out_reg = 8'b11110111;
			end
			if (bit_counter==704) begin
				data_out_reg = 8'b11101111;
			end
			if (bit_counter==712) begin
				data_out_reg = 8'b11011110;
			end
			if (bit_counter==720) begin
				data_out_reg = 8'b10111100;
			end
			if (bit_counter==728) begin
				data_out_reg = 8'b01111000;
			end
			if (bit_counter==736) begin
				data_out_reg = 8'b11110001;
			end
			if (bit_counter==744) begin
				data_out_reg = 8'b11100011;
			end
			if (bit_counter==752) begin
				data_out_reg = 8'b11000110;
			end
			if (bit_counter==760) begin
				data_out_reg = 8'b10001100;
			end
			if (bit_counter==768) begin
				data_out_reg = 8'b00011001;
			end
			if (bit_counter==776) begin
				data_out_reg = 8'b00110010;
			end
			if (bit_counter==784) begin
				data_out_reg = 8'b01100101;
			end
			if (bit_counter==792) begin
				data_out_reg = 8'b11001010;
			end
			if (bit_counter==800) begin
				data_out_reg = 8'b10010101;
			end
			if (bit_counter==808) begin
				data_out_reg = 8'b00101010;
			end
			if (bit_counter==816) begin
				data_out_reg = 8'b01010100;
			end
			if (bit_counter==824) begin
				data_out_reg = 8'b10101000;
			end
			if (bit_counter==832) begin
				data_out_reg = 8'b01010001;
			end
			if (bit_counter==840) begin
				data_out_reg = 8'b10100010;
			end
			if (bit_counter==848) begin
				data_out_reg = 8'b01000100;
			end
			if (bit_counter==856) begin
				data_out_reg = 8'b10001000;
			end
			if (bit_counter==864) begin
				data_out_reg = 8'b00010001;
			end
			if (bit_counter==872) begin
				data_out_reg = 8'b00100011;
			end
			if (bit_counter==880) begin
				data_out_reg = 8'b01000111;
			end
			if (bit_counter==888) begin
				data_out_reg = 8'b10001111;
			end
			if (bit_counter==896) begin
				data_out_reg = 8'b00011110;
			end
			if (bit_counter==904) begin
				data_out_reg = 8'b00111100;
			end
			if (bit_counter==912) begin
				data_out_reg = 8'b01111000;
			end
			if (bit_counter==920) begin
				data_out_reg = 8'b11110000;
			end
			if (bit_counter==928) begin
				data_out_reg = 8'b11100000;
			end
			if (bit_counter==936) begin
				data_out_reg = 8'b11000000;
			end
			if (bit_counter==944) begin
				data_out_reg = 8'b10000001;
			end
			if (bit_counter==952) begin
				data_out_reg = 8'b00000010;
			end
			if (bit_counter==960) begin
				data_out_reg = 8'b00000100;
			end
			if (bit_counter==968) begin
				data_out_reg = 8'b00001000;
			end
			if (bit_counter==976) begin
				data_out_reg = 8'b00010000;
			end
			if (bit_counter==984) begin
				data_out_reg = 8'b00100001;
			end
			if (bit_counter==992) begin
				data_out_reg = 8'b01000011;
			end
			if (bit_counter==1000) begin
				data_out_reg = 8'b10000110;
			end
			if (bit_counter==1008) begin
				data_out_reg = 8'b00001101;
			end
			if (bit_counter==1016) begin
				data_out_reg = 8'b00011011;
			end
			if (bit_counter==1024) begin
				data_out_reg = 8'b00110110;
			end
			if (bit_counter==1032) begin
				data_out_reg = 8'b01101100;
			end
			if (bit_counter==1040) begin
				data_out_reg = 8'b11011000;
			end
			if (bit_counter==1048) begin
				data_out_reg = 8'b10110001;
			end
			bit_counter = bit_counter + 8;
		end
	end
end

assign data_ready = data_ready_reg;
assign data_out = data_out_reg;
	
endmodule 