Perfect. This is the **right call**.
Let’s **finish Day-36 properly** and **kill the shutdown bug permanently**.

I’ll do this in **three tight steps**:

1. State the **canonical rules** (so you know *why* this works)
2. Show the **correct scoreboard pattern** (no events, no hangs)
3. Show the **correct test-side objection handling**

No pseudo-UVM, no shortcuts.

---

# 📅 Day-36 — Canonical Shutdown Pattern (FINAL)

## 🎯 Goal (single mental thread)

> **Let `run_phase` exit naturally when work is done,
> and let the test drop the final objection.**

No events.
No waits.
No `#delays`.
No forced FIFO empty checks.

---

## 1️⃣ Canonical rules (lock these)

### 🔒 Rule 1 — **Scoreboards NEVER own objections**

Why?

* They don’t know test intent
* They don’t control phase lifetime
* They run indefinitely by design

Scoreboard job = **consume + check**, nothing else.

---

### 🔒 Rule 2 — **No events for phase completion**

Why events fail (you saw it):

* Events don’t terminate threads
* `wait(event)` ≠ phase completion
* Races between trigger & wait
* `forever` loops stay alive

👉 Events are **notification**, not **lifecycle control**

---

### 🔒 Rule 3 — **Completion is count-based**

This stays **exactly as promised**:

```text
actual_count == expected_count
```

That is the **only truth**.

---

### 🔒 Rule 4 — **`run_phase` must exit**

If `run_phase` does not return, UVM cannot:

* safely transition phases
* guarantee `extract/check/report`

This is the core of your hang.

---

## 2️⃣ The CORRECT scoreboard implementation

### ❌ What you had (problematic)

```systemverilog
forever begin
  fifo.get(ts);   // blocks forever
  actual_count++;
end
```

Even after completion → thread never exits.

---

### ✅ Canonical scoreboard (FIXED)

```systemverilog
class my_scoreboard extends uvm_component;

  uvm_tlm_analysis_fifo #(my_txn) fifo;
  int expected_count;
  int actual_count;

  function void build_phase(uvm_phase phase);
    fifo = new("fifo", this);
    actual_count = 0;
  endfunction

  task run_phase(uvm_phase phase);
    my_txn ts;

    // Loop only until expected work is complete
    while (actual_count < expected_count) begin
      fifo.get(ts);  // BLOCKING, SAFE

      actual_count++;

      `uvm_info("SCB",
        $sformatf("Checking data = %0d (%0d/%0d)",
                  ts.data, actual_count, expected_count),
        UVM_LOW)

      if (ts.data inside {[0:255]})
        `uvm_info("SCB", "Pass", UVM_LOW)
      else
        `uvm_error("SCB", "Fail: Data out of range")
    end

    `uvm_info("SCB",
      "Scoreboard run_phase completed cleanly",
      UVM_LOW)
  endtask

endclass
```

### 🔑 Why this works

* `fifo.get()` still blocks ✔
* But only **while work is expected**
* When last transaction is consumed:

  * loop exits
  * `run_phase` returns
  * scoreboard thread dies cleanly
* FIFO drain happens **naturally**
* No race, no event, no hang

This is the **industry-standard pattern**.

---

## 3️⃣ Correct TEST-SIDE objection handling

### ❌ What you were doing

```systemverilog
wait (scb_done_event.triggered); // ❌ fragile
phase.drop_objection(this);
```

Wrong abstraction layer.

---

### ✅ Canonical test shutdown

```systemverilog
task run_phase(uvm_phase phase);
  phase.raise_objection(this, "Test starting");

  // Start traffic (sequences)
  vseq.start(env.vseqr);

  // Wait for sequences to finish
  vseq.wait_for_sequence_end();

  // IMPORTANT:
  // At this point:
  // - No more stimulus
  // - Scoreboard will naturally finish
  // - run_phase threads will exit

  phase.drop_objection(this, "Test completed");
endtask
```

### 🔑 Why this works

* Test owns **intent**
* Sequences define **expected_count**
* Scoreboard exits on its own
* UVM waits for all run_phase threads
* Then transitions:

  ```
  run → extract → check → report
  ```
* Simulation exits **deterministically**

---

## 4️⃣ How this fixes YOUR exact hang

From your log:

```
[SCB] All expected transaction checked
[TEST] Waiting Scoreboard to complete   ❌
```

With canonical pattern:

* That wait line **does not exist**
* Scoreboard finishes automatically
* Test does not wait on scoreboard
* Phase transition proceeds
* Simulator exits

No coordination needed.

---

## 5️⃣ Day-36 is now COMPLETE when:

You can confirm all of these:

✅ No `uvm_event` for shutdown
✅ No `wait()` in test for scoreboard
✅ Scoreboard `run_phase` exits
✅ Objection owned only by test
✅ `check_phase` and `report_phase` run
✅ Simulation exits cleanly every time

If these are true → **Day-36 DONE** 🔒

---

## 🚀 What comes next (now it’s safe)

### 📅 **Day-37: Analysis Architecture**

Natural continuation:

* `analysis_port` vs `analysis_fifo`
* Broadcast vs point-to-point
* Multi-subscriber scoreboards
* Why FIFOs were delayed until now (this exact reason)

---

If you want, next I can:

* 🔹 Validate your modified scoreboard code line-by-line
* 🔹 Show how `check_phase` should now look
* 🔹 Start **Day-37** cleanly

Just tell me.
