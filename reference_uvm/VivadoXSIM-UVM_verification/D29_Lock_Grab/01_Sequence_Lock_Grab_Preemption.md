Perfect. 🚀
We now move into **Day-29: Sequence Locking, Grab & Preemption (OWNERSHIP control)**.

This day is **short but very important** — interview-critical.

---

# 📅 Day-29: Sequence Lock / Grab / Preemption

## Why Day-29 exists (1-line)

Priority controls **fairness** (Day-28).
**Lock / Grab controls ownership** (Day-29).

---

## 1️⃣ Problem Priority CANNOT Solve

From Day-28 you already observed:

* Low-priority sequence still executes
* No starvation allowed by UVM

But sometimes you need:

* Reset sequence
* Error-recovery sequence
* Protocol-critical atomic transaction

➡ **Nothing else must run during this time**

That is **OWNERSHIP**, not priority.

---

## 2️⃣ `lock()` — Polite Ownership

### What it does

* Sequence **waits** until sequencer is free
* Once acquired → exclusive access
* Releases after sequence ends

### Usage

```systemverilog
task body();
  sequencer.lock(this);

  repeat (3) begin
    start_item(req);
    assert(req.randomize());
    finish_item(req);
  end

  sequencer.unlock(this);
endtask
```

### Key points

* Cooperative (waits)
* Safe for normal traffic
* No preemption

---

## 3️⃣ `grab()` — FORCEFUL Ownership (Preemption)

### What it does

* Immediately **preempts** running sequences
* Takes ownership **NOW**
* Other sequences are paused

### Usage

```systemverilog
task body();
  sequencer.grab(this);

  repeat (2) begin
    start_item(req);
    assert(req.randomize());
    finish_item(req);
  end

  sequencer.ungrab(this);
endtask
```

### Key points

* Aggressive
* Used for reset / error handling
* Dangerous if misused

---

## 4️⃣ lock vs grab (VERY IMPORTANT)

| Feature            | lock() | grab() |
| ------------------ | ------ | ------ |
| Waits politely     | ✅      | ❌      |
| Preempts others    | ❌      | ✅      |
| Safe default       | ✅      | ❌      |
| Reset/error flows  | ❌      | ✅      |
| Interview favorite | ⭐      | ⭐⭐⭐    |

---

## 5️⃣ Hands-On (Minimal & Clean)

### Create a **reset_seq** (new file)

Yes — **reset must be its own sequence**.
This is intentional and correct.

```systemverilog
class reset_seq extends uvm_sequence #(my_txn);
  `uvm_object_utils(reset_seq)

  task body();
    `uvm_info("RESET_SEQ", "Taking GRAB ownership", UVM_MEDIUM)

    sequencer.grab(this);

    repeat (2) begin
      start_item(req);
      req.data = 8'h00;
      finish_item(req);
    end

    sequencer.ungrab(this);
  endtask
endclass
```

---

## 6️⃣ Virtual Sequence Control (Realistic)

```systemverilog
task body();
  reset_s = reset_seq::type_id::create("reset_s");
  rand_s  = random_seq::type_id::create("rand_s");

  fork
    rand_s.start(p_sequencer.seqr);
    begin
      #20;
      reset_s.start(p_sequencer.seqr);
    end
  join
endtask
```

### Expected Behavior

* Random traffic starts
* Reset **interrupts everything**
* After reset → random resumes

This **cannot be done with priority alone**.

---

## 7️⃣ What You Should Observe in Log

```
[SEQ_Rand] running
[RESET_SEQ] Taking GRAB ownership
[DUT] Reset
[DUT] Reset
[SEQ_Rand] resumes
```

✔ That confirms correct preemption.

---

## 8️⃣ Interview Gold (memorize)

> **Priority decides who goes next.
> Lock decides who waits.
> Grab decides who gets kicked out.**

---

## 9️⃣ Day-29 Status

✅ Concepts covered
✅ Hands-on pattern given
✅ No DUT change
✅ Same environment
✅ Roadmap intact

---

### 🔜 Next

**Day-30: Layered Sequences + Reusable Scenario Modeling**

Say:

> **Proceed Day-30**
