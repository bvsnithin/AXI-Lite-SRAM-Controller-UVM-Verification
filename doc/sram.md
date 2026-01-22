# SRAM (Static Random Access Memory) Basics

## 1. What is SRAM?

**SRAM** stands for **Static Random Access Memory**.  
It is a type of **volatile memory** used to store data temporarily while a system is running.

- "Volatile" means the data is lost when the power is turned off.
- "Static" means it **does not need to be refreshed** like DRAM (Dynamic RAM).
- Stores data using **flip-flops** for each bit.

---

## 2. Key Characteristics of SRAM

| Feature | Description |
|---------|-------------|
| Storage | Uses flip-flops (6 transistors per bit) |
| Speed | Very fast access (usually faster than DRAM) |
| Volatility | Data lost when power is off |
| Power | Consumes more power than DRAM when storing data |
| Size | Usually smaller than DRAM due to transistor count |
| Use | Cache memory, buffers, small memory blocks |

---

## 3. How SRAM Works

SRAM memory stores each bit using a **cross-coupled flip-flop**.  

- Each memory cell has **6 transistors**: 4 for storing the bit, 2 for access.
- Accessing SRAM:
  1. **Address lines** select a specific memory cell.
  2. **Read or write signals** control whether data is read from or written to the cell.
  3. **Data lines** carry the actual data in or out.

**Key point:** Data remains stable as long as power is supplied, no refresh needed.

---

## 4. SRAM vs DRAM

| Feature | SRAM | DRAM |
|---------|------|------|
| Cell type | Flip-flop (6 transistors) | Capacitor + transistor |
| Refresh | Not needed | Required periodically |
| Speed | Very fast | Slower |
| Density | Lower (larger cell) | Higher (smaller cell) |
| Power | Higher per bit | Lower per bit |
| Use case | Cache, small fast memory | Main memory, large memory |

---

## 5. Typical Applications of SRAM

- CPU cache memory (L1, L2, sometimes L3)
- Small buffers in peripherals (like UART, SPI, I2C)
- FPGA block RAM
- Embedded systems for fast temporary storage
- Scratchpad memory in microcontrollers

---

## 6. Key Signals in SRAM

Even simple SRAM modules have some standard signals:

| Signal | Purpose |
|--------|---------|
| `ADDR` | Address to read/write |
| `DATA_IN` | Data to write to memory |
| `DATA_OUT` | Data read from memory |
| `WE` | Write enable |
| `OE` | Output enable / read enable |
| `CS` | Chip select (activate memory module) |

---

## 7. SRAM in AXI-Lite SRAM Controller

In your AXI-Lite SRAM controller project:

- 32-bit data from the controller is split into **4 bytes (8-bit each)** to match the SRAM cell width.
- SRAM provides **fast read/write operations**.
- Controlled entirely through **AXI4-Lite interface signals**:
  - Read and write addresses
  - Valid/Ready handshakes
  - Response signals (`RRESP`, `BRESP`)
- This makes verification easier because SRAM acts like a **predictable memory block**.

---

## 8. Interview Tips: SRAM Questions

Here are common **interview questions** and simple answers:

**Q1:** What is SRAM?  
**A:** SRAM is fast volatile memory that stores data in flip-flops and doesn’t need refresh.

**Q2:** Difference between SRAM and DRAM?  
**A:** SRAM uses flip-flops, is faster, needs more power, and is smaller. DRAM uses capacitors, is slower, and needs refresh.

**Q3:** Why use SRAM in a controller project?  
**A:** It is fast, simple, and works well for small temporary storage, perfect for embedded memory or cache.

**Q4:** How many transistors in a typical SRAM cell?  
**A:** Usually 6 transistors.

**Q5:** What signals are needed to read/write SRAM?  
**A:** Address, Data_in, Data_out, Write Enable (WE), Output Enable (OE), and Chip Select (CS).

**Q6:** Why is SRAM called static?  
**A:** Because it keeps its data as long as power is supplied, unlike DRAM which needs refresh.

---

## 9. Summary

- SRAM = **fast, static memory**
- Data stored in **flip-flops**
- Used for **cache, buffers, and small memory blocks**
- Easy to interface with AXI4-Lite controllers
- Key for **high-speed, reliable memory access** in embedded systems

---

