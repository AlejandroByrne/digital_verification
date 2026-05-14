Ah! Now this makes **perfect sense**, and the reason is subtle but **completely deterministic**. Let me explain carefully.

---

# What’s happening

Your `run_phase` now looks like this:

```systemverilog
task run_phase(uvm_phase phase);
    my_txn act, exp;
    `uvm_info("SCB", "Run phase: entered", UVM_LOW)

    phase.raise_objection(this);
    repeat (7) begin
        act_fifo.get(act);    // BLOCKING
        exp_fifo.get(exp);    // BLOCKING

        ...
    end
    phase.drop_objection(this);
endtask
```

**Observation:**

* `act_fifo.get(act)` is **blocking**
* `exp_fifo.get(exp)` is **blocking**

---

## Why Vivado FATAL ERROR occurs

1. **Time = 0 ps** — your sequence hasn’t yet written **anything** to either FIFO.

   * Both FIFOs are **empty at start**.
   * `.get()` is **blocking indefinitely**.

2. Vivado **cannot advance delta cycles** because there is no **non-blocking activity** scheduled.

   * UVM will try to schedule other processes, but **all are blocked** waiting on a zero-time FIFO.
   * This triggers the **“kernel discovered an exceptional condition”** crash.

✅ This is **not a UVM bug** — it’s **Vivado’s XSIM handling of deadlock at time 0**.

---

# Correct Step-2 approach in Vivado

### Rule:

> **Never block at time 0** on a FIFO that hasn’t received any transactions.

---

## 1️⃣ Safe version: **Wait for first transaction using `peek` + `wait`**

```systemverilog
task run_phase(uvm_phase phase);
    my_txn act, exp;
    `uvm_info("SCB", "Run phase: entered", UVM_LOW)

    phase.raise_objection(this);

    // Wait until at least one transaction arrives
    wait (act_fifo.num() > 0 && exp_fifo.num() > 0);

    repeat (7) begin
        act_fifo.get(act);
        exp_fifo.get(exp);

        `uvm_info("SCB",
            $sformatf("Received txn %0d (Actual), Predicted %0d", act.data, exp.data),
            UVM_LOW);
    end

    `uvm_info("SCB", "Scoreboard run_phase completed cleanly", UVM_LOW)
    phase.drop_objection(this);
endtask
```

✅ `wait` **advances simulation time** until predictor/monitor writes to FIFO.
✅ Avoids **blocking at 0 ps**.

---

## 2️⃣ Alternative approach: **Non-blocking FIFO consumption with `try_get`**

```systemverilog
task run_phase(uvm_phase phase);
    my_txn act, exp;
    int received = 0;
    phase.raise_objection(this);

    forever begin
        if (act_fifo.try_get(act)) begin
            `uvm_info("SCB", $sformatf("Act=%0d", act.data), UVM_LOW);
        end
        if (exp_fifo.try_get(exp)) begin
            `uvm_info("SCB", $sformatf("Exp=%0d", exp.data), UVM_LOW);
        end

        received++;
        if (received >= 7) break;
        @(posedge 1ns); // force time advance
    end

    phase.drop_objection(this);
endtask
```

* `try_get()` does **not block**, avoids kernel crash.
* `@(posedge 1ns)` **forces delta cycle advancement**.

---

# ✅ TL;DR — Why your current approach crashes

1. `act_fifo.get()` + `exp_fifo.get()` **blocking at time 0**
2. **No transaction written yet** → deadlock
3. XSIM cannot handle **all processes blocked at time 0** → FATAL_ERROR

---

# ✅ Correct solution

* Use `wait` on FIFO count OR `try_get` + `@(posedge …)`
* Only then call `get()`
* Keep **raise_objection / drop_objection** as is

---

If you want, I can **rewrite your Step-2 `run_phase` completely for Vivado XSIM**, **safe at time 0**, with both **actual + predictor FIFO**, and `expected_count = 7`.

Do you want me to do that?
