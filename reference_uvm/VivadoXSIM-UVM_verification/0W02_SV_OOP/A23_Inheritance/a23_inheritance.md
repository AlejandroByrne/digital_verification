Excellent ✅
**A2.2 — Constructor behavior is CLEAR and CONFIRMED.**

We proceed **exactly per roadmap**, no skips, no UVM leakage.

---

# 🔵 Phase A2.3 — Inheritance (FOUNDATION for UVM)

Inheritance is **non-negotiable**.
If this is weak → UVM agents won’t make sense later.

---

## 🧠 What inheritance gives you

* Code reuse
* Specialization without duplication
* Base class handles **common behavior**
* Child class adds **extra behavior**

UVM is **90% inheritance**.

---

## 1️⃣ Base class

```systemverilog
class packet;
    rand bit [7:0] data;
    rand bit       valid;

    function void display();
        $display("[BASE] data=%0h valid=%0b", data, valid);
    endfunction
endclass
```

---

## 2️⃣ Child class (`extends`)

```systemverilog
class error_packet extends packet;
    rand bit parity;

    function void display();
        $display("[CHILD] data=%0h valid=%0b parity=%0b",
                 data, valid, parity);
    endfunction
endclass
```

✔️ Child **inherits**:

* `data`
* `valid`
* `randomize()`

---

## 🧪 Hands-on (XSIM)

📁 **File: `a2_3_inheritance.sv`**

```systemverilog
class packet;
    rand bit [7:0] data;
    rand bit       valid;

    function void display();
        $display("[BASE] data=%0h valid=%0b", data, valid);
    endfunction
endclass


class error_packet extends packet;
    rand bit parity;

    function void display();
        $display("[CHILD] data=%0h valid=%0b parity=%0b",
                 data, valid, parity);
    endfunction
endclass


module tb;
    packet       p;
    error_packet ep;

    initial begin
        p  = new();
        ep = new();

        assert(p.randomize());
        assert(ep.randomize());

        p.display();
        ep.display();

        #10 $finish;
    end
endmodule
```

---

## ▶️ Run

```tcl
xvlog -sv a2_3_inheritance.sv
xelab tb
xsim tb -R --sv_seed random
```

---

## 🔍 Expected Output

```
[BASE]  data=3a valid=1
[CHILD] data=9f valid=0 parity=1
```

---

## ❗ Key Rules (Memorize)

| Rule                         | Truth |
| ---------------------------- | ----- |
| Child can access parent vars | ✔️    |
| Parent can access child vars | ❌     |
| Child inherits randomize()   | ✔️    |
| Child can override methods   | ✔️    |

---

## 🎯 UVM Mapping (IMPORTANT)

| SV Concept     | UVM                  |
| -------------- | -------------------- |
| `packet`       | `uvm_sequence_item`  |
| `error_packet` | Extended transaction |
| `display()`    | `do_print()`         |

---

## ✅ Exit Criteria

Reply only with:

> **“A2.3 inheritance clear”**

Then we go to **A2.4 — Polymorphism & virtual methods** (MOST IMPORTANT OOP topic).
