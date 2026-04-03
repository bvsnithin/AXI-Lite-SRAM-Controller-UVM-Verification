class axilite_coverage extends uvm_subscriber #(axilite_transaction);
    `uvm_component_utils(axilite_coverage)

    axilite_transaction txn;

    covergroup cg_axilite;
        option.per_instance = 1;
        option.name = "cg_axilite";

        // Transaction Type
        cp_txn_type: coverpoint txn.txn_type {
            bins write = {axilite_transaction::WRITE};
            bins read  = {axilite_transaction::READ};
        }

        // Address Coverage (assuming 4KB range as per transaction constraints)
        cp_addr: coverpoint txn.addr {
            bins low_addr  = {[32'h0000 : 32'h03FF]};
            bins mid_addr  = {[32'h0400 : 32'h07FF]};
            bins high_addr = {[32'h0800 : 32'h0FFF]};
        }

        // Write Strobe
        cp_strb: coverpoint txn.strb {
            bins all_bytes = {4'hF};
            bins single_byte = {4'h1, 4'h2, 4'h4, 4'h8};
            bins multi_byte = {4'h3, 4'h6, 4'hC, 4'h7, 4'hE};
        }

        // Response
        cp_resp: coverpoint txn.resp {
            bins OKAY   = {2'b00};
            bins EXOKAY = {2'b01};
            bins SLVERR = {2'b10};
            bins DECERR = {2'b11};
        }

        // Cross coverage
        cross cp_txn_type, cp_resp;
        cross cp_txn_type, cp_addr;
    endgroup

    function new(string name = "axilite_coverage", uvm_component parent);
        super.new(name, parent);
        cg_axilite = new();
    endfunction

    virtual function void write(axilite_transaction t);
        this.txn = t;
        cg_axilite.sample();
    endfunction
endclass
