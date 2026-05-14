Good.
This is **exactly** the right recovery move 👍
We will **freeze scope**, reduce surface area, and prove each pipe works **before** adding the next.

Below is **Step-1 only**.
Do **nothing else** until this passes.

---

# 🔒 STEP-1: Monitor → Scoreboard ONLY

(**No predictor. No compare. No DUT changes.**)

Goal:
👉 Prove that **analysis → TLM FIFO → blocking get()** works.

---

## 0️⃣ What is DISABLED (important)

❌ Predictor
❌ Expected path
❌ Comparison
❌ forever + dual get
❌ Any reference to `exp_fifo`

We are **only testing plumbing**.

---

# 1️⃣ MONITOR (unchanged except clarity)

### Ports

```systemverilog
class my_monitor extends uvm_monitor;

  uvm_analysis_port #(my_txn) ap;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction
```

### Write point

```systemverilog
task run_phase(uvm_phase phase);
  my_txn t;

  forever begin
    // wait for DUT accept event
    @(posedge vif.accept);

    t = my_txn::type_id::create("t");
    t.data = vif.data;

    `uvm_info("MON", $sformatf("Sending txn %0d", t.data), UVM_LOW)
    ap.write(t);
  end
endtask
```

---

# 2️⃣ SCOREBOARD (ACTUAL-ONLY VERSION)

### Ports + FIFO

```systemverilog
class my_scoreboard extends uvm_scoreboard;

  uvm_analysis_imp #(my_txn, my_scoreboard) act_imp;
  uvm_tlm_analysis_fifo #(my_txn) act_fifo;

  int rx_count;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    act_imp  = new("act_imp", this);
    act_fifo = new("act_fifo", this);
    rx_count = 0;
  endfunction
```

### Analysis callback

```systemverilog
function void write(my_txn t);
  `uvm_info("SCB", $sformatf("write() got %0d", t.data), UVM_LOW)
  act_fifo.write(t);
endfunction
```

### Run phase — **NO forever**

```systemverilog
task run_phase(uvm_phase phase);
  my_txn act;

  phase.raise_objection(this);
  `uvm_info("SCB", "Run phase entered", UVM_LOW)

  repeat (5) begin   // 🔒 fixed count for debug
    act_fifo.get(act);   // blocking
    rx_count++;

    `uvm_info("SCB",
      $sformatf("Received txn %0d (count=%0d)", act.data, rx_count),
      UVM_LOW)
  end

  `uvm_info("SCB", "Scoreboard done receiving", UVM_LOW)
  phase.drop_objection(this);
endtask
```

📌 This **must print 5 receives** or we stop.

---

# 3️⃣ ENV — CONNECT PHASE (MINIMAL)

```systemverilog
function void connect_phase(uvm_phase phase);
  super.connect_phase(phase);

  drv.seq_item_port.connect(seqr.seq_item_export);
  vseqr.seqr = seqr;

  // ONLY this connection
  mon.ap.connect(scb.act_imp);
endfunction
```

🚫 No predictor connections
🚫 No exp_fifo anywhere

---

# 4️⃣ EXPECTED LOG FLOW (CHECK THIS EXACTLY)

You **must** see this ordering:

```
[MON] Sending txn 21
[SCB] write() got 21
[SCB] Received txn 21 (count=1)

[MON] Sending txn 26
[SCB] write() got 26
[SCB] Received txn 26 (count=2)
...
[SCB] Scoreboard done receiving
```

### ❌ If you see:

* `write()` prints but no `get()` → FIFO issue
* no `write()` → connect issue
* simulation hangs → objection misuse

---

# 5️⃣ DO NOT PROCEED UNTIL THIS PASSES

Once this is **100% stable**, next steps are:

### Step-2

👉 Add **predictor only**, no compare
(exp_fifo receive debug)

### Step-3

👉 Enable **dual FIFO blocking compare**

---

Reply with **one of these only**:

**A)** “Step-1 passes, logs look correct”
**B)** “write() prints but get() blocks”
**C)** “write() never prints”

We will debug precisely based on that.
