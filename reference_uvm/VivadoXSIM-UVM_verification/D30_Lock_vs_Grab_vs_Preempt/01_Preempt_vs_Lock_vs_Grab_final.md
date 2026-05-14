Perfect.
**📅 Day-30: Preempt vs Lock vs Grab (FINAL control mastery)**

You are now at the **last control primitive** in UVM sequencing. Everything after this is *composition*, not new mechanics.

---

## 🎯 Day-30 Goal

You must clearly understand **WHEN** and **WHY** to use:

* `lock()`
* `grab()`
* `preempt()`

And what actually happens **on the sequencer**.

---

## 1️⃣ Mental Model (MOST IMPORTANT)

Think of the sequencer as a **single shared road**.

| Mechanism              | Meaning                                            |
| ---------------------- | -------------------------------------------------- |
| **Normal arbitration** | Cars take turns                                    |
| **lock()**             | “No new cars allowed, but current one finishes”    |
| **grab()**             | “Emergency vehicle — stop everyone NOW”            |
| **preempt()**          | “I can interrupt *only if I have higher priority*” |

---

## 2️⃣ `lock()` – Graceful Ownership

### What it does

* Blocks **new sequences**
* Allows **currently running item** to finish
* Safe, clean, protocol-friendly

### When to use

✔ Configuration
✔ Mode change
✔ Power state transitions

### Example

```systemverilog
task body();
  p_sequencer.lock(this);

  repeat (2) begin
    my_txn tx = my_txn::type_id::create("tx");
    start_item(tx);
    tx.data = 8'hAA;
    finish_item(tx);
  end

  p_sequencer.unlock(this);
endtask
```

📌 **Lock waits politely**

---

## 3️⃣ `grab()` – Hard Ownership (You already used this 👍)

### What it does

* **Immediately** takes control
* Kills arbitration fairness
* Blocks everyone else

### When to use

✔ Reset
✔ Fatal recovery
✔ Bus clear / flush

### You already proved it works:

```text
[RESET_SEQ] Taking grab ownership
... only reset items ...
[RESET_SEQ] Releasing grab
```

📌 **Grab is nuclear** ☢️ — use sparingly

---

## 4️⃣ `preempt()` – Priority-Based Interruption (NEW)

### What it does

* Interrupts **lower priority sequences**
* Only works if:

  ```
  my_priority > running_priority
  ```

### When to use

✔ Error injection
✔ Watchdog timeout
✔ Urgent debug traffic

---

### 🔹 Preempt Example

```systemverilog
class urgent_seq extends uvm_sequence #(my_txn);
  `uvm_object_utils(urgent_seq)
  `uvm_declare_p_sequencer(my_sequencer)

  task body();
    set_priority(1000);
    `uvm_info("URGENT", "Attempting preempt", UVM_MEDIUM)

    p_sequencer.preempt(this);

    my_txn tx = my_txn::type_id::create("tx");
    start_item(tx);
    tx.data = 8'hFF;
    finish_item(tx);
  endtask
endclass
```

📌 If priority is lower → **preempt FAILS silently**

---

## 5️⃣ Comparison Table (MEMORIZE)

| Feature                    | lock   | grab  | preempt   |
| -------------------------- | ------ | ----- | --------- |
| Immediate takeover         | ❌      | ✅     | ✅*        |
| Allows current item finish | ✅      | ❌     | ❌         |
| Needs priority             | ❌      | ❌     | ✅         |
| Safe for protocol          | ✅      | ⚠️    | ⚠️        |
| Typical use                | Config | Reset | Emergency |

---

## 6️⃣ Interview Killer Answer 🔥

> **Q:** Difference between lock, grab, preempt?

**Answer:**

> *lock prevents new sequences but allows current transaction to complete; grab forcefully takes ownership immediately; preempt conditionally interrupts based on priority.*

---

## 7️⃣ You Are DONE with Control Primitives ✅

You now fully understand:

* Arbitration
* Priority
* Parallel sequences
* lock
* grab
* preempt

🚨 **No more low-level control topics remain**

---

## 🔜 Next (Day-31 Preview)

**Layered Sequences**

* Reset layer
* Config layer
* Traffic layer
* Clean separation
* Real SoC modeling

Say:

> **Proceed Day-31**

You’ve crossed the hardest UVM barrier.
