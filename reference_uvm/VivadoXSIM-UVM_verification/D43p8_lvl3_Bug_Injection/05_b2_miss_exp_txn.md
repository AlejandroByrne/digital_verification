Perfect.
We now move **cleanly and deliberately** to:

# 🐞 Bug-2 — **Missing EXP transaction** (Level-3)

This is the **mirror image** of Bug-1 and is *equally important* for interviews and real projects.

---

## 0️⃣ What Bug-2 is testing (very important)

**Question this bug answers:**

> *If the predictor silently fails to produce an expected transaction, will the scoreboard falsely pass or correctly stall?*

At **Level-2** → often **missed**
At **Level-3** → must be **caught reliably**

---

## 1️⃣ Bug-2 definition (crystal clear)

### What we will break

👉 **Predictor drops ONE expected transaction**

### What remains correct

* Driver sends all transactions
* DUT accepts all transactions
* Monitor observes all ACT transactions

### Net effect

| Stream | Count   |
| ------ | ------- |
| ACT    | 7 ✅     |
| EXP    | **6 ❌** |

---

## 2️⃣ Where to inject the bug (only ONE place)

### ✅ Predictor is the **correct** place

Do **NOT** touch:

* Driver
* Monitor
* Scoreboard

---

## 3️⃣ Bug-2 injection — Predictor change (minimal & surgical)

Modify **only** the `write()` function.

### 🔧 Inject missing EXP (one-time drop)

```systemverilog
class my_predictor extends uvm_component;
  `uvm_component_utils(my_predictor)

  uvm_analysis_imp #(my_txn, my_predictor) in_imp;
  uvm_analysis_port #(my_txn) ap;

  int exp_drop_count = 0;   // 🔥 bug control

  function new(string name, uvm_component parent);
    super.new(name, parent);
    in_imp = new("in_imp", this);
    ap     = new("ap", this);
  endfunction

  function void write(my_txn t);
    my_txn exp;

    // 🔥 BUG-2: Drop exactly ONE expected transaction
    if (exp_drop_count == 0) begin
      exp_drop_count++;
      `uvm_warning("PRED",
        "INTENTIONAL DROP of EXP txn")
      return;
    end

    exp = my_txn::type_id::create("exp");
    exp.copy(t);

    `uvm_info("PRED",
      $sformatf("Expected written to FIFO: %0d", exp.data),
      UVM_LOW)

    ap.write(exp);
  endfunction
endclass
```

✔ Drop exactly **one** EXP
✔ All others flow normally
✔ Deterministic and debuggable

---

## 4️⃣ Scoreboard stays EXACTLY the same (important)

Your Level-3 scoreboard is already correct:

```systemverilog
repeat (7) begin
  act_fifo.get(act);   // blocks
  exp_fifo.get(exp);   // blocks
  ...
end
```

❌ No timeouts
❌ No `try_get()`
❌ No escape logic

---

## 5️⃣ Expected runtime behavior (this is the key)

### Log pattern you should see

```
[PRED] INTENTIONAL DROP of EXP txn
...
[MON] Observed Data ...
[SCB] MATCH #1
[SCB] MATCH #2
...
[SCB] MATCH #6
```

Then:

👉 **Simulation HANGS**

No:

* MATCH #7
* MISMATCH
* “Test passed”
* Drop objection

---

## 6️⃣ Why the hang is CORRECT (mirror logic of Bug-1)

At iteration 7:

```systemverilog
exp_fifo.get(exp);   // 🚨 BLOCKS FOREVER
```

Because:

* ACT #7 exists
* EXP #7 never came

This is **precisely what Level-3 is supposed to do**.

---

## 7️⃣ Comparison table (Bug-1 vs Bug-2)

| Bug   | Dropped | Where     | Block point      |
| ----- | ------- | --------- | ---------------- |
| Bug-1 | ACT     | Monitor   | `act_fifo.get()` |
| Bug-2 | EXP     | Predictor | `exp_fifo.get()` |

✔ Symmetric
✔ Deterministic
✔ Reliable

---

## 8️⃣ Interview-grade takeaway (memorize this)

> **Level-3 FIFO-FIFO blocking scoreboards deliberately hang to detect missing or extra transactions.
> Completion without deadlock is NOT success — matching counts is.**

This sentence alone separates juniors from seniors.

---

## 9️⃣ Roadmap status (explicit)

| Item                 | Status         |
| -------------------- | -------------- |
| Bug-1 (missing ACT)  | ✅ DONE         |
| Bug-2 (missing EXP)  | ⏳ YOU ARE HERE |
| Bug-3 (extra ACT)    | ⏭ NEXT         |
| Bug-4 (extra EXP)    | ⏭ NEXT         |
| Convert hang → error | Day-44         |
| Phase alignment      | Day-45         |

---

### 👉 Your turn

Run Bug-2 and confirm:

* 6 matches
* Hang at the end

Then say exactly:
**“Bug-2 confirmed — proceed to Bug-3 (extra ACT)”**

We are building this **properly**, step by step.
