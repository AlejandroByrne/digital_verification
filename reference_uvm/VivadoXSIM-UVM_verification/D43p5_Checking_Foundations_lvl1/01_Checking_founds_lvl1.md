Good. Let’s **hard-reset properly** and do this the **right way**, slowly, cleanly, and **from first principles**.

Forget Day-44, forget failures, forget FIFO.
Assume **you just finished Day-43 with a working UVM TB** (driver/monitor/sequences run fine, no checking).

---

# 🔁 RESET POINT (AGREED)

**You have:**

* Working DUT
* Working sequence → driver → DUT → monitor
* NO scoreboard
* NO predictor
* NO queues
* NO checking

**Goal now:**
👉 *Introduce checking in the simplest possible way without breaking the TB.*

---

# 📘 Day-43.5 — Checking Foundations (Fresh Start)

We will build **checking in 3 strictly ordered levels**:

| Level       | Purpose                  | Safety       |
| ----------- | ------------------------ | ------------ |
| **Level-1** | Learn *what checking is* | ❌ unsafe     |
| Level-2     | Add timing safety        | ⚠️ semi-safe |
| Level-3     | Real project style       | ✅ safe       |

---

# 🔵 LEVEL-1 — Queue–Queue (Concept Only)

## 🎯 Why this level exists

Before FIFO, phases, objections, etc., you must answer **one question**:

> “What is EXPECTED vs ACTUAL?”

That’s it.
No timing protection, no blocking, no env tricks.

---

## 🧠 Core idea (very important)

```
ACTUAL   = what DUT produced (from monitor)
EXPECTED = what DUT SHOULD have produced (from predictor)

Compare them.
```

---

## 📐 Architecture (Level-1 ONLY)

```
Sequence → Driver → DUT → Monitor ───┐
                                     ├──> Scoreboard (act_q)
Monitor ───────────> Predictor ──────┘
                         |
                         └──> exp_q
```

📌 **Rules**

* Predictor produces EXPECTED data
* Scoreboard receives ACTUAL data
* Both stored in queues
* Scoreboard pops & compares

---

# 🧩 Components (minimal & complete)

---

## 1️⃣ Transaction (assumed existing)

```systemverilog
class my_txn extends uvm_sequence_item;
  rand bit [7:0] data;

  `uvm_object_utils(my_txn)

  function new(string name="my_txn");
    super.new(name);
  endfunction
endclass
```

---

## 2️⃣ Monitor (only responsibility: OBSERVE)

```systemverilog
class my_monitor extends uvm_component;
  `uvm_component_utils(my_monitor)

  uvm_analysis_port #(my_txn) ap;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction

  task run_phase(uvm_phase phase);
    my_txn t;
    forever begin
      // sample DUT signals here
      t = my_txn::type_id::create("t");
      t.data = dut.data; // example
      ap.write(t);
      #10;
    end
  endtask
endclass
```

---

## 3️⃣ Predictor (LEVEL-1 = **pure function model**)

> Predictor answers: *“If DUT is correct, what should output be?”*

```systemverilog
class my_predictor extends uvm_component;
  `uvm_component_utils(my_predictor)

  uvm_analysis_imp #(my_txn, my_predictor) in_ap;
  my_txn exp_q[$];

  function new(string name, uvm_component parent);
    super.new(name, parent);
    in_ap = new("in_ap", this);
  endfunction

  function void write(my_txn t);
    my_txn exp = t.clone();
    exp.data = t.data; // pass-through DUT model
    exp_q.push_back(exp);

    `uvm_info("PRED",
      $sformatf("Expected enqueued: %0d", exp.data),
      UVM_LOW)
  endfunction
endclass
```

---

## 4️⃣ Scoreboard (LEVEL-1 = queue–queue)

```systemverilog
class my_scoreboard extends uvm_component;
  `uvm_component_utils(my_scoreboard)

  uvm_analysis_imp #(my_txn, my_scoreboard) act_imp;
  my_txn act_q[$];

  my_predictor pred; // handle to predictor

  function new(string name, uvm_component parent);
    super.new(name, parent);
    act_imp = new("act_imp", this);
  endfunction

  function void write(my_txn t);
    act_q.push_back(t);
    `uvm_info("SCB",
      $sformatf("Actual enqueued: %0d", t.data),
      UVM_LOW)
  endfunction

  task run_phase(uvm_phase phase);
    my_txn act, exp;

    forever begin
      if (act_q.size() > 0 && pred.exp_q.size() > 0) begin
        act = act_q.pop_front();
        exp = pred.exp_q.pop_front();

        if (act.data == exp.data)
          `uvm_info("SCB", "MATCH", UVM_LOW)
        else
          `uvm_error("SCB", "MISMATCH");
      end
      #1;
    end
  endtask
endclass
```

---

## 5️⃣ ENV — **MANDATORY, minimal, no logic**

This is where earlier confusion happened.
ENV **ONLY creates and connects**.

```systemverilog
class my_env extends uvm_env;
  `uvm_component_utils(my_env)

  my_monitor    mon;
  my_predictor  pred;
  my_scoreboard scb;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    mon  = my_monitor   ::type_id::create("mon",  this);
    pred = my_predictor ::type_id::create("pred", this);
    scb  = my_scoreboard::type_id::create("scb",  this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    mon.ap.connect(pred.in_ap);   // to predictor
    mon.ap.connect(scb.act_imp);  // to scoreboard

    scb.pred = pred; // scoreboard can access expected queue
  endfunction
endclass
```

📌 **No queues in env**
📌 **No comparisons in env**
📌 **No timing control in env**

---

# ✅ What you should see in simulation

```
[PRED] Expected enqueued: 25
[SCB] Actual enqueued: 25
[SCB] MATCH
```

---

# ⚠️ Why this level is UNSAFE (but necessary)

❌ Assumes perfect order
❌ Assumes no drops
❌ Assumes timing alignment
❌ Can false-pass easily

➡️ **This is intentional.**
This weakness is what Level-2 & Day-44 will expose.

---

# 🔒 ROADMAP (locked & clear)

| Topic        | Where                       |
| ------------ | --------------------------- |
| Queue–Queue  | **Day-43.5 Level-1 (DONE)** |
| FIFO–Queue   | Day-43.5 Level-2            |
| FIFO–FIFO    | Day-43.5 Level-3            |
| False Passes | **Day-44 ONLY**             |
| Phase misuse | **Day-44 ONLY**             |

---

## Next step (choose ONE)

**A)** Proceed to **Level-2 FIFO–Queue**
**B)** Explain **why Level-1 false-passes using this code**

No jumping. No mixing.
