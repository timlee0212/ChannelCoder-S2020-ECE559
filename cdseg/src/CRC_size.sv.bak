
module cal_size ( input logic [11:0] B,
						output logic [1:0] C_plus,
						output logic [1:0] C_minus,
						output logic [9:0] filler,
						output logic max_exceed_error);
						
	logic [2:0] branch;
	
	// 5'd12240 = 4'h2FD0    // 4'd7152  = 4'h1BF0
	// 4'd1530  = 4'h05FA    // 4'd0894  = 4'h037E for Byte
    //
	// 4'd6144  = 4'h1800    // 4'd1056  = 4'h0420
	// 4'd0768  = 4'h0300    // 4'd0132  = 4'h0084 for Byte
	
	//localparam max  = 16'h2FD0;
	//localparam high = 16'h1BF0;
	//localparam mid  = 16'h1800;
	//localparam low  = 16'h0420;
	localparam max  = 12'h5FA;
	localparam high = 12'h37E;
	localparam mid  = 12'h300;
	localparam low  = 12'h084;
	
	assign max_exceed_error = (B > max) ? 1'b1: 1'b0;
	assign branch[2] = (B > high) ? 1'b1: 1'b0;  // two large blocks
	assign branch[1] = (B > mid) ? 1'b1: 1'b0;   // one large, one small
	assign branch[0] = (B > low) ? 1'b1: 1'b0;   // one large block
															   // one small block
	always_comb
		case(branch)
			3'b111: begin
				C_plus = 2'b10;
				C_minus = 2'b00;
				filler = max - B;
				end
			3'b011: begin
				C_plus = 2'b01;
				C_minus = 2'b01;
				filler = high - B;
				end
			3'b001: begin
				C_plus = 2'b01;
				C_minus = 2'b00;
				filler = mid - B;
				end
			3'b000: begin
				C_plus = 2'b00;
				C_minus = 2'b01;
				filler = low - B;
				end
			default: begin
				C_plus = 2'b00;
				C_minus = 2'b00;
				filler = 10'h000;
				end
		endcase
endmodule




module CRC_size  (input logic aclr,
						input logic clk,
						input logic w,
						input logic [11:0] inputSize,
						input logic r_out,
						output logic empty_out,
						output logic [13:0] data_out);
						
	logic empty, full, r;
	logic [11:0] B;
	// reading inputSize from 12 - bit FIFO 1536Bytes Max
	fifo12 fifo12_inst (.aclr(aclr), .clock(clk), .data(inputSize), .rdreq(r), 
							  .wrreq(w), .empty(empty), .full(full), .q(B));
	
	logic w_in, full_in;
	logic [13:0] data_in;	
	// writing concat outputs to 14-bit FIFO Max filler 10bits
	fifo14 fifo14_inst (.aclr(aclr), .clock(clk), .data(data_in), .rdreq(r_out), 
							  .wrreq(w_in), .empty(empty_out), .full(full_in), .q(data_out));

	logic max_exceed_error;
	logic [1:0] C_minus, C_plus;
	logic [9:0] filler;
	// calculate block & filler sizes
	cal_size cal_size_inst (B, C_plus, C_minus, filler, max_exceed_error);
	
	
	logic stop, prev_stop;
	assign stop = (empty | full_in);
	
	always_ff @(posedge clk, posedge aclr)
		if (aclr) prev_stop <= 1;
		else 		 prev_stop <= stop;
	
	assign r = (~stop);
	assign w_in = (~prev_stop);
	
	assign data_in = {C_plus, C_minus, filler};
	
endmodule


