Excellent 👍
**Day-22: Coverage-Driven Stimulus & Closure** starts now.

This day is **very important** — it converts coverage from a *passive metric* into an *active driver of stimulus*. This is where verification maturity shows.

---

# 🟦 Day-22 — Coverage-Driven Verification (CDV)

## 🎯 Goal of Day-22

* Use **coverage results** to **drive stimulus**
* Close **unhit bins intentionally**
* Learn **how professionals reach 100% coverage**
* Add **illegal bins & cross coverage (intro)**

You already have:

* Driver ✅
* Monitor ✅
* Scoreboard ✅
* Covergroup ✅ (66.67% coverage)

Now we **close the gap**.

---

## 1️⃣ Understand What Is Missing (MANDATORY STEP)

From Day-21:

```
Bins:
low   [0:63]   ❌ MISS
med   [64:127] ✅ HIT
high  [128:255] ✅ HIT
Coverage = 66.67%
```

👉 **Low bin is uncovered**

This tells us:

> “Stimulus never generated values between 0–63”

This is **good coverage feedback**, not a failure.

---

## 2️⃣ Coverage-Driven Stimulus (Directed Closure)

### 🔹 Method-1: Directed Constraint (Preferred)

In your **sequence**:

```systemverilog
class my_sequence extends uvm_sequence #(my_txn);
  `uvm_object_utils(my_sequence)

  task body();
    my_txn req;
    req = my_txn::type_id::create("req");

    start_item(req);
    assert(req.randomize() with {
      data inside {[0:63]};   // Target uncovered bin
    });
    finish_item(req);
  endtask
endclass
```

✅ Run simulation
✅ Coverage becomes **100%**

📌 This is **real CDV**.

---

### 🔹 Method-2: Statistical Closure (Not ideal alone)

```systemverilog
repeat (50) begin
  start_item(req);
  assert(req.randomize());
  finish_item(req);
end
```

⚠ Works eventually
⚠ Not deterministic
⚠ Not interview-preferred

---

## 3️⃣ Add Illegal Bins (VERY IMPORTANT CONCEPT)

Illegal bins ensure:

* Design **must never** see certain values note

Example:

```systemverilog
coverpoint cov_data {
  bins low    = {[0:63]};
  bins med    = {[64:127]};
  bins high   = {[128:255]};
  illegal_bins invalid = {[256:$]};
}
```

📌 If illegal bin hits → **coverage error**
📌 Used heavily in protocols & safety logic

---

## 4️⃣ Add Cross Coverage (Intro Level)

Example: data × reset

```systemverilog
covergroup data_cg;
  coverpoint cov_data;
  coverpoint rst;
  cross cov_data, rst;
endgroup
```

This answers:

> “Was data driven **during reset**?”

📌 Cross coverage = **corner-case detector**

---

## 5️⃣ When to Sample (Critical Rule)

✔ Sample **only when transaction is valid**
✔ Never sample during reset

Correct pattern:

```systemverilog
if (!vif.rst && vif.valid) begin
  cov_data = vif.data;
  data_cg.sample();
end
```

This avoids **fake coverage hits**.

---

## 6️⃣ Coverage Closure Checklist (INTERVIEW GOLD)

Before saying “coverage complete”:

✔ All functional bins hit
✔ Illegal bins **never hit**
✔ Cross coverage reviewed
✔ Reset excluded
✔ Coverage driven by stimulus, not luck

Say this confidently in interviews.

---

## 🧠 Interview-Grade Answer (Memorize)

> “We analyze uncovered bins, then refine stimulus using directed constraints or targeted sequences to close functional coverage deterministically.”

That sentence alone = **strong DV signal**.

---

## ✅ Day-22 Completion Criteria

| Item                      | Status |
| ------------------------- | ------ |
| Identify missing bins     | ✅      |
| Directed stimulus         | ✅      |
| Coverage reaches 100%     | ✅      |
| Illegal bins added        | ✅      |
| Cross coverage introduced | ✅      |

---

## 🔜 What Comes Next

**Day-23: Assertions (SVA) + Assertion Coverage**
This completes the **verification triangle**:

* Stimulus
* Checking
* Coverage

When ready, say:
👉 **“Proceed Day-23”**

You are now operating at **industry-ready verification depth**.
