
---

# 🔵 Phase A1 — SystemVerilog Randomization (FOUNDATION)

> Goal: You must **feel** randomization, not memorize it.

We cover **only**:

* `foreach`
* `inside`
* `dist`

Nothing else.

---

## 1️⃣ `foreach` — Controlled Iteration (VERY IMPORTANT)

### ❌ Verilog mindset (wrong for SV)

```verilog
for (i = 0; i < 8; i = i + 1)
```

### ✅ SV mindset

> “Iterate over what exists”

### Example 1: Basic `foreach`

```systemverilog
class pkt;
    rand bit [7:0] data[4]; // unpacked array
endclass

pkt p = new();
initial begin
    p.randomize();

    foreach (p.data[i]) begin
        $display("data[%0d] = %0d", i, p.data[i]);
    end
end
```

### Why `foreach` matters

* No hardcoded size
* Works with queues, arrays, associative arrays
* Used **everywhere** in coverage, scoreboards, monitors

---

## 2️⃣ `inside` — Legal Value Filtering

> `inside` answers:
> **“Is this value allowed?”**

### Example 2: `inside` with ranges

```systemverilog
class pkt;
    rand int addr;

    constraint addr_c {
        addr inside {[0:15], [32:63]};
    }
endclass
```

✔ Valid: `0–15`, `32–63`
❌ Invalid: `16–31`

---

### Example 3: `inside` with sets

```systemverilog
constraint legal_vals {
    addr inside {3, 7, 9, 12};
}
```

💡 Used heavily in:

* Protocol fields
* Opcode selection
* Avoiding illegal DUT states

---

## 3️⃣ `dist` — Weighted Randomization (CRITICAL FOR REAL TBs)

> `dist` answers:
> **“How often should this value appear?”**

### Example 4: Simple distribution

```systemverilog
class pkt;
    rand bit en;

    constraint en_dist {
        en dist {1 := 80, 0 := 20};
    }
endclass
```

🧠 Meaning:
📌 `:=` → **absolute weight**

* `en = 1` → ~80%
* `en = 0` → ~20%

---

### Example 5: Range-based distribution

```systemverilog
class pkt;
    rand int size;

    constraint size_dist {
        size dist {
            [1:4]  := 60,
            [5:8]  := 30,
            [9:16] := 10
        };
    }
endclass
```

✔ Small packets common
✔ Big packets rare
👉 This is **exactly** how real traffic is modeled

---

## 🔥 Combine `foreach + inside + dist`

### Example 6: Realistic packet fields

```systemverilog
class pkt;
    rand bit [3:0] payload[8];

    constraint payload_c {
        foreach (payload[i]) {
            payload[i] inside {[1:10]};
            payload[i] dist { [1:5] := 70, [6:10] := 30 };
        }
    }
endclass
```

💡 Every byte:

* Is legal
* Is biased
* Is controlled

---

## 🧠 Mental Model (IMPORTANT)

| Keyword   | Purpose             |
| --------- | ------------------- |
| `foreach` | Iterate safely      |
| `inside`  | Enforce legality    |
| `dist`    | Control probability |

If you miss **any one**, randomization becomes useless.

---

## 🧪 Mini Self-Test (DO NOT SKIP)

Answer mentally:

1. Why is `foreach` preferred over `for` in TBs?
2. Can `inside` reject values completely? (yes/no)
3. Can `dist` guarantee exact percentages? (no — probabilistic)

If these feel obvious → you’re ready.

---

## ✅ Phase A1 Status

✔ foreach — DONE
✔ inside — DONE
✔ dist — DONE

---

## ➡️ Next Step (Phase A2)

**OOP Foundations (CLEAN & SLOW)**

Topics:

* Classes & objects
* Constructors
* Inheritance
* Polymorphism
* Virtual methods
* Shallow vs deep copy

Still:
🚫 No mailbox
🚫 No driver
🚫 No monitor

Say:

**“Start Phase A2”**

We continue properly.
