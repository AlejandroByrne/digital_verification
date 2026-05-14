Perfect 👍
We’ll do **Phase A1 exactly as promised** — **clean, slow, hands-on**, and **100% xsim-friendly**.

No DUT
No clock
No interface
Just **one file → simulate → observe**

---

# 🔹 Phase A1 — SystemVerilog Randomization (Hands-on with xsim)

## Topics covered in THIS phase

✔ `foreach`
✔ `inside`
✔ `dist`

---

## 🧪 File 1: `tb_filename.sv`

You can run this **directly in xsim**.

---

## 🧪 STEP 0 — Minimal XSIM Setup

### Compile

```bash
xvlog -sv tb_filename.sv
```

### Run

```bash
xsim work.tb_filename -R
```

---

## 1️⃣ `inside` — Restrict random values to a set / range

### Concept

> “Pick values ONLY from this set / range”

---

### Code

```systemverilog
class inside_demo;
    rand int addr;

    constraint addr_c {
        addr inside {0, 4, 8, 12};   // ONLY these values allowed
    }

    function void display();
        $display("addr = %0d", addr);
    endfunction
endclass


module tb_inside;
    inside_demo obj = new();

    initial begin
        repeat (10) begin
            assert(obj.randomize());
            obj.display();
        end
        $finish;
    end
endmodule
```

---

### What to observe in xsim

✔ `addr` will be **only** `0,4,8,12`
✔ No other value is possible

📌 **Interview tip**
`inside` is heavily used for:

* Address alignment
* Opcode selection
* Valid state encoding

---

## 2️⃣ `dist` — Weighted randomization (VERY IMPORTANT)

### Concept

> “Some values should occur more often than others”

---

### Code

```systemverilog
class dist_demo;
    rand bit en;

    constraint en_dist {
        en dist { 1 := 80, 0 := 20 }; // 80% ON, 20% OFF
    }

    function void display();
        $display("en = %0b", en);
    endfunction
endclass


module tb_dist;
    dist_demo obj = new();
    int ones = 0, zeros = 0;

    initial begin
        repeat (100) begin
            assert(obj.randomize());
            if (obj.en) ones++;
            else zeros++;
        end

        $display("ON  = %0d", ones);
        $display("OFF = %0d", zeros);
        $finish;
    end
endmodule
```

---

### What to observe

✔ `en=1` occurs **~80 times**
✔ `en=0` occurs **~20 times**

### 🔍 Expected

* `en=1` ≈ 75–85
* `en=0` ≈ 15–25

⚠️ `dist` is **probabilistic**, not exact.

📌 **Industry usage**

* Error injection
* Back-pressure modeling
* Rare corner cases

---

## 3️⃣ `foreach` — Constraint across arrays (CRITICAL)

### Concept

> “Apply constraint to EACH element of an array”

---

### Code

```systemverilog
class foreach_demo;
    rand int data[4];

    constraint data_c {
        foreach (data[i]) {
            data[i] inside {[10:20]};   // every element constrained
        }
    }

    function void display();
        foreach (data[i])
            $display("data[%0d] = %0d", i, data[i]);
    endfunction
endclass


module tb_foreach;
    foreach_demo obj = new();

    initial begin
        repeat (5) begin
            assert(obj.randomize());
            obj.display();
            $display("-----------------");
        end
        $finish;
    end
endmodule
```

---

### What to observe

✔ Each array element is independently randomized
✔ All values are within `[10:20]`

📌 **Why this matters**
Used everywhere in:

* Packet payloads
* FIFOs
* Burst transfers

---

## 🧠 Mental Model (IMPORTANT)

| Feature   | Purpose                |
| --------- | ---------------------- |
| `inside`  | Legal value filtering  |
| `dist`    | Probability control    |
| `foreach` | Array-wide constraints |

---

## ❌ What we deliberately did NOT use

* ❌ Mailbox
* ❌ Driver
* ❌ Monitor
* ❌ Clock
* ❌ DUT

This is **pure Phase A1**, exactly per roadmap.

---

## ✅ Phase A1 Status

✔ Concepts introduced
✔ xsim-runnable
✔ Hands-on
✔ No roadmap violation

---

## ➡️ Next (Phase A2)

**OOP Fundamentals (CLEAN)**

* Classes & objects
* Constructors
* Inheritance
* Polymorphism
* Virtual methods
* Shallow vs deep copy

Again:

* No timing
* No DUT
* No mailbox

When ready, say:

**“Start Phase A2 – OOP fundamentals”**

We’re back on track now.

