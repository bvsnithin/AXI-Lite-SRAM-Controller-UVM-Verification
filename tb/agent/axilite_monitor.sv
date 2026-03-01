class axilite_monitor extends uvm_monitor;

    `uvm_component_utils(axilite_monitor)

    virtual axilite_if vif;

    uvm_analysis_port #(axilite_transaction) ap;

    function new(string name = "axilite_monitor", uvm_component parent);
        super.new(name, parent);
        ap = new("ap", this);
    endfunction: new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db #(virtual axilite_if)::get(this, "", "vif", vif))
            `uvm_fatal("MONITOR", "Failed to get virtual interface")
    endfunction: build_phase

    task run_phase(uvm_phase phase);
        @(posedge vif.rst_n);

        fork
            monitor_write();
            monitor_read();
        join
    endtask: run_phase

    task monitor_write();
        axilite_transaction txn;
        logic [31:0] addr, data;
        logic [3:0]  strb;

        forever begin
            // Wait for write address handshake
            @(vif.mon_cb);
            while (!(vif.mon_cb.awvalid && vif.mon_cb.awready))
                @(vif.mon_cb);

            addr = vif.mon_cb.awaddr;

            // Capture write data (may happen same cycle or later)
            if (vif.mon_cb.wvalid && vif.mon_cb.wready) begin
                data = vif.mon_cb.wdata;
                strb = vif.mon_cb.wstrb;
            end else begin
                while (!(vif.mon_cb.wvalid && vif.mon_cb.wready))
                    @(vif.mon_cb);
                data = vif.mon_cb.wdata;
                strb = vif.mon_cb.wstrb;
            end

            // Wait for write response
            while (!(vif.mon_cb.bvalid && vif.mon_cb.bready))
                @(vif.mon_cb);

            txn = axilite_transaction::type_id::create("txn");
            txn.txn_type = axilite_transaction::WRITE;
            txn.addr     = addr;
            txn.data     = data;
            txn.strb     = strb;
            txn.resp     = vif.mon_cb.bresp;

            `uvm_info("MONITOR", $sformatf("Write observed: %s", txn.convert2string()), UVM_MEDIUM)
            ap.write(txn);
        end
    endtask: monitor_write

    task monitor_read();
        axilite_transaction txn;

        forever begin
            // Wait for read address handshake
            @(vif.mon_cb);
            while (!(vif.mon_cb.arvalid && vif.mon_cb.arready))
                @(vif.mon_cb);

            txn = axilite_transaction::type_id::create("txn");
            txn.txn_type = axilite_transaction::READ;
            txn.addr     = vif.mon_cb.araddr;

            // Wait for read data
            while (!(vif.mon_cb.rvalid && vif.mon_cb.rready))
                @(vif.mon_cb);

            txn.rdata = vif.mon_cb.rdata;
            txn.resp  = vif.mon_cb.rresp;

            `uvm_info("MONITOR", $sformatf("Read observed: %s", txn.convert2string()), UVM_MEDIUM)
            ap.write(txn);
        end
    endtask: monitor_read

endclass: axilite_monitor
