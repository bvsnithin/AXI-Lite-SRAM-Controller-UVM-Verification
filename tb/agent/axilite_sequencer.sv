class axilite_sequencer extends uvm_sequencer #(axilite_transaction);

    `uvm_component_utils(axilite_sequencer)

    function new(string name = "axilite_sequencer", uvm_component parent);
        super.new(name, parent);
    endfunction: new

endclass: axilite_sequencer
