Good. We move **forward cleanly** now — no revisits, no rewrites.

---

# 🟦 Day-40: **Virtual Sequences & Policy Control (WHO decides WHAT runs, WHEN)**

> Up to Day-39
> ✔ Driver controls signals
> ✔ Monitor samples correctly
> ✔ Scoreboard + coverage aligned
>
> **Now we move control UP a level.**

---

## 🎯 Day-40 Objective

By end of today you will **clearly understand and implement**:

* Why **virtual sequences exist**
* What problem they solve (real SoC tests)
* How **policy** controls traffic *without touching sequences*
* How this differs from **layered sequences** (Day-31)

---

## 1️⃣ Problem Statement (Why Virtual Sequences?)

Your current structure:

```
test
 └── env
     ├── seqr (real sequencer)
     └── driver
```

Your test does this:

```systemverilog
seq.start(env.seqr);
```

### ❌ Limitation

* Test **must know** which sequence to run
* No global coordination
* Hard to scale to:

  * multiple agents
  * multiple phases
  * policies (sanity / stress / error)

---

## 2️⃣ Concept: Virtual Sequencer

A **virtual sequencer**:

* Has **NO driver**
* Holds **handles to real sequencers**
* Exists only to **coordinate sequences**

```
virtual_sequencer
 ├── rst_seqr
 ├── cfg_seqr
 └── data_seqr
```

Think of it as:

> 🧠 *Traffic controller, not signal driver*

---

## 3️⃣ Virtual Sequence vs Layered Sequence (IMPORTANT)

| Feature         | Layered Seq (Day-31)      | Virtual Seq (Day-40)       |
| --------------- | ------------------------- | -------------------------- |
| Runs on         | Real sequencer            | Virtual sequencer          |
| Controls        | Ordering inside one agent | Coordination across agents |
| Driver attached | Yes                       | ❌ No                       |
| Scale           | Medium                    | 🔥 High                    |

You already used **layered sequences**.
Now we **wrap them with a virtual sequence**.

---

## 4️⃣ Architecture After Day-40

```
my_test
 └── env
     ├── vseqr          <-- virtual sequencer
     │    ├── rst_seqr
     │    ├── cfg_seqr
     │    └── data_seqr
     ├── agent
     │    ├── seqr
     │    └── driver
     └── monitor / scb / cov
```

---

## 5️⃣ Virtual Sequencer Code

### `virtual_sequencer.sv`

```systemverilog
class virtual_sequencer extends uvm_sequencer;
    `uvm_component_utils(virtual_sequencer)

    // Handles to real sequencers
    my_sequencer rst_seqr;
    my_sequencer cfg_seqr;
    my_sequencer data_seqr;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
endclass
```

📌 No `seq_item_port`, no driver.

---

## 6️⃣ Environment Hook-up

### `env.build_phase`

```systemverilog
vseqr = virtual_sequencer::type_id::create("vseqr", this);
```

### `env.connect_phase`

```systemverilog
vseqr.rst_seqr  = agent.seqr;
vseqr.cfg_seqr  = agent.seqr;
vseqr.data_seqr = agent.seqr;
```

(Yes — same sequencer for now. Multi-agent comes later.)

---

## 7️⃣ Virtual Sequence (CORE OF DAY-40)

### `base_virtual_seq.sv`

```systemverilog
class base_virtual_seq extends uvm_sequence;
    `uvm_object_utils(base_virtual_seq)

    virtual_sequencer vseqr;

    function new(string name="base_virtual_seq");
        super.new(name);
    endfunction

    task body();
        if (!$cast(vseqr, m_sequencer))
            `uvm_fatal("VSEQ", "Virtual sequencer cast failed")
    endtask
endclass
```

---

## 8️⃣ Policy-Controlled Virtual Sequence

### `policy_vseq.sv`

```systemverilog
typedef enum {SANITY, STRESS} test_policy_e;

class policy_vseq extends base_virtual_seq;
    `uvm_object_utils(policy_vseq)

    test_policy_e policy;

    task body();
        super.body();

        case (policy)
            SANITY: begin
                reset_seq   rst = reset_seq::type_id::create("rst");
                sanity_seq  san = sanity_seq::type_id::create("san");

                rst.start(vseqr.rst_seqr);
                san.start(vseqr.data_seqr);
            end

            STRESS: begin
                // later
            end
        endcase
    endtask
endclass
```

---

## 9️⃣ Test Chooses POLICY, Not Sequences

### `my_test.sv`

```systemverilog
task run_phase(uvm_phase phase);
    policy_vseq vseq;

    phase.raise_objection(this);

    vseq = policy_vseq::type_id::create("vseq");
    vseq.policy = SANITY;
    vseq.start(env.vseqr);

    phase.drop_objection(this);
endtask
```

🎯 **This is the KEY mindset shift.**

Test **never touches**:

* reset_seq
* sanity_seq
* config_seq

Only sets **policy**.

---

## 10️⃣ What You Achieved Today

✔ Understand virtual sequencer purpose
✔ Implement base virtual sequence
✔ Separate **WHAT** from **WHO decides**
✔ Enable scalable test architecture
✔ Industry-standard UVM structure

---

## 🔒 Day-40 Status

**LOCKED — DO NOT MODIFY LATER**

Virtual sequences are **foundation** for:

* config DB (Day-41)
* factory overrides (Day-42)
* regression control (Day-43+)

---

### Next

👉 **Day-41: UVM Config DB — HOW things are configured (not decided)**
