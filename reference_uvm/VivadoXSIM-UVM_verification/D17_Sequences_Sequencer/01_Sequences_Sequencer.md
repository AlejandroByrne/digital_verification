Excellent.
Day-17 is where **UVM stops being “objects” and starts becoming a real stimulus flow**.

As always: **required theory first → then code → then checks**.
No skipping concepts.

---

# 📅 **Day-17 — Sequences & Sequencer (Transaction Flow Begins)**

🎯 **Goal of Day-17**
Understand **how transactions are generated and delivered** in UVM using:

* `uvm_sequence`
* `uvm_sequencer`
* the **request–grant–response** flow

By end of today:

* You will generate transactions **from a sequence**
* See them **arrive at a driver**
* Still **NO DUT driving yet** (that’s Day-18)

---

## 1️⃣ Prerequisites (Confirm)

You should already be clear on:

* `uvm_sequence_item` (Day-16)
* Factory creation
* Tasks vs functions
* Mailbox-style thinking (producer → consumer)

If yes → proceed.

---

## 2️⃣ Required Theory — Why Sequences Exist (CRITICAL)

### 🔴 Without sequences

Driver would:

* Randomize data
* Decide stimulus order
* Control traffic

❌ Bad design
❌ No reuse
❌ No layered stimulus

---

### 🟢 With sequences (UVM way)

**Separation of concerns**:

| Component | Responsibility                |
| --------- | ----------------------------- |
| Sequence  | **What** transactions to send |
| Sequencer | Arbitration & ordering        |
| Driver    | **How** to drive signals      |

📌 **Golden Rule**

> Sequences never touch signals
> Drivers never randomize

---

## 3️⃣ Required Theory — Sequencer’s Role

Sequencer:

* Accepts requests from sequences
* Arbitrates between them
* Hands transactions to driver

Think of it as:

> “Traffic controller between stimulus and execution”

---

## 4️⃣ Required Theory — Transaction Handshake

Every sequence–driver interaction follows:

```
start_item(txn)
  randomize()
finish_item(txn)
```

Conceptually:

1. Sequence asks permission
2. Sequencer grants
3. Transaction is delivered to driver

You **must** understand this flow — syntax comes next.

---

## 5️⃣ Code: Basic Sequencer

### 🔹 `my_sequencer.sv`

```systemverilog
`include "uvm_macros.svh"
import uvm_pkg::*;

class my_sequencer extends uvm_sequencer #(my_txn);
  `uvm_component_utils(my_sequencer)

  function new(string name="my_sequencer", uvm_component parent=null);
    super.new(name, parent);
  endfunction
endclass
```

📌 **Concept**

* Parameterized by transaction type
* No behavior yet (that’s normal)

---

## 6️⃣ Code: Basic Sequence (Stimulus Generator)

### 🔹 `my_sequence.sv`

```systemverilog
`include "uvm_macros.svh"
import uvm_pkg::*;

class my_sequence extends uvm_sequence #(my_txn);
  `uvm_object_utils(my_sequence)

  function new(string name="my_sequence");
    super.new(name);
  endfunction

  task body();
    my_txn tx;

    repeat (5) begin
      tx = my_txn::type_id::create("tx");
      start_item(tx);
      assert(tx.randomize());
      finish_item(tx);
    end
  endtask
endclass
```

---

### 🔍 Key Concepts in This Code

* `body()`
  → main sequence execution task

* `start_item()` / `finish_item()`
  → handshake with sequencer

* Randomization happens **inside sequence**

---

## 7️⃣ Code: Minimal Driver (NO DUT YET)

### 🔹 `my_driver.sv`

```systemverilog
`include "uvm_macros.svh"
import uvm_pkg::*;

class my_driver extends uvm_driver #(my_txn);
  `uvm_component_utils(my_driver)

  function new(string name="my_driver", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    my_txn tx;
    forever begin
      seq_item_port.get_next_item(tx);
      `uvm_info("DRIVER", "Transaction received:", UVM_MEDIUM)
      tx.print();
      seq_item_port.item_done();
    end
  endtask
endclass
```

📌 **Concept**

* Driver waits for transactions
* No signal driving yet
* Just prints → confirms data flow

---

## 8️⃣ Connect Sequencer ↔ Driver

### 🔹 Update `my_env.sv`

```systemverilog
class my_env extends uvm_env;
  `uvm_component_utils(my_env)

  my_sequencer seqr;
  my_driver    drv;

  function new(string name="my_env", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    seqr = my_sequencer::type_id::create("seqr", this);
    drv  = my_driver   ::type_id::create("drv",  this);
  endfunction

  function void connect_phase(uvm_phase phase);
    drv.seq_item_port.connect(seqr.seq_item_export);
  endfunction
endclass
```

📌 **Concept**

* Structural connection
* No stimulus here

---

## 9️⃣ Start Sequence from Test

### 🔹 Update `my_test.sv`

```systemverilog
task run_phase(uvm_phase phase);
  my_sequence seq;

  phase.raise_objection(this);

  seq = my_sequence::type_id::create("seq");
  seq.start(env.seqr);

  phase.drop_objection(this);
endtask
```

📌 **Concept**

* Test controls **which sequence runs**
* Enables reuse across tests

---

## 🔟 XSIM Flow (Day-17)

```bash
xvlog -sv -L uvm *.sv
xelab top -L uvm -debug typical
xsim top -runall
```

### ✅ Expected Output

You should see:

* Sequence creating transactions
* Driver printing transactions
* Multiple items printed

This confirms:

> Sequence → Sequencer → Driver flow is working

---

## 1️⃣1️⃣ Day-17 Completion Checklist

✔ You understand **why sequences exist**
✔ Sequence generates transactions
✔ Sequencer arbitrates
✔ Driver receives items
✔ No DUT yet (as intended)

If all ✔ → **Day-17 COMPLETE**

---

## 🔜 Next: **Day-18 — Driver → DUT (Virtual Interface)**

Now we answer:

> “How does this transaction touch real signals?”

That requires:

* Interfaces
* Virtual interfaces
* Clean signal driving

When ready, say:

> **“Proceed Day-18”**

You’re now past the hardest conceptual hump in UVM.
