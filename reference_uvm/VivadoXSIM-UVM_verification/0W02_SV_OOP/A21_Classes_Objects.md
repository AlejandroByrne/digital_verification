Perfect.
We move **slow, clean, and correct** now.

---

# 🔵 Phase A2.1 — Classes & Objects (SystemVerilog OOP BASICS)

**Focus:**
👉 What is a class
👉 How object creation works
👉 How this is different from a module
👉 Must compile & run in **XSIM**

---

## 🧠 Key Concepts (Read Once)

### Module vs Class

| Module                           | Class                    |
| -------------------------------- | ------------------------ |
| Hardware                         | Software construct       |
| Static                           | Dynamic                  |
| One instance unless instantiated | Many objects via `new()` |
| Synthesizable                    | **NOT synthesizable**    |

👉 Classes are **testbench only**.

---

## ✅ What We Will Build

A **simple packet transaction**:

* Randomizable fields
* Display method
* Object creation inside `initial`

---

## 📄 File: `A2_1_class_basics.sv`

```systemverilog
// A2_1_class_basics.sv
// Phase A2.1 – Classes & Objects

class packet;

    // Data members
    rand bit [7:0] data;
    rand bit       valid;

    // Method inside class
    function void display();
        $display("PACKET :: data = 0x%0h , valid = %0b", data, valid);
    endfunction

endclass


module tb_class_basics;

    packet pkt;   // class handle (NOT object yet)

    initial begin
        // Create object
        pkt = new();

        // Randomize object
        if (!pkt.randomize())
            $fatal("Randomization failed");

        // Call class method
        pkt.display();

        #10;
        $finish;
    end

endmodule
```

---

## 🛠 XSIM Commands (DO NOT SKIP)

From the folder containing the file:

```tcl
xvlog -sv A2_1_class_basics.sv
xelab tb_class_basics -s a2_1
xsim a2_1 -R
```

---

## 🖥 Expected Output (Example)

```
PACKET :: data = 0x3A , valid = 1
```

(Values will change every run)

---

## ⚠️ VERY IMPORTANT OBSERVATIONS

### 1️⃣ Handle vs Object

```systemverilog
packet pkt;   // handle only
pkt = new();  // object created here
```

If `new()` is missing → **null handle → simulation crash**

---

### 2️⃣ Why `rand`?

* Enables constrained-random testing
* Core concept for **verification**, not RTL

---

### 3️⃣ Why method inside class?

Encapsulation → **data + behavior together**

This is the foundation of:

* transactions
* drivers
* monitors
* UVM objects

---

## ✅ Checkpoint (YOU must confirm)

Reply **only after** you have:

1. Compiled without errors
2. Seen randomized output
3. Understood handle vs object

Reply with:

> **“A2.1 DONE”**

Then we move to **A2.2 – Constructors (`new`)**
No skipping.
