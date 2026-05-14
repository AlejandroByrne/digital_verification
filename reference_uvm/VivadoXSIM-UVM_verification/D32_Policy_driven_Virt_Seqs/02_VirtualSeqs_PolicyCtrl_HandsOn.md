Good. Proceeding **Day-32 hands-on** — clean, aligned, no reshuffle.

---

# 📅 **DAY-32: Virtual Sequences + Policy Control (HANDS-ON)**

> **Goal**: Decide **WHEN / WHICH traffic runs**, without touching env, driver, monitor, DUT.

You will **reuse Day-31 exactly as-is**.
We add **only policy logic**.

---

## 🧠 Day-32 Mental Model (Lock This)

* **Sequencer** → unchanged
* **Driver** → unchanged
* **Env** → unchanged
* **Only virtual sequence gets smarter**

> Day-31 = *WHAT runs*
> Day-32 = *WHEN / WHICH runs*

---

## 1️⃣ Define policy (mode)

Create a **simple enum** (can be inside `layered_vseq.sv` or a common pkg):

```systemverilog
typedef enum { SANITY, STRESS } test_mode_e;
```

---

## 2️⃣ Create two traffic sequences

### 🔹 `sanity_traffic_seq.sv`

Light, predictable traffic.

```systemverilog
class sanity_traffic_seq extends uvm_sequence #(my_txn);
  `uvm_object_utils(sanity_traffic_seq)

  function new(string name="sanity_traffic_seq");
    super.new(name);
  endfunction

  task body();
    `uvm_info("SANITY_SEQ", "Running sanity traffic", UVM_MEDIUM)

    repeat (5) begin
      my_txn tx = my_txn::type_id::create("tx");
      start_item(tx);
      tx.randomize() with { data inside {[8'h10:8'h1F]}; };
      finish_item(tx);
    end
  endtask
endclass
```

---

### 🔹 `stress_traffic_seq.sv`

Heavy/random traffic.

```systemverilog
class stress_traffic_seq extends uvm_sequence #(my_txn);
  `uvm_object_utils(stress_traffic_seq)

  function new(string name="stress_traffic_seq");
    super.new(name);
  endfunction

  task body();
    `uvm_info("STRESS_SEQ", "Running stress traffic", UVM_MEDIUM)

    repeat (50) begin
      my_txn tx = my_txn::type_id::create("tx");
      start_item(tx);
      tx.randomize();
      finish_item(tx);
    end
  endtask
endclass
```

✔ Same transaction
✔ Same sequencer
✔ Only behavior differs

---

## 3️⃣ Modify **layered virtual sequence** (CORE STEP)

This is **Day-32 essence**.

### 🔹 `layered_vseq.sv`

```systemverilog
class layered_vseq extends uvm_sequence;
  `uvm_object_utils(layered_vseq)
  `uvm_declare_p_sequencer(virtual_sequencer)

  test_mode_e mode;

  reset_seq          rst_s;
  config_seq         cfg_s;
  sanity_traffic_seq san_s;
  stress_traffic_seq str_s;

  function new(string name="layered_vseq");
    super.new(name);
    mode = SANITY; // default
  endfunction

  task body();
    `uvm_info("LAYERED_VSEQ", "Starting layers", UVM_MEDIUM)

    rst_s = reset_seq::type_id::create("rst_s");
    cfg_s = config_seq::type_id::create("cfg_s");
    san_s = sanity_traffic_seq::type_id::create("san_s");
    str_s = stress_traffic_seq::type_id::create("str_s");

    rst_s.start(p_sequencer.seqr);
    cfg_s.start(p_sequencer.seqr);

    if (mode == SANITY) begin
      `uvm_info("LAYERED_VSEQ", "Policy: SANITY", UVM_MEDIUM)
      san_s.start(p_sequencer.seqr);
    end
    else begin
      `uvm_info("LAYERED_VSEQ", "Policy: STRESS", UVM_MEDIUM)
      str_s.start(p_sequencer.seqr);
    end

    `uvm_info("LAYERED_VSEQ", "All layers completed", UVM_MEDIUM)
  endtask
endclass
```

🚨 **No arbitration**
🚨 **No factory**
🚨 **No config_db yet**

---

## 4️⃣ Control policy from **test** (NOT env)

### 🔹 `my_test.sv`

```systemverilog
class my_test extends uvm_test;
  `uvm_component_utils(my_test)

  my_env env;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = my_env::type_id::create("env", this);
  endfunction

  task run_phase(uvm_phase phase);
    layered_vseq vseq;
    phase.raise_objection(this);

    vseq = layered_vseq::type_id::create("vseq");
    vseq.mode = STRESS;   // 🔁 Change to SANITY / STRESS
    vseq.start(env.vseqr);

    phase.drop_objection(this);
  endtask
endclass
```

✔ One line switches behavior
✔ No recompilation logic change
✔ Interview-grade policy control

---

## ✅ What You Should Observe

### SANITY mode

* Few transactions
* Narrow data range
* Short sim

### STRESS mode

* Many transactions
* Full random
* Long sim

**Same env. Same DUT. Same driver.**

---

## ✅ Day-32 Completion Criteria

✔ Policy-based traffic selection
✔ Runtime behavior switch
✔ Virtual sequence control
✔ Zero env changes

If this runs → **Day-32 DONE**.

---

## ⏭ Next (DO NOT IMPLEMENT YET)

**Day-33: Configuration DB**

* Move `mode` into `uvm_config_db`
* No more hard-coding in test

---

### Say **one line only** when ready:

**“Day-32 runs clean, proceed Day-33.”**

We are fully aligned now.
