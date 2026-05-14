Outstanding.
Reset handling in the monitor is a **very professional fix** — most beginners miss that.

---

# 🟦 Day-20 — Scoreboard (End-to-End Checking)

This is where verification **actually finds bugs**.

Up to now:

* Driver **sent** transactions
* Monitor **observed** transactions

Now:
➡️ **Scoreboard decides PASS / FAIL**

---

## 🎯 Day-20 Goal

By the end of today, you will:

✔ Understand **what a scoreboard really does**
✔ Use `uvm_analysis_imp` correctly
✔ Compare **expected vs observed** transactions
✔ Report mismatches cleanly

---

## 1️⃣ REQUIRED THEORY (ESSENTIAL)

### ❓ What is a Scoreboard?

A scoreboard:

* Receives **observed transactions**
* Has a model of **expected behavior**
* Compares them

Basic idea:

```
Expected queue  ← Driver/Sequence
Observed queue  ← Monitor
          ↓
        Compare
```

For Day-20 (simple case):

* DUT is **pass-through**
* So **expected == observed**

---

### ❓ Why `uvm_analysis_imp`?

* Monitor uses `uvm_analysis_port`
* Scoreboard must **implement a write() method**
* `analysis_imp` connects port → implementation

---

## 2️⃣ Day-20 Architecture

```
Sequence → Driver → DUT → Monitor → Scoreboard
                                 (analysis_port)
```

Scoreboard is:

* Passive
* Non-driving
* Decision maker

---

## 3️⃣ Files to ADD / MODIFY

```
Day20_Scoreboard/
├── my_scoreboard.sv   (NEW)
├── my_env.sv          (MODIFIED)
```

---

## 4️⃣ Scoreboard Implementation (CORE)

### `my_scoreboard.sv`

```systemverilog
class my_scoreboard extends uvm_component;
    `uvm_component_utils(my_scoreboard)

    uvm_analysis_imp #(my_txn, my_scoreboard) imp;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        imp = new("imp", this);
    endfunction

    function void write(my_txn t);
        `uvm_info("SCB",
            $sformatf("Checking data = %0d", t.data),
            UVM_MEDIUM)

        // Simple pass-through check
        // (Future: compare with expected queue)
        if (t.data inside {[0:255]}) begin
            `uvm_info("SCB", "PASS", UVM_LOW)
        end else begin
            `uvm_error("SCB", "FAIL: Data out of range")
        end
    endfunction
endclass
```

📌 Today’s scoreboard is **simple on purpose**
📌 Structure matters more than complexity

---

## 5️⃣ Modify Environment (Connect Monitor → Scoreboard)

### `my_env.sv`

```systemverilog
class my_env extends uvm_env;
    `uvm_component_utils(my_env)

    my_driver      drv;
    my_sequencer   seqr;
    my_monitor     mon;
    my_scoreboard  scb;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        drv  = my_driver     ::type_id::create("drv", this);
        seqr = my_sequencer  ::type_id::create("seqr", this);
        mon  = my_monitor    ::type_id::create("mon", this);
        scb  = my_scoreboard ::type_id::create("scb", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        drv.seq_item_port.connect(seqr.seq_item_export);
        mon.ap.connect(scb.imp);   // ⭐ KEY LINE ⭐
    endfunction
endclass
```

---

## 6️⃣ Update `filelist.f`

Add **before `my_env.sv`**:

```text
my_scoreboard.sv
```

Correct order snippet:

```text
my_monitor.sv
my_scoreboard.sv
my_env.sv
```

---

## 7️⃣ Compile & Run (Same Flow)

```bash
xvlog -sv -L uvm -f filelist.f
xelab top -L uvm -debug typical
xsim top -runall
```

---

## 8️⃣ Expected Output (MUST SEE)

For each transaction:

```
[MON] Observed Data = 110
[SCB] Checking data = 110
[SCB] PASS
```

If mismatch:

```
UVM_ERROR [SCB] FAIL: Data out of range
```

---

## 9️⃣ Day-20 Completion Criteria

Day-20 is complete only if:

✔ Scoreboard receives transactions
✔ `analysis_port → analysis_imp` works
✔ PASS / FAIL messages appear
✔ No UVM_FATAL errors

---

## 🔑 Why Day-20 Is Huge

This is where you stop being:

> “Someone who writes UVM code”

And become:

> **“Someone who catches bugs”**

Everything after this (coverage, assertions) builds on this.

---

## 🔜 Next Preview

### **Day-21 — Functional Coverage (covergroup + sampling)**

---

### Now reply with:

* **“Day-20 ran successfully”** ✅
* Or paste the **first error / unexpected output**

You are progressing *exactly* as a real DV engineer should.
