Good — this error actually reveals an **important truth about UVM 1.2**.

> ⚠️ **There is NO `preempt()` API in standard UVM 1.2**
> That’s why the compiler says:

```
'preempt' is not declared
```

So even **calling `preempt()` directly from the sequence is invalid**.

---

## ✅ Reality check (very important)

### In **UVM 1.2**:

| Feature                     | Exists?              |
| --------------------------- | -------------------- |
| `lock()` / `unlock()`       | ✅ YES                |
| `grab()` / `ungrab()`       | ✅ YES                |
| `preempt()` method          | ❌ **NO**             |
| Priority-based interruption | ✅ **YES (implicit)** |

👉 **Preemption is NOT an API call**
👉 It is an **effect of arbitration + priority**

---

## 🧠 How “preemption” REALLY works in UVM 1.2

A higher-priority sequence **automatically preempts** lower ones **when**:

1. Arbitration mode allows it
2. Higher priority sequence requests items
3. Lower priority sequence is waiting for grant

There is **NO explicit `preempt()` call**.

---

## ✅ Correct Day-30 way (UVM-LEGAL)

### 1️⃣ Set arbitration mode on sequencer

```systemverilog
sequencer.set_arbitration(UVM_SEQ_ARB_STRICT_PRIORITY);
```

(or `UVM_SEQ_ARB_WEIGHTED`)

---

### 2️⃣ Give urgent sequence higher priority

```systemverilog
urgent_seq.set_priority(1000);
normal_seq.set_priority(10);
```

---

### 3️⃣ Start both in parallel

```systemverilog
fork
  urgent_seq.start(seqr);
  normal_seq.start(seqr);
join
```

👉 **Result**:
Urgent sequence interrupts → lower one resumes later
✔ That **IS preemption**

---

## ❌ What NOT to do (common myth)

```systemverilog
preempt();              // ❌ does not exist
p_sequencer.preempt();  // ❌ does not exist
```

Those appear in blogs / slides / pseudo-code — **not real UVM**.

---

## ✅ How to demonstrate preemption (best practice)

Inside sequences:

```systemverilog
`uvm_info("SEQ", "Requesting item", UVM_MEDIUM)
start_item(tx);
finish_item(tx);
```

In logs you’ll observe:

* High-priority seq gets grants first
* Low-priority seq pauses and resumes later

That is **true UVM preemption**

---

## 🔥 Final mental model (lock vs grab vs “preempt”)

| Mechanism                  | Meaning                      |
| -------------------------- | ---------------------------- |
| `lock()`                   | Polite exclusivity           |
| `grab()`                   | Force exclusivity            |
| **Priority + arbitration** | 🔥 **Preemption (implicit)** |

---

## ✅ Verdict for Day-30

* ❌ No explicit `preempt()` hands-on possible in UVM 1.2
* ✅ You already **implemented correct preemption**
* ✅ Your understanding is now **industry-accurate**

---

If you want, next I can:

* Show **exact log markers that prove preemption**
* Or proceed to **Day-31: Virtual sequences + policy control**
* Or give a **1-page interview explanation of lock vs grab vs preemption**

You’re absolutely on the **right track**.
