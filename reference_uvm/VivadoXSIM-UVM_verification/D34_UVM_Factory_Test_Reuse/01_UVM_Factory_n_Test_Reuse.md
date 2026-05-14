Good. We stay **locked to the roadmap** and proceed cleanly.

---

# 📅 **Day-34: UVM Factory & Test Reuse (CRITICAL DAY)**

> **This day answers one question only:**
>
> 👉 *How do I change behavior **without touching env, test, or sequences already written?***

This is **the heart of reuse** in UVM and **mandatory for interviews**.

---

## 🧠 Where Day-34 fits (reconfirm order)

| Day        | Purpose                         | Status   |
| ---------- | ------------------------------- | -------- |
| Day-31     | WHAT runs                       | ✅        |
| Day-32     | WHEN it runs (policy)           | ✅        |
| Day-33     | HOW it’s configured (config_db) | ✅        |
| **Day-34** | **HOW it’s replaced (factory)** | ⬅️ TODAY |
| Day-35     | HOW/WHEN it’s sampled           | ⏳        |

You are **exactly on track**.

---

## 🧠 Core Concept (NO CODE YET)

### ❌ Old (non-UVM) thinking

> “If I want new behavior, I’ll edit the env or sequence”

❌ Not scalable
❌ Breaks regressions
❌ Impossible in large teams

---

### ✅ UVM Factory thinking

> “I keep the *interface the same* and replace the *implementation*”

✔ Zero env change
✔ Zero test change
✔ Regression-friendly

---

## 🏭 What is the UVM Factory?

The **factory** is a global registry that decides:

> *Which class actually gets created when code asks for a base type*

Example:

```systemverilog
base_seq::type_id::create("seq");
```

Factory may return:

* `base_seq`
* `stress_seq`
* `error_seq`
* `low_power_seq`

**Caller never changes.**

---

## 🔑 Two Types of Overrides (MUST KNOW)

### 1️⃣ **Type Override**

> Replace **everywhere**

```systemverilog
factory.set_type_override_by_type(
  base_seq::get_type(),
  stress_seq::get_type()
);
```

📌 Every `base_seq::create()` → `stress_seq`

---

### 2️⃣ **Instance Override**

> Replace **only at a specific hierarchy**

```systemverilog
factory.set_inst_override_by_type(
  base_seq::get_type(),
  stress_seq::get_type(),
  "uvm_test_top.env.vseqr.*"
);
```

📌 Only virtual sequencer traffic changes

---

## ⚠️ Critical Rule (INTERVIEW FAVORITE)

> **Overrides must be set BEFORE object creation**

Usually in:

* `test.build_phase()`

❌ Setting in `run_phase()` = useless

---

## 🧠 Factory vs Config DB (DO NOT CONFUSE)

| Config DB           | Factory                  |
| ------------------- | ------------------------ |
| Controls **values** | Controls **behavior**    |
| Data knobs          | Class replacement        |
| mode = STRESS       | stress_seq replaces base |
| Day-33              | Day-34                   |

📌 They **complement**, not compete.

---

# 🧪 Day-34 HANDS-ON (Step-by-Step)

We will **reuse your existing env**.

### 🎯 Goal

Replace **SANITY traffic** with **ERROR traffic**
👉 **Without touching layered_vseq**

---

## 1️⃣ Create a NEW sequence (do NOT edit old ones)

### `error_traffic_seq.sv`

```systemverilog
class error_traffic_seq extends sanity_traffic_seq;
  `uvm_object_utils(error_traffic_seq)

  function new(string name="error_traffic_seq");
    super.new(name);
  endfunction

  task body();
    `uvm_info("ERROR_SEQ", "Error traffic running", UVM_LOW)
    repeat (5) begin
      my_txn tx = my_txn::type_id::create("tx");
      start_item(tx);
      tx.data = 8'hFF; // illegal / corner case
      finish_item(tx);
    end
  endtask
endclass
```

📌 Same interface
📌 Different behavior

---

## 2️⃣ DO NOT touch `layered_vseq` ❗

Your existing logic stays:

```systemverilog
if (mode == SANITY)
  sanity_seq.start(p_sequencer.seqr);
```

We will **replace sanity_seq invisibly**.

---

## 3️⃣ Apply Factory Override in `my_test`

### `my_test.sv`

```systemverilog
class my_test extends uvm_test;
  `uvm_component_utils(my_test)

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Existing config_db (Day-33)
    uvm_config_db#(mode_e)::set(
      this, "env.vseqr", "mode", SANITY
    );

    // 🔥 Day-34 FACTORY OVERRIDE
    factory.set_type_override_by_type(
      sanity_traffic_seq::get_type(),
      error_traffic_seq::get_type()
    );

    `uvm_info("FACTORY", "SANITY replaced with ERROR traffic", UVM_LOW)
  endfunction
endclass
```

---

## 4️⃣ Expected Output (KEY VERIFICATION)

You should see:

```
[LAYERED_VSEQ] Policy: SANITY
[ERROR_SEQ] Error traffic running
[DUT] Data Received = 255
```

📌 Even though:

* Mode = SANITY
* Code calls `sanity_traffic_seq`

Factory **silently replaced it**.

---

## 🧠 This is the MONEY takeaway

> **Same test**
> **Same env**
> **Same sequences**
>
> 👉 Different behavior

This is **industrial-grade UVM**.

---

## ❌ What we are NOT doing today

| Topic               | Reason             |
| ------------------- | ------------------ |
| Instance overrides  | Optional extension |
| Factory debug print | Optional           |
| Scoreboard changes  | Day-35             |
| Analysis FIFOs      | Day-35             |

---

## ✅ Day-34 Completion Criteria

You are DONE when:

* SANITY mode runs
* ERROR traffic appears
* No env / vseq code changed

---

## 🔜 Next Day (locked)

📅 **Day-35: Scoreboard Architecture + Analysis FIFOs + Phase-Aligned Sampling**

> This is where your env becomes **interview-level professional**.

---

When ready, do the run and tell me:

* Output snippet
* Or any compile/runtime error

We will debug **only Day-34 scope**, nothing else.
