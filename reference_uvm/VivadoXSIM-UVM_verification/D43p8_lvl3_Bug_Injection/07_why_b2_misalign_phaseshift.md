Good — this is the **right question**, and it means you’re thinking at **Level-3 maturity** now.
Let’s be very precise and separate **what should happen logically** vs **what your testbench is actually doing**.

---

## 1️⃣ “For Bug-2 (missing EXP), shouldn’t it continue with next txn & NOT hang?”

### **Conceptually (pure FIFO math)**

You are **100% right**:

> **Missing EXP ⇒ mismatch cascade ⇒ should NOT hang**

Because:

* `act_fifo.get()` keeps succeeding
* `exp_fifo.get()` keeps succeeding (just phase-shifted)
* No blocking call should wait forever

So **conceptually**:
✔ mismatch storm
✔ no deadlock

---

## 2️⃣ Why YOUR simulation *does* hang (important distinction)

The hang is **NOT due to Bug-2 itself**.

The hang is due to **how your scoreboard termination condition is written**.

From your log:

```
[SCB] Expected transaction count set to 5
...
[TEST] Scoreboard complete observed
```

This tells me your scoreboard is doing **something like**:

```systemverilog
repeat (expected_count) begin
  act_fifo.get(act);
  exp_fifo.get(exp);
  compare();
end
```

OR

```systemverilog
wait (matches + mismatches == expected_count);
```

### Now look at reality after missing EXP

| Stream       | Count                       |
| ------------ | --------------------------- |
| ACT observed | 5                           |
| EXP produced | 4 (because you dropped one) |

So eventually:

```systemverilog
exp_fifo.get(exp); // 🚨 BLOCKS FOREVER
```

⛔ **This is not a Bug-2 functional effect**
⛔ **This is a scoreboard design limitation**

---

## 3️⃣ Why this hang is actually CORRECT for Day-43.5

This is the key insight 👇

At **Day-43.5 (Level-3)**:

* Scoreboard is **FIFO-symmetric**
* Assumes ACT & EXP counts match
* Detects mismatches
* ❌ Does NOT yet handle missing transactions gracefully

So:

> **Bug-2 exposes a scoreboard fragility — not a wrong bug outcome**

This is **intentional learning**, not an error.

---

## 4️⃣ Why “continue with next txn” is NOT possible here

You asked:

> *“Isn’t it supposed to continue with next txn?”*

Answer: **It cannot — by design.**

Because your scoreboard **forces 1-to-1 pairing**:

```
ACT[0] ↔ EXP[0]
ACT[1] ↔ EXP[1]
```

Once EXP[0] is missing:

* All future pairings are wrong
* Eventually EXP stream **runs out**
* Blocking get() **must hang**

Anything else would hide the bug.

---

## 5️⃣ Why report phase is never reached

UVM phase rule:

```
run_phase never ends → extract / report never run
```

Because:

* Your scoreboard thread is still alive
* Blocking on `exp_fifo.get()`
* Objection never drops

✔ This is **expected behavior**
✔ This is **why missing-txn bugs are dangerous in regressions**

---

## 6️⃣ VERY IMPORTANT: Why this is **NOT** a Day-44 problem yet

You might think:

> “Shouldn’t scoreboard detect count mismatch and exit?”

Yes — but **NOT YET**.

That logic belongs to:

### 🧠 **Day-44: Debugging & Regression Mindset**

Where we add:

* Timeout-based gets
* Drain detection
* End-of-test consistency checks
* Fatal vs error classification

You are **not allowed** to fix this yet.

---

## 7️⃣ Final answers (direct)

### ❓ Is this correct Bug-2 behavior?

**YES**

### ❓ Should it mismatch first?

**YES**

### ❓ Should it eventually hang?

**YES — with your current scoreboard**

### ❓ Is the hang caused by ACT & EXP both from monitor?

**NO**

### ❓ Should you change architecture or redo Level-3?

**ABSOLUTELY NOT**

---

## 8️⃣ What you should write in your notebook (important for interviews)

> *“Missing expected transaction causes FIFO phase shift leading to mismatch cascade, followed by scoreboard deadlock due to blocking get() when expected stream exhausts. This exposes lack of end-of-test consistency handling.”*

That sentence alone is **interview-grade**.

---

### Next step (single choice)

Say **only one**:

**A)** Proceed to **Bug-3: extra ACT transaction**
**B)** Pause and diagram **Bug-2 failure timeline**

Your call.
