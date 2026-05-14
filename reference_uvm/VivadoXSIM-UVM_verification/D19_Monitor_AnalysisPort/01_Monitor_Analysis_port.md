Excellent.
We continue **cleanly, incrementally, and correctly** — same environment, no rewrites.

---

# 🟦 Day-19 — Monitor & Analysis Port

*(Observation path: DUT → TB)*

This is the **mirror image of Day-18**.

If Day-18 was **“how to drive hardware”**,
Day-19 is **“how to observe hardware correctly”**.

---

## 🎯 Day-19 Goal

By end of today, you must:

✔ Understand **passive vs active components**
✔ Sample DUT signals using **virtual interface**
✔ Convert pin-level activity → **transaction**
✔ Send transactions via **`uvm_analysis_port`**

---

## 1️⃣ REQUIRED THEORY (ESSENTIAL, NOT OPTIONAL)

### ❓ Why a Monitor?

* Driver **knows what it sends**
* But DUT may:

  * Modify data
  * Drop cycles
  * Delay signals

👉 **Only monitor sees the truth**

Monitor is:

* **Passive**
* **Non-intrusive**
* **Never drives signals**

---

### ❓ Why `uvm_analysis_port`?

* Monitor can have **multiple listeners**

  * Scoreboard
  * Coverage
  * Logger
* Analysis port is **broadcast**

```
Monitor → analysis_port → subscribers
```

No blocking, no handshake.

---

## 2️⃣ Day-19 Architecture

```
           ┌──────────┐
           │   DUT    │
           └────┬─────┘
                │
         (virtual interface)
                │
          ┌─────▼─────┐
          │  Monitor  │
          └─────┬─────┘
        uvm_analysis_port
                │
           (future scoreboard)
```

---

## 3️⃣ Files to ADD / MODIFY

```
Day19_Monitor_Analysis/
├── my_monitor.sv      (NEW)
├── my_env.sv          (MODIFIED)
```

---

## 4️⃣ Monitor Implementation (CORE FILE)

### `my_monitor.sv`

```systemverilog
class my_monitor extends uvm_component;
    `uvm_component_utils(my_monitor)

    virtual my_if vif;
    uvm_analysis_port #(my_txn) ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        ap = new("ap", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual my_if)::get(this, "", "vif", vif))
            `uvm_fatal("NOVIF", "Virtual interface not found in monitor")
    endfunction

    task run_phase(uvm_phase phase);
        my_txn t;
        forever begin
            @(posedge vif.clk);
            if (vif.valid) begin
                t = my_txn::type_id::create("t", this);
                t.data = vif.data;
                ap.write(t);

                `uvm_info("MON", $sformatf("Observed data = %0d", t.data), UVM_MEDIUM)
            end
        end
    endtask
endclass
```

---

## 5️⃣ Modify Environment

### `my_env.sv`

```systemverilog
class my_env extends uvm_env;
    `uvm_component_utils(my_env)

    my_driver    drv;
    my_sequencer seqr;
    my_monitor   mon;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        drv  = my_driver   ::type_id::create("drv", this);
        seqr = my_sequencer::type_id::create("seqr", this);
        mon  = my_monitor  ::type_id::create("mon", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        drv.seq_item_port.connect(seqr.seq_item_export);
    endfunction
endclass
```

📌 Monitor does **NOT** connect to driver
📌 It only **observes**

---

## 6️⃣ Compile & Run (Same Flow)

```bash
xvlog -sv -L uvm -f filelist.f
xelab top -L uvm -debug typical
xsim top -runall
```

---

## 7️⃣ Expected Output (VERY IMPORTANT)

You should see **both**:

```
DUT: Data Received = 110
UVM_INFO ... [MON] Observed data = 110
```

✔ Driver drove DUT
✔ Monitor independently observed DUT

If these values differ → DUT bug (later!)

---

## 8️⃣ Completion Criteria (STRICT)

Day-19 is complete **only if**:

✔ Monitor does NOT drive signals
✔ Uses virtual interface
✔ Uses `uvm_analysis_port`
✔ Observed data matches DUT prints

---

## 🔑 Why This Day Is Critical

This is the foundation for:

* Scoreboard (Day-20)
* Coverage
* Assertions
* End-to-end checking

Without a good monitor, **verification is fake**.

---

## 🔜 Next Preview

### **Day-20 — Scoreboard (Transaction Comparison)**

This is where **bugs are caught**.

---

### Now respond with:

* **“Day-19 ran successfully”** ✅
* Or paste the **first error/output mismatch**

You are now operating at **junior-to-mid DV engineer level**.
