Perfect.
Day-42 is a **big architectural day**, so I’ll be very precise and clean (no noise, no repetition of earlier days).

---

# 🟣 **Day-42 — UVM Factory (Replacement & Scalability)**

### **HOW components & behavior are replaced (without editing code)**

This is **not about syntax**.
This is about **why UVM scales to million-line projects**.

---

## 1️⃣ Why Factory Exists (Industry Reality)

Without factory:

* You change code → recompile → break tests
* Every variant = new env/agent

With factory:

* Same env
* Same test
* Different behavior **selected at runtime**

📌 **Factory = late binding of implementation**

---

## 2️⃣ Factory Concepts (Mental Model)

| Concept               | Meaning                     |
| --------------------- | --------------------------- |
| `type_id::create()`   | Factory-controlled creation |
| Base class            | Contract                    |
| Derived class         | Behavior variant            |
| `set_type_override()` | Replace everywhere          |
| `set_inst_override()` | Replace only at one path    |

⚠️ If you use `new()` → **factory is bypassed** (illegal in scalable UVM)

---

## 3️⃣ What We Will Replace (Hands-On Scope)

We will **NOT** touch stimulus (already done via virtual sequences).

We will replace:

* **Driver behavior**
  (normal vs faulty vs coverage-friendly)

This mirrors **real silicon bring-up**.

---

## 4️⃣ Step-1: Base Driver (Already Exists)

```systemverilog
class my_driver extends uvm_driver #(my_txn);
  `uvm_component_utils(my_driver)

  virtual my_if vif;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual my_if)::get(this, "", "vif", vif))
      `uvm_fatal("DRV", "vif not set")
  endfunction

  task run_phase(uvm_phase phase);
    forever begin
      seq_item_port.get_next_item(req);
      drive(req);
      seq_item_port.item_done();
    end
  endtask

  virtual task drive(my_txn t);
    vif.valid <= 1;
    vif.data  <= t.data;
    wait (vif.ready);
    vif.valid <= 0;
  endtask
endclass
```

📌 **drive() is virtual** → this is intentional

---

## 5️⃣ Step-2: Create a Derived Driver (New File)

📁 `my_faulty_driver.sv`

```systemverilog
class my_faulty_driver extends my_driver;
  `uvm_component_utils(my_faulty_driver)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  // Override behavior only
  virtual task drive(my_txn t);
    `uvm_info("FAULTY_DRV", "Injecting protocol violation", UVM_MEDIUM)

    vif.valid <= 1;
    vif.data  <= t.data;

    // ❌ Violation: deassert valid too early
    #1;
    vif.valid <= 0;
  endtask
endclass
```

✔ Same interface
✔ Same env
✔ Same test
✔ Different behavior

---

## 6️⃣ Step-3: Replace Using Factory (Test Level)

📁 `my_test_factory.sv`

```systemverilog
class my_test_factory extends my_test;
  `uvm_component_utils(my_test_factory)

  function new(string name="my_test_factory", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    // 🔥 Global replacement
    uvm_factory::get().set_type_override_by_type(
      my_driver::get_type(),
      my_faulty_driver::get_type()
    );

    super.build_phase(phase);
  endfunction
endclass
```

📌 **NO env edits**
📌 **NO agent edits**

---

## 7️⃣ What Happens at Runtime

```
UVM_INFO FACTORY: Replacing my_driver with my_faulty_driver
UVM_INFO FAULTY_DRV: Injecting protocol violation
SCB: Protocol error detected
```

✔ Factory decides implementation
✔ Scoreboard catches bug
✔ Test proves robustness

---

## 8️⃣ Instance Override (Advanced, Very Important)

Replace **only one driver**, not all:

```systemverilog
uvm_factory::get().set_inst_override_by_type(
  my_driver::get_type(),
  my_faulty_driver::get_type(),
  "uvm_test_top.env.drv"
);
```

📌 Used in:

* Multi-agent systems
* One bad lane
* One stress corner

---

## 9️⃣ Common Real-World Mistakes (Memorize)

❌ Using `new()` instead of `type_id::create()`
❌ Putting overrides in env (wrong ownership)
❌ Overriding monitors (dangerous)
❌ Forgetting `virtual` methods

---

## 10️⃣ Day-42 Completion Criteria

You are **DONE** when:

* [ ] Factory override changes behavior
* [ ] Env code untouched
* [ ] Scoreboard reacts differently
* [ ] You understand *why* this scales

---

## 🔒 Roadmap Integrity Check

We are still aligned with your locked roadmap:

* Day-40 → WHO controls stimulus ✅
* Day-41 → HOW behavior is configured ✅
* **Day-42 → HOW implementation is replaced** ✅
* Day-43 → **Factory + Config DB together** (real projects)

---

## Next

When you’re ready:

👉 **Proceed Day-43 — Factory × Config DB (Real-World Patterns)**
