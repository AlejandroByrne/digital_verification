Absolutely — here is **📅 Day-27 rewritten EXACTLY**, but **using ONLY your existing sequences**
👉 `random_seq`
👉 `dir_bin_seq ([0:63])`

No new sequence files, no reset_seq, no confusion.

---

# 📅 **Day-27: Multi-Sequence Control**

### *(Virtual Sequences – Advanced, using existing sequences)*

---

## 🎯 **Goal of Day-27**

Learn how a **virtual sequence** can:

* Coordinate **multiple existing sequences**
* Run them **in order** or **in parallel**
* Keep the **test clean**
* Scale to real projects

> ⚠️ Focus is on **coordination**, NOT new stimulus types.

---

## 🧩 What You Already Have (Perfect Setup)

You already implemented:

* ✅ `random_seq`
* ✅ `dir_bin_seq` (forcing `[0:63]`)
* ✅ `virtual_sequencer`
* ✅ `my_virtual_seq`
* ✅ `start(null)`

This is **ideal** for Day-27.

---

## 1️⃣ **Ordered (Sequential) Multi-Sequence Control**

### Scenario

👉 First send **directed low-range traffic**
👉 Then send **random traffic**

### ✅ Virtual Sequence Code

```systemverilog
class main_vseq extends uvm_sequence;
  `uvm_object_utils(main_vseq)

  virtual_sequencer vseqr;

  task body();
    dir_bin_seq low_s;
    random_seq  rand_s;

    low_s  = dir_bin_seq::type_id::create("low_s");
    rand_s = random_seq::type_id::create("rand_s");

    `uvm_info("VSEQ", "Starting directed [0:63] sequence", UVM_MEDIUM)
    low_s.start(vseqr.seqr);

    `uvm_info("VSEQ", "Starting random sequence", UVM_MEDIUM)
    rand_s.start(vseqr.seqr);
  endtask
endclass
```

### ✅ What this demonstrates

✔ Deterministic ordering
✔ Directed → Random flow
✔ Very common in real DV projects

---

## 2️⃣ **Parallel Multi-Sequence Control (CRITICAL PATTERN)**

### Scenario

👉 Run **directed** and **random** traffic together

### ✅ Virtual Sequence Code

```systemverilog
task body();
  dir_bin_seq low_s;
  random_seq  rand_s;

  low_s  = dir_bin_seq::type_id::create("low_s");
  rand_s = random_seq::type_id::create("rand_s");

  `uvm_info("VSEQ", "Starting parallel sequences", UVM_MEDIUM)

  fork
    low_s.start(vseqr.seqr);
    rand_s.start(vseqr.seqr);
  join
endtask
```

### 🔍 Important Notes

* Both sequences target **the same sequencer**
* Arbitration decides execution (FIFO by default)
* No protocol violation — sequencer serializes items

---

## 3️⃣ **Ordered + Parallel (REAL-WORLD COMBINATION)**

### Scenario

👉 Step-1: Directed traffic
👉 Step-2: Parallel stress with random + directed

```systemverilog
task body();
  dir_bin_seq low_s;
  random_seq  rand_s;

  low_s  = dir_bin_seq::type_id::create("low_s");
  rand_s = random_seq::type_id::create("rand_s");

  // Step-1: Directed first
  low_s.start(vseqr.seqr);

  // Step-2: Parallel stress
  fork
    rand_s.start(vseqr.seqr);
    low_s.start(vseqr.seqr);
  join
endtask
```

✔ This pattern is **very common in regressions**

---

## 4️⃣ **What Virtual Sequences ARE Allowed to Do**

✅ Start other sequences
✅ Control order
✅ Control parallelism
✅ Insert delays (`#50ns`)
> Virtual sequences **CAN control time**:

    ```systemverilog
    #50ns;
    ```
✅ Coordinate scenarios

---

## 5️⃣ **What Virtual Sequences Must NOT Do**

❌ `start_item()`
❌ Drive signals
❌ Access interface
❌ Implement protocol logic
❌ Raise/drop objections

> Virtual sequence = **orchestrator**, not driver

---

## 6️⃣ **Objections Reminder (Still the Same)**

✔ **Test** controls objections
❌ Virtual sequence does NOT

You already follow this correctly.

---

## 7️⃣ **Day-27 Completion Checklist**

You are DONE with Day-27 when you have:

✅ Used **existing sequences only**
✅ Run sequences **sequentially**
✅ Run sequences **in parallel**
✅ Used `fork…join` correctly
✅ Started everything from **virtual sequence**
✅ Kept test clean

---

## 🔒 **Roadmap Integrity Check**

* No new DUT
* No new sequence types required
* No topics skipped
* No reordering

Day-27 builds **directly** on Day-26 — exactly as planned.

---

## 🔜 **Next (Day-28 – LOCKED)**

➡️ **Multi-Agent Virtual Sequences**
(Control multiple sequencers from ONE virtual sequence)

---

When you finish running **ordered + parallel** using
`random_seq` & `dir_bin_seq`, say:

**“Day-27 hands-on done”**
