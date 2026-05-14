Good catch 👍 — yes, that **was missing**, and it **matters**.

Here is the **corrected short note**, with **`xelab -L uvm -debug typical` properly explained**.

---

# 🔹 XSIM / Vivado Simulation & Coverage – Short Notes (Corrected)

---

## 1️⃣ Compile — `xvlog`

```bash
xvlog -sv -L uvm -f filelist.f
```

### Purpose

Compiles **SystemVerilog + UVM** source files.

### Key Options

* `-sv` → Enable SystemVerilog
* `-L uvm` → Link UVM library
* `-f filelist.f` → Compile files in listed order

### Notes

* Syntax + semantic checking
* No hierarchy or simulation yet
* File order matters

---

## 2️⃣ Elaborate — `xelab`

```bash
xelab top -s sim_name
    (OR)
xelab top -L uvm -debug typical -s sim_name
```

### Purpose

Elaborates the design into a **simulation snapshot**.

### Key Options

* `top` → Top-level module
* `-L uvm` → Links UVM library at elaboration
* `-debug typical` → Enables:

  * UVM hierarchy visibility
  * Object names
  * Waveform-friendly debug
* `-s sim_name` → Names the snapshot

### Notes

* Resolves:

  * UVM factory
  * Phase scheduling
  * Module/class connectivity
* **Required for meaningful UVM debug**
* Errors here = hierarchy / factory / connection issues

📌 In real projects, `-debug typical` is **always used**.

---

## 3️⃣ Simulate — `xsim`

### Basic Run

```bash
xsim sim_name -sv_seed random -runall
```

### With coverage DB isolation

```bash
xsim sim_name -sv_seed random -cov_db_dir covdb_name -runall
```

### Purpose

Runs the simulation.

### Key Options

* `-sv_seed random` → Randomizes stimulus
* `-runall` → Runs until `$finish`
* `-cov_db_dir` → Stores coverage in a separate directory

### Notes

* Without `-cov_db_dir` → `xsim.covdb`
* With `-cov_db_dir` → regression-safe workflow

---

## 4️⃣ Coverage Report — `xcrg`

### Override previous report

```bash
xcrg -report_format html \
     -dir ./covdb_path \
     -report_dir ./report_path
```

### Append coverage groups

```bash
xcrg -report_format html \
     -dir ./xsim.covdb \
     -report_dir ./report_path
```

### Purpose

Generates **HTML functional coverage reports**.

### Notes

* Each run → new `groupX`
* Coverage DB is never modified
* HTML reports are snapshots

---

## 🧠 Complete Tool Flow (Remember This)

```
xvlog  → compile
xelab  → elaborate (+ debug)
xsim   → simulate + generate coverage DB
xcrg   → coverage report
```

---

## ⭐ Interview-Level One-Liner

> “We elaborate with `xelab -L uvm -debug typical` to enable full UVM hierarchy and debug visibility before running simulations.”

That’s a **strong, experienced answer**.

---

When you’re ready:
👉 **Proceed Day-22 – Coverage-Driven Stimulus & Closure**

You’re doing this **properly**, not skipping fundamentals.
