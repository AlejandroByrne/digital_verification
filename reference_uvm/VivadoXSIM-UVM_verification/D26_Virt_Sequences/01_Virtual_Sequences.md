Perfect. **Day-26: Virtual Sequences** starts now.
This is a **major UVM milestone** — once this clicks, you’re at **senior-DV level**.

---

# 📅 Day-26 — Virtual Sequences (FOUNDATION)

## 🎯 Goal of Day-26

Understand **WHY** virtual sequences exist and **HOW** they control other sequences **without touching DUT or driver code**.

---

## 1️⃣ Problem Virtual Sequences Solve (Very Important)

Until now, you did this in `my_test`:

```systemverilog
rand_s.start(env.seqr);
```

This works **only when**:

* Single agent
* Single sequencer
* Simple traffic

### ❌ This does NOT scale

Imagine:

* TX agent + RX agent
* Reset sequence
* Config sequence
* Data traffic sequence

If you start everything from `test`:

* Test becomes messy
* No synchronization
* No reuse

👉 **Virtual Sequence fixes this**

---

## 2️⃣ What is a Virtual Sequence? (Exact Definition)

> A **virtual sequence** is a sequence that **does NOT drive transactions**,
> but **controls other sequences running on one or more sequencers**.

### Key points

| Item                     | Virtual Seq           |
| ------------------------ | --------------------- |
| Drives items             | ❌ No                  |
| Has sequencer            | ❌ No                  |
| Controls other sequences | ✅ Yes                 |
| Runs on                  | `null` (no sequencer) |

---

## 3️⃣ Core Rule (Memorize)

> **Normal sequence → runs on sequencer**
> **Virtual sequence → runs on NO sequencer**

---

## 4️⃣ Virtual Sequencer (Required Companion)

Virtual sequences **cannot talk directly to agents**.

So we introduce:

### 👉 `virtual_sequencer`

```systemverilog
class virtual_sequencer extends uvm_sequencer;
  `uvm_component_utils(virtual_sequencer)

  my_sequencer seqr;   // handle to real sequencer

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
endclass
```

📌 This is **only a container of handles**, nothing else.

---

## 5️⃣ Environment Changes (Minimal & Clean)

In `my_env.sv`:

```systemverilog
class my_env extends uvm_env;
  `uvm_component_utils(my_env)

  my_sequencer       seqr;
  virtual_sequencer  vseqr;

  function void build_phase(uvm_phase phase);
    seqr  = my_sequencer::type_id::create("seqr", this);
    vseqr = virtual_sequencer::type_id::create("vseqr", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    vseqr.seqr = seqr;   // 🔥 KEY CONNECTION
  endfunction
endclass
```

---

## 6️⃣ Writing a Virtual Sequence (Hands-On Core)

```systemverilog
class my_virtual_seq extends uvm_sequence;
  `uvm_object_utils(my_virtual_seq)

  virtual_sequencer vseqr;

  function new(string name="my_virtual_seq");
    super.new(name);
  endfunction

  task body();
    random_seq rs;

    rs = random_seq::type_id::create("rs");

    `uvm_info("VSEQ", "Starting child sequence", UVM_MEDIUM)

    rs.start(vseqr.seqr);   // 🔥 controlling real sequencer
  endtask
endclass
```

---

## 7️⃣ Starting Virtual Sequence (From TEST)

```systemverilog
task run_phase(uvm_phase phase);
  my_virtual_seq vseq;

  phase.raise_objection(this);

  vseq = my_virtual_seq::type_id::create("vseq");
  vseq.vseqr = env.vseqr;     // 🔥 inject virtual sequencer
  vseq.start(null);           // 🔥 ALWAYS null

  #100;
  phase.drop_objection(this);
endtask
```

---

## 8️⃣ WHY `start(null)`? (Interview Favorite)

Because:

* Virtual sequence **has no sequencer**
* It only **coordinates**, not drives

> **Driving = sequencer**
> **Coordination = virtual sequence**

---

## 9️⃣ What You Practiced Today (Checklist)

✅ Why virtual sequences exist
✅ Difference: sequence vs virtual sequence
✅ Virtual sequencer role
✅ env → vseqr → seqr connection
✅ `start(null)` concept
✅ No DUT / driver changes

---

## 🔒 Roadmap Integrity Check (Important)

Nothing from previous days was skipped.
Day-26 depends on **Day-25 sequences**, which you completed.

---

## 🔜 Next (Day-27 — LOCKED)

➡️ **Multi-Sequence Control (Reset + Traffic + Config)**
➡️ Parallel sequences (`fork…join`)
➡️ Ordering & synchronization

Say **“Proceed Day-27”** when ready.
