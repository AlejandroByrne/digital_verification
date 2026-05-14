Perfect. We’ll do **ONE clean, controlled bug-injection hands-on** using **your existing DFF setup**.
No directory changes, no UVM yet, no confusion.

This is **Day-13 → Bug Injection (Hands-on)**.

---

# 🎯 Goal of This Exercise

Prove **all three** are working correctly:

* ✅ Assertion
* ✅ Scoreboard
* ✅ Monitor timing

We will:

1. **Inject ONE RTL bug**
2. Predict expected failures
3. Observe actual failures
4. Conclude what worked (and why)

---

## 🧩 Step 0 — Baseline (Assumed Working)

Your **correct DFF** (golden reference):

```systemverilog
module d_ff (
  input  logic clk,
  input  logic rst,
  input  logic en,
  input  logic d,
  output logic q
);

  always_ff @(posedge clk) begin
    if (rst)
      q <= 0;
    else if (en)
      q <= d;
  end

endmodule
```

You already verified:

* Assertions PASS
* Scoreboard PASS
* Coverage reasonable

✅ Good baseline.

---

# 🔴 Step 1 — Inject a REAL Bug (Enable Ignored)

This is a **classic silicon bug**.

### ❌ Buggy DUT (INTENTIONAL)

```systemverilog
module d_ff (
  input  logic clk,
  input  logic rst,
  input  logic en,
  input  logic d,
  output logic q
);

  always_ff @(posedge clk) begin
    if (rst)
      q <= 0;
    else
      q <= d;      // ❌ BUG: en is ignored
  end

endmodule
```

⚠️ Do **NOT** change testbench, assertions, monitor, or scoreboard.

---

# 🧠 Step 2 — Predict Before Running (VERY IMPORTANT)

When **en = 0**, correct behavior:

```
q must HOLD previous value
```

But buggy DUT:

```
q updates every clock
```

### Expected reactions:

| Component                    | Expected         |
| ---------------------------- | ---------------- |
| Assertion `hold_when_en_low` | ❌ FAIL           |
| Scoreboard                   | ❌ FAIL           |
| Monitor                      | Still correct    |
| Simulation                   | ❌ Errors visible |

If **nothing fails**, your TB is broken.

---

# ▶️ Step 3 — Run Simulation

```tcl
xsim <your_sim> -runall
```

---

# 🧾 Step 4 — What You SHOULD See

### ❌ Assertion Failure

Example:

```
ASSERTION FAILED: Hold violation en=0, q changed
```

✔ This proves assertion is **correctly written & timed**.

---

### ❌ Scoreboard Failure

Example:

```
[ScoreBoard] Fail, Actual=1, Expect=0
```

✔ This proves reference model is **correct**.

---

### ✔ Monitor Logs Still Reasonable

Example:

```
[Monitor] en=0 d=1 q=1
```

✔ Monitor sampled correctly.

---

# 🧠 Step 5 — What Did We PROVE?

| Item                 | Proven    |
| -------------------- | --------- |
| Assertion logic      | ✅ Correct |
| Assertion timing     | ✅ Correct |
| Scoreboard modeling  | ✅ Correct |
| Monitor sampling     | ✅ Correct |
| Testbench usefulness | ✅ Real    |
| Silent PASS avoided  | ✅         |

This is **real verification**.

---

# 🎤 Interview-Ready Explanation (MEMORIZE)

> “After building assertions and scoreboard, I injected an RTL bug where enable was ignored. The hold assertion fired and the scoreboard flagged mismatches, proving the environment was effective and timing-correct.”

This is **strong DV maturity**.

---

# 🧭 Where This Fits in Roadmap

| Day        | Topic                  | Status |
| ---------- | ---------------------- | ------ |
| Day-9      | Monitor + Scoreboard   | ✅      |
| Day-10     | Functional Coverage    | ✅      |
| Day-11     | Assertions vs Coverage | ✅      |
| Day-12     | Coverage refinement    | ✅      |
| **Day-13** | **Bug Injection**      | ✅ DONE |

You are **READY for UVM concepts now**.

---

## 🔜 Next (Your Choice)

Reply with **ONE number only**:

**1️⃣ One more bug (timing bug – negedge clock)**
**2️⃣ Bug in testbench (monitor sampling bug)**
**3️⃣ Move to UVM (Day-14: UVM motivation + mapping from your TB)**

I recommend **3️⃣**, but your call.
