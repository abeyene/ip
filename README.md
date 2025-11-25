# IP Blocks for FPGA and ASIC Use

The repo holds digital IP units for FPGA or ASIC work.
Each unit follows clear synchronous design rules.
Each unit aims for simple reuse across many systems.

## Goals

Provide clean RTL units for lab work.
Provide solid testbenches for each unit.
Provide short guides for new users.

## Repo Layout

```
ip/
  rtl/
  tb/
  docs/
```

The rtl folder holds Verilog source.
The tb folder holds testbenches.
The docs folder holds notes and diagrams.

## Features

- UART unit for serial transfer
- SPI unit for external device control
- FIFO unit for safe rate match
- Protocol bridge unit for cross link control
- Control unit for RTL algorithm flow

## RTL Practice

All units follow a clear clock edge rule.
All units use safe reset paths.
All units use ready valid flow for each transfer.
All units avoid vendor specific blocks.

## Verification

Each unit has a testbench with clear stimulus.
Each unit uses assertions for key protocol checks.
Each unit targets high functional coverage.

Run a testbench with a tool such as Verilator or Questa:

```
make sim
```

or

```
vsim -do run.do
```

## How To Use

Clone the repo:

```
git clone https://github.com/abeyene/ip.git
```

Move into the folder:

```
cd ip
```

Build a unit:

```
make uart
```

Run a waveform view:

```
gtkwave wave.vcd
```

Add a unit to a top level by wiring ready and valid with your main FSM.
Place FIFO units at each slow to fast boundary.
Drive all resets from one top level source.

## License

The repo stays free for research use.
Contact the author for any wider use.
