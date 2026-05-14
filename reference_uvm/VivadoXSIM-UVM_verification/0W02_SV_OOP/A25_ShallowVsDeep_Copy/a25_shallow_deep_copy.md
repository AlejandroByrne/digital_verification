Perfect.
We continue **exactly where the roadmap says**. No detours.

---

# 🟦 A2.5 – Shallow vs Deep Copy (CRITICAL OOP CONCEPT)

This topic is **non-negotiable** for verification.
If you miss this → **scoreboard bugs, reused transactions break silently**.

We’ll do this in **3 steps** using **XSIM-friendly code**.

---

## 1️⃣ Problem Setup – A Class With a Handle Member

This is the **exact situation** that causes bugs in DV.

```systemverilog
class payload;
    rand byte data;

    function void display();
        $display("    payload.data = 0x%0h", data);
    endfunction
endclass


class packet;
    rand bit  valid;
    payload   pld;     // HANDLE MEMBER (important!)

    function new();
        pld = new();   // allocate payload
    endfunction

    function void display();
        $display("packet.valid = %0b", valid);
        pld.display();
    endfunction
endclass
```

Key point:

> `pld` is an **object handle**, not actual data.

---

## 2️⃣ SHALLOW COPY – The Bug

### ❌ Shallow copy behavior

Two packets **share the same payload object**.

```systemverilog
module tb;
    packet p1, p2;

    initial begin
        p1 = new();
        p2 = new();

        assert(p1.randomize());
        p2 = p1;   // ❌ SHALLOW COPY (handle copy)

        $display("Before modification:");
        p1.display();
        p2.display();

        // Modify payload through p2
        p2.pld.data = 8'hAA;

        $display("After modifying p2:");
        p1.display();
        p2.display();

        #10 $finish;
    end
endmodule
```

### 🔍 Output (key observation)

```text
After modifying p2:
packet.valid = 1
payload.data = 0xAA   ❌ p1 changed unexpectedly
```

### ⚠️ THIS IS THE BUG

* `p1.pld` and `p2.pld` point to **same object**
* Changing one affects the other
* **Scoreboards explode silently**

---

## 3️⃣ DEEP COPY – The Fix (Correct Way)

We **manually clone** internal objects.

---

### ✅ Add a `copy()` method (Deep Copy)

```systemverilog
class packet;
    rand bit valid;
    payload pld;

    function new();
        pld = new();
    endfunction

    function void copy(packet rhs);
        this.valid = rhs.valid;
        this.pld.data = rhs.pld.data;  // deep copy payload
    endfunction

    function void display();
        $display("packet.valid = %0b", valid);
        pld.display();
    endfunction
endclass
```

---

### ✅ Test Deep Copy

```systemverilog
module tb;
    packet p1, p2;

    initial begin
        p1 = new();
        p2 = new();

        assert(p1.randomize());
        p2.copy(p1);   // ✅ DEEP COPY

        $display("Before modification:");
        p1.display();
        p2.display();

        p2.pld.data = 8'h55;

        $display("After modifying p2:");
        p1.display();
        p2.display();

        #10 $finish;
    end
endmodule
```

### ✔️ Correct Behavior

```text
p1.payload.data unchanged
p2.payload.data changed
```

---

## 🧠 Interview-Level Summary (Memorize This)

> **Shallow copy copies handles**
> **Deep copy copies actual data**

| Context     | Why it matters               |
| ----------- | ---------------------------- |
| Scoreboards | Stored txns must not mutate  |
| Monitors    | Same txn reused every cycle  |
| UVM         | `copy()`, `clone()` required |
| Debug       | Bug looks random & painful   |

---

## 🔒 Roadmap Status (Updated)

### Phase A2 – OOP in SV

| Topic                    | Status     |
| ------------------------ | ---------- |
| Classes & Objects        | ✅          |
| Constructors             | ✅          |
| Inheritance              | ✅          |
| Polymorphism             | ✅          |
| **Shallow vs Deep Copy** | ✅ **DONE** |

---

## ⏸️ As you requested earlier

We **do NOT** start Monitor / Scoreboard yet.

### ⏭️ Next (only when you say)

> **Start A2.6 – Mailbox (concept + hands-on)**

We will do:

* producer / consumer
* blocking vs non-blocking
* why mailbox ≠ queue
* exactly how drivers & monitors use it

You’re now **exactly back on track**.
