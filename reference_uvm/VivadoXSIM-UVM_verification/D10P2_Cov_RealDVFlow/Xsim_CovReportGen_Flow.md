Short answer: **YES — you can avoid moving it manually.**
xsim lets you **directly control where the coverage database is written at run time**.

This is the **correct, professional way**.

---

## ✅ Best Practice: Set coverage DB directory at run time

### Method 1 (RECOMMENDED): Use `-covdir` during xsim launch

When launching xsim:

```bash
xsim d09_monscb2 \
  -sv_seed random \
  -cov_db_dir covdb_run_02_add_toggle \
  -runall
```

✔ Result:

```
covdb_run_02_add_toggle/
```

No `xsim.covdb` is created
No manual move needed

---

### Method 2: From inside xsim (TCL command)

If already inside xsim:

```tcl
set_property cov_db_dir covdb_run_03_fix_bins [current_sim]
run -all
exit
```

⚠️ Less commonly used, but valid.

---

## 🔁 Clean End-to-End Flow (Zero Manual Steps)

```bash
# 1. Run simulation
xsim d10_fc \
  -sv_seed 123 \
  -cov_db_dir covdb_run_03_fix_bins \
  -runall

# 2. Generate report
xcrg \
  -report_format html \
  -dir covdb_run_03_fix_bins \
  -report_dir reports/run_03_fix_bins
```

This is **exactly how regressions are scripted**.

---

## 📌 Naming Convention (VERY IMPORTANT)

Use **semantic names**, not random numbers:

| Change        | covdir name         |
| ------------- | ------------------- |
| Baseline      | covdb_01_baseline   |
| Add bins      | covdb_02_bins_added |
| Fix assertion | covdb_03_assert_fix |
| Regression    | covdb_04_regression |

This helps during interviews when you explain **coverage closure**.

---

## ❌ What NOT to rely on

* Default `xsim.covdb`
* Overwriting old runs
* Single coverage DB for multiple experiments

---

## 🔍 Bonus: Same approach works for

* **per-instance coverage**
* **merged coverage**
* **seed-based comparison**
* **CI regression scripts**

---

### Where this fits in roadmap

✔ Day-10: Functional coverage mechanics
➡️ **Day-11**: Assertions vs Coverage (root-cause timing bug you hit)

When ready:
**Start Day-11.0 – Assertion Timing & Clocking Blocks**
