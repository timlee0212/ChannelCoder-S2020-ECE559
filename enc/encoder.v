module encoder(
	input serial_in, switch, clock, reset, en,
	output zk, xk,
	output [2:0] q);

assign q = dffs;
reg [2:0] dffs;

wire d2, q2, d1, q1, d0, q0;
wire t0, t1;

always @(posedge clock, posedge reset) begin
	if (reset) begin
		dffs <= 3'b0;
	end
	else begin
		if (en) begin
			dffs[2] <= d2;
			dffs[1] <= d1;
			dffs[0] <= d0;
		end
	end
end

assign q2 = dffs[2];
assign q1 = dffs[1];
assign q0 = dffs[0];

assign zk = q2 ^ t0;
assign t0 = d0 ^ q0;
assign t1 = q1 ^ q2;

assign xk = switch ? t1 : serial_in;
assign d0 = t1 ^ xk;
assign d1 = q0;
assign d2 = q1;

endmodule 
