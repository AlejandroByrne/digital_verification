Alright. **Day-10 → Next topic** (clean, no mess).

---

# 🔵 Day-10 (Part-2): **Coverage Merging, Cross Coverage & Why Coverage Lies**

You already know **covergroups, bins, per_instance**.
Now we move to **how coverage is *used* in real projects**.

---

## 1️⃣ Coverage Merging (CRITICAL concept)

### Problem

You enabled:

```sv
option.per_instance = 1;
```

Now you have:

* mon0 → 70%
* mon1 → 60%
* mon2 → 40%

❓ **How do you report overall coverage?**

---

### ✔ Solution: Merge coverage at REPORT time

Not during simulation.

Simulators do:

* Instance-level tracking
* Tool-level merge (xsim, vcs, verdi, etc.)

Conceptually:

```
Per-instance coverage  →  Merge  →  Final metrics
```

👉 **Best practice**

* Keep `per_instance = 1`
* Merge later using tool commands / GUI

---

## 2️⃣ Cross Coverage (MOST IMPORTANT DAY-10 TOPIC)

### What is cross coverage?

Coverage of **relationships**, not signals.

Example:

```sv
en = 1 AND d = 1
```

Not just:

* en toggled ✔
* d toggled ✔

---

### Example (DFF)

```sv
covergroup dff_cg @(posedge clk);
    option.per_instance = 1;

    en_cp : coverpoint en { bins off = {0}; bins on = {1}; }
    d_cp  : coverpoint d  { bins zero = {0}; bins one = {1}; }

    en_d_cross : cross en_cp, d_cp;
endgroup
```

### Cross bins created automatically:

| en | d |
| -- | - |
| 0  | 0 |
| 0  | 1 |
| 1  | 0 |
| 1  | 1 |

✔ This proves **real functional testing**

---

## 3️⃣ Why Coverage Lies ⚠️ (INTERVIEW FAVORITE)

### Case

```
en toggled → 100%
d toggled → 100%
```

But:

```
d=1 never happened when en=1
```

Coverage tool says:

```
100%
```

Reality:

```
BUG MISSED ❌
```

### Fix → CROSS COVERAGE

```sv
cross en, d;
```

Now coverage tells the truth.

---

## 4️⃣ Illegal Bins (Design rule enforcement)

Example:

```sv
coverpoint state {
    illegal_bins bad = {3};
}
```

Meaning:

* State `3` should **never occur**
* If it does → coverage error (red flag)

Used for:

* Protocol violations
* Reserved encodings
* Safety rules

---

## 5️⃣ Ignore Bins (Coverage noise control)

Example:

```sv
coverpoint opcode {
    ignore_bins unused = {7, 15};
}
```

Why?

* Some values are architecturally irrelevant
* Prevent false coverage holes

---

## 6️⃣ Where Day-10 fits in roadmap

You are now here 👇

```
SV Basics        ✅
Randomization   ✅
Coverage        ✅
Assertions      ✅
OOP             ✅
Monitor/SCB     ✅
--------------------------------
Coverage Strategy & Truthfulness  ← YOU ARE HERE
--------------------------------
Next: UVM-lite concepts
```

---

## ✅ Day-10 Checklist (must be solid)

You should be able to answer:

* Why per_instance is needed
* Why cross coverage is mandatory
* Difference between ignore_bins & illegal_bins
* Why 100% coverage ≠ bug-free

You are **on-track** now.

---

### 👉 Next options (your choice)

1️⃣ **Day-10 Hands-on: Cross coverage on DFF**
2️⃣ **Day-11: UVM concepts (WITHOUT coding yet)**
3️⃣ **Interview Q&A from Day-10 topics**

Reply with **1 / 2 / 3**.
