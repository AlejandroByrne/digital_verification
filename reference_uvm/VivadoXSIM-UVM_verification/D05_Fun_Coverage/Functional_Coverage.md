Perfect 👍
Now we enter **Day-5: Functional Coverage** — this is the topic that **separates juniors from real verification engineers**.

Everything you wrote so far was preparation **for this day**.

---

# 🟢 DAY-5 — FUNCTIONAL COVERAGE (SYSTEMVERILOG)

## 🎯 Day-5 Goal

By the end of Day-5, you must be able to explain:

> “How do you know your random tests are *good enough*?”

Functional coverage answers that.

---

## 1️⃣ What Functional Coverage IS (Conceptual)

Randomization answers:

> *What values did I generate?*

Coverage answers:

> *What behaviors did I actually test?*

Without coverage:

* Random ≠ complete
* Bugs hide silently

📌 **Golden interview line**:

> “Random stimulus without functional coverage is blind verification.”

---

## 2️⃣ Code Coverage vs Functional Coverage (Very Important)

| Code Coverage       | Functional Coverage   |
| ------------------- | --------------------- |
| Tool-generated      | User-defined          |
| RTL-focused         | Spec-focused          |
| Statements/branches | Scenarios             |
| “Did code execute?” | “Did behavior occur?” |

👉 DV engineers own **functional coverage**, not code coverage.

---

## 3️⃣ Where Coverage Lives

Coverage belongs in:

* Testbench
* Monitor
* Checker
* NOT inside DUT

✔ Same place as random stimulus
✔ Same abstraction level

---

## 4️⃣ Your First `covergroup` (Minimal & Correct)

Let’s add coverage for your **DFF behavior**.

### Coverage goals:

* `en` = 0 and 1
* `d` = 0 and 1
* Valid `(en,d)` combinations

---

## 5️⃣ Add This to Your TB (Minimal Change)

### 🔹 Step 1: Declare Covergroup

Add **inside `tb_dff`**:

```systemverilog
covergroup dff_cg @(posedge clk);
    coverpoint en {
        bins en_0 = {0};
        bins en_1 = {1};
    }

    coverpoint d {
        bins d_0 = {0};
        bins d_1 = {1};
    }

    cross en, d;
endgroup
```

📌 Sampling happens at `posedge clk` — exactly correct for sequential logic.

---

### 🔹 Step 2: Create Coverage Instance

Still inside `tb_dff`:

```systemverilog
dff_cg cg = new();
```

That’s it. No manual sampling needed.

---

## 6️⃣ Why This Is CORRECT

* Sampling aligned with clock
* Uses DUT-facing signals
* Cross automatically ignores illegal `(en=0,d=1)` because your stimulus never creates it

📌 You are measuring **what the DUT actually saw**.

---

## 7️⃣ Run Simulation Again

```bash
xvlog -sv dff_c.sv tb_dff.sv
xelab tb_dff -debug typical
xsim tb_dff -runall
```

Simulation will run as before — coverage collects silently.

---

## 8️⃣ How to View Coverage (Important)

After simulation:

```bash
xsim tb_dff
xsim> report_coverage
```

You’ll see:

* Coverpoint hit percentages
* Cross coverage numbers

📌 **100% coverage does NOT mean bug-free**
📌 **0% coverage means useless test**

---

## 9️⃣ Expected Coverage Behavior

Given enough random cycles:

| Coverage Item | Expectation             |
| ------------- | ----------------------- |
| en            | 100%                    |
| d             | 100%                    |
| en × d        | 75% (one illegal combo) |

That’s **correct**, not a failure.

---

## 🔟 Common Beginner Mistakes (Avoid These)

❌ Sampling on `@(*)`
❌ Putting covergroups in DUT
❌ Expecting coverage to increase without running simulation
❌ Treating coverage as pass/fail
❌ Ignoring cross coverage

---

## 1️⃣1️⃣ Interview Questions You Can Now Answer

* What is functional coverage?
* Difference between code & functional coverage?
* Why cross coverage is needed?
* Where do you sample coverage?
* Why 100% coverage is not always possible?

---

## 🧪 Day-5 Mandatory Exercise

1. Add the covergroup above
2. Run simulation
3. Generate coverage report
4. Observe:

   * Which bins hit
   * Which bin is missing and WHY

---

## ✅ Day-5 Progress Check

When done, paste:

* Coverage report output (text)
  OR say:

> **“Coverage bins observed as expected”**

Then we proceed to:

> **Day-6: Assertions (SVA) — this is BIG** 🚀
