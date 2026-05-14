Perfect. Day-24 is an **IMPORTANT FOUNDATION DAY**.
I’ll cover **theory + hands-on**, tightly aligned to **your existing DUT & UVM env** (no DUT changes, no confusion).

---

# 📘 Day-24: **UVM Phase Control & Objections**

---

## 🎯 Day-24 Goals

By end of today, you will:

* Understand **ALL UVM phases** (what runs when & why)
* Know **where to put what code**
* Correctly use **objections**
* Debug **“simulation ended too early”** issues
* Control simulation **start / end deterministically**

This day is **mandatory before**:

* Virtual sequences
* Multi-agent
* Complex test control

---

## 1️⃣ UVM PHASES – BIG PICTURE (THEORY)

UVM has **3 categories of phases**:

### 🔹 A. Build-Time Phases (ELABORATION)

Run **once**, top-down.

| Phase                       | Purpose           |
| --------------------------- | ----------------- |
| `build_phase`               | Create components |
| `connect_phase`             | Connect TLM ports |
| `end_of_elaboration_phase`  | Final checks      |
| `start_of_simulation_phase` | Print topology    |

⚠️ **NO time-consuming code here**

---

### 🔹 B. Run-Time Phases (TIME CONSUMING)

These consume simulation time.

| Phase             | Used for           |
| ----------------- | ------------------ |
| `reset_phase`     | Reset driving      |
| `configure_phase` | Config programming |
| `main_phase`      | Normal traffic     |
| `shutdown_phase`  | Graceful stop      |
| `run_phase`       | Legacy / combined  |

👉 `run_phase` is a **super-phase** (used commonly)

---

### 🔹 C. Cleanup Phases

| Phase           | Purpose        |
| --------------- | -------------- |
| `extract_phase` | Gather results |
| `check_phase`   | Final checking |
| `report_phase`  | Print results  |
| `final_phase`   | Last cleanup   |

---

## 2️⃣ WHY OBJECTIONS EXIST (VERY IMPORTANT)

### ❌ Without objections:

Simulation ends **as soon as all run_phase threads finish**

### ✅ With objections:

Simulation continues **until objections are dropped**

👉 **Objection = “I’m still busy, don’t end sim”**

---

## 3️⃣ WHERE OBJECTIONS ARE USED

✔ ONLY in **time-consuming phases**

* `run_phase`
* `main_phase`
* `reset_phase`

❌ NEVER in build/connect phases

---

## 4️⃣ OBJECTION MECHANISM (THEORY)

```systemverilog
phase.raise_objection(this);
// do time-consuming work
phase.drop_objection(this);
```

Simulation ends **only when objection count = 0**

---

## 5️⃣ HANDS-ON #1 – ADD OBJECTION IN TEST

### 📌 my_test.sv (MODIFY)

```systemverilog
class my_test extends uvm_test;
    `uvm_component_utils(my_test)

    my_env env;

    function new(string name="my_test", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        env = my_env::type_id::create("env", this);
    endfunction

    task run_phase(uvm_phase phase);
        phase.raise_objection(this);

        `uvm_info("TEST", "Starting stimulus", UVM_MEDIUM)

        #100ns;

        `uvm_info("TEST", "Ending stimulus", UVM_MEDIUM)

        phase.drop_objection(this);
    endtask
endclass
```

---

## 6️⃣ HANDS-ON #2 – OBJECTION IN SEQUENCE (BEST PRACTICE)

### ❌ BAD PRACTICE

* Raising objection in driver/monitor

### ✅ BEST PRACTICE

* Raise objection in **test**
* OR in **top-level sequence**

---

### 📌 my_sequence.sv (MODIFY)

```systemverilog
task body();
    if (starting_phase != null)
        starting_phase.raise_objection(this);

    repeat (5) begin
        my_txn tx;
        tx = my_txn::type_id::create("tx");
        start_item(tx);
        assert(tx.randomize());
        finish_item(tx);
    end

    if (starting_phase != null)
        starting_phase.drop_objection(this);
endtask
```

✔ This makes sequence **phase-aware**

---

## 7️⃣ WHAT IS `starting_phase`? (THEORY)

* Automatically set when sequence is started via test
* Allows sequence to control sim end
* **Critical for virtual sequences**

---

## 8️⃣ COMMON BUGS (YOU MUST KNOW)

### ❌ Bug 1: Simulation ends at time 0

→ No objection raised

### ❌ Bug 2: Simulation never ends

→ Objection raised but **never dropped**

### ❌ Bug 3: Multiple sequences fighting

→ Objections raised in wrong places

---

## 9️⃣ HANDS-ON #3 – OBSERVE SIMULATION END

Run simulation and observe:

✔ `$finish` happens **only after objection drop**
✔ `TEST_DONE` log appears correctly
✔ Scoreboard still works
✔ No DUT change required

---

## 🔍 CHECKPOINT (VERY IMPORTANT)

Confirm these answers mentally:

1. Which phases consume time?
2. Why objections are not allowed in build_phase?
3. Who should raise objections — driver or test?
4. Why `starting_phase` matters?

If yes → **Day-24 is DONE**.

---

## 📌 WHAT COMES NEXT (LOCKED ORDER)

➡️ **Day-25: Advanced Sequences**

* fork/join
* parallel traffic
* layered stimulus

➡️ **Day-26: Virtual Sequences**

* multi-agent coordination

➡️ **Day-27: Assertion + Functional Coverage Correlation**

No topic will be skipped.

---

Say **“Day-24 done”** after running hands-on successfully.
