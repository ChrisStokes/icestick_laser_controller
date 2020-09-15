/*
	parameter integer BAUD_RATE = 9600;
	parameter integer CLOCK_FREQ_HZ = 12000000;
	localparam integer PERIOD = CLOCK_FREQ_HZ / BAUD_RATE;

	rs232_send #(
		.PERIOD(PERIOD)
	) send (
		.clk  (clk ),
		.TX   (TX  ),
		.LED1 (LED1),
		.LED2 (LED2),
		.LED3 (LED3),
		.LED4 (LED4),
		.LED5 (LED5)
	);
*/
module uart_tx #(
	parameter integer PERIOD = 10  // clock cycles per bit
) (
	input  clk,  // clock
	input write,  // assert that data is ready to write
	input [7:0] to_write,  // byte to write
	output reg writing,  // is port currently writing
	output reg latched,  // is data latched
	output TX
);

	reg [$clog2(PERIOD):0] cycle_cnt = 0;  // clock cycle counter
	reg [4:0] bit_cnt = 0;  // bit counter
	reg [7:0] current_byte = 8'hFF;
	reg current_bit = 1'b1;
	reg [7:0] next_byte;
	reg next_ready = 0;

	initial begin
		writing = 0;
		latched = 0;
	end

	always @(posedge clk) begin
		cycle_cnt <= cycle_cnt + 1;  // count clock cycles per bit period
		if (cycle_cnt == PERIOD-1) begin
			cycle_cnt <= 0;
			bit_cnt <= bit_cnt + 1;
			if (bit_cnt == 10) begin
				bit_cnt <= 0;
				if (next_ready) begin
					current_byte <= next_byte;
					writing <= 1;
				end else begin
					writing <= 0;
				end
				if (write) begin
					next_byte <= to_write;
					next_ready <= 1;
					latched <= 1;
				end else begin
					next_ready <= 0;
				end
			end
			if (bit_cnt == 1) begin
				latched <= 0;
			end
		end
	end

	always @(posedge clk) begin
		current_bit = 'bx;
		case (bit_cnt)
			0: current_bit <= 0; // start bit
			1: current_bit <= current_byte[0];
			2: current_bit <= current_byte[1];
			3: current_bit <= current_byte[2];
			4: current_bit <= current_byte[3];
			5: current_bit <= current_byte[4];
			6: current_bit <= current_byte[5];
			7: current_bit <= current_byte[6];
			8: current_bit <= current_byte[7];
			9: current_bit <= 1;  // stop bit
			10: current_bit <= 1; // stop bit
		endcase
		if (!writing) begin
			current_bit <= 1;
		end
	end

	assign TX = current_bit;
endmodule
