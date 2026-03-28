class sa_env extends uvm_env;
  `uvm_component_utils(sa_env)

  // Top-level SA components
  sa_agent      sa_agent_h;
  sa_coverage   sa_coverage_h;
  sa_scoreboard sa_scoreboard_h;

  // Passive sub-agents: observe internal DUT hierarchy
  ha_agent                ha_agent_h;              // 1 half adder (bit 0)
  fa_agent                fa_agents[SA_WIDTH-1];   // SA_WIDTH-1 full adders (bits 1..WIDTH-1)

  function new(string name = "sa_env", uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    // ── Top-level active agent + subscribers ──
    sa_agent_h      = sa_agent::type_id::create("sa_agent", this);
    sa_coverage_h   = sa_coverage::type_id::create("sa_coverage_h", this);
    sa_scoreboard_h = sa_scoreboard::type_id::create("sa_scoreboard_h", this);

    // ── Passive HA agent ──
    // Set to PASSIVE *before* create so build_phase skips driver+sequencer
    uvm_config_db #(uvm_active_passive_enum)::set(this, "ha_agent", "is_active", UVM_PASSIVE);
    ha_agent_h = ha_agent::type_id::create("ha_agent", this);

    // ── Passive FA agents (one per full adder in the chain) ──
    for (int i = 0; i < SA_WIDTH-1; i++) begin
      string agent_name = $sformatf("fa_agent_%0d", i+1); // fa_agent_1, fa_agent_2, ...
      uvm_config_db #(uvm_active_passive_enum)::set(this, agent_name, "is_active", UVM_PASSIVE);
      fa_agents[i] = fa_agent::type_id::create(agent_name, this);
    end
  endfunction : build_phase

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    // SA top-level wiring
    sa_agent_h.analysis_port.connect(sa_coverage_h.analysis_export);
    sa_agent_h.analysis_port.connect(sa_scoreboard_h.imp);

    // Passive agents wire internally (monitor → coverage) in their own connect_phase.
    // Nothing extra needed here — they're self-contained observers.
  endfunction : connect_phase
endclass : sa_env
