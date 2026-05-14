Perfect.
We continue **same clean flow**, **no shortcuts**, **required theory first → then hands-on**.

---

# 🟦 Day-21 — Functional Coverage (covergroup, sampling, closure mindset)

This is the **last core pillar of verification**.

If **scoreboard** answers

> *“Is DUT correct?”*

Then **coverage** answers

> *“Did we test enough?”*

---

## 🎯 Day-21 Goal

By end of today, you will:

✔ Understand **what functional coverage is (and is not)**
✔ Write a **covergroup** correctly
✔ Sample coverage from **monitor**
✔ Understand **coverage closure mindset** (interview critical)

---

## 1️⃣ REQUIRED THEORY (DO NOT SKIP)

### ❓ What is Functional Coverage?

Functional coverage:

* Measures **what scenarios were exercised**
* Is **user-defined**
* Is **intent-based**, not structural

Example:

> “Did I test all data values?”
> “Did I test corner cases?”

This **cannot** be answered by code coverage alone.

---

### ❓ Functional Coverage vs Code Coverage

| Aspect           | Code Coverage   | Functional Coverage   |
| ---------------- | --------------- | --------------------- |
| Who defines      | Tool            | Verification engineer |
| What it measures | Lines, branches | Behavior, scenarios   |
| Meaning          | Shallow         | Deep                  |
| Interview weight | Medium          | **High**              |

---

### ❓ Where should coverage live?

✅ **Monitor** (BEST PRACTICE)

Why?

* Monitor sees **real DUT behavior**
* Not what driver *intended*
* Same reason as scoreboard input

---

## 2️⃣ Day-21 Architecture

```
DUT → Monitor → Scoreboard
              → Coverage
```

Coverage:

* Passive
* Observational
* No influence on DUT

---

## 3️⃣ What We Will Cover Today (Scope Control)

For Day-21:

* Single covergroup
* Single coverpoint
* Sampling on valid data

❌ No crosses yet (Day-22 topic)

---

## 4️⃣ Modify Monitor — Add Coverage

We extend **existing monitor** (no new files).

---

### 🔹 Update `my_monitor.sv`

Add **coverage declarations** inside the class.

```systemverilog
class my_monitor extends uvm_component;
    `uvm_component_utils(my_monitor)

    virtual my_if vif;
    uvm_analysis_port #(my_txn) ap;

    // -------------------------
    // Functional Coverage
    // -------------------------
    covergroup data_cg;
        option.per_instance = 1;

        coverpoint data {
            bins low  = {[0:63]};
            bins mid  = {[64:127]};
            bins high = {[128:255]};
        }
    endgroup

    function new(string name, uvm_component parent);
        super.new(name, parent);
        ap = new("ap", this);
        data_cg = new();
    endfunction
```

---

### 🔹 Sample Coverage in `run_phase`

Modify run phase slightly:

```systemverilog
task run_phase(uvm_phase phase);
    my_txn t;
    forever begin
        @(posedge vif.clk);
        if (!vif.rst && vif.valid) begin
            t = my_txn::type_id::create("t");
            t.data = vif.data;

            // Sample coverage
            data_cg.sample();

            ap.write(t);

            `uvm_info("MON",
                $sformatf("Observed Data = %0d", t.data),
                UVM_MEDIUM)
        end
    end
endtask
```

📌 Coverage is sampled **only on valid data**
📌 Coverage is **per monitor instance**

---

## 5️⃣ Compile & Run (Same as Before)

```bash
xvlog -sv -L uvm -f filelist.f
xelab top -L uvm -debug typical
xsim top -runall
```

---

## 6️⃣ Viewing Coverage in XSIM (Important)

### Option A: Console summary (basic)

XSIM will internally track bins hit, but console is limited.

### Option B: GUI (recommended if using Vivado GUI)

After simulation:

* Open **Coverage → Functional Coverage**
* Inspect bins:

  * low / mid / high

For now:
✔ Focus on **concept + correctness**, not GUI polish.

---

## 7️⃣ Completion Criteria (STRICT)

Day-21 is complete **only if**:

✔ Covergroup compiles without error
✔ Coverage sampled only on valid cycles
✔ Simulation runs cleanly
✔ You understand **what bins represent**

---

## 🧠 VERY IMPORTANT INTERVIEW CONCEPT

If asked:

> “What does 100% functional coverage mean?”

❌ Wrong answer:

> “All bins are hit.”

✅ Correct answer:

> “All *meaningful* scenarios defined by the verification plan are hit.”

Coverage is **guided by spec**, not ego.

---

## 🔑 What You Have Achieved Now

You now know all **four pillars of UVM verification**:

1. Stimulus (Sequences)
2. Checking (Scoreboard)
3. Observation (Monitor)
4. Measurement (Coverage)

This is the **minimum industry-ready verification foundation**.

---

## 🔜 Next Preview

### **Day-22 — Coverage Cross + Coverage Closure**

Where we answer:

> “Did combinations of scenarios occur?”

---

### Now reply with:

* **“Day-21 ran successfully”** ✅
* Or paste **any compile/runtime error**

You are now operating at a **strong intermediate UVM level** — this is no longer beginner territory.
