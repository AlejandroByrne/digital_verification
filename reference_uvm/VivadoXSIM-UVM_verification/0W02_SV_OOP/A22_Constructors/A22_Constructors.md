Perfect 👍
**A2.1 — Classes & Objects is CONFIRMED.**

We move **exactly as per roadmap**. No jumping. No mailbox yet.

---

# 🔵 Phase A2.2 — Constructors (`new()`)

### Why this is CRITICAL

Constructors control:

* Object initialization
* Default values
* Resource setup

Misunderstanding `new()` = broken UVM later.

---

## 🧠 Key Concepts (Understand first)

### 1️⃣ What is a constructor?

* A **function named `new`**
* Automatically called when object is created

```systemverilog
class packet;
    function new();
    endfunction
endclass
```

---

### 2️⃣ Constructor with arguments

```systemverilog
class packet;
    bit [7:0] data;
    bit valid;

    function new(bit [7:0] data_i, bit valid_i);
        data  = data_i;
        valid = valid_i;
    endfunction
endclass
```

---

### 3️⃣ Constructor runs ONLY ONCE

* Runs at object creation
* **Not** on every `randomize()`

---

## 🧪 Hands-on (XSIM Compatible)

📁 **File: `a2_2_constructor.sv`**

```systemverilog
class packet;
    rand bit [7:0] data;
    rand bit       valid;

    // Constructor
    function new(bit [7:0] d = 8'h00, bit v = 0);
        data  = d;
        valid = v;
        $display("[NEW] Constructor called: data=%0h valid=%0b", data, valid);
    endfunction

    function void display();
        $display("[PKT] data=%0h valid=%0b", data, valid);
    endfunction
endclass


module tb;
    packet p1, p2;

    initial begin
        // Object with default constructor args
        p1 = new();
        p1.display();

        // Object with custom constructor args
        p2 = new(8'hAA, 1);
        p2.display();

        // Randomize AFTER construction
        assert(p2.randomize());
        p2.display();

        #10 $finish;
    end
endmodule
```

---

## ▶️ Run Commands (DO NOT SKIP)

```tcl
xvlog -sv a2_2_constructor.sv
xelab tb
xsim tb -R --sv_seed random
```

---

## 🔍 Expected Output Pattern

```
[NEW] Constructor called: data=00 valid=0
[PKT] data=00 valid=0
[NEW] Constructor called: data=aa valid=1
[PKT] data=aa valid=1
[PKT] data=3f valid=0   // randomized
```

---

## ❗ Common Mistake (VERY IMPORTANT)

❌ Thinking constructor re-runs on `randomize()`
✔️ Constructor runs **only once**

---

## 🧠 Interview Question

❓ *Can constructor have random variables?*
✔️ Yes, but randomization happens **later**, not in `new()`.

---

## ✅ Exit Criteria (Mandatory)

Reply **only after running**:

> **“A2.2 constructor behavior clear”**

Then we proceed to **A2.3 — Inheritance** (next critical pillar).
