module counter (enable, clk, reset, count);
	input enable;
	input clk, reset;
	
	output reg [12:0] count;
	
	wire [12:0] target = 13'd6144;
	wire target_reached, reset_or_restart;
	
	assign target_reached = (count == target);
	
	or (reset_or_restart, reset, target_reached);
	
	always @(posedge clk or posedge reset_or_restart) begin
		if (reset_or_restart)
			count <= 13'b0;
		else if (enable)
			count <= count + 13'b1;
	end
endmodule