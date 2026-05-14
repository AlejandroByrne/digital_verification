Excellent observation 👌 — this means you’re **actually looking at real XSIM/xcrg behavior**, not toy examples.

This is **not a bug**. It’s **how xcrg is designed to work**.

Let’s explain it cleanly and then I’ll tell you **exactly how to control it**.

---

## 🔍 Why xcrg Creates `group1`, `group2`, … Every Run

By default:

> **`xcrg` NEVER overwrites an existing coverage group**

So if you run:

```bash
xcrg -dir covdb_run
```

multiple times **into the same report directory**, xcrg will:

```
group0  ← first run
group1  ← second run
group2  ← third run
...
```

This is intentional and **very important for regression flows**.

### Why?

* Allows comparing multiple runs
* Allows merging coverage
* Prevents accidental data loss

📌 This behavior is **industry-standard**, not a Vivado quirk.

---

## ✅ Three CORRECT Ways to Handle This

### ✅ **OPTION 1 (RECOMMENDED): New report directory per run**

This is what you *should* do (and you already hinted at it).

```bash
xcrg \
  -dir covdb_run_03_fix_bins \
  -report_dir reports/run_03_fix_bins
```

Result:

```
reports/run_03_fix_bins/group0
```

✔ Clean
✔ Predictable
✔ Best for learning & signoff

---

### ✅ **OPTION 2: Manually delete report directory (simple)**

If you want `group0` every time:

```bash
rm -rf reports/run_03_fix_bins
xcrg -dir covdb_run_03_fix_bins -report_dir reports/run_03_fix_bins
```

✔ group0 recreated
❌ manual step
❌ not regression-safe

---

### ⚠️ **OPTION 3: Merge mode (advanced / later)**

When doing regression:

```bash
xcrg \
  -dir covdb_run_* \
  -report_dir reports/merged
```

This intentionally creates:

```
group0
group1
group2
...
```

📌 This is **Day-24+ material**.

---

## 🧠 Key Concept (VERY IMPORTANT)

### Coverage DB ≠ Coverage Report

| Item                    | Purpose         |
| ----------------------- | --------------- |
| Coverage DB (`covdb_*`) | Raw truth       |
| HTML Report             | Snapshot        |
| `groupX`                | One logical run |

You **never override DBs**.
You **optionally override reports**.

---

## 🧪 Interview-Level Explanation

If asked:

> “Why does your coverage report show group1, group2?”

Correct answer:

> “xcrg appends groups to preserve historical runs; we isolate reports per run or clean the report directory if a single snapshot is needed.”

That’s a **strong verification answer**.

---

## ✅ What YOU Should Do Going Forward

✔ New **cov_db_dir** per code change
✔ New **report_dir** per coverage snapshot
✔ Let xcrg create group0 naturally

You’re already doing this — your observation proves you understand the toolchain.

---

### 🔜 Next Logical Step

**Day-22: Coverage-driven stimulus**

* Look at uncovered bin
* Modify sequence
* Prove coverage closes to 100%

Say:
👉 **“Proceed Day-22”**

You’re doing very solid, professional DV work.
