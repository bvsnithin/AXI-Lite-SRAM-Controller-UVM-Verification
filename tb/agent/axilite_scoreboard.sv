class axilite_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(axilite_scoreboard)

    uvm_analysis_imp #(axilite_transaction, axilite_scoreboard) analysis_export;

    // Reference memory model
    bit [31:0] ref_mem [bit[31:0]];

    // Statistics
    int write_count;
    int read_count;
    int pass_count;
    int fail_count;

    function new(string name = "axilite_scoreboard", uvm_component parent);
        super.new(name, parent);
        analysis_export = new("analysis_export", this);
    endfunction: new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        write_count = 0;
        read_count  = 0;
        pass_count  = 0;
        fail_count  = 0;
    endfunction: build_phase

    function void write(axilite_transaction txn);
        if (txn.txn_type == axilite_transaction::WRITE) begin
            check_write(txn);
        end else begin
            check_read(txn);
        end
    endfunction: write

    function void check_write(axilite_transaction txn);
        bit [31:0] current_data;

        write_count++;

        // Check response
        if (txn.resp != 2'b00) begin
            `uvm_warning("SCOREBOARD", $sformatf("Write got non-OKAY response: %0d at addr 0x%08h", txn.resp, txn.addr))
        end

        // Update reference model with byte strobes
        if (ref_mem.exists(txn.addr))
            current_data = ref_mem[txn.addr];
        else
            current_data = 32'h0;

        for (int i = 0; i < 4; i++) begin
            if (txn.strb[i])
                current_data[i*8 +: 8] = txn.data[i*8 +: 8];
        end

        ref_mem[txn.addr] = current_data;

        `uvm_info("SCOREBOARD", $sformatf("Write stored: addr=0x%08h data=0x%08h (strb=0x%01h)", 
                  txn.addr, current_data, txn.strb), UVM_HIGH)
        pass_count++;
    endfunction: check_write

    function void check_read(axilite_transaction txn);
        bit [31:0] expected_data;

        read_count++;

        // Get expected data from reference model
        if (ref_mem.exists(txn.addr))
            expected_data = ref_mem[txn.addr];
        else
            expected_data = 32'h0;

        // Compare
        if (txn.rdata == expected_data) begin
            `uvm_info("SCOREBOARD", $sformatf("Read PASS: addr=0x%08h expected=0x%08h actual=0x%08h",
                      txn.addr, expected_data, txn.rdata), UVM_MEDIUM)
            pass_count++;
        end else begin
            `uvm_error("SCOREBOARD", $sformatf("Read FAIL: addr=0x%08h expected=0x%08h actual=0x%08h",
                       txn.addr, expected_data, txn.rdata))
            fail_count++;
        end
    endfunction: check_read

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("SCOREBOARD", "========== SCOREBOARD SUMMARY ==========", UVM_NONE)
        `uvm_info("SCOREBOARD", $sformatf("  Total Writes: %0d", write_count), UVM_NONE)
        `uvm_info("SCOREBOARD", $sformatf("  Total Reads:  %0d", read_count), UVM_NONE)
        `uvm_info("SCOREBOARD", $sformatf("  Pass Count:   %0d", pass_count), UVM_NONE)
        `uvm_info("SCOREBOARD", $sformatf("  Fail Count:   %0d", fail_count), UVM_NONE)
        `uvm_info("SCOREBOARD", "=========================================", UVM_NONE)

        if (fail_count > 0)
            `uvm_error("SCOREBOARD", "TEST FAILED - Mismatches detected")
        else
            `uvm_info("SCOREBOARD", "TEST PASSED", UVM_NONE)
    endfunction: report_phase

endclass: axilite_scoreboard
