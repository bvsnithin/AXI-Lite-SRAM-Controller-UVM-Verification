class axilite_agent extends uvm_agent;

    `uvm_component_utils(axilite_agent)

    axilite_driver    driver;
    axilite_monitor   monitor;
    axilite_sequencer sequencer;

    function new(string name = "axilite_agent", uvm_component parent);
        super.new(name, parent);
    endfunction: new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        monitor = axilite_monitor::type_id::create("monitor", this);

        if (get_is_active() == UVM_ACTIVE) begin
            driver    = axilite_driver::type_id::create("driver", this);
            sequencer = axilite_sequencer::type_id::create("sequencer", this);
        end
    endfunction: build_phase

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        if (get_is_active() == UVM_ACTIVE) begin
            driver.seq_item_port.connect(sequencer.seq_item_export);
        end
    endfunction: connect_phase

endclass: axilite_agent
