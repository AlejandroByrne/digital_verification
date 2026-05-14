Good — this is a **tool-usage issue**, not a SystemVerilog issue 👍
Very common when first using XSIM interactively.

Let’s fix it **cleanly and correctly**, and I’ll also explain **what went wrong** so you won’t repeat it.

---

# ❌ What Went Wrong (Exactly)

### 1️⃣ You are trying to run `xsim` *inside* an active `xsim` session

Your log:

```
xsim% xsim tb_dff
ERROR: Unable to locate simulation image ...
```

👉 Once you see the prompt:

```
xsim%
```

you are **already inside the simulator**.

You **must NOT** run `xsim` again from there.

---

### 2️⃣ Coverage was not enabled during elaboration

This error:

```
invalid command name "report_coverage"
```

means:

> Coverage database was never created

In XSIM, **coverage is NOT enabled by default**.

---

# ✅ Correct XSIM FLOW (Memorize This)

## Step 1️⃣ Compile (same as before)

```bash
xvlog -sv dff_c.sv tb_dff.sv
```

---

## Step 2️⃣ Elaborate **WITH COVERAGE ENABLED** (IMPORTANT)

```bash
xelab tb_dff -coverage -debug typical
```

📌 `-coverage` is mandatory
Without it → no `report_coverage`

---

## Step 3️⃣ Run Simulation (Batch Mode)

```bash
xsim tb_dff -runall
```

✔ Simulation runs
✔ Coverage data collected

---

## Step 4️⃣ Report Coverage (Correct Way)

Now run **a new interactive session**:

```bash
xsim tb_dff
```

You should see:

```
xsim%
```

Now type:

```tcl
report_coverage
```

✅ This will work **only now**

---

# 🧠 Why Your Previous Attempt Failed

| Command                      | Why it failed            |
| ---------------------------- | ------------------------ |
| `xsim tb_dff` inside `xsim%` | Nested simulator call ❌  |
| `report_coverage`            | Coverage not enabled ❌   |
| `xsim>` prompt               | You were in wrong mode ❌ |

---

# 🟢 Correct Mental Model

| Phase     | Tool              | Purpose              |
| --------- | ----------------- | -------------------- |
| Compile   | `xvlog`           | Syntax & SV          |
| Elaborate | `xelab -coverage` | Build sim + coverage |
| Run       | `xsim -runall`    | Execute              |
| Inspect   | `report_coverage` | Analyze              |

---

# 🎯 Expected Output (Example)

You’ll see something like:

```
=================================================
Covergroup: dff_cg
Coverage: 75.00%

Coverpoint en:
  en_0 : HIT
  en_1 : HIT

Coverpoint d:
  d_0 : HIT
  d_1 : HIT

Cross en x d:
  (0,0) : HIT
  (0,1) : ILLEGAL / NOT HIT
  (1,0) : HIT
  (1,1) : HIT
=================================================
```

📌 **75% cross coverage is CORRECT**
One bin is illegal and should not be hit.

---

# 🧪 Quick Checklist (Before You Retry)

✔ Did you use `xelab -coverage`?
✔ Did you exit previous `xsim` session?
✔ Did you run `report_coverage` only at `xsim%` prompt?

---

## ✅ Final Verdict

* Your TB is correct
* Your coverage code is correct
* This is **pure XSIM usage learning**
* You’re doing exactly what a real engineer does on Day-1 with a new tool

---

### Do this now

Re-run with:

```bash
xelab tb_dff -coverage -debug typical
xsim tb_dff -runall
xsim tb_dff
report_coverage
```

Paste the **coverage output**, or say:

> **“Coverage report generated”**

Then we continue Day-5 with:
**illegal_bins + coverage closure strategy** 🚀
