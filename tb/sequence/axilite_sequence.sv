// Base sequence
class axilite_base_sequence extends uvm_sequence #(axilite_transaction);

    `uvm_object_utils(axilite_base_sequence)

    function new(string name = "axilite_base_sequence");
        super.new(name);
    endfunction: new

endclass: axilite_base_sequence


// Single write sequence
class axilite_write_sequence extends axilite_base_sequence;

    `uvm_object_utils(axilite_write_sequence)

    rand bit [31:0] addr;
    rand bit [31:0] data;
    rand bit [3:0]  strb;

    constraint c_strb { strb == 4'hF; }

    function new(string name = "axilite_write_sequence");
        super.new(name);
    endfunction: new

    task body();
        axilite_transaction txn;
        txn = axilite_transaction::type_id::create("txn");
        start_item(txn);
        txn.txn_type = axilite_transaction::WRITE;
        txn.addr     = addr;
        txn.data     = data;
        txn.strb     = strb;
        finish_item(txn);
    endtask: body

endclass: axilite_write_sequence


// Single read sequence
class axilite_read_sequence extends axilite_base_sequence;

    `uvm_object_utils(axilite_read_sequence)

    rand bit [31:0] addr;

    function new(string name = "axilite_read_sequence");
        super.new(name);
    endfunction: new

    task body();
        axilite_transaction txn;
        txn = axilite_transaction::type_id::create("txn");
        start_item(txn);
        txn.txn_type = axilite_transaction::READ;
        txn.addr     = addr;
        finish_item(txn);
    endtask: body

endclass: axilite_read_sequence


// Write-then-read sequence
class axilite_write_read_sequence extends axilite_base_sequence;

    `uvm_object_utils(axilite_write_read_sequence)

    rand bit [31:0] addr;
    rand bit [31:0] data;

    constraint addr_align_c { addr[1:0] == 2'b00; }
    constraint addr_range_c { addr < 32'h1000; }

    function new(string name = "axilite_write_read_sequence");
        super.new(name);
    endfunction: new

    task body();
        axilite_transaction txn;

        // Write
        txn = axilite_transaction::type_id::create("txn");
        start_item(txn);
        txn.txn_type = axilite_transaction::WRITE;
        txn.addr     = addr;
        txn.data     = data;
        txn.strb     = 4'hF;
        finish_item(txn);

        // Read back
        txn = axilite_transaction::type_id::create("txn");
        start_item(txn);
        txn.txn_type = axilite_transaction::READ;
        txn.addr     = addr;
        finish_item(txn);
    endtask: body

endclass: axilite_write_read_sequence


// Random sequence
class axilite_random_sequence extends axilite_base_sequence;

    `uvm_object_utils(axilite_random_sequence)

    rand int num_txns;

    constraint c_num { num_txns inside {[10:50]}; }

    function new(string name = "axilite_random_sequence");
        super.new(name);
    endfunction: new

    task body();
        axilite_transaction txn;
        repeat (num_txns) begin
            txn = axilite_transaction::type_id::create("txn");
            start_item(txn);
            if (!txn.randomize())
                `uvm_fatal("SEQ", "Randomization failed")
            finish_item(txn);
        end
    endtask: body

endclass: axilite_random_sequence


// Full memory test sequence - write then read all locations
class axilite_full_mem_sequence extends axilite_base_sequence;

    `uvm_object_utils(axilite_full_mem_sequence)

    int num_locations;

    function new(string name = "axilite_full_mem_sequence");
        super.new(name);
        num_locations = 64;  // Test first 64 locations
    endfunction: new

    task body();
        axilite_transaction txn;
        bit [31:0] test_data [];
        test_data = new[num_locations];

        // Write phase
        for (int i = 0; i < num_locations; i++) begin
            txn = axilite_transaction::type_id::create("txn");
            start_item(txn);
            txn.txn_type = axilite_transaction::WRITE;
            txn.addr     = i * 4;
            txn.data     = $urandom();
            txn.strb     = 4'hF;
            test_data[i] = txn.data;
            finish_item(txn);
        end

        // Read phase
        for (int i = 0; i < num_locations; i++) begin
            txn = axilite_transaction::type_id::create("txn");
            start_item(txn);
            txn.txn_type = axilite_transaction::READ;
            txn.addr     = i * 4;
            finish_item(txn);
        end
    endtask: body

endclass: axilite_full_mem_sequence
