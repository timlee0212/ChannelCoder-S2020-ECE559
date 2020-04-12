module fifoFSM(input init_we, count_complete, clock, reset,
					output we);					
	parameter INIT = 2'd0;
	parameter COUNTING = 2'd1;
	parameter END = 2'd2;
	
	//wire state;
	reg[1:0] state_curr, state_next;
	//assign state = state_curr;
	
	always @(posedge clock, posedge reset) begin
		if (reset) begin
			state_curr <= INIT;
		end
		else begin
			state_curr <= state_next;
		end
	end
	
	//Outputs
	assign we = state_curr == COUNTING;
	
	//State Transitions
	always @(state_curr, init_we, count_complete) begin
		case (state_curr)
			INIT: begin
				if(init_we) begin
					state_next <= COUNTING;
				end 
				else begin
					state_next <= INIT;
				end
			end
			COUNTING: begin
				if(count_complete) begin
					state_next <= END;
				end
				else begin
					state_next <= COUNTING;
				end
			end
			END: begin
				state_next <= END;
			end
		endcase
	end
endmodule
					
