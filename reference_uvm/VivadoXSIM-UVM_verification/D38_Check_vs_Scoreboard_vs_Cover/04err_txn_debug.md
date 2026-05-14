Good — this error is **clean, deterministic, and expected**.
Let’s resolve it *precisely*, not by guesswork.

---

## 🔴 Error you saw

```
ERROR: [VRFC 10-2989] 'txn' is not declared
```

at **line 1** of `my_coverage.sv`

---

## 🔍 Root cause (exact)

You used `txn` (or `my_txn`) in the **class parameter or method**, but:

* The **type is not visible** at that point
* XSIM compiles **file-by-file**, not “project-wide magically”

So this is **not a UVM issue** — it’s **SV compilation order / visibility**.

---

## ❌ What caused it

Typical pattern that triggers this:

```systemverilog
class my_coverage extends uvm_subscriber #(txn);
```

or

```systemverilog
virtual function void write(txn t);
```

but:

* `txn` is declared in **another file**
* That file is **not compiled earlier**
* Or the type is inside a package not imported

---

## ✅ Canonical fix (industry-correct)

### **Option 1 — Use your real transaction type (recommended)**

#### 1️⃣ Put transaction in its own file

`my_txn.sv`

```systemverilog
class my_txn extends uvm_sequence_item;
  `uvm_object_utils(my_txn)
  rand bit [7:0] data;
endclass
```

#### 2️⃣ Compile order MUST be:

```text
my_txn.sv
my_coverage.sv
```

or in XSIM:

```powershell
xvlog my_txn.sv my_coverage.sv ...
```

#### 3️⃣ Coverage class

```systemverilog
class my_coverage extends uvm_subscriber #(my_txn);
  `uvm_component_utils(my_coverage)

  int unsigned cov_data;

  covergroup cg;
    option.per_instance = 1;
    data_cp : coverpoint cov_data;
  endgroup;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    cg = new();
  endfunction

  virtual function void write(my_txn t);
    cov_data = t.data;
    cg.sample();
  endfunction
endclass
```

---

### **Option 2 — Use a package (best practice at scale)**

#### `txn_pkg.sv`

```systemverilog
package txn_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class my_txn extends uvm_sequence_item;
    `uvm_object_utils(my_txn)
    rand bit [7:0] data;
  endclass
endpackage
```

#### In `my_coverage.sv`

```systemverilog
import txn_pkg::*;
```

This **completely eliminates compile-order bugs**.

---

## ❌ What NOT to do

```systemverilog
extends uvm_subscriber #(uvm_sequence_item); // ❌
virtual function void write(uvm_sequence_item t); // ❌
```

Why?

* You lose type safety
* You can’t access fields like `t.data`
* You break scoreboard/coverage correctness later

---

## 🧠 Mental rule (lock this)

> **Coverage and scoreboards must consume the SAME transaction type the monitor publishes.**

No wrappers. No casts. No guessing.

---

## ✅ Status check (where you are now)

✔ Coverage concept correct
✔ Subscriber vs analysis_port understanding correct
✔ Tool quirk resolved
✔ Type visibility issue understood

👉 You are **exactly** where Day-38 should end.

---

Next step (clean, ordered, no merge):

**Day-39 — Phase-Aligned Sampling & Temporal Correctness**

Say **“Proceed Day-39”** when ready.
