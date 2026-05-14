Perfect — let’s do a **clean, start‑to‑finish Level‑3 hands-on**, strictly inside **Day‑43.5 → Level‑3: TLM FIFO – TLM FIFO**. We’ll **upgrade your Level‑2 TB** step by step. No confusion about DUT FIFO, no protocol changes, no Level‑2 distractions.

---

# 📘 Day‑43.5 — **Level-3: TLM FIFO – TLM FIFO**

**Goal:**

* Fully block both expected and actual paths.
* Detect **missing, duplicate, or out-of-order transactions**.
* Keep **DUT unchanged**, **sequences unchanged**, **predictor/monitor safe**.

**Difference vs Level‑2:**

| Aspect         | Level-2             | Level-3               |
| -------------- | ------------------- | --------------------- |
| Expected       | TLM FIFO (blocking) | TLM FIFO (blocking)   |
| Actual         | Queue [$]           | TLM FIFO (blocking)   |
| Scoreboard     | get expected only   | dual blocking `get()` |
| False passes   | possible            | eliminated            |
| DUT / Protocol | unchanged           | unchanged             |

---

## 1️⃣ Predictor — Level-3

**Only small modification from Level‑2**. Same `exp_fifo`.

```systemverilog
class my_predictor extends uvm_component;
  `uvm_component_utils(my_predictor)

  uvm_analysis_imp #(my_txn, my_predictor) in_ap;
  uvm_tlm_analysis_fifo #(my_txn) exp_fifo;  // blocking FIFO

  function new(string name, uvm_component parent);
    super.new(name, parent);
    in_ap = new("in_ap", this);
    exp_fifo = new("exp_fifo", this);
  endfunction

  function void write(my_txn t);
    my_txn exp = t.clone();  // deep copy
    exp_fifo.write(exp);      // push to TLM FIFO

    `uvm_info("PRED",
      $sformatf("Expected written to FIFO: %0d", exp.data),
      UVM_LOW)
  endfunction
endclass
```

✅ Predictor remains **unchanged from Level‑2**, only `exp_fifo` used in scoreboard.

---

## 2️⃣ Monitor — Level-3

**Now we upgrade actual path to TLM FIFO**:

```systemverilog
class my_monitor extends uvm_component;
  `uvm_component_utils(my_monitor)

  uvm_analysis_port #(my_txn) ap;
  uvm_tlm_analysis_fifo #(my_txn) act_fifo;  // new blocking FIFO

  function new(string name, uvm_component parent);
    super.new(name, parent);
    ap = new("ap", this);
    act_fifo = new("act_fifo", this);
  endfunction

  function void write(my_txn t);
    my_txn act = t.clone();          // deep copy
    act_fifo.write(act);             // push to TLM FIFO

    `uvm_info("MON",
      $sformatf("Observed Data (ACCEPT EDGE) = %0d", act.data),
      UVM_LOW)
  endfunction
endclass
```

✅ Key: **actual path now has TLM FIFO**, enabling dual blocking comparison.

---

## 3️⃣ Scoreboard — Level-3

**Dual blocking `get()`**:

```systemverilog
class my_scoreboard extends uvm_component;
  `uvm_component_utils(my_scoreboard)

  uvm_analysis_imp #(my_txn, my_scoreboard) act_imp;
  my_predictor pred;
  my_monitor mon;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    act_imp = new("act_imp", this);
  endfunction

  function void write(my_txn t); // called by monitor
    // NO queue, monitor now blocks
    `uvm_info("SCB", $sformatf("Actual received: %0d", t.data), UVM_LOW)
  endfunction

  task run_phase(uvm_phase phase);
    my_txn exp, act;

    forever begin
      // dual blocking
      pred.exp_fifo.get(exp);   // block until expected
      mon.act_fifo.get(act);    // block until actual

      if (act.data == exp.data)
        `uvm_info("SCB", "MATCH", UVM_LOW)
      else
        `uvm_error("SCB", "MISMATCH");
    end
  endtask
endclass
```

✅ Now **scoreboard ensures**:

* One-to-one match
* No missing or extra actuals
* Out-of-order detected

---

## 4️⃣ ENV — Level-3

```systemverilog
// connections
mon.ap.connect(pred.in_ap);  // optional
scb.pred = pred;
scb.mon  = mon;
```

* **No other changes**.
* DUT, sequences, and test remain **exactly as Level‑2**.

---

## 5️⃣ Expected Simulation Observations

### Normal case

```
[PRED] Expected written to FIFO: 10
[MON] Observed Data (ACCEPT EDGE) = 10
[SCB] MATCH
...
[TEST] Scoreboard complete observed
```

### If actual is missing / duplicate / out-of-order

```
[SCB] MISMATCH  // immediately detected
```

* Unlike Level‑2, there is **no false-pass**.

---

## 6️⃣ Optional Bug Injection — Verify Level-3 catches errors

* Drop one actual in monitor → **SCB immediately errors**
* Duplicate DUT output → **SCB immediately errors**
* Out-of-order transaction → **SCB immediately errors**

✅ Demonstrates why **dual TLM FIFO + blocking get()** is essential.

---

## 7️⃣ Key Takeaways — Level-3

| Aspect                   | Level-2 | Level-3       |
| ------------------------ | ------- | ------------- |
| Expected FIFO            | ✅       | ✅             |
| Actual FIFO              | ❌ Queue | ✅ TLM FIFO    |
| Scoreboard blocking      | partial | dual blocking |
| Detect missing/duplicate | ❌       | ✅             |
| Detect out-of-order      | ❌       | ✅             |
| DUT change               | ❌       | ❌             |
| Protocol dependency      | ❌       | ❌             |

---

## 8️⃣ Next Steps After Level-3

* **Option A:** Inject multiple DUT bugs → Level-3 should catch all
* **Option B:** Transition to **Day-44 → Phase-aligned + Analysis FIFOs** for multi-stream correctness and regression hygiene
* **Option C:** Start **coverage & reporting refinements**

---

If you want, I can **draw a visual flow of Level-3 hands-on**, showing **Predictor FIFO → Scoreboard ← Monitor FIFO**, with **blocking `get()` and matching**, just like the visual we did for Level‑2.

Do you want me to do that next?
