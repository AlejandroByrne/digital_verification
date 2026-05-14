Perfect 👍
We’ll **redo Phase A1**, but this time **100% hands-on**, **XSIM-friendly**, **no DUT**, **no clock**, **no confusion**.

Everything below can be compiled and run **directly in xsim**.

---

# 🔵 Phase A1 — Randomization (Hands-on with XSIM)

> Folder: `phase_A1_random/`
> File: `tb_random.sv`

---

## 🧪 STEP 0 — Minimal XSIM Setup

### Compile

```bash
xvlog -sv tb_random.sv
```

### Run

```bash
xsim work.tb_random -R
```

---

# 1️⃣ `foreach` — HANDS-ON

### 🔹 Goal

Iterate over randomized arrays **safely**

---

### ✅ Example 1: `foreach` on array

```systemverilog
module tb_random;

    class pkt;
        rand bit [7:0] data[4];
    endclass

    initial begin
        pkt p = new();
        p.randomize();

        $display("---- foreach demo ----");
        foreach (p.data[i]) begin
            $display("data[%0d] = %0d", i, p.data[i]);
        end

        $finish;
    end

endmodule
```

### 🔍 What you learn

* No loop bounds
* No size assumptions
* Used later in **coverage & scoreboards**

---

# 2️⃣ `inside` — HANDS-ON

### 🔹 Goal

Allow **only legal values**

---

### ✅ Example 2: `inside` with ranges

```systemverilog
module tb_random;

    class pkt;
        rand int addr;

        constraint addr_c {
            addr inside {[0:15], [32:63]};
        }
    endclass

    initial begin
        pkt p = new();

        repeat (10) begin
            p.randomize();
            $display("addr = %0d", p.addr);
        end

        $finish;
    end

endmodule
```

### 🔍 Observe

* You will **never** see `16–31`
* Illegal values are **never generated**

This is how protocol legality is enforced.

---

# 3️⃣ `dist` — HANDS-ON (CRITICAL)

### 🔹 Goal

Bias stimulus like real traffic

---

### ✅ Example 3: Weighted enable signal

```systemverilog
module tb_random;

    class pkt;
        rand bit en;

        constraint en_dist {
            en dist {1 := 80, 0 := 20};
        }
    endclass

    initial begin
        pkt p = new();
        int ones = 0, zeros = 0;

        repeat (100) begin
            p.randomize();
            if (p.en) ones++;
            else zeros++;
        end

        $display("en=1 count = %0d", ones);
        $display("en=0 count = %0d", zeros);

        $finish;
    end

endmodule
```

### 🔍 Expected

* `en=1` ≈ 75–85
* `en=0` ≈ 15–25

⚠️ `dist` is **probabilistic**, not exact.

---

# 4️⃣ `foreach + inside + dist` (REAL TB STYLE)

### 🔹 Goal

Per-field control (industry-grade)

---

### ✅ Example 4: Packet payload modeling

```systemverilog
module tb_random;

    class pkt;
        rand bit [3:0] payload[8];

        constraint payload_c {
            foreach (payload[i]) {
                payload[i] inside {[1:10]};
                payload[i] dist {
                    [1:5]  := 70,
                    [6:10] := 30
                };
            }
        }
    endclass

    initial begin
        pkt p = new();

        repeat (5) begin
            p.randomize();
            $display("Payload:");
            foreach (p.payload[i])
                $write("%0d ", p.payload[i]);
            $display("");
        end

        $finish;
    end

endmodule
```

### 🔍 What this proves

* Every byte is legal
* Small values dominate
* Large values appear rarely
* This is **exactly** how real buses are modeled

---

# 🧠 Mental Check (XSIM-based)

You now **physically saw**:

✔ `foreach` iterates without bounds
✔ `inside` blocks illegal values
✔ `dist` biases stimulus

No DUT.
No clock.
No mailbox.
No magic.

---

# ✅ Phase A1 — OFFICIALLY COMPLETE

| Topic       | Status |
| ----------- | ------ |
| foreach     | ✅      |
| inside      | ✅      |
| dist        | ✅      |
| XSIM tested | ✅      |

---

## ⏸️ As requested

* **Monitor & Scoreboard → PAUSED**
* **Roadmap respected**
* **No skipping ahead**

---

## ➡️ Next (Phase A2)

**OOP Foundations — CLEAN RESTART**

Topics:

* Classes & objects
* Constructors
* Inheritance
* Polymorphism
* Virtual methods
* Shallow vs deep copy

🚫 No mailbox
🚫 No driver
🚫 No interface

Say exactly:

**`Start Phase A2`**

We continue cleanly.
