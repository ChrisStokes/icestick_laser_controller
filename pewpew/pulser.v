module pulser #(
	parameter N_BITS = 20
) (
	input clk,
	input reset,
	input [N_BITS-1:0] repeat_period,
	input [N_BITS-1:0] pulse_length,
	input [N_BITS-1:0] warm_up_time,
	input [N_BITS-1:0] delay,
	input [N_BITS-1:0] pre_exposure,
	input [N_BITS-1:0] exposure_time,
	output warm_up_a,
	output warm_up_b,
	output trigger_a,
	output trigger_b,
	output camera
);
	reg [N_BITS-1:0] count = 0;

	always @(posedge clk, posedge reset) begin
		if (reset) begin
			count <= 0;
		end else if (count >= repeat_period) begin
			count <= 0;
		end else begin
			count <= count + 1;
		end
	end

	assign warm_up_a = ~reset & (count > 0) & (count <= pulse_length);
	assign warm_up_b = ~reset & (
		(count > delay) &
		(count <= (delay + pulse_length)));
	assign trigger_a = ~reset & (
		(count > warm_up_time) &
		(count <= (warm_up_time + pulse_length)));
	assign trigger_b = ~reset & (
		(count > (warm_up_time + delay)) &
		(count <= (warm_up_time + delay + pulse_length)));
	assign camera = ~reset & (
		(
			(count > (warm_up_time - pre_exposure)) &
			(count <= (warm_up_time - pre_exposure + exposure_time))) |
		(
			(count > (warm_up_time - pre_exposure + delay)) &
			(count <= (warm_up_time - pre_exposure + delay + exposure_time))));
endmodule
