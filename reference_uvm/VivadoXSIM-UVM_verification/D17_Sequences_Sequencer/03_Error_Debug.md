Excellent — this is a **real UVM semantic error**, not a tool glitch.
And it’s actually a **good sign**: you’re now hitting *methodology-level correctness*.

Let’s fix it cleanly and explain the **concept behind the error**, so it never bites you again.

---

# ❌ Error Explained (Exactly What Went Wrong)

```
ERROR: port 'parent' is not connected on function call 'create'
```

This points to this line in **`my_test.sv`**:

```systemverilog
seq = my_sequence::type_id::create("seq");
```

### 🔴 Root Cause (CRITICAL CONCEPT)

You are calling **`create()` on a class that expects a parent**, but you did not provide one.

This happens because:

* `my_sequence` is a **UVM object**, not a component
* In **XSIM / Vivado UVM**, the factory `create()` for sequences is implemented as:

```text
create(string name, uvm_component parent)
```

When you omit the parent:

* Vivado complains
* Other simulators may silently accept it (but that’s unsafe)

📌 **XSIM is strict — and that’s good for learning**

---

# 🧠 Required Theory — Parent in UVM

### Components vs Objects (Reinforced)

| Type                | Parent required?     | Why                    |
| ------------------- | -------------------- | ---------------------- |
| `uvm_component`     | ✅ Yes                | Hierarchy & phases     |
| `uvm_sequence_item` | ❌ No                 | Pure data              |
| `uvm_sequence`      | ⚠️ Context-dependent | Runs under a sequencer |

Even though `uvm_sequence` is an object, **XSIM expects a parent context** when created via factory.

---

# ✅ CORRECT FIX (Industry-Safe)

## 🔹 Fix in `my_test.sv`

Change this:

```systemverilog
seq = my_sequence::type_id::create("seq");
```

### ✅ To this:

```systemverilog
seq = my_sequence::type_id::create("seq", this);
```

📌 Here:

* `this` = `my_test`
* Gives the sequence a valid parent context
* Satisfies XSIM’s strict checking

---

# ✅ Why This Fix Is Correct (Concept)

* The **test owns the sequence**
* The sequence is started on the sequencer:

  ```systemverilog
  seq.start(env.seqr);
  ```
* Parent context is now unambiguous

This is **clean, portable UVM code**.

---

# 🧪 Alternative (Also Valid, Less Common)

You *could* also do:

```systemverilog
seq = my_sequence::type_id::create("seq", env.seqr);
```

This makes the **sequencer** the parent.

Both work — but **test-as-parent** is clearer for learning.

---

# 🔁 What To Do Now (Step-by-Step)

1. Fix the `create()` call:

   ```systemverilog
   seq = my_sequence::type_id::create("seq", this);
   ```
2. Re-run:

   ```bash
   xvlog -sv -L uvm -f filelist.f
   xelab top -L uvm -debug typical
   xsim top -runall
   ```
3. You should now see:

   * Sequence running
   * Driver receiving transactions
   * Printed transactions

---

# ✅ Day-17 Status After This Fix

Once this runs:

✔ Sequence creation correct
✔ Factory usage correct
✔ Sequencer arbitration correct
✔ Driver receives items

👉 **Day-17 will be COMPLETE**

---

## 🔜 What This Unlocks Next

Now that **sequence → driver flow** is working, we’re ready for:

### **Day-18 — Driver → DUT (Virtual Interface)**

This is where **real signal driving begins**.

Please reply with **one line only**:

* **“Ran successfully”** ✅
  or
* Paste the **next error** (we’ll fix it)

You’re progressing exactly like a real DV engineer — hitting the *right* problems.
