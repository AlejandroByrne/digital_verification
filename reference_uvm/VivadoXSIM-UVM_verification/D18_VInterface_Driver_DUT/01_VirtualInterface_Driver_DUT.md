Perfect.
We continue **exactly on the same roadmap**, **no cleanup**, **no theory removal**, only **required theory → then hands-on**.

---

# 🟦 Day-18 — Virtual Interface & Driver → DUT

*(One of the MOST IMPORTANT UVM days)*

You now move from **abstract transactions** to **real signal driving**.

---

## 🎯 Day-18 Goal

By end of today, you must clearly understand:

✔ Why **virtual interface** exists
✔ How driver accesses DUT signals
✔ How `uvm_config_db` connects TB ↔ DUT
✔ One clean end-to-end transaction → signal drive

---

## 1️⃣ REQUIRED THEORY (DO NOT SKIP)

### ❓ Why Virtual Interface?

* DUT interface is **static (module world)**
* UVM classes are **dynamic (object world)**
* Direct access is **not allowed**

➡️ **Virtual interface is the bridge**

```
UVM Driver (class)
        ↓
virtual interface
        ↓
DUT interface (signals)
```

---

### ❓ Why not pass interface directly?

Because:

* Classes cannot contain **static nets**
* Interface instances live in **module scope**

So we pass a **handle** → `virtual interface`

---

## 2️⃣ Architecture for Day-18

```
top (module)
 ├── DUT
 ├── interface
 └── uvm_config_db::set()

UVM:
 test
  └── env
       └── driver  → virtual interface
```

---

## 3️⃣ Hands-On (Step-by-Step)

We’ll build the **smallest possible DUT**.

---

## 📁 Files Added (Day-18)

```
Day18_Virtual_Interface/
├── dut.sv
├── my_if.sv
├── top.sv
├── my_driver.sv   (MODIFIED)
├── my_env.sv      (MODIFIED)
├── my_test.sv     (MODIFIED)
```

---

## 4️⃣ DUT (Very Simple)

### `dut.sv`

```systemverilog
module dut (
    input  logic clk,
    input  logic rst,
    input  logic valid,
    input  logic [7:0] data
);
    always_ff @(posedge clk) begin
        if (rst)
            $display("DUT: Reset");
        else if (valid)
            $display("DUT: Data received = %0d", data);
    end
endmodule
```

---

## 5️⃣ Interface (KEY FILE)

### `my_if.sv`

```systemverilog
interface my_if (input logic clk);
    logic rst;
    logic valid;
    logic [7:0] data;
endinterface
```

📌 Interface groups signals
📌 Driver talks ONLY through this

---

## 6️⃣ Modify Driver (CORE CHANGE)

### `my_driver.sv`

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
            `uvm_fatal("NOVIF", "Virtual interface not found")
    endfunction

    task run_phase(uvm_phase phase);
        my_txn t;
        forever begin
            seq_item_port.get_next_item(t);

            // Drive DUT
            vif.valid <= 1;
            vif.data  <= t.data;
            @(posedge vif.clk);
            vif.valid <= 0;

            seq_item_port.item_done();
        end
    endtask
endclass
```

---

## 7️⃣ Top Module (MOST IMPORTANT)

### `top.sv`

```systemverilog
module top;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    logic clk = 0;
    always #5 clk = ~clk;

    my_if if0(clk);

    dut d0 (
        .clk(clk),
        .rst(if0.rst),
        .valid(if0.valid),
        .data(if0.data)
    );

    initial begin
        if0.rst   = 1;
        if0.valid = 0;
        #20 if0.rst = 0;
    end

    initial begin
        uvm_config_db#(virtual my_if)::set(null, "*", "vif", if0);
        run_test("my_test");
    end
endmodule
```

📌 This line is **CRITICAL**:

```systemverilog
uvm_config_db#(virtual my_if)::set(null, "*", "vif", if0);
```

This is how UVM **injects hardware into classes**.

---

## 8️⃣ Compile & Run (XSIM)

```bash
xvlog -sv -L uvm -f filelist.f
xelab top -L uvm -debug typical
xsim top -runall
```

---

## 9️⃣ Expected Output (MUST SEE)

```
UVM_INFO ... Driver driving data = XX
DUT: Data received = XX
```

✔ Transaction → Driver
✔ Driver → Interface
✔ Interface → DUT

---

## ✅ Day-18 Completion Criteria

You must confirm ALL:

✔ You understand **why virtual interface exists**
✔ `uvm_config_db` get/set makes sense
✔ Driver drives DUT signals
✔ DUT prints received data

---

## 🔥 This Day Is HUGE

Most people **memorize** virtual interfaces.

You **implemented and debugged** it — that’s the difference.

---

## 🔜 Next (Preview)

### **Day-19 — Monitor + Analysis Port**

(Observing DUT → scoreboard path begins)

---

### Now reply with ONE of these:

* **“Day-18 ran successfully”** ✅
* Paste the **first error** you hit

We continue **only after Day-18 is solid**.
