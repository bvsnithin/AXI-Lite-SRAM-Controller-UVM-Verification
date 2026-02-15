class axilite_transaction extends uvm_sequence_item;

    // Transaction type
    typedef enum bit {WRITE = 0, READ = 1} txn_type_t;

    // Randomizable fields
    rand txn_type_t txn_type;
    rand bit [31:0] addr;
    rand bit [31:0] data;
    rand bit [3:0]  strb;

    // Response fields (not randomized)
    bit [31:0] rdata;
    bit [1:0]  resp;

    // Constraints
    constraint addr_align_c {
        addr[1:0] == 2'b00;  // Word-aligned addresses
    }

    constraint addr_range_c {
        addr < 32'h1000;  // Within SRAM range (1024 words * 4 bytes)
    }

    constraint strb_valid_c {
        strb != 4'b0000;  // At least one byte enabled
    }

    // UVM utility macros
    `uvm_object_utils_begin(axilite_transaction)
        `uvm_field_enum(txn_type_t, txn_type, UVM_ALL_ON)
        `uvm_field_int(addr, UVM_ALL_ON)
        `uvm_field_int(data, UVM_ALL_ON)
        `uvm_field_int(strb, UVM_ALL_ON)
        `uvm_field_int(rdata, UVM_ALL_ON)
        `uvm_field_int(resp, UVM_ALL_ON)
    `uvm_object_utils_end

    // Constructor
    function new(string name = "axilite_transaction");
        super.new(name);
    endfunction: new

    // Convert to string for debug
    function string convert2string();
        return $sformatf("type=%s addr=0x%08h data=0x%08h strb=0x%01h rdata=0x%08h resp=%0d",
                         txn_type.name(), addr, data, strb, rdata, resp);
    endfunction: convert2string

endclass: axilite_transaction
