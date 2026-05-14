Quick and clean 👍

You already have **all the pieces** — you just need one small tweak to the `xcrg` command.

---

## ✅ Save HTML report in a **separate directory**

Use `-report_dir` to control **where the HTML is generated**.

### Example

```bash
xcrg -report_format html \
     -dir ./xsim.covdb/ \
     -report_dir ./cov_html/
```

### Result

```
xsim.covdb/          ← coverage database (input)
cov_html/            ← NEW directory (output)
  └── functionalCoverageReport/
        ├── dashboard.html
        ├── index.html
        └── ...
```

Open:

```
cov_html/functionalCoverageReport/dashboard.html
```

---

## ✅ Common useful patterns

### 1️⃣ Per-run timestamped directory (recommended)

```bash
xcrg -report_format html \
     -dir ./xsim.covdb/ \
     -report_dir ./cov_reports/run_01/
```

### 2️⃣ Per-testcase

```bash
xcrg -report_format html \
     -dir ./xsim.covdb/ \
     -report_dir ./cov_reports/dff_basic/
```

---

## ⚠️ Important notes

* `-report_dir` **must exist** (create it if needed)
* `xcrg` will **always create** `functionalCoverageReport/` inside it
* HTML files are **static** → safe to zip / email / archive

---

## 🧠 One-line mental model (remember this)

> `xsim.covdb` = raw data
> `xcrg` = report generator
> `report_dir` = where humans read coverage

---

If you want next:

* **merge coverage from multiple runs**
* **exclude covergroups**
* **CI-style coverage automation**

Just say **“Next”** 👍

