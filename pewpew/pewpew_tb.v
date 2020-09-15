`timescale 1 ns/1 ps

module pewpew_tb ();
	localparam N_BITS = 20;

	reg clk = 0;
	reg reset = 1;
	/*
	reg [N_BITS-1:0] repeat_period = 80000;
	reg [N_BITS-1:0] pulse_length = 120;
	reg [N_BITS-1:0] warm_up_time = 1680;
	reg [N_BITS-1:0] delay = 1200;
	reg [N_BITS-1:0] pre_exposure = 120;
	reg [N_BITS-1:0] exposure_time = 360;
	*/
	reg [N_BITS-1:0] repeat_period = 1000;
	reg [N_BITS-1:0] pulse_length = 10;
	reg [N_BITS-1:0] warm_up_time = 50;
	reg [N_BITS-1:0] delay = 30;
	reg [N_BITS-1:0] pre_exposure = 10;
	reg [N_BITS-1:0] exposure_time = 20;


	wire reg warm_up_a;
	wire reg warm_up_b;
	wire reg trigger_a;
	wire reg trigger_b;
	wire reg camera;

	pulser #(
		.N_BITS(N_BITS)
	) uart_tx1 (
		.clk(clk),
		.reset(reset),
		.repeat_period(repeat_period),
		.pulse_length(pulse_length),
		.warm_up_time(warm_up_time),
		.delay(delay),
		.pre_exposure(pre_exposure),
		.exposure_time(exposure_time),
		.warm_up_a(warm_up_a),
		.warm_up_b(warm_up_b),
		.trigger_a(trigger_a),
		.trigger_b(trigger_b),
		.camera(camera)
	);

	always begin
		#20 clk = !clk;
	end

	initial begin
		$dumpfile("pulser_tb.vcd");
		$dumpvars;
	end

	initial begin
		reset = 1;
		repeat (1000) @(posedge clk);
		reset = 0;
		repeat (3000) @(posedge clk);
		reset = 1;
		repeat (1000) @(posedge clk);
		#200 $finish;
	end
endmodule
