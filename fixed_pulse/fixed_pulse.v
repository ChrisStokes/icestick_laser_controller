/*
* Target timing
* Main cycle 15 hz (8E5 ticks)
* warm-up trigger pulse is 10 us (120 ticks)
* warm-up to trigger delay 140 us (1680 ticks)
* trigger pulse is 10 us (120 ticks)
* warm-up to camera delay 130 us (1560 ticks)
* camera trigger pulse 30 us (360 ticks)
*
* currently, pressing 1 puts the system in 'reset' (off)
* pressing anything but 1 lets the system run
*/
module top #(
	parameter REPEAT_HZ = 16,
) (
	input  clk,
	input  RX,
	output TX,
	output LED1,
	output TST1,
	output TST2,
	output TST3,
	output TST4,
	output TST5,
);
	parameter integer BAUD_RATE = 9600;
	parameter integer CLOCK_FREQ_HZ = 12000000;
	localparam integer PERIOD = CLOCK_FREQ_HZ / BAUD_RATE;

	parameter integer REPEAT_PERIOD = 800000;
	parameter integer BITS = 21;

	wire reset;
	wire gated_clk;
	wire [BITS-1:0] count;

	rs232_recv #(
		.HALF_PERIOD(PERIOD / 2)
	) recv (
		.clk  (clk ),
		.RX   (RX  ),
		.reset (reset),
	);

	assign gated_clk = clk & ~reset;
	assign LED1 = ~reset;

	Counter #(
		.BITS(BITS),
		.RESET_VALUE(REPEAT_PERIOD)
	) counter (
		.clk (gated_clk),
		.reset (reset),
		.count (count),
	);

	assign TST1 = ~reset & (count > 0) & (count <= 120);  // laser a warm-up
	assign TST2 = ~reset & (count > 1680) & (count <= 1800);  // laser a trigger
	assign TST3 = ~reset & (count > 1200) & (count <= 1320);  // laser b warm-up
	assign TST4 = ~reset & (count > 2880) & (count <= 3000);  // laser b trigger
	assign TST5 = ~reset & (
		((count > 1560) & (count <= 1920)) |
		((count > 2780) & (count <= 3140)));
endmodule

module Counter #(
	parameter BITS = 24,
	parameter RESET_VALUE = 12000000,
) (
	input clk,
	input reset,
	output [BITS-1:0] count,
);
	always @(posedge clk, posedge reset) begin
		if (reset) begin
			count <= 0;
		end else if (count >= RESET_VALUE) begin
			count <= 0;
		end else begin
			count <= count + 1;
		end
	end
endmodule

module rs232_recv #(
	parameter integer HALF_PERIOD = 5
) (
	input  clk,
	input  RX,
	output reg reset,
);
	reg [7:0] buffer;
	reg buffer_valid;

	reg [$clog2(3*HALF_PERIOD):0] cycle_cnt;
	reg [3:0] bit_cnt = 0;
	reg recv = 0;

	always @(posedge clk) begin
		buffer_valid <= 0;
		if (!recv) begin  // wait for start bit
			if (!RX) begin  // start bit is active low
				cycle_cnt <= HALF_PERIOD;
				bit_cnt <= 0;
				recv <= 1;
			end
		end else begin
			if (cycle_cnt == 2*HALF_PERIOD) begin  // half way through bit
				cycle_cnt <= 0;
				bit_cnt <= bit_cnt + 1;
				if (bit_cnt == 9) begin  // end of byte
					buffer_valid <= 1;
					recv <= 0;  // stop receiving
				end else begin
					// shift in current bit
					buffer <= {RX, buffer[7:1]};
				end
			end else begin
				cycle_cnt <= cycle_cnt + 1;
			end
		end
	end

	always @(posedge clk) begin
		if (buffer_valid) begin
			if (buffer == "1") reset <= 1'b1;
			else reset <= 1'b0;
		end
	end
endmodule
