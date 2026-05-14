Good — this error is **100% expected** 👍
You’re doing the **right thing in the wrong place**.

Let’s fix the mental model **once and forever**.

---

## ❌ What went wrong (very important)

You typed:

```
report_coverage
launch_simulation
```

in **PowerShell (PS)** ❌

But these are **XSIM Tcl commands**, not Windows commands.

So PowerShell correctly says:

> “not recognized as a cmdlet”

---

## ✅ Correct Mental Model (LOCK THIS IN)

There are **3 different worlds**:

| Where you are        | Prompt looks like | What commands work                           |
| -------------------- | ----------------- | -------------------------------------------- |
| **PowerShell / CMD** | `PS C:\...>`      | `xelab`, `xsim`, `xvlog`                     |
| **XSIM Tcl Console** | `xsim%`           | `run`, `report_coverage`, `open_wave_config` |
| **GUI**              | Vivado window     | Coverage browser                             |

👉 `report_coverage` **ONLY works in XSIM Tcl**, never in PowerShell.

---

## ✅ Correct Way (Step-by-Step, no confusion)

### 1️⃣ From PowerShell → start simulation

```powershell
xsim d09_monscb2 -sv_seed random
```

Now look carefully.

Your prompt must change to:

```
xsim%
```

If you **don’t see `xsim%`**, you are NOT inside the simulator.

---

### 2️⃣ Inside `xsim%` → run simulation

```tcl
run -all
```

(or it may auto-run)

---

### 3️⃣ Now run coverage commands (THIS is where they work)

```tcl
report_coverage
```

or detailed:

```tcl
report_coverage -details
```

✅ This will now work.

---

## 🧠 Why `launch_simulation` failed

`launch_simulation` is a **Vivado GUI Tcl command**, not an xsim batch command.

You are running **standalone xsim**, so:

* ❌ `launch_simulation` → invalid
* ✅ `run`, `report_coverage` → valid

---

## ✅ How to SEE coverage visually (recommended)

### Option A: Open waveform + coverage

From **xsim%**:

```tcl
open_wave_config
```

Then in GUI:

```
Coverage → Functional Coverage → dff_cg
```

---

### Option B: Coverage report file (industry style)

During elaboration:

```powershell
xelab tb_dff -coverage all
xsim tb_dff -runall
```

Then check:

```
xsim.dir/*/coverage*
```

---

## 🚨 Very Important XSIM Limitation (REALITY)

XSIM coverage support is **limited** compared to:

* VCS
* Questa

So:

* You **can** collect coverage ✔
* GUI browsing may be clunky ❗
* This is OK for **learning + resume**

Interviewers **do not expect** mastery of XSIM GUI.

They expect:

> “I know what coverage is and why it matters”

You are already there.

---

## ✅ What YOU should do now

Reply with **one word**:

* **OK** → proceed to **Day-11 (UVM concepts, no code yet)**
* **FIX** → I’ll help you force-hit the `(en=1, d=1)` cross bin
* **WHY** → Deep dive: why XSIM coverage behaves weird

You’re back on track.
