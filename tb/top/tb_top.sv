`timescale 1ns/1ps

module tb_top;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    // Include all TB files
    `include "axilite_transaction.sv"
    `include "axilite_sequencer.sv"
    `include "axilite_driver.sv"
    `include "axilite_monitor.sv"
    `include "axilite_scoreboard.sv"
    `include "axilite_agent.sv"
    `include "axilite_env.sv"
    `include "axilite_sequence.sv"
    `include "base_test.sv"

    // Parameters
    parameter ADDR_WIDTH = 32;
    parameter DATA_WIDTH = 32;
    parameter SRAM_DEPTH = 1024;

    // Clock and reset
    logic clk;
    logic rst_n;

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 100MHz clock
    end

    // Reset generation
    initial begin
        rst_n = 0;
        repeat (5) @(posedge clk);
        rst_n = 1;
    end

    // Interface instantiation
    axilite_if #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) vif (
        .clk(clk),
        .rst_n(rst_n)
    );

    // DUT instantiation
    axilite_sram_controller #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .SRAM_DEPTH(SRAM_DEPTH)
    ) dut (
        .clk           (clk),
        .rst_n         (rst_n),
        .s_axi_awaddr  (vif.awaddr),
        .s_axi_awvalid (vif.awvalid),
        .s_axi_awready (vif.awready),
        .s_axi_wdata   (vif.wdata),
        .s_axi_wstrb   (vif.wstrb),
        .s_axi_wvalid  (vif.wvalid),
        .s_axi_wready  (vif.wready),
        .s_axi_bready  (vif.bready),
        .s_axi_bvalid  (vif.bvalid),
        .s_axi_bresp   (vif.bresp),
        .s_axi_araddr  (vif.araddr),
        .s_axi_arvalid (vif.arvalid),
        .s_axi_arready (vif.arready),
        .s_axi_rready  (vif.rready),
        .s_axi_rdata   (vif.rdata),
        .s_axi_rresp   (vif.rresp),
        .s_axi_rvalid  (vif.rvalid)
    );

    // Pass interface to UVM
    initial begin
        uvm_config_db #(virtual axilite_if)::set(null, "*", "vif", vif);
    end

    // Start UVM test
    initial begin
        run_test();
    end

    // Waveform dump
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_top);
    end

    // Timeout watchdog
    initial begin
        #1000000ns;
        `uvm_fatal("TIMEOUT", "Simulation timeout!")
    end

endmodule: tb_top
