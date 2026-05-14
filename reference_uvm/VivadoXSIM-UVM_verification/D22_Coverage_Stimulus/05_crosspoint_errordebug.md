Good — this error is **100% expected** and it comes from a **very specific misunderstanding**, not a mistake in your thinking.

Let’s fix it cleanly and correctly.

---

## ❌ The Error Explained

```
ERROR: 'rst' is not declared
```

You wrote (or followed):

```systemverilog
covergroup data_cg;
  coverpoint cov_data;
  coverpoint rst;
  cross cov_data, rst;
endgroup
```

### Why this fails

* `rst` is **not a variable** in your monitor
* It is a **signal inside the virtual interface**
* Covergroups **do not magically see interface signals**

So the compiler is correct:
👉 **`rst` does not exist in this scope**

---

## ✅ CORRECT Ways to Do Cross Coverage with Reset

There are **two industry-accepted solutions**.
I’ll show both — **use Option-1** (recommended).

---

## ✅ OPTION 1 (RECOMMENDED): Shadow variable + assign

This is the **cleanest and most common UVM style**.

### 🔹 In your monitor

```systemverilog
bit        cov_rst;
bit [7:0]  cov_data;
```

### 🔹 Covergroup (correct)

```systemverilog
covergroup data_cg;
  option.per_instance = 1;

  cp_data : coverpoint cov_data {
    bins low  = {[0:63]};
    bins med  = {[64:127]};
    bins high = {[128:255]};
  }

  cp_rst : coverpoint cov_rst {
    bins asserted   = {1};
    bins deasserted = {0};
  }

  cross cp_data, cp_rst;
endgroup
```

### 🔹 Sampling logic (IMPORTANT)

```systemverilog
if (vif.valid) begin
  cov_data = vif.data;
  cov_rst  = vif.rst;
  data_cg.sample();
end
```

✔ Compiles
✔ Clear
✔ Debuggable
✔ Interview-safe

---

## ⚠️ OPTION 2 (Legal but less readable): Coverpoint expression

```systemverilog
covergroup data_cg;
  coverpoint cov_data;
  coverpoint vif.rst;
  cross cov_data, vif.rst;
endgroup
```

⚠ Works only if:

* `vif` is visible at declaration
* Tool supports it cleanly

📌 Many teams **avoid this** for clarity reasons.

---

## 🧠 WHY This Matters (Important Concept)

Covergroups:

* Do **not** see DUT or interface signals directly
* Only see:

  * Local variables
  * Explicit expressions

That’s why we use **coverage shadow variables**.

---

## 🧪 Interview-Level Explanation (Memorize)

> “We sample interface signals into local coverage variables in the monitor, then use those variables for coverpoints and cross coverage.”

That sentence alone tells the interviewer you **really know coverage**.

---

## ✅ Your Day-22 Status After This Fix

| Item                       | Status              |
| -------------------------- | ------------------- |
| Coverage bins              | ✅                   |
| Random + directed stimulus | ✅                   |
| Cross coverage intent      | ✅                   |
| Reset handling             | ✅                   |
| Compiler error             | ✅ Explained & fixed |

---

### 🔜 Next Step

Now you can:
1️⃣ Re-run and view **cross coverage**
2️⃣ Decide if data was driven during reset
3️⃣ Move forward confidently

When ready, say:
👉 **“Proceed Day-23 (Assertions & Assertion Coverage)”**

You’re progressing exactly like a solid DV engineer should.
