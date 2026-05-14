Good catch — this is a **pure UVM API misuse**, not a simulator bug.

### Root cause (exact)

You are calling **`set_priority()` in the wrong scope**.

```systemverilog
set_priority(1000);
```

❌ **Illegal here** → causes the syntax error near `=` in XSIM.

---

## Why this happens

* `set_priority()` is **NOT a sequence method**
* It belongs to **`uvm_sequence_base` *handle usage*** when the sequence is **started**
* Inside `body()` it is **not valid**

That’s why the parser explodes at `=` — it doesn’t recognize it as a task call in this context.

---

## ✅ Correct way to do preempt (Day-30)

### Option 1️⃣ (RECOMMENDED): Set priority **before `start()`**

In **virtual sequence or test**

```systemverilog
urgent_s.set_priority(1000);
urgent_s.start(seqr);
```

❌ Remove `set_priority()` from `body()` completely.

---

### Option 2️⃣ (If you want to keep it inside sequence)

Use **`set_priority()` via `starting_phase`** (advanced, usually skipped)

For roadmap learning → **don’t use this**.

---

## ✅ Correct `urgent_seq.sv`

```systemverilog
class urgent_seq extends uvm_sequence #(my_txn);
  `uvm_object_utils(urgent_seq)
  `uvm_declare_p_sequencer(my_sequencer)

  task body();
    `uvm_info("URGENT", "Attempting preempt", UVM_MEDIUM)

    p_sequencer.preempt(this);

    my_txn tx = my_txn::type_id::create("tx");
    start_item(tx);
    tx.data = 8'hFF;
    finish_item(tx);
  endtask
endclass
```

---

## ✅ Virtual sequence

```systemverilog
urgent_s = urgent_seq::type_id::create("urgent_s");
urgent_s.set_priority(1000);   // ✅ CORRECT place
urgent_s.start(seqr);
```

---

## Mental model (important for interviews)

| Mechanism   | Where priority is set                      |
| ----------- | ------------------------------------------ |
| Arbitration | `sequencer.set_arbitration()`              |
| Priority    | `sequence.set_priority()` **before start** |
| Preempt     | `sequencer.preempt(seq)`                   |
| Grab        | `sequencer.grab(seq)`                      |
| Lock        | `sequencer.lock(seq)`                      |

---

## Status check

* ✅ Your **preempt logic is correct**
* ❌ Only the **placement of `set_priority()` was wrong**
* 🟢 Fix is trivial → rerun → logs will clearly show interruption

After this fix:
👉 **Day-30 is DONE properly**
👉 Next is **Day-31: Layered Sequences**

If you want, I can tell you **exactly what log line proves preempt worked**.
