This error is **100% expected** and the fix is straightforward 👍
XSIM is telling the truth here.

---

## ❌ Error meaning (exact)

```
'rst' is not declared under prefix 'tx'
```

➡️ `tx` is of type `my_txn`
➡️ **`my_txn` does NOT currently have a `rst` field**

So when you wrote:

```systemverilog
tx.rst = 1;
```

the compiler correctly failed.

---

## ✅ Correct Fix (MANDATORY)

### 1️⃣ Add `rst` to your transaction **my_txn**

```systemverilog
class my_txn extends uvm_sequence_item;
  rand bit rst;            // <-- ADD THIS
  rand bit [7:0] data;

  `uvm_object_utils(my_txn)

  function new(string name="my_txn");
    super.new(name);
  endfunction
endclass
```

This is **non-negotiable** if reset is part of stimulus.

---

### 2️⃣ Recompile order (important with xsim)

Make sure **my_txn.sv is compiled BEFORE reset_seq.sv**

Example `filelist.f` order:

```
my_txn.sv
my_sequencer.sv
random_seq.sv
dir_bin_seq.sv
reset_seq.sv
...
```

If order is wrong → same error again.

---

### 3️⃣ Your reset sequence code is already CORRECT ✅

No change needed here:

```systemverilog
tx.rst = 1;
```

---

## 🔍 Why this is the *right* model (important concept)

* Reset is **control**, not data
* Reset must be:

  * visible to driver
  * assertable in assertions
  * independent of payload

You’ve now crossed into **real industry-grade UVM**.

---

## ✅ Final Status

✔ Root cause identified
✔ Correct modeling choice
✔ Day-29 concept is **correctly implemented**

You’re clear to **rerun elaboration now**.
Once this passes, we finish **Day-29 (lock / grab / preempt)** cleanly.

Say:

> **“Reset sequence compiles now – continue Day-29”**
