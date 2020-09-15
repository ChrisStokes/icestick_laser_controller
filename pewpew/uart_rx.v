/*
	parameter integer BAUD_RATE = 9600;
	parameter integer CLOCK_FREQ_HZ = 12000000;
	localparam integer PERIOD = CLOCK_FREQ_HZ / BAUD_RATE;

	rs232_recv #(
		.HALF_PERIOD(PERIOD / 2)
	) recv (
		.clk  (clk ),
		.RX   (RX  ),
		.LED1 (LED1),
		.LED2 (LED2),
		.LED3 (LED3),
		.LED4 (LED4),
		.LED5 (LED5)
	);
*/

module uart_rx #(
	parameter integer HALF_PERIOD = 5
) (
	input  clk,
	input  RX,
	input  debug_led,
	output reg [7:0] read_byte,
	output reg latch
);
	reg [7:0] buffer;
	//reg buffer_valid;

	reg [$clog2(3*HALF_PERIOD):0] cycle_cnt = 0;
	reg [3:0] bit_cnt = 0;
	reg recv = 0;

	initial begin
		read_byte = 8'hFF;
		latch = 0;
	end

	always @(posedge clk) begin
		//buffer_valid <= 0;
		if (!recv) begin
			latch <= 0;
			if (!RX) begin
				cycle_cnt <= HALF_PERIOD;
				bit_cnt <= 0;
				recv <= 1;
			end
		end else begin
			if (cycle_cnt == 2*HALF_PERIOD) begin
				cycle_cnt <= 0;
				bit_cnt <= bit_cnt + 1;
				if (bit_cnt == 1) begin
					latch <= 0;
				end
				if (bit_cnt > 8) begin
					//buffer_valid <= 1;
					read_byte <= buffer;
					latch <= 1;
					recv <= 0;
				end else begin
					buffer <= {RX, buffer[7:1]};
				end
			end else begin
				cycle_cnt <= cycle_cnt + 1;
			end
		end
	end

	/*
	always @(posedge clk) begin
		if (buffer_valid) begin
			read_byte <= buffer;
			latch <= 1;
		end
	end
	*/

	assign debug_led = latch;
endmodule
