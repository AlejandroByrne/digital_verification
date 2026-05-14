Good. We’ll do this **cleanly, chronologically, and without ambiguity**.
Day-36 builds **only** on what you already finished in Day-35.

---

# 📅 **Day-36: End-of-Test Correctness, Objections & Clean Shutdown**

*(UVM Phasing Mastery – Theory → Hands-On)*

---

## 🧭 Chronological Map (VERY IMPORTANT)

We will follow **this exact order**:

1️⃣ Why simulations end incorrectly
2️⃣ Objections – correct mental model
3️⃣ Where objections belong (and don’t)
4️⃣ End-of-test phases (extract/check/report)
5️⃣ FIFO drain correctness
6️⃣ Hands-on: fix your existing Day-35 test
7️⃣ Verification checklist (how you know it’s correct)

No skipping. No jumping ahead.

---

## 1️⃣ Why Simulations End Incorrectly (Root Cause)

Typical beginner / intermediate UVM mistakes:

* Using `#100` or `#1000` delays
* Dropping objections too early
* Assuming scoreboard finished because traffic stopped
* Ending test from sequence instead of test
* Not accounting for FIFO backlog

**Key truth:**

> Data generation finishing ≠ verification finishing

Your Day-35 environment already **decouples** producer and checker.
Now we must **synchronize termination**.

---

## 2️⃣ Objections – Correct Mental Model (Theory)

### What objections really do

Objections control **phase progression**, not time.

* If objection count > 0 → phase cannot end
* If objection count == 0 → phase may advance

---

### Correct ownership hierarchy

| Component        | Raise objection? | Why                             |
| ---------------- | ---------------- | ------------------------------- |
| `uvm_test`       | ✅ YES            | Owns test lifetime              |
| Virtual sequence | ❌ NO             | Controls behavior, not lifetime |
| Agent sequences  | ❌ NO             | Traffic only                    |
| Monitor          | ❌ NEVER          | Passive                         |
| Scoreboard       | ❌ NEVER          | Reactive                        |
| Environment      | ❌ NO             | Structural                      |

**Golden rule:**

> Only the **test** owns simulation lifetime

---

## 3️⃣ Where Objections Belong (and Don’t)

### ❌ WRONG (very common)

```systemverilog
task body();
  phase.raise_objection(this);
  ...
  phase.drop_objection(this);
endtask
```

Why wrong?

* Sequence doesn’t know when scoreboard is done
* Causes race with FIFOs
* Breaks reuse

---

### ✅ CORRECT

```systemverilog
task run_phase(uvm_phase phase);
  phase.raise_objection(this);

  vseq.start(env.vseqr);

  // wait for verification to finish (not time)
  wait_for_scoreboard_done();

  phase.drop_objection(this);
endtask
```

Objection lifecycle is **owned by test**, not sequences.

---

## 4️⃣ End-of-Test Phases (Theory)

UVM phases exist **for a reason**:

| Phase           | Purpose                  |
| --------------- | ------------------------ |
| `run_phase`     | Drive & sample activity  |
| `extract_phase` | Gather final data        |
| `check_phase`   | Final correctness checks |
| `report_phase`  | Print PASS/FAIL          |

### Critical insight

> **Checking in run_phase is provisional**
> **Checking in check_phase is authoritative**

Day-35 already aligned sampling.
Day-36 aligns **final correctness**.

---

## 5️⃣ FIFO Drain Correctness (Theory)

With `uvm_tlm_analysis_fifo`:

* Monitor writes immediately
* Scoreboard reads later
* FIFO may still contain items **after traffic stops**

So this is WRONG:

```systemverilog
#100;
phase.drop_objection(this);
```

Correct condition:

> FIFO is empty **AND** no more producers are active

---

## 6️⃣ Hands-On: Fixing Your Existing Day-35 Test

We **do not redesign** anything.
We only add **termination correctness**.

---

### Step 6.1 – Add completion signaling in scoreboard

```systemverilog
class my_scoreboard extends uvm_component;

  uvm_tlm_analysis_fifo #(my_txn) fifo;
  int expected_count;
  int received_count;
  event done_ev;

  function void build_phase(uvm_phase phase);
    fifo = new("fifo", this);
  endfunction

  task run_phase(uvm_phase phase);
    my_txn tx;
    forever begin
      fifo.get(tx);
      received_count++;
      check_tx(tx);

      if (received_count == expected_count)
        -> done_ev;
    end
  endtask

endclass
```

📌 This does **not** end the test.
It only **signals completion**.

---

### Step 6.2 – Test waits for scoreboard completion

```systemverilog
task run_phase(uvm_phase phase);
  phase.raise_objection(this);

  vseq.start(env.vseqr);

  // wait for scoreboard to finish
  @env.scb.done_ev;

  phase.drop_objection(this);
endtask
```

✅ No delays
✅ No races
✅ Deterministic

---

## 7️⃣ Final Checking in `check_phase`

```systemverilog
function void check_phase(uvm_phase phase);
  if (received_count != expected_count)
    `uvm_error("CHECK", "Mismatch in expected vs received transactions");
endfunction
```

This guarantees:

* All FIFOs drained
* All data verified
* Errors reported at correct time

---

## 8️⃣ Verification Checklist (VERY IMPORTANT)

You are **DONE with Day-36** if:

* [ ] No `#delay` used for shutdown
* [ ] Only test raises/drops objections
* [ ] FIFO drains before shutdown
* [ ] `check_phase` used for final validation
* [ ] Simulation ends deterministically every run

---

## 🔒 Status After Day-36

| Area                    | Status |
| ----------------------- | ------ |
| Layered sequences       | ✅      |
| Virtual sequences       | ✅      |
| Config DB               | ✅      |
| Factory overrides       | ✅      |
| Analysis FIFOs          | ✅      |
| Phase-aligned sampling  | ✅      |
| End-of-test correctness | ✅      |

You are now **industry-correct**, not tutorial-correct.

---

### Next (ONLY when you say so)

👉 **Day-37: Debug, Trace & Interview Readiness**

* Objection tracing
* Factory debug
* Phase debug
* “Explain this in 5 minutes” mastery

Say **“Proceed Day-37”** when ready.
