Good.
**Day-11 is exactly the right place to be now.**
Today we clean up the *last conceptual cracks* that caused all the confusion in Day-9/10.

---

# 🟦 Day-11: **Assertions vs Coverage**

### (Clocking-block aligned, zero hand-waving)

🎯 **Goal of Day-11**
By the end of today, you will:

* Know **why your assertion failed even when DUT looked correct**
* Know **when coverage lies**
* Write **timing-correct assertions using clocking blocks**
* Stop mixing *monitor thinking* with *assertion thinking*

---

## 1️⃣ First — reset the mental model (VERY IMPORTANT)

### ❌ Wrong assumption (most learners make)

> “If scoreboard passes, assertion should also pass”

❗ **False**

They observe **different things at different times**.

---

## 2️⃣ Three different observers in DV (never mix them)

| Component                | Observes              | Time reference                        |
| ------------------------ | --------------------- | ------------------------------------- |
| **Driver**               | Drives signals        | *Before clock edge*                   |
| **Monitor / Scoreboard** | Samples DUT behavior  | *After clock edge*                    |
| **Assertion**            | Checks protocol rules | *Exactly at specified clocking event* |

👉 Scoreboard = *functional correctness*
👉 Assertion = *temporal correctness*

Both can disagree — **legitimately**.

---

## 3️⃣ Why your `hold_when_en_low` assertion failed

Your assertion:

```systemverilog
property hold_when_en_low;
  @(cb) disable iff (rst)
  !en |-> (cb.q == $past(cb.q));
endproperty
```

### Looks correct ❌

### Actually flawed ❌❌

---

### 🔴 Problem #1 — `en` is NOT sampled via clocking block

You used:

```systemverilog
!en
```

But assertion is clocked on `@(cb)`.

👉 That means:

* `cb.q` is sampled via clocking block
* `en` is sampled **outside** clocking skew

This creates a **sampling mismatch**.

---

### ✅ Correct version (RULE)

> **Inside a clocked property, ONLY use clocking block signals**

### ✅ Fixed assertion

```systemverilog
property hold_when_en_low;
  @(cb) disable iff (rst)
  !cb.en |-> (cb.q == $past(cb.q));
endproperty
```

📌 This alone fixes **many** false failures.

---

## 4️⃣ Problem #2 — `$past()` without reset alignment

At time 0 / after reset:

* `$past(cb.q)` is **X**
* Assertion compares `q == X` → **FAIL**

### ✅ Correct reset-safe assertion

```systemverilog
property hold_when_en_low;
  @(cb)
  disable iff (rst)
  (!cb.en && !$isunknown($past(cb.q)))
    |-> (cb.q == $past(cb.q));
endproperty
```

Now:

* Assertion is **silent during reset**
* No false firing on first cycle

---

## 5️⃣ Why scoreboard showed FAIL while DUT was correct

Your scoreboard logic:

```systemverilog
if (t.en)
  exp_q = t.d;
```

### ❌ Problem

You are updating `exp_q` **in the same cycle** you sample `q`.

But a DFF updates `q` **after the clock edge**.

So you must compare against **previous cycle’s d**.

---

### ✅ Correct scoreboard model (1-cycle latency)

```systemverilog
bit prev_d;

if (t.en)
  prev_d = t.d;

if (t.q !== prev_d)
  $error(...);
```

👉 Assertion checks **protocol**
👉 Scoreboard checks **function with latency**

Different jobs. Different timing.

---

## 6️⃣ Why coverage didn’t catch this bug

Coverage asked:

> “Did en=1 and d=1 occur?”

It did.

Coverage **does NOT ask**:

> “Did q update correctly *one cycle later*?”

Coverage ≠ correctness
Coverage ≠ timing
Coverage = **stimulus completeness only**

---

## 7️⃣ Golden rule (memorize this)

> **Assertions protect behavior**
> **Scoreboards protect results**
> **Coverage protects stimulus**

Never swap their responsibilities.

---

## 8️⃣ What you actually completed so far (reality check)

You have now:

* Used **clocking blocks correctly**
* Debugged **false assertion failures**
* Seen **seed-dependent bugs**
* Generated **functional coverage**
* Learned **why coverage can lie**
* Built **non-UVM DV infra correctly**

👉 This is **solid Day-11 level**, not beginner.

---

## ▶️ Next step (still Day-11)

Next we will:

1. Rewrite your assertion **clean + minimal**
2. Add **one assertion coverage point**
3. Show **assertion coverage vs functional coverage**
4. Decide **what belongs in Day-12**

Say **“Continue Day-11”** when ready.
