Excellent.
**Day-25: Advanced Sequences** — this is where you cross from *basic UVM* into **real project-level verification**.
We will **not change DUT / interface / driver**. Only sequences and test behavior evolve.

---

# 🟦 Day-25: Advanced Sequences (COMPLETE HANDS-ON)

## 🎯 Day-25 Objectives

By the end of today you will **confidently use**:

* `pre_body()` / `post_body()`
* Sequence arbitration
* Sequence priority
* Sequence locking (`lock / unlock`)
* Layered sequences
* Correct reuse patterns

After today, you will:

* Control **sequence lifetime**
* Use **pre_body / post_body**
* Run **multiple sequences correctly**
* Understand **arbitration, priority, and locking**
* Answer **advanced interview questions confidently**

This is **interview-critical**.

---

## 1️⃣ Sequence Execution Lifecycle (IMPORTANT)

When a sequence runs, this is the exact order:

```
pre_body()
  body()
post_body()
```

📌 `pre_body()` and `post_body()` **run automatically**
📌 No need to call them explicitly

---

## 2️⃣ pre_body() / post_body() — WHY THEY EXIST

### ❌ Wrong practice

Putting setup / cleanup logic inside `body()`.

### ✅ Correct usage

### 🔹 pre_body()

* Runs **after objection is raised by test**
* Used for:

  * Reset sync
  * Resource locking
  * Setup prints
  * logging

### 🔹 post_body()

* Cleanup
* Unlocking
* End-of-sequence checks

---

## 3️⃣ HANDS-ON: Modify `my_sequence.sv`

```systemverilog
class my_sequence extends uvm_sequence #(my_txn);
    `uvm_object_utils(my_sequence)

    function new(string name="my_sequence");
        super.new(name);
    endfunction

    task pre_body();
        `uvm_info("SEQ", "Sequence pre_body started", UVM_MEDIUM)
    endtask

    task body();
        my_txn tx;

        repeat (5) begin
            tx = my_txn::type_id::create("tx");
            start_item(tx);
            assert(tx.randomize());
            finish_item(tx);
        end
    endtask

    task post_body();
        `uvm_info("SEQ", "Sequence post_body completed", UVM_MEDIUM)
    endtask
endclass
```

✔ No DUT changes
✔ No env changes

### ✔ Expected Log

```
[SEQ] Sequence pre_body started
[DUT] Data Received = ...
[SEQ] Sequence post_body completed
```

---

## 4️⃣ Running Multiple Sequences (CORRECT WAY)

### ❌ Wrong (parallel start inside sequence)

```systemverilog
seq1.start(seqr);
seq2.start(seqr);
```

This causes arbitration conflicts.

---

### ✅ Correct (from TEST)

```systemverilog
task run_phase(uvm_phase phase);
    my_sequence seq1, seq2;

    phase.raise_objection(this);

    seq1 = my_sequence::type_id::create("seq1");
    seq2 = my_sequence::type_id::create("seq2");

    seq1.start(env.agent.seqr);
    seq2.start(env.agent.seqr);

    #100;
    phase.drop_objection(this);
endtask
```

📌 Sequencer **arbitrates** automatically.

---
## 5️⃣ Sequence Arbitration (VERY IMPORTANT) (INTERVIEW CRITICAL)

When **multiple sequences target same sequencer**, UVM must decide:

> Who drives next?

This is called **arbitration**.

---

## 6️⃣ Default Arbitration Modes

When multiple sequences request the sequencer:

| Mode                      | Meaning                          |
| ------------------------- | -------------------------------- |
| `UVM_SEQ_ARB_FIFO`        | First come first serve (default) |
| `UVM_SEQ_ARB_PRIORITY`    | Higher priority wins             |
| `UVM_SEQ_ARB_RANDOM`      | Random selection                 |
| `UVM_SEQ_ARB_STRICT_FIFO` | Strict ordering                  |

---

## 7️⃣ HANDS-ON: Priority-Based Sequences

### 🔹 Create Two Sequences

```systemverilog
class high_pri_seq extends uvm_sequence #(my_txn);
    `uvm_object_utils(high_pri_seq)

    task body();
        my_txn tx;
        repeat (3) begin
            tx = my_txn::type_id::create("tx");
            start_item(tx);
            assert(tx.randomize());
            finish_item(tx);
        end
    endtask
endclass
```

