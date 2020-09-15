/*
* States:
* - awaiting packet start: awaiting key, if other char
* - in packet: key received no \n
* - packet done: \n received
* - packet error
*
* x10 is the same as ((v << 1) + (v << 3))
* repeat frequency: 15 hz
* warm up pulse: 10 us
* warm up trigger delay: 140 us
* trigger pulse: 10 us
* warm up to camera delay: 130 us
* camera exposure: 30 us
*
* all values are <256 so 8 bits should work
*/
module cmd_val #(
	parameter KEY = "a",
	parameter VAL_BITS = 8
) (
	input clk,
	input [7:0] in_byte,
	input latch,
	output match,
	output [VAL_BITS-1:0] value
);
	parameter STATE_WAIT = 0;  // waiting for key
	parameter STATE_IGNORE = 1;  // in non-key packet
	parameter STATE_PACKET = 2;  // in key packet
	reg [2:0] state = STATE_WAIT;
	/*
	reg packet_done = 0;
	reg last_packet_done = 0;
	*/

	always @(posedge clk) begin
		case (state)
			STATE_WAIT: begin
				match <= 0;
				if (latch) begin
					if (in_byte == KEY) begin
						state <= STATE_PACKET;
						value <= 0;
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
				if (latch) begin
					case (in_byte)
						10, 13: begin
							state <= STATE_WAIT;
							match <= 1;
						end
						"0","1","2","3","4",  // no need to use 0
						"5","6","7","8","9": begin
							state = STATE_PACKET;
							value = (
								(value << 3) + (value << 1) +
								(in_byte - 48)
							);
						end
						default: state = STATE_PACKET;
					endcase
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
						value = 0;
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
				if (latch) begin
					case (in_byte)
						"\n": begin
							state = STATE_WAIT;
							packet_done = 1;
						end
						"0","1","2","3","4",  // no need to use 0
						"5","6","7","8","9": begin
							state = STATE_PACKET;
							value = (
								(value << 3) + (value << 1) +
								(in_byte - 48)
							);
						end
						default: state = STATE_PACKET;
					endcase
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
