Good — now we’ll do **only what is actually missing**, nothing more, nothing repeated.

---

# 📅 **Day-39 (Finalize): Phase-Aligned & Valid Sampling**

> This is a **refinement layer**, not a new architecture day.

You already have:

* Monitor
* Transaction (`my_txn`)
* Scoreboard
* Coverage subscriber
* Covergroup bins working
* HTML report generated correctly

What is **still wrong** is **semantic correctness of coverage**.

---

## 1️⃣ The Core Problem (why your current coverage is misleading)

Right now your coverage does this:

```systemverilog
cov_data = t.data;
cg.sample();
```

That means:

❌ You sample **every observed transaction**
❌ Even if it is:

* During reset
* Protocol-invalid
* Rejected by scoreboard
* Duplicate / retried

So your bins are **numerically correct** but **logically wrong**.

This is why seniors say:

> “Coverage without acceptance is a lie.”

---

## 2️⃣ Rule of Day-39 (single sentence)

> **Only transactions that are ACCEPTED by the design are coverable.**

Not:

* observed
* received
* seen

But **accepted**.

---

## 3️⃣ Where acceptance is decided (important)

Acceptance is **NOT**:

* Coverage’s job
* Monitor’s job

Acceptance is decided by the **scoreboard**.

Therefore:

* Scoreboard = authority
* Coverage = consumer

---

## 4️⃣ Minimal required change (no refactor)

### 🔹 Step 1: Add acceptance flag to transaction

```systemverilog
class my_txn extends uvm_sequence_item;
  rand bit [7:0] data;

  bit accepted;   // NEW

  `uvm_object_utils(my_txn)
endclass
```

Default is `0` (rejected).

---

### 🔹 Step 2: Scoreboard sets acceptance

In scoreboard **only when check passes**:

```systemverilog
if (actual == expected) begin
  txn.accepted = 1;
end
else begin
  txn.accepted = 0;
end
```

This is **semantic truth**:

> “This transaction is valid and counted.”

---

## 5️⃣ Phase-Aligned Coverage Gating (THE Day-39 fix)

Now fix coverage **write()**.

### ❌ What you had (wrong)

```systemverilog
virtual function void write(my_txn t);
  cov_data = t.data;
  cg.sample();
endfunction
```

---

### ✅ Correct Day-39 version

```systemverilog
virtual function void write(my_txn t);

  // Gate sampling on acceptance
  if (!t.accepted)
    return;

  cov_data = t.data;
  cg.sample();

  `uvm_info("COV",
    $sformatf("Coverage sampled for accepted txn data=%0d", cov_data),
    UVM_LOW)

endfunction
```

This does **three critical things**:

✔ Samples only legal transactions
✔ Prevents double counting
✔ Aligns coverage with scoreboard truth

---

## 6️⃣ Preventing double-counting (why this works)

Why you **don’t need extra logic**:

* Each transaction object is sampled **once**
* Acceptance is decided **once**
* Coverage sees the final decision

No:

* events
* flags
* counters
* phase hacks

This is **phase-aligned by design**, not timing.

---

## 7️⃣ Your HTML report — how to read it now

After this fix:

* Low / Med / High bins mean **accepted functional space**
* Illegal bins actually mean **illegal accepted behavior**
* Coverage % is **defensible in reviews**

Before Day-39:
📊 *Activity coverage*

After Day-39:
📊 *Functional correctness coverage*

---

## 8️⃣ What Day-39 is now COMPLETE for

✔ Gate sampling on protocol-valid condition
✔ Prevent double counting
✔ Define *when* a transaction is coverable
✔ Align monitor → scoreboard → coverage
✔ Trustworthy coverage metrics

---

### 🔒 Closure statement (important)

**Day-39 ends here.**
Anything more would leak into **stimulus control**, which is Day-40.

---

👉 Next (only when you say):
**Day-40 — Virtual Sequences & Policy Control (WHO drives WHAT, WHEN)**
