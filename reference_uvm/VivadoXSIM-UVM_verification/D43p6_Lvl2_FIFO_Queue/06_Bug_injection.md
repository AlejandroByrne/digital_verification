Good. We’ll do this **slow, minimal, and 100% in‑scope**.

No DUT change
No protocol
No wr/rd signals
No RTL FIFO
Only **Level‑2 checking mechanics**

---

# Day‑43.5 — Level‑2

## Minimal Bug Injection that **FALSE‑PASSES**

### 🔒 Baseline reminder (do not skip)

**Level‑2 architecture (frozen):**

```
Predictor  ──► uvm_tlm_analysis_fifo (expected)
Monitor    ──► queue[$]              (actual)
Scoreboard ──► get() vs pop_front()
```

Comparison rule (this is the weakness):

> Compare **first available expected**
> with **first available actual**

No IDs
No cycle alignment
No phase alignment

---

## 🎯 Goal of this exercise

Show **ONE bug** that:

* Is **real**
* Would be **catastrophic in silicon**
* **Still PASSES** Level‑2
* Requires **no DUT modification**

This proves **why Level‑2 is unsafe by design**.

---

## 🔴 The Bug We Inject (Minimal & Legal)

### Bug type: **Silent drop of ONE actual transaction**

We inject the bug **in the scoreboard input path**, not DUT.

### Why this bug is perfect

* Very realistic (monitor glitch, analysis connection issue)
* Common in real benches
* Level‑2 **cannot detect it**
* Level‑3 **will detect it**

---

## 🧪 Exact Bug Injection

### Original (correct) code — Level‑2

```systemverilog
function void write_actual(my_txn t);
  act_q.push_back(t);
endfunction
```

---

### 🔴 Bug‑injected version (DROP ONE ITEM)

```systemverilog
int drop_once = 1;

function void write_actual(my_txn t);
  if (drop_once) begin
    drop_once = 0;
    `uvm_warning("BUG", "Dropping one ACTUAL transaction")
    return; // ❌ silent loss
  end
  act_q.push_back(t);
endfunction
```

That’s it.
**One line of damage.**

---

## 🧠 What ACTUALLY happens (step‑by‑step)

Assume data stream:

```
Expected stream: A, B, C, D
Actual stream:   A, B, C, D
```

Now inject the drop.

### After bug:

```
Expected FIFO: A, B, C, D
Actual queue:  A, C, D
               ↑
           B is LOST
```

---

## 🔍 How Level‑2 compares

Scoreboard logic:

```systemverilog
exp = exp_fifo.get();
act = act_q.pop_front();
compare(exp, act);
```

### Comparison sequence:

| Step | Expected | Actual | Result        |
| ---- | -------- | ------ | ------------- |
| 1    | A        | A      | MATCH         |
| 2    | B        | C      | ❌ SHOULD FAIL |
| 3    | C        | D      | ❌ SHOULD FAIL |

### ❗ But here is the trap

Most Level‑2 benches:

* Stop when **expected count exhausted**
* Or rely on **expected-driven completion**
* Or never check **extra / missing actuals**

So what happens in practice:

```
MATCH
MATCH
MATCH
TEST PASSED
```

⚠️ **One transaction vanished.**
⚠️ **No failure.**
⚠️ **False PASS.**

---

## 🧨 Why Level‑2 CANNOT catch this

Because Level‑2 **assumes**:

* “If something arrives eventually, it’s fine”
* “Order is enough”
* “Count mismatches are somebody else’s problem”

### Structural limitations (not a mistake):

| Missing capability   | Why it matters               |
| -------------------- | ---------------------------- |
| No count symmetry    | Extra/missing items ignored  |
| No transaction ID    | Cannot detect shift          |
| No phase ownership   | Late/early indistinguishable |
| Queue on actual side | No blocking guarantee        |

This is **exactly why Level‑3 exists**.

---

## ❗ Very important clarification

This failure has **NOTHING** to do with:

❌ FIFO DUT
❌ wr/rd signals
❌ protocol
❌ timing

It is purely a **checking architecture failure**.

---

## 🧠 What this teaches (this is the lesson)

> **“First‑available vs first‑available” comparison is unsafe**

Even with:

* Correct monitor
* Correct predictor
* Correct DUT

---

## 🔒 Status after this exercise

✅ You have a **proven Level‑2 false‑pass**
✅ You now understand **why queues are dangerous**
✅ You did NOT violate scope
✅ You did NOT change DUT

---

## 🚦 What is NEXT (only one logical step)

### Level‑3: FIFO – FIFO

Why?

Because only FIFO–FIFO can detect:

* Missing transactions
* Extra transactions
* Backpressure symmetry
* Stream integrity

This transition will feel **obvious now** — that’s intentional.

---

### Final checkpoint (answer this mentally)

> If one transaction disappears forever,
> **should a verification environment pass?**

Level‑2: ❌ *passes*
Level‑3: ✅ *fails*

---

Say **“Proceed to Level‑3 FIFO–FIFO”** when ready.
