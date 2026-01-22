# AXI-Lite SRAM Controller Verification

![Language](https://img.shields.io/badge/Language-SystemVerilog-blue)
![Methodology](https://img.shields.io/badge/Methodology-UVM-orange)

## 📖 Project Overview

This project is a complete **verification environment** built using **SystemVerilog** and **UVM** to validate an **AXI-Lite SRAM Controller**. 

The goal is to verify that the SRAM controller correctly:
- Receives read and write transactions from an AXI-Lite master
- Correctly addresses and accesses the internal SRAM memory
- Returns appropriate responses with data (for reads) or status (for writes)
- Handles protocol timing and handshaking requirements

---

## 🎯 The Concept

The **AXI-Lite SRAM Controller** acts as a bridge between an AXI-Lite master (like a processor) and SRAM memory:

1. **The Master (AXI-Lite Source):** Initiates read and write transactions with addresses and data.
2. **The AXI-Lite Protocol:** A lightweight synchronous bus protocol that carries transactions between master and slave.
3. **The SRAM Controller (Device Under Test):** Translates AXI-Lite commands into SRAM operations.
4. **The SRAM Memory:** Internal memory accessed by the controller.
5. **The UVM Testbench (Verification Environment):** Generates stimulus, monitors responses, and validates correctness.

The testbench verifies that the controller handles various scenarios:
- Basic read/write operations
- Burst transactions
- Back-to-back transfers
- Edge cases and protocol compliance

---

## 📁 Directory Structure

```
AXI-Lite_SRAM_Controller_UVM_Verification/
├── README.md                    # Project documentation
├── setupX.bash                  # Setup script
├── dut/                         # Design Under Test
│   └── axilite_sram_controller.sv
├── tb/                          # UVM Testbench
│   ├── agent/                   # UVM Agent
│   │   ├── axilite_agent.sv
│   │   ├── axilite_driver.sv
│   │   ├── axilite_monitor.sv
│   │   ├── axilite_scoreboard.sv
│   │   └── axilite_sequencer.sv
│   ├── env/                     # Environment
│   │   └── env.sv
│   ├── interface/               # Protocol Interfaces
│   │   └── axilite_if.sv
│   ├── transaction/             # Transaction Definitions
│   │   └── axilite_transaction.sv
│   ├── test/                    # Test Cases
│   │   └── base_test.sv
│   └── top/                     # Top-level Testbench
│       └── tb_top.sv
└── sim/                         # Simulation
    ├── file_list.f              # File compilation list
    └── run.f                    # Simulation commands
```

### Directory Descriptions

- **`dut/`** - The design under test: AXI-Lite SRAM Controller RTL
- **`tb/`** - Complete UVM-based verification environment:
  - **`agent/`** - Reusable UVM agent implementing the AXI-Lite protocol
  - **`env/`** - Environment configuration, scoreboards, and coverage
  - **`interface/`** - SystemVerilog interface definitions for AXI-Lite protocol
  - **`transaction/`** - Transaction class definitions for stimulus and response
  - **`test/`** - Test cases and verification scenarios
  - **`top/`** - Top-level testbench module
- **`sim/`** - Simulation artifacts and configuration files

---

## 🚀 How to Run the Project

### For Texas A&M Students

If you are a **Texas A&M student** with access to the ECEN Linux servers, follow these steps:

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

If you are not on the TAMU ECEN server, you will need to:
- Install a compatible SystemVerilog simulator (e.g., Cadence Xcelium, Mentor Questa, or an open-source alternative)
- Ensure UVM libraries are properly configured
- Modify the simulation scripts as needed for your environment
- Run: `xrun -f sim/run.f` (or equivalent command for your simulator)eforms in the output directory.

---

## 📊 Verification Strategy

- **Functional Coverage:** Tracks which transactions and protocols states are exercised
- **Code Coverage:** Monitors DUT logic and decision coverage
- **Scoreboarding:** Compares expected vs. actual DUT behavior
- **Assertions:** Protocol and design assumptions are validated continuously

---

## ✨ Key Features

- **Full UVM Testbench:** Modular, reusable, and scalable verification environment
- **AXI-Lite Protocol Compliance:** Correctly implements master and slave protocols
- **Comprehensive Testing:** Covers normal operations, edge cases, and protocol requirements

---
