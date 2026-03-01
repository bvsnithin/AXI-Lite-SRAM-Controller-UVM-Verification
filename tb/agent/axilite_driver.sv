class axilite_driver extends uvm_driver #(axilite_transaction);

    `uvm_component_utils(axilite_driver)

    virtual axilite_if vif;

    function new(string name = "axilite_driver", uvm_component parent);
        super.new(name, parent);
    endfunction: new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db #(virtual axilite_if)::get(this, "", "vif", vif))
            `uvm_fatal("DRIVER", "Failed to get virtual interface")
    endfunction: build_phase

    task run_phase(uvm_phase phase);
        axilite_transaction txn;

        // Initialize signals
        vif.drv_cb.awaddr  <= '0;
        vif.drv_cb.awvalid <= 1'b0;
        vif.drv_cb.wdata   <= '0;
        vif.drv_cb.wstrb   <= '0;
        vif.drv_cb.wvalid  <= 1'b0;
        vif.drv_cb.bready  <= 1'b0;
        vif.drv_cb.araddr  <= '0;
        vif.drv_cb.arvalid <= 1'b0;
        vif.drv_cb.rready  <= 1'b0;

        // Wait for reset
        @(posedge vif.rst_n);
        @(posedge vif.clk);

        forever begin
            seq_item_port.get_next_item(txn);
            `uvm_info("DRIVER", $sformatf("Driving: %s", txn.convert2string()), UVM_MEDIUM)

            if (txn.txn_type == axilite_transaction::WRITE)
                drive_write(txn);
            else
                drive_read(txn);

            seq_item_port.item_done();
        end
    endtask: run_phase

    task drive_write(axilite_transaction txn);
        logic aw_done, w_done;

        // Drive write address and data simultaneously
        @(vif.drv_cb);
        vif.drv_cb.awaddr  <= txn.addr;
        vif.drv_cb.awvalid <= 1'b1;
        vif.drv_cb.wdata   <= txn.data;
        vif.drv_cb.wstrb   <= txn.strb;
        vif.drv_cb.wvalid  <= 1'b1;

        // Wait for both address and data handshakes (can happen simultaneously)
        aw_done = 0;
        w_done = 0;
        while (!aw_done || !w_done) begin
            @(vif.drv_cb);
            if (vif.drv_cb.awready && !aw_done) begin
                aw_done = 1;
                vif.drv_cb.awvalid <= 1'b0;
            end
            if (vif.drv_cb.wready && !w_done) begin
                w_done = 1;
                vif.drv_cb.wvalid <= 1'b0;
            end
        end

        // Wait for response
        vif.drv_cb.bready <= 1'b1;
        do @(vif.drv_cb);
        while (!vif.drv_cb.bvalid);

        txn.resp = vif.drv_cb.bresp;
        vif.drv_cb.bready <= 1'b0;
    endtask: drive_write

    task drive_read(axilite_transaction txn);
        // Drive read address
        @(vif.drv_cb);
        vif.drv_cb.araddr  <= txn.addr;
        vif.drv_cb.arvalid <= 1'b1;

        // Wait for address handshake
        do @(vif.drv_cb);
        while (!vif.drv_cb.arready);
        vif.drv_cb.arvalid <= 1'b0;

        // Wait for read data
        vif.drv_cb.rready <= 1'b1;
        do @(vif.drv_cb);
        while (!vif.drv_cb.rvalid);

        txn.rdata = vif.drv_cb.rdata;
        txn.resp  = vif.drv_cb.rresp;
        vif.drv_cb.rready <= 1'b0;
    endtask: drive_read

endclass: axilite_driver
