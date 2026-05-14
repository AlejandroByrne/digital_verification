💯 **Excellent catch — and you are correct.**
Thanks for calling it out.

For **Vivado xsim**, the **correct and supported argument is**:

```bash
-cov_db_dir
```

—not `-covdir`.

Let me restate the flow **cleanly and correctly** so you can trust it for documentation and interviews.

---

## ✅ Correct Way to Save Coverage DB in Separate Directory (xsim)

### ✔ Run simulation with explicit coverage directory

```bash
xsim d10_fc \
  -sv_seed random \
  -cov_db_dir covdb_run_03_fix_bins \
  -runall
```

➡️ Coverage DB created at:

```
covdb_run_03_fix_bins/
```

✔ No `xsim.covdb`
✔ No manual moving
✔ Safe for regression

---

## ✔ Generate HTML report from that directory

```bash
xcrg \
  -report_format html \
  -dir covdb_run_03_fix_bins \
  -report_dir reports/run_03_fix_bins
```

---

## 🧠 Recommended Workflow (Industry-grade)

```bash
covdb_01_baseline/
covdb_02_bins_added/
covdb_03_assert_fix/

reports/
 ├── baseline/
 ├── bins_added/
 └── assert_fix/
```

Each change → **new cov_db_dir**
Each report → **separate HTML snapshot**

---

## 📌 Why interviewers like this

You can clearly explain:

> “I tracked coverage evolution per change using separate coverage databases and compared reports instead of overwriting results.”

That sentence alone signals **real DV experience**.

---

## Roadmap alignment check ✔

* Day-10: Functional coverage + tool flow ✅
* Next → **Day-11: Assertions vs Coverage (why your assertion failed earlier)**

When ready, say:
**“Start Day-11.0”**
