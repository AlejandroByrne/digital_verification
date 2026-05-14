Good.
Now we do **Day-43 cleanly and correctly**, building **directly on your Day-42 code** — no new env, no churn.

---

# ✅ **Day-43 — Factory × Config DB (Real-World Patterns)**

### **WHY factories alone are not enough**

> **Factory = WHAT object exists**
> **Config DB = HOW that object behaves**

If you remember only one sentence from Day-43, remember this 👆

---

## 1️⃣ The Core Mental Model (Interview-Critical)

| Mechanism     | Controls             | Should NOT control  |
| ------------- | -------------------- | ------------------- |
| **Factory**   | Class replacement    | Runtime behavior    |
| **Config DB** | Knobs, modes, delays | Structural topology |

### Correct usage

* Factory → swap **driver class**
* Config DB → control **fault mode, timing, limits**

### Wrong usage (very common bug)

* Using factory to create 10 driver variants
* Using config DB to “select” topology

---

## 2️⃣ What You Already Did (Day-42 recap — validated ✅)

You already proved:

* Type override works
* `my_faulty_driver` replaces `my_driver`
* Override happens **before build**
* Child test inherits parent phases correctly

So **mechanics are DONE**.

Now we go **production-style**.

---

## 3️⃣ Real-World Pattern #1 — Single Driver, Multiple Behaviors

Instead of this ❌:

```text
my_driver
my_faulty_driver
my_slow_driver
my_glitchy_driver
```

Do this ✅:

```text
my_driver
  + behavior controlled by config DB
```

---

## 4️⃣ HANDS-ON (Minimal, Surgical Change)

### 🔹 Step A — Add behavior knob to driver

In **my_driver.sv**

```systemverilog
class my_driver extends uvm_driver#(my_txn);
  `uvm_component_utils(my_driver)

  bit fault_enable;

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (!uvm_config_db#(bit)::get(
          this, "", "fault_enable", fault_enable))
      fault_enable = 0;
  endfunction

  task run_phase(uvm_phase phase);
    forever begin
      seq_item_port.get_next_item(req);

      if (fault_enable) begin
        `uvm_info("DRV", "Fault mode active", UVM_LOW)
        // inject timing / protocol issue
        vif.valid <= 1'b0;
      end else begin
        // normal drive
        vif.valid <= 1'b1;
      end

      seq_item_port.item_done();
    end
  endtask
endclass
```

📌 **Notice**
Same class, **different behavior**.

---

### 🔹 Step B — Control behavior from TEST (not env!)

In **my_test_factory.build_phase**

```systemverilog
uvm_config_db#(bit)::set(
  null, "uvm_test_top.env.drv", "fault_enable", 1);
```

💡 This is **why test owns policy**.

---

## 5️⃣ When to Use Factory AND Config Together

### Example matrix (interview gold)

| Scenario           | Factory | Config DB |
| ------------------ | ------- | --------- |
| RTL vs Gate        | ✅       | ❌         |
| Normal vs Faulty   | ❌       | ✅         |
| PCIe vs AXI agent  | ✅       | ❌         |
| Timing stress      | ❌       | ✅         |
| Silicon workaround | ✅       | ✅         |

---

## 6️⃣ Debugging Pattern You’ll See in Real Projects

### Symptom

> “Why is my driver not faulty?”

### Root causes

1. Override done **after env creation**
2. Wrong config path
3. Instance override vs type override mismatch
4. Multiple drivers — setting config on wrong one

### Debug trick

```systemverilog
uvm_factory::get().print();
uvm_top.print_topology();
```

If you don’t see this in logs — you’re blind.

---

## 7️⃣ What Day-43 Completes (Checklist)

✔ Factory vs config separation
✔ Structural vs behavioral control
✔ Single driver, multi-mode design
✔ Test-level policy ownership
✔ Production-grade pattern

---

## ⛔ What We Did NOT Do (by design)

* ❌ No new env
* ❌ No new agent
* ❌ No extra inheritance trees
* ❌ No academic examples

---

## 🔜 What Comes Next

### 👉 **Day-44 — Debugging, Failure Modes & Regression Mindset**

Where we:

* Break scoreboards on purpose
* Create false coverage passes
* Misuse phases
* Simulate **real regression failures**

Say **“Proceed Day-44”** when ready.
