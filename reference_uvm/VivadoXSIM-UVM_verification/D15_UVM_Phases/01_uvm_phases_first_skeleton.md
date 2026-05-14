Good.
We proceed **Day-15** exactly as promised: **theory first (only what is required), then code**, then checks. No gaps, no blind jumps.

---

# 📅 **Day-15 — UVM Phases + First Minimal Skeleton**

🎯 **Goal of Day-15**
You must **understand the UVM execution model** and **write a minimal, correct UVM skeleton** that:

* Compiles
* Uses phases correctly
* Does NOT drive a DUT yet

This day builds the **spine** of every UVM testbench you will ever write.

---

## 1️⃣ Prerequisites (Confirm Before Continuing)

You already have these, but align mentally:

* SV class syntax
* `extends`, `super.new()`
* Function vs task
* Dynamic object creation
* Hierarchical parent–child idea

If these are clear → proceed.

---

## 2️⃣ Required Theory — UVM Phases (Core Concepts Only)

### 🔹 Why Phases Exist (Concept)

UVM must:

* Build a **component tree**
* Connect components
* Then run stimulus **in parallel**

Phases enforce **order + synchronization** across the entire TB.

---

### 🔹 Two Big Categories (Conceptual)

#### **Build-time phases** (structure)

* Executed **top-down**
* Used to *create & connect components*

#### **Run-time phases** (behavior)

* Executed **in parallel**
* Used to *run stimulus*

Today we use **only one run-time phase**.

---

### 🔹 Phases You MUST Know Today

| Phase             | Why it exists     | What is allowed      |
| ----------------- | ----------------- | -------------------- |
| `new()`           | Constructor       | Store args only      |
| `build_phase()`   | Create components | Factory creation     |
| `connect_phase()` | Connect ports     | No creation          |
| `run_phase()`     | Run stimulus      | Time-consuming tasks |

🚨 **Golden Rules**

* ❌ Never create components in `run_phase`
* ❌ Never drive DUT in `build_phase`
* ✔ Structure first, behavior later

If these rules feel logical → theory absorbed.

---

## 3️⃣ Required Theory — uvm_component Lifecycle

Every `uvm_component`:

1. Is constructed (`new`)
2. Added to hierarchy
3. Enters phased execution

So this is **wrong**:

```sv
env = new();   // breaks UVM control
```

This is **correct**:

```sv
env = my_env::type_id::create("env", this);
```

📌 Concept:

> UVM must **know** about every component to control phases.

---

## 4️⃣ Minimal UVM Skeleton (FIRST CODE)

We now write the **smallest correct UVM TB**.

### 🔹 Files (Conceptual)

* `my_test.sv`
* `my_env.sv`
* `top.sv`

No DUT yet.

---

### 🔹 `my_env.sv` — Environment (Structure Only)

```systemverilog
class my_env extends uvm_env;
  `uvm_component_utils(my_env)

  function new(string name="my_env", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // no components yet
  endfunction
endclass
```

**Concepts reinforced**

* `uvm_env` is structural
* `build_phase` prepares hierarchy

---

### 🔹 `my_test.sv` — Test (Top Controller)

```systemverilog
class my_test extends uvm_test;
  `uvm_component_utils(my_test)

  my_env env;

  function new(string name="my_test", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = my_env::type_id::create("env", this);
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info("TEST", "Day-15: UVM skeleton running", UVM_MEDIUM)
    #50;
    phase.drop_objection(this);
  endtask
endclass
```

**Concepts reinforced**

* Test creates env
* run_phase controls simulation life
* Objection = simulation control

---

### 🔹 `top.sv` — Entry Point

```systemverilog
module top;
  initial begin
    run_test("my_test");
  end
endmodule
```

**Concept**

* `run_test()` hands control to UVM
* No manual instantiation

---

## 5️⃣ What You Must UNDERSTAND (Not Memorize)

Be able to explain:

1️⃣ Why `env` is created in `build_phase`
2️⃣ Why `run_phase` is a task, not function
3️⃣ Why objections are needed
4️⃣ Why `run_test()` is used instead of `new my_test`

If you can explain these → Day-15 theory is solid.

---

## 6️⃣ What We Deliberately Did NOT Do Today

❌ No DUT
❌ No driver
❌ No sequences
❌ No config_db
❌ No TLM

This is intentional.
Today is about **control & structure**, not stimulus.

---

## 7️⃣ Day-15 Completion Checklist

✔ UVM phases make sense
✔ Skeleton compiles
✔ run_phase executes
✔ Objection concept understood
✔ No illegal phase usage

If all ✔ → **Day-15 COMPLETE**

---

## 🔜 Next: **Day-16 — Transactions & Sequence Items**

Before we can send stimulus, we must **define what data looks like**.

Day-16 will introduce:

* `uvm_sequence_item`
* Transactions
* Randomization
* Copy/print/compare concepts (theory first)

When ready, say:

> **“Proceed Day-16”**

You’re building this the **correct industry way**.
