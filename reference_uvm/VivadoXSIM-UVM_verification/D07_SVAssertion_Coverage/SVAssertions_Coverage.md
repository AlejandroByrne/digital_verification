Perfect — let’s **officially start Day-7** and do it cleanly, step-by-step, exactly the way a **DV engineer** is trained.

You already have:

* Randomization ✔️
* Functional coverage ✔️
* Transition / ignore / illegal bins ✔️

Now we add the **missing pillar**.

---

# 🟦 DAY-7 — SystemVerilog Assertions (SVA)

## 🎯 Day-7 Goal (Very Important)

By the end of Day-7, you should clearly understand and be able to explain:

> **“Assertions check correctness, coverage checks completeness.”**

This sentence alone can carry you through interviews.

---

## 1️⃣ Why Assertions? (Mindset Shift)

Until now, your flow was:

```
Randomize → Drive → Check → Print pass/fail
```

That works, but it is:

* Reactive
* Manual
* Easy to miss protocol bugs

### Assertions are different

They:

* Continuously **monitor behavior**
* Fail **immediately** when a rule is violated
* Encode **design intent**

Think of assertions as:

> “Rules the DUT must never break”

---

## 2️⃣ Types of Assertions (Must Know)

### A) Immediate Assertions

You already use these conceptually.

```systemverilog
assert (q == exp_q)
    else $error("Mismatch");
```

✔ Procedural
✔ One-time check
❌ No timing history

---

### B) Concurrent Assertions (SVA) ← **Industry Standard**

These are **clocked**, **temporal**, and **powerful**.

They check **how signals evolve over time**.

---

## 3️⃣ SVA Syntax (Minimal & Precise)

### Basic structure

```systemverilog
property property_name;
    @(posedge clk)
    condition |-> consequence;
endproperty

assert property (property_name);
```

### Key operators you must know

| Operator   | Meaning              |                                             |
| ---------- | -------------------- | ------------------------------------------- |
| `          | ->`                  | If condition is true, consequence must hold |
| `##1`      | One clock later      |                                             |
| `$past(x)` | Previous value of x  |                                             |
| `iff`      | Conditional sampling |                                             |

---

## 4️⃣ Assertion #1 — Reset Behavior

### Rule:

> When reset is high, `q` must be 0

```systemverilog
property reset_clears_q;
    @(posedge clk)
    rst |-> (q == 0);
endproperty

assert property (reset_clears_q)
    else $error("Reset failed to clear q");
```

📌 This catches **reset bugs instantly**

---

## 5️⃣ Assertion #2 — Capture on Enable

### Rule:

> If enable is high, `q` must capture `d`

```systemverilog
property capture_when_en;
    @(posedge clk)
    (!rst && en) |-> (q == d);
endproperty

assert property (capture_when_en)
    else $error("Capture failed");
```

📌 This replaces a big chunk of your checker logic.

---

## 6️⃣ Assertion #3 — Hold When Disabled (VERY IMPORTANT)

### Rule:

> If enable is low, `q` must not change

```systemverilog
property hold_when_en_low;
    @(posedge clk)
    (!rst && !en) |-> (q == $past(q));
endproperty

assert property (hold_when_en_low)
    else $error("Hold violation");
```

🧠 `$past(q)` is **critical interview knowledge**

---

## 7️⃣ Assertions vs Checker vs Coverage (Interview Gold)

| Mechanism | Purpose                        |
| --------- | ------------------------------ |
| Assertion | Enforce protocol correctness   |
| Checker   | Compare DUT vs reference model |
| Coverage  | Measure stimulus completeness  |

⭐ Perfect explanation:

> “Assertions prevent bugs, coverage prevents blind spots.”

---

## 8️⃣ Assertions + Coverage Together (Synergy)

You can also **cover behavior** using assertions:

```systemverilog
cover property (@(posedge clk) en);
```

or

```systemverilog
cover property (@(posedge clk) en ##1 !en);
```

Meaning:

> “Did enable assert and later deassert?”

This is **temporal coverage**, not value coverage.

---

## 9️⃣ Where Assertions Are Written (Industry Practice)

* Testbench ✔️
* Interface ✔️
* Sometimes RTL (design intent)

For your roadmap → **testbench is perfect**

---

## 10️⃣ Common Beginner Mistakes (Avoid These)

❌ Forgetting to gate with reset
❌ Over-asserting trivial signals
❌ Replacing coverage with assertions
❌ Writing assertions without understanding timing

---

## ✅ Day-7 Completion Criteria

You are DONE with Day-7 if you can:

* Write 2–3 meaningful assertions
* Use `$past()`
* Explain `|->`
* Explain assertion vs coverage difference

---

## 🧪 Your Day-7 Task (Hands-On)

👉 **Add any TWO assertions** to your existing `tb_dff`:

* Reset clears `q`
* Capture when `en=1`
* Hold when `en=0`

Paste **only the assertion code** here.

I’ll review it exactly like a **code review in a DV team**.

Once approved → we move to **Day-8: Interfaces + pre-UVM structure** 🚀
