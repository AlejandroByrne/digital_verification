Perfect. We’ll go **exactly in the order DV teams use in real projects**, and I’ll tie it **directly to Day-10 functional coverage**, not theory fluff.

---

# Day-10 (Next) — Coverage in Real DV Flow

We’ll cover **three things**:

1️⃣ **Merging multiple `xsim.covdb` (regression flow)**
2️⃣ **Excluding bins / covergroups (clean coverage)**
3️⃣ **Per-instance coverage (what it *actually* means & when to use)**

---

## 1️⃣ Merging multiple `xsim.covdb` (MOST IMPORTANT)

### ❓ Why merge coverage?

Because **one random seed never hits all bins**.

Typical DV flow:

```
seed 1  → xsim.covdb
seed 2  → xsim.covdb
seed 3  → xsim.covdb
--------------------
MERGE → final coverage report
```

---

### ✅ Step-by-step (Vivado / xcrg)

Assume you ran **3 simulations**:

```
run1/xsim.covdb
run2/xsim.covdb
run3/xsim.covdb
```

### 🔹 Merge command

```bash
xcrg \
  -merge \
  -dir run1/xsim.covdb run2/xsim.covdb run3/xsim.covdb \
  -report_format html \
  -report_dir ./MergedCoverage
```

Result:

```
MergedCoverage/
└── functionalCoverageReport/
    └── dashboard.html
```

👉 **This is what managers look at.**

---

### 🧠 Key rule (INTERVIEW GOLD)

> Coverage is **never judged per seed** — only **merged regression coverage matters**.

---

## 2️⃣ Excluding bins / covergroups (CLEAN COVERAGE)

### ❓ Why exclude?

Some bins are:

* unreachable
* debug-only
* illegal but modeled
* reset-only artifacts

Leaving them:
❌ reduces %
❌ wastes debug time
❌ makes you look junior

---

### ✅ Method 1: `ignore_bins` (BEST PRACTICE)

Example from your Day-10 covergroup:

```systemverilog
covergroup cg_dff @(posedge clk);
  option.per_instance = 1;

  coverpoint en {
    bins en0 = {0};
    bins en1 = {1};
  }

  coverpoint d {
    bins d0 = {0};
    bins d1 = {1};
  }

  // ❌ ignore illegal combo
  cross en, d {
    ignore_bins no_d_when_en0 = binsof(en.en0) && binsof(d.d1);
  }
endgroup
```

➡️ This bin:

* exists
* but does **NOT** count toward coverage %

---

### ✅ Method 2: `illegal_bins` (STRONGER)

```systemverilog
cross en, d {
  illegal_bins illegal_case = binsof(en.en0) && binsof(d.d1);
}
```

Effect:

* Coverage tool flags violation
* Testbench bug or DUT bug exposed

📌 Use **illegal_bins** only when **design guarantees impossibility**.

---

### 🧠 Interview difference

| ignore_bins          | illegal_bins   |
| -------------------- | -------------- |
| Excluded from %      | Must never hit |
| Expected unreachable | Design rule    |
| No error             | Error if hit   |

---

## 3️⃣ Per-instance coverage (THIS CONFUSES 90%)

You asked earlier: **“What is option per instance?”**
Now the **real explanation**.

---

### ❓ What happens WITHOUT per-instance?

```systemverilog
covergroup cg;
  coverpoint en;
endgroup

cg cg1 = new();
cg cg2 = new();
```

Coverage result:

```
cg.en → MERGED across all instances
```

➡️ You **cannot tell** which instance was covered.

---

### ✅ With `option.per_instance = 1`

```systemverilog
covergroup cg;
  option.per_instance = 1;
  coverpoint en;
endgroup
```

Coverage result:

```
cg1.en → reported separately
cg2.en → reported separately
```

---

### 🧠 When do we REALLY use it?

| Scenario          | per_instance |
| ----------------- | ------------ |
| Multiple DFFs     | ✅            |
| Multi-channel DUT | ✅            |
| Reusable agents   | ✅            |
| Single DUT block  | ❌            |

---

### 📌 Day-10 relevance (YOUR CODE)

If your monitor has:

```systemverilog
cg_dff cov = new();
```

and you later scale to:

```systemverilog
cg_dff cov[4];
```

👉 **You MUST enable per_instance**, or coverage becomes meaningless.

---

## 🔥 Real-world DV rule

> **Functional coverage without per-instance in scalable designs is a BUG**

---

## ✅ What you now officially know (Day-10 complete)

✔ How coverage databases are generated
✔ How regression coverage is merged
✔ How to clean coverage % properly
✔ Why per-instance exists
✔ When to enable / avoid it
✔ Tool commands used in real projects

---

## Next logical step (say the word)

We can go to **Day-11**:

* Monitor-driven functional coverage
* Sampling at correct clocking block phase
* Avoiding double-sampling bugs
* Coverage-driven stimulus closure

Just say: **Proceed Day-11**
