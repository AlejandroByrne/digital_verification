Short, decisive answer — no ambiguity.

---

## ✅ What YOU should choose (for this roadmap)

### **RESET → Keep it OUTSIDE transactions**

**Chosen model:** **Top-level / interface reset (non-transactional)**

✔ Reset driven in `top.sv`
✔ Sequences **do not touch reset**
✔ Driver ignores reset logic
✔ Assertions check reset behavior separately

This is **correct**, **clean**, and **industry-standard** for:

* learning UVM
* protocol verification
* layered / virtual sequences
* arbitration / preemption work

👉 **Do NOT add `rst` to `my_txn` in this roadmap**

---

## ✅ What to choose for **VALID**

### **VALID → Transactional (INSIDE driver, NOT in txn)**

**Chosen model:**

* `valid` is a **protocol signal**
* **Driver controls `valid`**
* **Transaction does NOT contain `valid`**

### Correct flow

```
Sequence → creates tx (data only)
Driver   → asserts valid when sending tx
DUT      → responds with ready
```

### Example (correct)

```systemverilog
// my_txn
class my_txn extends uvm_sequence_item;
  rand bit [7:0] data;
endclass
```

```systemverilog
// driver
vif.valid <= 1;
vif.data  <= tx.data;
wait (vif.ready);
vif.valid <= 0;
```

✔ `valid` is **derived behavior**
✔ Not a stimulus parameter
✔ Keeps protocol rules centralized

---

## ❌ What NOT to do

| Mistake                          | Why wrong                                             |
| -------------------------------- | ----------------------------------------------------- |
| `tx.rst`                         | Reset is global, not transactional (for this roadmap) |
| `tx.valid`                       | Valid is protocol timing, not data intent             |
| Sequences toggling `vif.valid`   | Breaks UVM layering                                   |
| Mixing reset + traffic semantics | Kills reuse                                           |

---

## 🔑 Golden Rule (remember this)

> **Transactions describe WHAT, drivers decide HOW & WHEN**

| Signal  | Where it belongs  |
| ------- | ----------------- |
| `data`  | ✅ transaction     |
| `valid` | ✅ driver          |
| `ready` | ✅ DUT             |
| `rst`   | ✅ top / interface |

---

## Final decision summary

✔ Reset → **top-level only**
✔ Valid → **driver only**
✔ Transactions → **pure data intent**
✔ Sequences → **policy & ordering only**

This choice is:

* correct for interviews
* scalable
* clean UVM architecture

You’re aligned now.
Say **“Proceed Day-31 layered sequences hands-on”** when ready.
