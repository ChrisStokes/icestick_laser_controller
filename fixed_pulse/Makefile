#PROJ = example
#PROJ = rs232demo
PROJ = pulse

PIN_DEF = icestick.pcf
DEVICE = hx1k

all: $(PROJ).rpt $(PROJ).bin

%.json: %.v
	yosys -p 'synth_ice40 -top top -json $@' $<

%.asc: %.json
	nextpnr-ice40 --$(DEVICE) --json $^ --pcf $(PIN_DEF) --asc $@

%.bin: %.asc
	icepack $< $@

%.rpt: %.asc
	icetime -d $(DEVICE) -mtr $@ $<

%_tb: %_tb.v %.v
	iverilog -o $@ $^

%_tb.vcd: %_tb
	vvp -N $< +vcd=$@

%_syn.v: %.blif
	yosys -p 'read_blif -wideports $^; write_verilog $@'

%_syntb: %_tb.v %_syn.v
	iverilog -o $@ $^ `yosys-config --datdir/ice40/cells_sim.v`

%_syntb.vcd: %_syntb
	vvp -N $< +vcd=$@

sim: $(PROJ)_tb.vcd

postsim: $(PROJ)_syntb.vcd

prog: $(PROJ).bin
	iceprog $<

screen: prog
	screen -fn /dev/ttyUSB1 9600

sudo-prog: $(PROJ).bin
	@echo 'Executing prog as root!!!'
	sudo iceprog $<

clean:
	rm -f $(PROJ).json $(PROJ).blif $(PROJ).asc $(PROJ).rpt $(PROJ).bin

.SECONDARY:
.PHONY: all prog clean
