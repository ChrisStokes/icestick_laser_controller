/*
* States:
* - awaiting packet start: awaiting key, if other char
* - in packet: key received no \n
* - packet done: \n received
* - packet error
*/
module cmd #(
	parameter KEY = "a"
) (
	input clk,
	input [7:0] in_byte,
	input latch,
	output match
);
	parameter STATE_WAIT = 0;  // waiting for key
	parameter STATE_IGNORE = 1;  // in non-key packet
	parameter STATE_PACKET = 2;  // in key packet
	reg [2:0] state = STATE_WAIT;
	/*
	reg packet_done = 0;
	reg last_packet_done = 0;
	*/
	reg match = 0;

	always @(posedge clk) begin
		case (state)
			STATE_WAIT: begin
				match <= 0;
				if (latch) begin
					if (in_byte == KEY) begin
						state <= STATE_PACKET;
						//packet_done <= 0;
						match <= 1;
					end else if ((in_byte == 10) | (in_byte == 13)) begin
						state <= STATE_WAIT;
					end else begin
						state <= STATE_IGNORE;
					end
				end else begin
					state <= STATE_WAIT;
				end
			end
			STATE_IGNORE: begin
				match <= 0;
				if (latch & ((in_byte == 10) | (in_byte == 13))) begin
					state <= STATE_WAIT;
				end else begin
					state <= STATE_IGNORE;
				end
			end
			STATE_PACKET: begin
				if (latch & ((in_byte == 10) | (in_byte == 13))) begin
					state <= STATE_WAIT;
					//packet_done <= 1;
				end else begin
					state <= STATE_PACKET;
				end
			end
		endcase
	end
	/*
	always @(*) begin
		case (state)
			STATE_WAIT: begin
				if (latch) begin
					if (in_byte == KEY) begin
						state = STATE_PACKET;
						packet_done = 0;
					end else begin
						state = STATE_IGNORE;
					end
				end else begin
					state = STATE_WAIT;
				end
			end
			STATE_IGNORE: begin
				state = (latch & (in_byte == "\n")) ? STATE_WAIT : STATE_IGNORE;
			end
			STATE_PACKET: begin
				if (latch & (in_byte == "\n")) begin
					state = STATE_WAIT;
					packet_done = 1;
				end else begin
					state = STATE_PACKET;
				end
			end
		endcase
	end
	
	always @(posedge clk) begin
		if (packet_done & !last_packet_done) begin
			match <= 1;
		end else begin
			match <= 0;
		end
		last_packet_done <= packet_done;
	end
	*/


endmodule
