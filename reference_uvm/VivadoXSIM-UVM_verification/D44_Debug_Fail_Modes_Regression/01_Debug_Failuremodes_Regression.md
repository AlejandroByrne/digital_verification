Good.
This is a **critical day** — this is where people stop being “UVM users” and start thinking like **verification engineers**.

---

## 🚨 Day-44 — Debugging, Failure Modes & Regression Mindset

> *“The testbench passed” is the most dangerous sentence in DV.*

Today is **NOT** about adding features.
It’s about learning **how things silently go wrong**.

---

## 1️⃣ False Scoreboard PASS (MOST COMMON INDUSTRY BUG)

### ❌ The Lie

Your scoreboard says **PASS**, but DUT is broken.

### How it happens

Typical causes:

* Expected queue is **empty**
* Monitor never sends transactions
* Scoreboard compares **default values**
* Scoreboard run_phase never really ran

### Example of a lying scoreboard

```systemverilog
if (exp_q.size() == 0) begin
  `uvm_info("SCB", "No expected data, skipping check", UVM_LOW)
  return;
end
```

☠️ This is **evil**.
Regression stays green forever.

### ✅ Correct mindset

A scoreboard must **FAIL LOUDLY**.

```systemverilog
if (exp_q.size() == 0)
  `uvm_fatal("SCB", "Expected queue empty — test is INVALID")
```

👉 **Rule:**

> *No comparison = test failure, not pass*

---

## 2️⃣ Coverage Lies (Coverage ≠ Correctness)

### ❌ The Lie

“Functional coverage is 100% — we’re done.”

### How coverage lies

* Coverage sampled on **invalid cycles**
* Sampled before reset deassertion
* Sampled even when DUT rejects data
* Monitor samples X/Z as valid bins

Example bug:

```systemverilog
covergroup cg;
  coverpoint data;
endgroup
```

No **valid qualifier** 😈

### ✅ Correct coverage sampling

```systemverilog
if (txn.accepted)
  cg.sample();
```

👉 **Rule:**

> Coverage must be gated by **protocol correctness**

Coverage without protocol qualification is **marketing**, not verification.

---

## 3️⃣ Phase Misuse (Silent Simulation Killers)

### ❌ Classic mistakes

* Driving stimulus in `build_phase`
* Objections raised in `start_of_simulation`
* Objection never dropped
* Infinite loops without phase awareness

### Real regression hang

```systemverilog
task run_phase(uvm_phase phase);
  phase.raise_objection(this);
  forever begin
    drive();
  end
  phase.drop_objection(this); // NEVER reached
endtask
```

Simulation runs forever → CI timeout.

### ✅ Correct pattern

```systemverilog
fork
  begin
    drive_n_txns(10);
  end
join

phase.drop_objection(this);
```

👉 **Rule:**

> Every objection must have a **provable drop path**

---

## 4️⃣ Tests That Look Green but Are Wrong

### ❌ Typical reasons

* No stimulus actually generated
* Virtual sequence never started
* Wrong sequencer connected
* Factory override didn’t apply
* Config DB path mismatch

Example silent failure:

```systemverilog
vseq.start(env.vseqr); // env.vseqr is null
```

No fatal → test passes with zero activity.

### ✅ Defensive verification

Add **assertive logging**:

```systemverilog
if (env.vseqr == null)
  `uvm_fatal("TEST", "Virtual sequencer is NULL")
```

👉 **Rule:**

> Assume nothing. Assert everything.

---

## 5️⃣ Regression Hygiene (What Seniors Care About)

### What makes regressions trustworthy

✔ Tests fail when broken
✔ No skipped checks
✔ Deterministic runtime
✔ Clear failure signatures
✔ No “INFO-only” failures

### Bad regression behavior

* Using `UVM_LOW` for failures
* Printing instead of asserting
* Ignoring monitor inactivity
* “Known failure” excuses

---

## 6️⃣ Interview-Level Failure Scenarios (You MUST answer these)

You should now confidently answer:

❓ *“Can coverage be 100% and design still be broken?”*
→ **Yes. Coverage measures observation, not correctness.**

❓ *“Have you seen a scoreboard lie?”*
→ **Yes. Empty expected queues, inactive monitors, bad gating.**

❓ *“How do you debug a hanging regression?”*
→ **Objections, infinite loops, phase misuse, blocked sequences.**

❓ *“Why did a test pass without driving traffic?”*
→ **Wrong sequencer, config DB miss, factory override not applied.**

---

## ✅ Day-44 Status

**Completed concepts:**

* False PASS scenarios ✔
* Coverage lies ✔
* Phase misuse ✔
* Regression hygiene ✔
* Real interview failure cases ✔

No new files needed today — **analysis & mindset day**.

---

## 🚀 What’s Next

👉 **Day-45 — Regression & Architecture Maturity**

* How seniors structure tests
* How to prevent future lies
* Factory + Config DB at scale
* Final mental model before interviews

Say **“Proceed Day-45”** when ready.
