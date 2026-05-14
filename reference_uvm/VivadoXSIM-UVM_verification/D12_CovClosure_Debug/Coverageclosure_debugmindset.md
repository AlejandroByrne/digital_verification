Perfect.
**Day-12 starts now.** No overlap, no repetition. This is **coverage-closure thinking**, exactly what interviewers test at 3–6 YOE level.

---

# 🟢 Day-12: Coverage Closure & Debug Mindset

## Goal (very important)

By end of Day-12, you must be able to answer:

> “Coverage is stuck at 92%. What do you do?”

This separates **real DV engineers** from tool runners.

---

## 1️⃣ Why coverage stalls at 90–95%

This is **normal**, not a failure.

Typical reasons:

### A. Dead bins

```systemverilog
coverpoint en {
  bins en_0 = {0};
  bins en_1 = {1};
}
```

But DUT logic:

```systemverilog
if (!rst)
   en <= 1'b1;   // en never goes 0
```

➡ Bin `en_0` is **unreachable**

---

### B. Illegal or impossible cross

```systemverilog
cross en, rst;
```

But protocol says:

* `rst=1` ⇒ `en=0` always

➡ `en=1 && rst=1` **can never occur**

---

### C. Over-constrained stimulus

```systemverilog
constraint c {
  en == 1;
}
```

➡ Half your bins are permanently dead

---

### D. Reset coverage pollution

Coverage collected:

* During reset
* During X/Z phase

➡ Noise bins hit or missed incorrectly

---

## 2️⃣ First rule of Coverage Closure

> ❗ **Never try to hit bins before proving they are reachable**

This is interview-level wisdom.

---

## 3️⃣ Coverage Debug Flow (REAL FLOW)

### Step-1: Find lowest-hit objects

From HTML report:

* Groups
* Coverpoints
* Crosses

Ask:

* 0%? → suspicious
* 1 hit only? → weak stimulus

---

### Step-2: Ask the *Golden Question*

For each missing bin:

> **Is this logically reachable in the DUT?**

If **NO** → dead bin
If **YES** → stimulus problem

---

## 4️⃣ What to do with Dead Bins (IMPORTANT)

### Option-1: Ignore bin (preferred)

```systemverilog
ignore_bins dead = {1};
```

### Option-2: illegal_bins (protocol violation)

```systemverilog
illegal_bins bad = binsof(en) intersect {1} &&
                   binsof(rst) intersect {1};
```

📌 **Interview rule**:

* `ignore_bins` → unreachable
* `illegal_bins` → should never happen

---

## 5️⃣ Coverage Closure ≠ 100%

Industry reality:

| Block type    | Typical target |
| ------------- | -------------- |
| Simple IP     | 95–100%        |
| Control logic | 90–95%         |
| Complex SoC   | 85–90%         |

Anyone demanding 100% blindly is **junior**.

---

## 6️⃣ Assertions + Coverage Closure (Key Link)

| Situation                      | What to trust    |
| ------------------------------ | ---------------- |
| Assertion fails                | Assertion        |
| Coverage low                   | Improve stimulus |
| Coverage high + assertion fail | Assertion        |
| Coverage high + no checks      | **Danger**       |

➡ Coverage without assertions = **false confidence**

---

## 7️⃣ What Interviewers WILL Ask (and you can answer now)

**Q:** “Coverage is stuck at 92%. What’s your approach?”

**Your answer (verbatim safe):**

> First I check if the uncovered bins are logically reachable in the DUT.
> If not, I mark them as ignore or illegal bins.
> If they are reachable, I improve stimulus or relax constraints.
> I never force coverage blindly.

This answer alone = **hire signal**.

---

## 8️⃣ Day-12 Hands-On (light, optional)

You can do **either**:

### Option-A (recommended)

* Pick 1 covergroup
* Add `ignore_bins`
* Regenerate report
* Observe coverage jump

### Option-B

* Add an illegal cross bin
* Prove it never hits

No need to over-code.

---

## ✅ Day-12 Completion Check

Tell me **YES** if you now clearly understand:

* Why coverage stalls
* What dead bins are
* When to ignore vs illegal
* Why 100% is not mandatory

---

### 🔜 Next (Day-13 – FINAL DV DAY)

**Interview-Grade Topics**

* How to explain your testbench in 5 minutes
* Common DV interview traps
* What NOT to say
* Resume-aligned answers

Say **“Proceed Day-13”** when ready.
