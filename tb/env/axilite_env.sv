class axilite_env extends uvm_env;

    `uvm_component_utils(axilite_env)

    axilite_agent      agent;
    axilite_scoreboard scoreboard;

    function new(string name = "axilite_env", uvm_component parent);
        super.new(name, parent);
    endfunction: new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agent      = axilite_agent::type_id::create("agent", this);
        scoreboard = axilite_scoreboard::type_id::create("scoreboard", this);
    endfunction: build_phase

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        agent.monitor.ap.connect(scoreboard.analysis_export);
    endfunction: connect_phase

endclass: axilite_env
