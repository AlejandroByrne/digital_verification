Perfect. Let’s do this **properly, cleanly, and in the right DV order**.
This is a **core industry concept**, so I’ll be precise and not rush.

---

# Day-44 (FOUNDATION)

## **Expected / Actual Queues — Proper Introduction**

> This is the **first time** we formally move from *toy scoreboard* → *real scoreboard*.

---

## 1️⃣ Why queues are mandatory (not optional)

### ❌ Old (toy) assumption

```text
Monitor sees txn → scoreboard checks immediately → pass
```

This assumes:

* Zero latency
* No reordering
* No drops
* No duplication

That **never holds** in real designs.

---

### ✅ Real hardware reality

* Expected data is produced by a **model**
* Actual data is observed by a **monitor**
* They:

  * Arrive at different times
  * May not be 1-to-1
  * May stop entirely (hangs)

➡️ Therefore we **buffer** both sides.

---

## 2️⃣ Conceptual architecture (commit this to memory)

```
        Reference Model / Predictor
                   |
                   v
             expected queue (exp_q)
                        \
                         ---> comparator ---> pass/fail
                        /
             actual queue (act_q)
                   ^
                   |
                Monitor
```

**Golden rule**

> A scoreboard NEVER assumes timing — only correctness.

---

## 3️⃣ What exactly goes into these queues?

### Transaction type

You already have something like:

```systemverilog
class my_txn extends uvm_sequence_item;
  rand bit [7:0] data;
endclass
```

Queues store **transactions**, not raw bits.

---

## 4️⃣ Declare queues (THIS is what was missing)

### Inside `my_scoreboard`

```systemverilog
class my_scoreboard extends uvm_component;
  `uvm_component_utils(my_scoreboard)

  // Expected transactions
  my_txn exp_q[$];

  // Actual transactions
  my_txn act_q[$];

  int expected_count;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
```

Now `exp_q` **exists** — no more compile error.

---

## 5️⃣ Who pushes into which queue?

### ✅ Actual queue — from MONITOR

Your monitor already does something like:

```systemverilog
ap.write(txn);
```

In scoreboard:

```systemverilog
function void write(my_txn t);
  act_q.push_back(t);
  `uvm_info("SCB", $sformatf("Actual enqueued: %0d", t.data), UVM_LOW)
endfunction
```

📌 This happens **whenever DUT produces output**.

---

### ✅ Expected queue — from MODEL / TEST

For now (Day-44), we keep it **simple and explicit**.

In scoreboard:

```systemverilog
function void push_expected(my_txn t);
  exp_q.push_back(t);
  `uvm_info("SCB", $sformatf("Expected enqueued: %0d", t.data), UVM_LOW)
endfunction
```

Later days:

* Predictor
* Reference model
* Coverage-driven expected gen

---

## 6️⃣ Comparison logic (decoupled!)

### ❌ Wrong approach (what beginners do)

```systemverilog
compare inside write()
```

This causes:

* False passes
* Order assumptions
* Missed bugs

---

### ✅ Correct approach — run_phase comparator

```systemverilog
task run_phase(uvm_phase phase);
  my_txn exp, act;

  forever begin
    wait (exp_q.size() > 0 && act_q.size() > 0);

    exp = exp_q.pop_front();
    act = act_q.pop_front();

    if (exp.data !== act.data) begin
      `uvm_error("SCB",
        $sformatf("Mismatch EXP=%0d ACT=%0d",
                  exp.data, act.data))
    end
    else begin
      `uvm_info("SCB",
        $sformatf("Match EXP=%0d ACT=%0d",
                  exp.data, act.data), UVM_LOW)
    end
  end
endtask
```

✔ Timing-independent
✔ Order-safe
✔ Regression-safe

---

## 7️⃣ Expected count ≠ immediate compare

Why you already had this:

```systemverilog
env.scb.set_expected_count(total_txns);
```

Because:

* Scoreboard must know **when it is DONE**
* Not when the first match happens

Later we’ll add:

* End-of-test detection
* Missing txn detection
* Hang detection

---

## 8️⃣ Key industry rules (INTERVIEW GOLD)

Memorize these:

1. **Scoreboards compare streams, not cycles**
2. **Never assume monitor and model timing**
3. **Queues exist to absorb reality**
4. **Immediate checking = false confidence**

---

## 9️⃣ Where this fits in the roadmap

| Day        | Focus                                 |
| ---------- | ------------------------------------- |
| Day-42     | Factory replacement                   |
| Day-43     | Factory × Config DB patterns          |
| **Day-44** | **Queue-based scoreboard foundation** |
| Day-45     | False pass / missing txn detection    |
| Day-46     | Regression hangs & timeouts           |

---

### Next step (important)

Now that queues exist, we can **intentionally break things**.

👉 Say **“Proceed Day-44 Step-2 (Failure Modes)”**
and we’ll:

* Create false pass
* Create missing expected
* Detect regression hangs

You’re exactly where a **real DV engineer** should be at this stage.
