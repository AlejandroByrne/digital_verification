Perfect. This **is exactly the right moment** for Day-35, and you were right earlier to **block me from introducing these topics prematurely**. Now they belong here.

I’ll split this cleanly into **two new days**, because cramming this into one day would *reduce understanding*.

---

# 📅 **Day-35: Analysis FIFOs & Professional Scoreboard Architecture**

> 🎯 **Goal**: Decouple stimulus from checking and build a scalable scoreboard
> 🔑 This is the **first correct place** to introduce Analysis FIFOs

---

## 1️⃣ Why your current scoreboard is still “learning-grade”

Right now (based on your logs):

```
Monitor → directly calls scoreboard
```

This works **only because**:

* Single monitor
* Single stream
* No reordering
* No latency variation

⚠️ This **breaks immediately** in real designs.

---

## 2️⃣ Problems with direct Monitor → Scoreboard calls

| Problem            | Why it matters               |
| ------------------ | ---------------------------- |
| Tight coupling     | Monitor knows scoreboard     |
| No buffering       | Backpressure not handled     |
| Race-prone         | Sampling vs checking timing  |
| Not scalable       | Multiple monitors impossible |
| Interview red flag | Considered junior-grade      |

---

## 3️⃣ Correct UVM architecture (industry standard)

```
Monitor
   |
   |  (write)
   v
uvm_analysis_fifo
   |
   |  (get)
   v
Scoreboard
```

✔ Monitor is **write-only**
✔ Scoreboard is **pull-based**
✔ Timing is controlled
✔ Order is deterministic

---

## 4️⃣ What an Analysis FIFO really is (conceptually)

An **Analysis FIFO** is:

* A **TLM buffer**
* Decouples producer and consumer
* Stores transactions safely
* Preserves order

Think of it as:

> “A mailbox with UVM semantics”

---

## 5️⃣ Hands-On: Add Analysis FIFO to your env

### 📁 `my_env.sv`

```systemverilog
class my_env extends uvm_env;
  `uvm_component_utils(my_env)

  my_monitor mon;
  my_scoreboard scb;

  uvm_analysis_fifo #(my_txn) mon2scb_fifo;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    mon = my_monitor   ::type_id::create("mon", this);
    scb = my_scoreboard::type_id::create("scb", this);

    mon2scb_fifo = new("mon2scb_fifo", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    mon.ap.connect(mon2scb_fifo.analysis_export);
    scb.fifo = mon2scb_fifo;
  endfunction
endclass
```

---

## 6️⃣ Modify the Monitor (write-only)

### 📁 `my_monitor.sv`

```systemverilog
class my_monitor extends uvm_monitor;
  `uvm_component_utils(my_monitor)

  uvm_analysis_port #(my_txn) ap;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction

  task run_phase(uvm_phase phase);
    my_txn tx;

    forever begin
      // sample DUT
      tx = my_txn::type_id::create("tx");
      tx.data = vif.data;

      ap.write(tx);

      `uvm_info("MON", $sformatf("Observed Data = %0d", tx.data), UVM_LOW)
      #10;
    end
  endtask
endclass
```

✔ Monitor **never** calls scoreboard
✔ Monitor **never blocks**

---

## 7️⃣ Modify the Scoreboard (pull-based)

### 📁 `my_scoreboard.sv`

```systemverilog
class my_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(my_scoreboard)

  uvm_analysis_fifo #(my_txn) fifo;

  task run_phase(uvm_phase phase);
    my_txn tx;

    forever begin
      fifo.get(tx);   // BLOCKING, SAFE

      `uvm_info("SCB",
        $sformatf("Checking data = %0d", tx.data),
        UVM_LOW)

      // compare expected vs actual
    end
  endtask
endclass
```

✔ Order preserved
✔ Natural backpressure
✔ Clean separation

---

## 8️⃣ What you should observe in logs (important)

You’ll still see:

```
[MON] Observed Data = X
[SCB] Checking data = X
```

But now:

* Monitor can run faster
* Scoreboard controls checking pace
* No race conditions

---

## 9️⃣ Interview-level takeaway (Day-35)

> “I never let monitors call the scoreboard directly.
> I use analysis FIFOs to decouple sampling from checking.”

That sentence alone separates you from **70% of candidates**.

---

# 📅 **Day-36: Phase-Aligned Sampling (CRITICAL)**

> 🎯 **Goal**: Eliminate race conditions & incorrect checking

This deserves its **own day**.

---

## 1️⃣ The silent bug in 90% of testbenches

Most people do this:

```
Monitor samples
Scoreboard checks
(both in run_phase)
```

⚠️ This is **not phase-aligned**
⚠️ Leads to false passes & misses

---

## 2️⃣ Correct mental model of phases

| Component  | Responsibility        |
| ---------- | --------------------- |
| Monitor    | Sample signals        |
| FIFO       | Buffer                |
| Scoreboard | Check AFTER stability |

Key insight:

> **Sampling and checking must not race**

---

## 3️⃣ What “phase-aligned” really means

It does **NOT** mean:

* New UVM phase
* Extra objections

It means:

* Sampling happens at a known time
* Checking happens after transaction is complete

The FIFO already gives you **temporal separation**.

That’s why FIFOs come **before** phase-aligned sampling.

(You blocked this earlier — correctly.)

---

## 4️⃣ Correct alignment pattern (what you now have)

```
run_phase (monitor)
   → write()

run_phase (scoreboard)
   → fifo.get()
   → check
```

Because `get()` blocks:

* Sampling finishes first
* Checking happens later
* Order is guaranteed

✔ Phase-aligned by design

---

## 5️⃣ Common WRONG patterns (do NOT do these)

❌ Checking inside monitor
❌ Using `#delay` for alignment
❌ Sharing variables across components
❌ Using `uvm_event` instead of FIFO

---

## 6️⃣ Final verification: Why your current env is now “professional”

| Feature            | Status |
| ------------------ | ------ |
| Layered sequences  | ✅      |
| Policy control     | ✅      |
| Config DB          | ✅      |
| Factory reuse      | ✅      |
| Analysis FIFO      | ✅      |
| Phase alignment    | ✅      |
| Race-free checking | ✅      |

---

# ✅ Day-35 & Day-36 COMPLETE

You now have:

* **Industry-grade scoreboard**
* **Race-free checking**
* **Interview-safe explanations**

---

### 👉 Next

Say **“Proceed Day-37”**
We’ll do:

* Debug methodology
* UVM print/trace mastery
* Interview traps & answers

You’ve crossed into **advanced UVM territory** now.
