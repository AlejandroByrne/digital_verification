

Think of **Day-2** as:
> *“Making SystemVerilog feel clearly more powerful than Verilog.”*

---

# 📘 DAY-2 — SYSTEMVERILOG FUNDAMENTALS (VERIFICATION VIEW)

## 🎯 Day-2 Goal
By the end of Day-2, you must be able to:
- Confidently use **SystemVerilog data types**
- Understand **why they exist**
- Write **clean, bug-free testbench code**
- Avoid beginner mistakes that interviewers catch instantly

No classes.  
No UVM.  
No randomization yet.

---

## 🧠 DAY-2 TOPIC MAP

### 1️⃣ Why SystemVerilog Data Types Exist  
### 2️⃣ 2-State vs 4-State Logic  
### 3️⃣ `logic`, `bit`, `byte`, `int` (Industry usage)  
### 4️⃣ Packed vs Unpacked Arrays  
### 5️⃣ `enum` — replacing magic numbers  
### 6️⃣ `struct` — modeling transactions (basic)  
### 7️⃣ `always_comb`, `always_ff` (verification relevance)  
### 8️⃣ `$display` vs `$monitor` vs `$strobe`

---

## 1️⃣ Why SystemVerilog Data Types Exist

### Verilog problem:
- `reg` and `wire` confused beginners
- Poor support for modeling real data
- Hard to scale testbenches

### SystemVerilog solution:
- Strong typing
- Cleaner intent
- Fewer bugs

**Verification engineers mostly write testbench code**, so **data modeling is critical**.

---

## 2️⃣ 2-State vs 4-State Logic (VERY IMPORTANT)

### 4-State (default in RTL)
- `0`, `1`, `X`, `Z`
- Used for **hardware accuracy**

### 2-State (testbench friendly)
- `0`, `1`
- Faster simulation
- No unknowns

### Industry rule:
- **DUT → 4-state**
- **Testbench → 2-state where possible**

---

## 3️⃣ Core Data Types (You MUST know these)

### 🔹 `logic` (Most used)
```systemverilog
logic a;
logic [7:0] data;
```

✔ Can replace `reg` & `wire`  
✔ Supports 4-state  
✔ Safe default for TB & RTL

---

### 🔹 `bit` (2-state)
```systemverilog
bit valid;
```

✔ Faster  
✔ Use in testbench variables  
❌ Don’t connect directly to DUT pins blindly

---

### 🔹 `byte`, `int`
```systemverilog
byte b;   // 8-bit signed
int  i;   // 32-bit signed
```

✔ Use for counters, loops, indices  
✔ Cleaner than `[31:0]`

---

## 4️⃣ Packed vs Unpacked Arrays (Interview favorite)

### Packed Array (bit-level)
```systemverilog
logic [7:0] data;
```

- Represents a **bus**
- Can do arithmetic

---

### Unpacked Array (array of elements)
```systemverilog
logic data_array [8];
```

- Represents **collection**
- Cannot be treated as a single number

---

### Combined (Very common in verification)
```systemverilog
logic [7:0] mem [16];  // 16 entries of 8-bit
```

📌 **Understand this well** — it appears everywhere.

---

## 5️⃣ `enum` — Write Intent, Not Numbers

### ❌ Bad style
```systemverilog
if (state == 2) ...
```

### ✅ Industry style
```systemverilog
typedef enum logic [1:0] {
    IDLE,
    READ,
    WRITE
} state_t;

state_t state;
```

✔ Readable  
✔ Debug-friendly  
✔ Interviewers LOVE this

---

## 6️⃣ `struct` — Modeling Data (Very Important Later)

### Example
```systemverilog
typedef struct {
    logic [7:0] addr;
    logic [7:0] data;
    bit         valid;
} packet_t;

packet_t pkt;
```

Why this matters:
- This becomes **transaction objects** later
- Scoreboards & drivers use this concept

---

## 7️⃣ `always_comb` & `always_ff`

### `always_comb`
```systemverilog
always_comb begin
    y = a & b;
end
```

✔ Auto sensitivity  
✔ Prevents latches  
✔ Required in good RTL

---

### `always_ff`
```systemverilog
always_ff @(posedge clk) begin
    q <= d;
end
```

✔ Ensures **only flip-flop behavior**  
✔ Flags errors if misused

---

## 8️⃣ Display System Tasks (Debugging Life Skill)

### `$display`
- Prints once when executed

### `$monitor`
- Prints whenever variable changes

### `$strobe`
- Prints at end of timestep

```systemverilog
$display("a=%0d b=%0d y=%0d", a, b, y);
```

---

## ✍️ Day-2 Hands-On Task (MANDATORY)

Create **`day2_sv_types/`**

### Task 1:
- Rewrite Day-1 testbench using:
  - `logic`
  - `enum`
  - `struct` (just define, don’t overuse)

### Task 2:
- Create a small packed+unpacked example
- Print values using `$display`

🎯 Goal:
- Comfort with data modeling

---

## 📚 Best References (Only What You Need)

### 📘 Read (Short & High Quality)
- Doulos SV Data Types  
👉 https://www.doulos.com/knowhow/systemverilog/systemverilog-data-types/

### 📘 Deep Understanding
- Cliff Cummings — *SystemVerilog for Design & Verification* (SNUG)

(Search: **Cliff Cummings SystemVerilog SNUG PDF**)

---

## ❌ Do NOT Do Today
- No classes
- No randomization
- No UVM
- No assertions

---

## ✅ Day-2 Completion Checklist

You should be able to answer:
- When to use `bit` vs `logic`
- Packed vs unpacked difference
- Why `enum` is better than parameters
- How `struct` helps verification

---

## 🔜 Coming Next (Just Preview)
- **Day-3:** Procedural blocks, tasks, functions, `fork/join`
- **Day-4:** Constrained randomization & `rand`
- **Day-5:** Mailboxes, events, TB architecture

👉 **Only do Day-2 today**.  
When finished, tell me:
> **“Day-2 done”**

Then we continue to **Day-3**.