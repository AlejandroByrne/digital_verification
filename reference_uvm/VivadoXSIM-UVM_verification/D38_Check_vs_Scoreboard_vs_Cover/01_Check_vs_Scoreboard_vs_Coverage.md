Perfect — proceeding 👍
We are now **officially entering Day-38**, and this day **does require hands-on**, but in a *very controlled, minimal, correctness-driven* way.

---

# 📅 **Day-38: Check vs Scoreboard vs Coverage

(Separation of Concerns)**

### 🎯 Single mental question of the day

> **“Who is responsible for correctness, and who is responsible for measurement — and why must they never be mixed?”**

If this is misunderstood, teams ship:

* unmaintainable scoreboards
* flaky regressions
* meaningless coverage

---

## 0️⃣ Why Day-38 exists (context lock)

You now have:

* ✅ Correct shutdown (Day-36)
* ✅ Correct dataflow architecture (Day-37)

Now a **new risk appears**:

> You *can* receive data correctly —
> but you might **validate it in the wrong place**.

That’s what Day-38 fixes.

---

## 1️⃣ The three roles (hard separation)

### 🔹 1. **Scoreboard**

**Purpose:**
✔ Decide **PASS / FAIL**

**Owns:**

* Expected vs actual comparison
* Ordering rules
* End-of-test correctness decision

**Must NOT:**

* Collect coverage
* Generate statistics
* Decide when simulation ends (already fixed in Day-36)

---

### 🔹 2. **Checkers**

**Purpose:**
✔ Validate **protocol rules**, not data correctness

Examples:

* Handshake violations
* Timing relationships
* Illegal sequences

**Characteristics:**

* Usually immediate
* Often assertions or lightweight components
* May fail fast

📌 Checkers answer:

> “Is the DUT behaving legally?”

---

### 🔹 3. **Coverage**

**Purpose:**
✔ Measure **what was exercised**, not whether it was right

**Owns:**

* Covergroups
* Crosses
* Distribution insight

**Must NEVER:**

* Influence PASS / FAIL
* Block dataflow
* Participate in shutdown logic

📌 Coverage answers:

> “Did we test enough?”

---

## 2️⃣ The most common industry bug (important)

> ❌ **Putting checking logic inside coverage**

Example of a *bad* idea:

```systemverilog
if (pkt.addr == illegal)
  `uvm_error(...)
```

inside a coverage collector.

Why this is wrong:

* Coverage may be disabled
* Coverage may be sampled differently
* Coverage is optional in regressions

👉 **Correctness must never depend on coverage presence**

---

## 3️⃣ Canonical architecture (mental diagram)

```
              +----------------+
              |   Monitor      |
              +----------------+
                       |
                       v
                analysis_port
                 (broadcast)
                  /        \
                 v          v
        +----------------+  +----------------+
        |   Scoreboard   |  |   Coverage     |
        +----------------+  +----------------+

        (Checkers may tap monitor or sit beside DUT)
```

Key rule:

* **Scoreboard and Coverage are peers**
* Neither knows about the other
* Neither blocks the monitor

---

## 4️⃣ Hands-on (minimal, but real)

You already have:

* Monitor → Scoreboard path

Now we **add coverage correctly**.

### 🔹 Step 1: Create a coverage subscriber

```systemverilog
class my_coverage extends uvm_subscriber #(my_txn);
  `uvm_component_utils(my_coverage)

  covergroup cg;
    option.per_instance = 1;
    data_cp : coverpoint item.data;
  endgroup

  function new(string name, uvm_component parent);
    super.new(name, parent);
    cg = new();
  endfunction

  virtual function void write(my_txn t);
    cg.sample();
  endfunction
endclass
```

📌 Note:

* No checking
* No blocking
* No shutdown logic

---

### 🔹 Step 2: Connect it in the environment

```systemverilog
monitor.ap.connect(scoreboard.analysis_export);
monitor.ap.connect(coverage.analysis_export);
```

That’s it.

No FIFOs.
No waits.
No objections.

---

## 5️⃣ What we deliberately do NOT do today

❌ No coverage-driven shutdown
❌ No coverage completeness checks
❌ No cross explosion
❌ No performance tuning

Those belong **later**, after correctness is frozen.

---

## 6️⃣ Why this ordering matters (senior insight)

If you do this **out of order**:

* Coverage starts influencing correctness
* Bugs disappear when coverage is off
* Regressions behave differently per run

If you do it **this way**:

* Correctness is deterministic
* Coverage is optional
* Scaling to regressions is trivial

This is **how real teams structure environments**.

---

## ✅ Day-38 completion criteria

You are DONE with Day-38 when:

✔ Scoreboard decides pass/fail
✔ Coverage never affects correctness
✔ Monitor broadcasts safely
✔ No shutdown logic changed
✔ Turning coverage off does NOT change result

---

## 🔜 What comes next (preview only)

### 📅 **Day-39: Phase-Aligned Sampling & Temporal Correctness**

* When exactly to sample
* run_phase vs extract/check
* Avoiding off-by-one coverage bugs
* Aligning analysis FIFOs with phases

We will **not** jump early.

---

If you want, next you can:

* Ask *why* `uvm_subscriber` is preferred over raw FIFO for coverage
* Or say **“Proceed to Day-39”** when ready

You are progressing **exactly** like a strong DV engineer would.
