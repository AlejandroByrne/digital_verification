Good. We now move **exactly as per roadmap**.
No UVM, no monitor/scoreboard yet.
This is **Phase A2.6 – Mailbox**, and this topic is **non-negotiable** for DV.

I’ll do this in **3 strict layers**:

1. **Concept (what & why)**
2. **Hands-on minimal example (xsim runnable)**
3. **DV-style usage (Driver ↔ Monitor pattern)**

---

# 🔵 A2.6 – MAILBOX

---

## 1️⃣ CONCEPT (VERY IMPORTANT)

### What is a mailbox?

A **mailbox** is a **thread-safe communication channel** between **parallel processes**.

Think:

```
Generator  --->  Mailbox  --->  Driver
```

### Why do we need it?

In verification:

* Generator runs independently
* Driver runs independently
* They must **synchronize safely**

Mailbox gives:

* Automatic **blocking**
* No race conditions
* Clean separation of roles

---

### Mailbox primitives

| Method      | Meaning                        |
| ----------- | ------------------------------ |
| `new()`     | Create mailbox                 |
| `put(item)` | Send item (blocks if full)     |
| `get(item)` | Receive item (blocks if empty) |
| `try_get()` | Non-blocking receive           |
| `num()`     | Items currently inside         |

---

## 2️⃣ HANDS-ON: MINIMAL MAILBOX EXAMPLE (xsim)

### Goal

* One process **produces**
* One process **consumes**

---

### 📄 `a26_mailbox_basic.sv`

```systemverilog
class packet;
    rand byte data;

    function void display(string tag="");
        $display("[%s] packet.data = 0x%0h", tag, data);
    endfunction
endclass


module tb;
    mailbox #(packet) mbx;
    packet p;

    initial begin
        mbx = new();

        fork
            producer();
            consumer();
        join

        #10 $finish;
    end

    task producer();
        packet pkt;
        repeat (5) begin
            pkt = new();
            assert(pkt.randomize());
            pkt.display("PRODUCER");
            mbx.put(pkt);   // BLOCKS if mailbox full
            #10;
        end
    endtask

    task consumer();
        packet pkt;
        repeat (5) begin
            mbx.get(pkt);   // BLOCKS if mailbox empty
            pkt.display("CONSUMER");
        end
    endtask
endmodule
```

---

### ▶️ Run (XSIM)

```tcl
xvlog -sv a26_mailbox_basic.sv
xelab tb
xsim tb
```

---

### 🔍 Observe

* Producer and consumer **run independently**
* Consumer waits until producer sends
* **No timing hacks, no race**

---

## 3️⃣ DV-STYLE USAGE (REAL TESTBENCH PATTERN)

Now the **real reason** mailbox exists.

---

### Roles

| Component | Responsibility       |
| --------- | -------------------- |
| Generator | Creates transactions |
| Driver    | Drives DUT           |
| Mailbox   | Transaction pipe     |

---

### 📄 `a26_mailbox_dv_style.sv`

```systemverilog
class dff_txn;
    rand bit en;
    rand bit d;

    function void display(string who="");
        $display("[%s] en=%0b d=%0b", who, en, d);
    endfunction
endclass


class generator;
    mailbox #(dff_txn) mbx;

    function new(mailbox #(dff_txn) mbx);
        this.mbx = mbx;
    endfunction

    task run();
        dff_txn t;
        repeat (5) begin
            t = new();
            assert(t.randomize());
            t.display("GEN");
            mbx.put(t);
            #5;
        end
    endtask
endclass


class driver;
    mailbox #(dff_txn) mbx;

    function new(mailbox #(dff_txn) mbx);
        this.mbx = mbx;
    endfunction

    task run();
        dff_txn t;
        repeat (5) begin
            mbx.get(t);
            t.display("DRV");
            // Here you would drive DUT signals
        end
    endtask
endclass


module tb;
    mailbox #(dff_txn) mbx;
    generator gen;
    driver drv;

    initial begin
        mbx = new();
        gen = new(mbx);
        drv = new(mbx);

        fork
            gen.run();
            drv.run();
        join

        #10 $finish;
    end
endmodule
```

---

### ▶️ Run

```tcl
xvlog -sv a26_mailbox_dv_style.sv
xelab tb
xsim tb
```

---

## 🧠 Critical DV Insights (Interview Gold)

### Why mailbox > queue?

| Queue       | Mailbox     |
| ----------- | ----------- |
| No blocking | Blocking    |
| Race-prone  | Thread-safe |
| Manual sync | Auto sync   |

---

### Blocking behavior is the KEY

```systemverilog
mbx.get(t); // Waits until data arrives
```

This is how **drivers naturally synchronize** with generators.

---

## ✅ A2.6 Status

| Topic           | Status |
| --------------- | ------ |
| Mailbox concept | ✅      |
| Hands-on        | ✅      |
| DV usage        | ✅      |

---

## ⛔ As promised

We **STOP here**.

### ❌ NOT starting:

* Monitor
* Scoreboard
* UVM

---

### ⏭️ Next (ONLY when you confirm)

**Phase A2 COMPLETE → Resume original path at
Day-9: Monitor + Scoreboard (non-UVM)**
