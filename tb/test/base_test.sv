class base_test extends uvm_test;

    `uvm_component_utils(base_test)

    axilite_env env;

    function new(string name = "base_test", uvm_component parent);
        super.new(name, parent);
    endfunction: new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = axilite_env::type_id::create("env", this);
    endfunction: build_phase

    task run_phase(uvm_phase phase);
        axilite_random_sequence seq;

        phase.raise_objection(this);
        `uvm_info("TEST", "Starting base_test", UVM_LOW)

        seq = axilite_random_sequence::type_id::create("seq");
        seq.num_txns = 20;
        seq.start(env.agent.sequencer);

        #100ns;
        phase.drop_objection(this);
        `uvm_info("TEST", "Completed base_test", UVM_LOW)
    endtask: run_phase

endclass: base_test


// Write-Read test
class write_read_test extends base_test;

    `uvm_component_utils(write_read_test)

    function new(string name = "write_read_test", uvm_component parent);
        super.new(name, parent);
    endfunction: new

    task run_phase(uvm_phase phase);
        axilite_write_read_sequence seq;

        phase.raise_objection(this);
        `uvm_info("TEST", "Starting write_read_test", UVM_LOW)

        repeat (10) begin
            seq = axilite_write_read_sequence::type_id::create("seq");
            if (!seq.randomize())
                `uvm_fatal("TEST", "Randomization failed")
            seq.start(env.agent.sequencer);
        end

        #100ns;
        phase.drop_objection(this);
        `uvm_info("TEST", "Completed write_read_test", UVM_LOW)
    endtask: run_phase

endclass: write_read_test


// Full memory test
class full_mem_test extends base_test;

    `uvm_component_utils(full_mem_test)

    function new(string name = "full_mem_test", uvm_component parent);
        super.new(name, parent);
    endfunction: new

    task run_phase(uvm_phase phase);
        axilite_full_mem_sequence seq;

        phase.raise_objection(this);
        `uvm_info("TEST", "Starting full_mem_test", UVM_LOW)

        seq = axilite_full_mem_sequence::type_id::create("seq");
        seq.start(env.agent.sequencer);

        #100ns;
        phase.drop_objection(this);
        `uvm_info("TEST", "Completed full_mem_test", UVM_LOW)
    endtask: run_phase

endclass: full_mem_test