```systemverilog
class low_pri_seq extends uvm_sequence #(my_txn);
    `uvm_object_utils(low_pri_seq)

    task body();
        my_txn tx;
        repeat (3) begin
            tx = my_txn::type_id::create("tx");
            start_item(tx);
            assert(tx.randomize());
            finish_item(tx);
        end
    endtask
endclass
```

---

### 🔹 Modify `my_test.sv`

```systemverilog
task run_phase(uvm_phase phase);
    high_pri_seq hseq;
    low_pri_seq  lseq;

    phase.raise_objection(this);

    hseq = high_pri_seq::type_id::create("hseq");
    lseq = low_pri_seq::type_id::create("lseq");

    hseq.set_priority(200);
    lseq.set_priority(50);

    fork
        hseq.start(env.agent.seqr);
        lseq.start(env.agent.seqr);
    join

    phase.drop_objection(this);
endtask
```

### ✔ Expected Behavior

High-priority sequence dominates arbitration.

---

## 7️⃣ Sequence Locking (CRITICAL REAL-WORLD TOPIC)

### Why locking?

Some sequences must **NOT be interrupted**.

---

## Lock / Grab (ADVANCED CONTROL)

### 🔒 lock()

* Blocks other sequences
* Released automatically at end

```systemverilog
virtual task pre_body();
    lock();
endtask
```

### 🛑 grab()

* Immediate exclusive access
* Dangerous if misused

📌 **lock > grab** in real projects.

---

### 🔹 Example: Atomic Sequence

```systemverilog
task body();
    my_txn tx;

    lock(m_sequencer);   // 🔒 Lock sequencer

    repeat (5) begin
        tx = my_txn::type_id::create("tx");
        start_item(tx);
        assert(tx.randomize());
        finish_item(tx);
    end

    unlock(m_sequencer); // 🔓 Unlock
endtask
```

📌 While locked:

* No other sequence can send items
* Prevents protocol violation

---

## 8️⃣ Layered Sequences (FOUNDATION FOR VIRTUAL SEQUENCES)

### Concept:

* **Parent sequence** controls flow
* **Child sequences** generate transactions

---

## Nested (Layered) Sequences

```systemverilog
class parent_seq extends uvm_sequence #(my_txn);
    `uvm_object_utils(parent_seq)

    child_seq cseq;

    task body();
        cseq = child_seq::type_id::create("cseq");
        cseq.start(m_sequencer);
    endtask
endclass
```

✔ Used in:

* Protocol layering
* Reusable VIP

---

### 🔹 Parent Sequence Example

```systemverilog
class top_sequence extends uvm_sequence;
    `uvm_object_utils(top_sequence)

    my_sequence seq1;
    my_sequence seq2;

    task body();
        seq1 = my_sequence::type_id::create("seq1");
        seq2 = my_sequence::type_id::create("seq2");

        seq1.start(m_sequencer);
        seq2.start(m_sequencer);
    endtask
endclass
```

📌 This is **not yet virtual sequence**
📌 Single agent only

---
## 9️⃣ What NOT to Do (Very Important)

❌ Raise objections in sequence
❌ Put delays in build_phase
❌ Drive signals in sequence
❌ Access DUT directly from sequence

Sequences create **transactions only**.

---

##  Interview Traps You Now Avoid

| Question                        | Correct Answer      |
| ------------------------------- | ------------------- |
| Can sequences control time?     | ❌ No                |
| Who owns simulation lifetime?   | Test                |
| Can two sequences run together? | Yes (via sequencer) |
| Difference between lock & grab? | grab is forceful    |

---

## What You Have MASTERED Today

✔ Sequence lifecycle
✔ pre_body / post_body
✔ Arbitration
✔ Priority handling
✔ Locking
✔ Layered sequences

---

## ✅ Day-25 Status

**100% COMPLETE**
No DUT changes
No interface changes
No driver changes

--- 

## 🔜 What Comes Next (STRICT ROADMAP)

➡️ **Day-26: Virtual Sequences (MULTI-AGENT CONTROL)**
This will build **directly** on today’s layered sequences.
(Needed before system-level tests)

Say: **“Proceed Day-26”**
