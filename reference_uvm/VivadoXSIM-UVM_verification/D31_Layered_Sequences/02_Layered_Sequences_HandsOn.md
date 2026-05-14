Perfect. We now **start Day-31 hands-on properly**.
No theory detours, no roadmap changes. This day is **FOUNDATIONAL**.

---

# 📅 Day-31: **Layered Sequences (Hands-On)**

## 🎯 Goal (Very Clear)

Model **real SoC stimulus flow** using **layers**:

```
RESET  →  CONFIG  →  TRAFFIC
```

Each layer is:

* Independent
* Reusable
* Ordered by a **virtual sequence**

---

## 🔹 Assumptions (Based on YOUR setup)

You already have:

* `my_txn`
* `my_sequencer`
* driver / monitor / scoreboard
* DUT + interface
* Virtual sequencer exists

We **reuse everything**.
No DUT changes.

---

## 🧱 Layer-1: Reset Sequence

### File: `reset_seq.sv`

Purpose:

* Drive known values
* Own the sequencer
* No randomization

```systemverilog
class reset_seq extends uvm_sequence #(my_txn);
  `uvm_object_utils(reset_seq)
  `uvm_declare_p_sequencer(my_sequencer)

  function new(string name="reset_seq");
    super.new(name);
  endfunction

  task body();
    `uvm_info("RESET_SEQ", "Starting reset layer", UVM_MEDIUM)

    p_sequencer.grab(this);

    repeat (2) begin
      my_txn tx = my_txn::type_id::create("tx");
      start_item(tx);
      tx.data  = 8'h00;
      tx.valid = 0;
      finish_item(tx);
    end

    p_sequencer.ungrab(this);
    `uvm_info("RESET_SEQ", "Reset layer done", UVM_MEDIUM)
  endtask
endclass
```

✅ Uses **grab** (correct for reset)
✅ No priority / arbitration here

---

## 🧱 Layer-2: Configuration Sequence

### File: `config_seq.sv`

Purpose:

* Program DUT setup
* Deterministic values
* Still **not traffic**

```systemverilog
class config_seq extends uvm_sequence #(my_txn);
  `uvm_object_utils(config_seq)

  function new(string name="config_seq");
    super.new(name);
  endfunction

  task body();
    `uvm_info("CFG_SEQ", "Starting configuration layer", UVM_MEDIUM)

    my_txn tx = my_txn::type_id::create("tx");
    start_item(tx);
    tx.data  = 8'hA5;   // example config value
    tx.valid = 1;
    finish_item(tx);

    `uvm_info("CFG_SEQ", "Configuration done", UVM_MEDIUM)
  endtask
endclass
```

✅ No grab
✅ No random
✅ Pure setup

---

## 🧱 Layer-3: Traffic Sequence

### File: `traffic_seq.sv`

Purpose:

* Normal stimulus
* Random / directed
* Reusable everywhere

```systemverilog
class traffic_seq extends uvm_sequence #(my_txn);
  `uvm_object_utils(traffic_seq)

  function new(string name="traffic_seq");
    super.new(name);
  endfunction

  task body();
    `uvm_info("TRAFFIC_SEQ", "Starting traffic layer", UVM_MEDIUM)

    repeat (5) begin
      my_txn tx = my_txn::type_id::create("tx");
      start_item(tx);
      assert(tx.randomize());
      finish_item(tx);
    end

    `uvm_info("TRAFFIC_SEQ", "Traffic done", UVM_MEDIUM)
  endtask
endclass
```

✅ Pure stimulus
✅ No reset/config mixing

---

## 🧠 Layered Virtual Sequence (Coordinator)

### File: `layered_vseq.sv`

This is the **heart of Day-31**.

```systemverilog
class layered_vseq extends uvm_sequence;
  `uvm_object_utils(layered_vseq)
  `uvm_declare_p_sequencer(virtual_sequencer)

  reset_seq   rst_s;
  config_seq  cfg_s;
  traffic_seq trf_s;

  function new(string name="layered_vseq");
    super.new(name);
  endfunction

  task body();
    `uvm_info("LAYERED_VSEQ", "Starting layered execution", UVM_MEDIUM)

    rst_s = reset_seq  ::type_id::create("rst_s");
    cfg_s = config_seq ::type_id::create("cfg_s");
    trf_s = traffic_seq::type_id::create("trf_s");

    rst_s.start(p_sequencer.seqr);
    cfg_s.start(p_sequencer.seqr);
    trf_s.start(p_sequencer.seqr);

    `uvm_info("LAYERED_VSEQ", "All layers completed", UVM_MEDIUM)
  endtask
endclass
```

### 🔑 IMPORTANT

* No parallelism
* No arbitration
* No priority
* **Strict order**

This is **SoC-style modeling**

---

## 🧪 Test Change (Minimal)

In `my_test.sv`:

```systemverilog
task run_phase(uvm_phase phase);
  layered_vseq vseq;

  phase.raise_objection(this);

  vseq = layered_vseq::type_id::create("vseq");
  vseq.start(env.vseqr);

  phase.drop_objection(this);
endtask
```

---

## ✅ What You Should Observe in Output

Order MUST be:

```
RESET_SEQ
CFG_SEQ
TRAFFIC_SEQ
```

Never interleaved.

If traffic appears before config → ❌ bug
If reset interleaves with traffic → ❌ bug

---

## 🧠 Why Day-31 Is Critical

You now understand:

* Why flat sequences are bad
* Why reset/config must be isolated
* How real verification teams structure tests
* Foundation for **policy control, reuse, regression**

---

## ⏭️ Next Day (Locked)

### 📅 Day-32: **Virtual Sequences + Policy Control**

* Switch traffic types
* Enable/disable layers
* Runtime behavior control

Say when ready:
**“Proceed Day-32”**
