Yes — **exactly what you want is already supported**, and you do **not** need to stay in the current directory 👍
You control this **entirely** with `-report_dir`.

---

## ✅ Direct answer (short)

**Yes.** Use an **absolute or relative path** with `-report_dir`.

```bash
xcrg -report_format html \
     -dir C:/Users/gouda/GitHubProjects/Hardware/DV\ Roadmap/SVerilog/Day10_FunCoverage_Monitor/xsim.covdb \
     -report_dir C:/Users/gouda/GitHubProjects/Hardware/CoverageReports/Day10/
```

➡️ HTML will be saved in:

```
C:/Users/gouda/GitHubProjects/Hardware/CoverageReports/Day10/
└── functionalCoverageReport/
```

You can run this command from **any directory**.

---

## ✅ Relative path example (not current dir)

```bash
xcrg -report_format html \
     -dir ./xsim.covdb \
     -report_dir ../Coverage_HTML/Day10/
```

If current dir is:

```
Day10_FunCoverage_Monitor/
```

HTML goes to:

```
Coverage_HTML/Day10/functionalCoverageReport/
```

---

## ❗ Important gotchas (Vivado-specific)

### 1️⃣ `-report_dir` **must already exist**

Create it first:

```powershell
mkdir C:\Users\gouda\GitHubProjects\Hardware\CoverageReports\Day10
```

### 2️⃣ `xcrg` always creates:

```
<report_dir>/functionalCoverageReport/
```

You **cannot rename** this folder (tool limitation).

---

## 🧠 Why this confused many users (including seniors)

* `xsim` shell ≠ OS shell
* `report_coverage` is **not** an xsim command
* Coverage report generation is **external** (`xcrg`)
* Path handling is **not auto-relative** unless you specify it

You figured this out correctly — well done.

---

## ✅ Best practice (what DV teams actually do)

```bash
xcrg -report_format html \
     -dir ./xsim.covdb \
     -report_dir ../../coverage_reports/$(date +%Y%m%d_%H%M)
```

(Or manual naming on Windows)

---

If you want next:

* merging multiple `xsim.covdb`
* excluding bins
* per-instance coverage meaning (ties to Day-10)

Just say **Next**
