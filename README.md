# AXI-Lite SRAM Controller UVM Verification

A UVM-based verification environment for an AXI-Lite SRAM Controller written in SystemVerilog.

## Overview

This project verifies an AXI-Lite SRAM Controller that:
- Accepts read and write transactions via AXI-Lite protocol
- Stores data in an internal 1024-word SRAM
- Supports byte-level writes using write strobes
- Returns appropriate responses (OKAY/SLVERR)

## Directory Structure

```
├── dut/
│   └── axilite_sram_controller.sv   # Design under test
├── tb/
│   ├── agent/
│   │   ├── axilite_agent.sv         # UVM agent
│   │   ├── axilite_driver.sv        # Drives AXI-Lite transactions
│   │   ├── axilite_monitor.sv       # Monitors bus activity
│   │   ├── axilite_scoreboard.sv    # Checks data integrity
│   │   └── axilite_sequencer.sv     # Sequencer
│   ├── env/
│   │   └── axilite_env.sv           # UVM environment
│   ├── interface/
│   │   └── axilite_if.sv            # AXI-Lite interface
│   ├── sequence/
│   │   └── axilite_sequence.sv      # Test sequences
│   ├── test/
│   │   └── base_test.sv             # Test cases
│   ├── top/
│   │   └── tb_top.sv                # Testbench top module
│   └── transaction/
│       └── axilite_transaction.sv   # Transaction class
├── sim/
│   ├── file_list.f                  # Source file list
│   └── run.f                        # Simulation options
└── docs/                            # Documentation
```

## Running Simulations

Navigate to the sim directory and run:

```bash
cd sim
xrun -f run.f
```

To run a specific test:

```bash
xrun -f run.f +UVM_TESTNAME=base_test
xrun -f run.f +UVM_TESTNAME=write_read_test
xrun -f run.f +UVM_TESTNAME=full_mem_test
```

## Available Tests

| Test | Description |
|------|-------------|
| base_test | Random read/write transactions |
| write_read_test | Write to address then read back |
| full_mem_test | Write and read multiple memory locations |

## DUT Details

The AXI-Lite SRAM Controller implements:
- 5 AXI-Lite channels (AW, W, B, AR, R)
- 32-bit address and data width
- 1024-word internal SRAM (4KB)
- Word-aligned addressing
- Byte strobes for partial writes

## Verification Components

- **Driver**: Sends AXI-Lite read/write transactions to DUT
- **Monitor**: Observes all bus activity
- **Scoreboard**: Maintains reference memory model, compares read data against expected values
- **Sequences**: Generate directed and random test patterns

## How to Run the Project

### For Texas A&M Students

If you are a **Texas A&M student** with access to the ECEN or CSCE Linux servers, follow these steps:

1. **Clone the repository** on the ECEN Linux server:
   ```bash
   git clone <repository-url>
   cd AXI-Lite-SRAM-Controller-UVM-Verification
   ```

2. **Load the CSCE-616 environment**:
   ```bash
   load-csce-616
   ```
   This command sets up all necessary EDA tools, compilers, and simulators for the project.

3. **Run the setup script**:
   ```bash
   bash setupX.bash
   ```
   This script configures the environment and prepares the project for simulation.

4. **Navigate to the simulation directory and run the testbench**:
   ```bash
   cd sim
   xrun -f run.f
   ```
   This command compiles and runs the complete verification environment using the xrun simulator.

### For Other Users

If you are not on the TAMU ECEN or CSCE server, I would recommend you to use eda playground to run this project. 
