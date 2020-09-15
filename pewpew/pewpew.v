module pewpew (
	input clk,
	input RX,
	//output TX,
	output TST1,
	output TST2,
	output TST3,
	output TST4,
	output TST5,
	output LED1,
	output LED2,
	output LED3,
	output LED4,
	output LED5
);
	parameter integer BAUD_RATE = 9600;
	parameter integer CLOCK_FREQ_HZ = 12000000;
	localparam integer PERIOD = CLOCK_FREQ_HZ / BAUD_RATE;

	reg [7:0] uart_rx_byte;
	reg uart_rx_latch;

	uart_rx #(
		.HALF_PERIOD(PERIOD / 2)
	) uart_rx1 (
		.clk(clk),
		.RX(RX),
		.debug_led(LED5),
		.read_byte(uart_rx_byte),
		.latch(uart_rx_latch)
	);

	localparam integer N_BITS = 20;
	reg reset = 1;  // E,D,R
	assign LED1 = ~reset;
	assign LED2 = ~RX;
	reg [N_BITS-1:0] repeat_period = 800000;  // p
	reg [N_BITS-1:0] pulse_length = 120;
	reg [N_BITS-1:0] warm_up_time = 1680;
	reg [N_BITS-1:0] delay = 1200;  // d
	reg [N_BITS-1:0] pre_exposure = 120;
	reg [N_BITS-1:0] exposure_time = 360; // e

	wire cmd_enable_match;
	cmd #(
		.KEY("E")
	) cmd_enable (
		.clk(clk),
		.in_byte(uart_rx_byte),
		.latch(uart_rx_latch),
		.match(cmd_enable_match)
	);
	wire cmd_disable_match;
	cmd #(
		.KEY("D")
	) cmd_disable (
		.clk(clk),
		.in_byte(uart_rx_byte),
		.latch(uart_rx_latch),
		.match(cmd_disable_match)
	);
	wire cmd_reset_match;
	cmd #(
		.KEY("R")
	) cmd_reset (
		.clk(clk),
		.in_byte(uart_rx_byte),
		.latch(uart_rx_latch),
		.match(cmd_reset_match)
	);

	wire cmd_val_repeat_period_match;
	wire [N_BITS-1:0] cmd_val_repeat_period_value;
	cmd_val #(
		.KEY("p"),
		.VAL_BITS(N_BITS)
	) cmd_val_repeat_period (
		.clk(clk),
		.in_byte(uart_rx_byte),
		.latch(uart_rx_latch),
		.match(cmd_val_repeat_period_match),
		.value(cmd_val_repeat_period_value)
	);
	wire cmd_val_delay_match;
	wire [N_BITS-1:0] cmd_val_delay_value;
	cmd_val #(
		.KEY("d"),
		.VAL_BITS(N_BITS)
	) cmd_val_delay (
		.clk(clk),
		.in_byte(uart_rx_byte),
		.latch(uart_rx_latch),
		.match(cmd_val_delay_match),
		.value(cmd_val_delay_value)
	);
	wire cmd_val_exposure_match;
	wire [N_BITS-1:0] cmd_val_exposure_value;
	cmd_val #(
		.KEY("e"),
		.VAL_BITS(N_BITS)
	) cmd_val_exposure (
		.clk(clk),
		.in_byte(uart_rx_byte),
		.latch(uart_rx_latch),
		.match(cmd_val_exposure_match),
		.value(cmd_val_exposure_value)
	);

	always @(posedge clk) begin
		if (cmd_enable_match) begin
			reset <= 0;
		end else if (cmd_disable_match) begin
			reset <= 1;
		end else if (cmd_reset_match) begin
			reset <= ~reset;
		end
		if (cmd_val_repeat_period_match) repeat_period <= cmd_val_repeat_period_value;
		if (cmd_val_delay_match) delay <= cmd_val_delay_value;
		if (cmd_val_exposure_match) exposure_time <= cmd_val_exposure_value;
	end

	// cmds:
	// - repeat_period
	// - pulse_length
	// - warm_up_time
	// - delay
	// - pre_exposure
	// - exposure_time

	//uart_tx?
	pulser #(
		.N_BITS(N_BITS)
	) pulser_1 (
		.clk(clk),
		.reset(reset),
		.repeat_period(repeat_period),
		.pulse_length(pulse_length),
		.warm_up_time(warm_up_time),
		.delay(delay),
		.pre_exposure(pre_exposure),
		.exposure_time(exposure_time),
		.warm_up_a(TST1),
		.warm_up_b(TST2),
		.trigger_a(TST3),
		.trigger_b(TST4),
		.camera(TST5)
	);
endmodule
