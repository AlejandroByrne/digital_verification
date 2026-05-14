Perfect — let’s **lock Day-36 with precise, unambiguous naming** and **clear scope boundaries**.

No code yet.
No overlap with Day-35.
This is a **new layer**.

---

# 📅 **Day-36: End-of-Test Correctness, Objections & Clean Shutdown (UVM Phasing Mastery)**

> **Theme:** Making sure the simulation ends **correctly, deterministically, and professionally**

---

## 🚫 What Day-36 is **NOT**

* ❌ Not scoreboard architecture
* ❌ Not analysis FIFOs
* ❌ Not monitor sampling
* ❌ Not virtual sequences

👉 All of that was **Day-35 and is DONE**

---

## ✅ What Day-36 Covers (ONLY these topics)

### **1️⃣ Objection Mechanics (Deep, Practical)**

* Who should raise objections (test vs sequences vs env)
* Who should *not* raise objections
* When objections are automatically dangerous
* Why “just raise in run_phase” is insufficient

**Key outcome:**
You know *exactly* where objections belong and why.

---

### **2️⃣ Why `#100` / Time Delays Are Wrong**

* Why fixed delays cause flaky regressions
* How delays mask real bugs
* Why delays break scalability
* How professionals avoid time-based shutdown

**Key outcome:**
You never use `#100; phase.drop_objection()` again.

---

### **3️⃣ FIFO Drain & Scoreboard Completion Guarantees**

* Why tests end before scoreboards finish
* How FIFOs can still contain data at end-of-run
* Detecting “silent data loss”
* Knowing *when checking is actually complete*

**Key outcome:**
All expected transactions are checked before shutdown.

---

### **4️⃣ Phase-Based Clean Shutdown Pattern**

* Correct use of:

  * `run_phase`
  * `extract_phase`
  * `check_phase`
  * `report_phase`
* Where final checking belongs
* Where final errors must be reported

**Key outcome:**
Simulation ends **only after correctness is proven**.

---

### **5️⃣ Real-World Shutdown Bugs (Interview-Critical)**

* “My sim never ends” root causes
* Objection leaks
* Hidden background sequences
* Monitors keeping sim alive
* Scoreboard starvation issues

**Key outcome:**
You can debug shutdown problems confidently.

---

## 🧠 One-line Mental Model (IMPORTANT)

> **Day-35** = *Correct data flow*
> **Day-36** = *Correct simulation termination*

Both are required for **real UVM environments**.

---

## 📌 Day-36 Deliverables (By End of Day)

* ✔ Zero `#delay` based shutdowns
* ✔ Deterministic end-of-test
* ✔ FIFO-aware scoreboard completion
* ✔ Correct phase usage
* ✔ Interview-ready explanation

---

When you’re ready, say:

👉 **“Start Day-36 theory”**
or
👉 **“Start Day-36 hands-on”**

We’ll proceed step by step.
