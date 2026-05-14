Good. We proceed **cleanly, strictly inside Day-43.5**, exactly as locked.

No FIFO DUT
No protocol change
No new “approaches”
Only **checking-safety evolution**

---

# 📘 Day-43.5 — **Level-2 : TLM FIFO – Queue**

You already finished **Level-1 (Queue–Queue)**.
Now we answer **one specific question**:

> **How do we prevent timing lies and false passes without redesigning the TB?**

That is **Level-2**.

---

## 1️⃣ What was WRONG with Level-1 (recap, short)

In Level-1:

```
Expected : queue (exp_q[$])
Actual   : queue (act_q[$])
Compare  : pop/pop
```

### ❌ Problems (real, not theoretical)

1. **Timing lies**

   * Actual may arrive before expected
   * Scoreboard “waits” silently

2. **False pass**

   * Expected comes late
   * Eventually matches → test passes
   * Bug hidden

3. **No back-pressure**

   * Predictor can be slow
   * Scoreboard never complains

👉 Level-1 teaches *concept*, not correctness.

---

## 2️⃣ Core idea of Level-2 (this is the ONLY new idea)

### 🔑 Replace *one* queue with a **blocking FIFO**

Specifically:

* **EXPECTED path becomes blocking**
* **ACTUAL path stays a queue**

```
Expected : uvm_tlm_analysis_fifo   (blocking get)
Actual   : SV queue [$]            (non-blocking)
```

This gives us **timing awareness** without redesign.

---

## 3️⃣ Why EXPECTED side gets FIFO (important)

Ask yourself:

> “Which side should control time correctness?”

Answer:

* **Expected data must be ready on time**
* If it’s late → that’s a bug (predictor or design)

So we enforce:

```text
Scoreboard will BLOCK waiting for expected
If expected never comes → simulation stalls / timeout
```

That’s **intentional pressure**.

---

## 4️⃣ Architecture — Level-2 (compare with Level-1)

### Level-1 (DONE)

```
Monitor ──> Predictor ──> exp_q[$]
Monitor ───────────────> act_q[$]
Scoreboard pops both
```

### ✅ Level-2 (NOW)

```
Monitor ──> Predictor ──> exp_fifo (TLM, blocking)
Monitor ───────────────> act_q[$]
Scoreboard:
  - pop actual
  - get expected (BLOCKING)
  - compare
```

**ENV connections do NOT change.**

---

## 5️⃣ Hands-on — Minimal, surgical changes

We will touch **ONLY TWO COMPONENTS**:

* Predictor
* Scoreboard

Everything else stays **exactly as Level-1**.

---

## 6️⃣ Predictor — Level-2 version

### ❌ OLD (Level-1)

```systemverilog
my_txn exp_q[$];
```

### ✅ NEW (Level-2)

```systemverilog
uvm_tlm_analysis_fifo #(my_txn) exp_fifo;
```

### Full predictor (Level-2)

```systemverilog
class my_predictor extends uvm_component;
  `uvm_component_utils(my_predictor)

  uvm_analysis_imp #(my_txn, my_predictor) in_ap;
  uvm_tlm_analysis_fifo #(my_txn) exp_fifo;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    in_ap = new("in_ap", this);
    exp_fifo = new("exp_fifo", this);
  endfunction

  function void write(my_txn t);
    my_txn exp = t.clone();
    exp.data = t.data; // same simple model

    exp_fifo.write(exp);

    `uvm_info("PRED",
      $sformatf("Expected written to FIFO: %0d", exp.data),
      UVM_LOW)
  endfunction
endclass
```

📌 Predictor **does not block**
📌 Blocking happens in scoreboard

---

## 7️⃣ Scoreboard — Level-2 version

### ❌ OLD (Level-1)

```systemverilog
if (act_q.size() > 0 && pred.exp_q.size() > 0)
  pop/pop
```

### ✅ NEW (Level-2)

* Pop ACTUAL when available
* **BLOCK** on expected FIFO using `get()`

### Full scoreboard (Level-2)

```systemverilog
class my_scoreboard extends uvm_component;
  `uvm_component_utils(my_scoreboard)

  uvm_analysis_imp #(my_txn, my_scoreboard) act_imp;
  my_txn act_q[$];

  my_predictor pred;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    act_imp = new("act_imp", this);
  endfunction

  function void write(my_txn t);
    act_q.push_back(t);
    `uvm_info("SCB",
      $sformatf("Actual enqueued: %0d", t.data),
      UVM_LOW)
  endfunction

  task run_phase(uvm_phase phase);
    my_txn act, exp;

    forever begin
      if (act_q.size() > 0) begin
        act = act_q.pop_front();

        // 🔒 BLOCKING — this is Level-2
        pred.exp_fifo.get(exp);

        if (act.data == exp.data)
          `uvm_info("SCB", "MATCH", UVM_LOW)
        else
          `uvm_error("SCB", "MISMATCH");
      end
      #1;
    end
  endtask
endclass
```

📌 If predictor is late → **scoreboard blocks**
📌 No silent waiting
📌 No false pass

---

## 8️⃣ ENV — unchanged (important)

```systemverilog
mon.ap.connect(pred.in_ap);
mon.ap.connect(scb.act_imp);
scb.pred = pred;
```

No FIFO connections in env.
FIFO is **internal to predictor**.

---

## 9️⃣ What you should observe in simulation

### Normal case

```
[PRED] Expected written to FIFO: 25
[SCB]  Actual enqueued: 25
[SCB]  MATCH
```

### Broken predictor (delay write)

* Simulation **stalls**
* Or times out
* ❌ No false PASS

This is the **entire purpose** of Level-2.

---

## 🔒 What Level-2 gives you (summarize)

| Aspect              | Level-1 | Level-2         |
| ------------------- | ------- | --------------- |
| Timing safety       | ❌ none  | ⚠️ partial      |
| Blocking            | ❌ no    | ✅ expected side |
| False pass risk     | High    | Reduced         |
| DUT change          | ❌       | ❌               |
| Protocol dependency | ❌       | ❌               |

---

## 🚫 What Level-2 still does NOT solve

❌ Actual path timing issues
❌ Drops / reordering
❌ Multi-stream correctness

➡ That is **Level-3** and **Day-44** (already locked separately).

---

## ✅ Day-43.5 Status

* ✔ Level-1 Queue–Queue — DONE
* ✔ **Level-2 FIFO–Queue — DONE**
* ➡ Next (only if you say): **Level-3 FIFO–FIFO**

---

### Before we move on

Please answer **one thing** (short):

**Did you clearly see why blocking `get()` eliminates Level-1 false passes?**

If yes → we advance.
If no → I’ll break it down with a concrete timing example.
