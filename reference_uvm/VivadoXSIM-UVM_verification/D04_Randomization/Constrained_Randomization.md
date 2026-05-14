Excellent. **Day-3 is officially done** ✅
You’ve crossed the most important conceptual barrier in verification.

Now we move to **Day-4: Constrained Randomization** — this is where verification becomes **powerful, scalable, and industry-relevant**.

---

# 📘 DAY-4 — CONSTRAINED RANDOMIZATION (PRE-UVM)

## 🎯 Day-4 Goal

By the end of Day-4, you will be able to:

* Generate **random but valid stimulus**
* Control randomness with **constraints**
* Reproduce bugs using **seeds**
* Write **self-checking random tests**
* Understand how this maps directly to **UVM sequences**

Still **no UVM**, but everything here is **100% UVM-ready**.

---

## 1️⃣ Why Constrained Randomization Exists

### ❌ Directed Testing (What you did in Day-3)

```systemverilog
drive_ip(1,1);
drive_ip(1,0);
```

Problems:

* Limited coverage
* Easy to miss corner cases
* Manual effort grows exponentially

---

### ✅ Constrained Random Testing

```systemverilog
rand logic en;
rand logic d;
```

Benefits:

* Finds unexpected bugs
* Scales automatically
* Used in **every real verification project**

---

## 2️⃣ `rand` and `randc`

### `rand`

* Random values
* Can repeat

```systemverilog
rand bit [3:0] addr;
```

### `randc` (Random Cyclic)

* Cycles through all values before repeating

```systemverilog
randc bit [1:0] state;
```

🔑 Interview point:

> Use `randc` when you want uniform coverage.

---

## 3️⃣ Constraints (CORE OF DAY-4)

### Simple Constraint

```systemverilog
constraint c1 {
    en inside {0,1};
}
```

### Relational Constraint

```systemverilog
constraint c2 {
    if (en == 0) d == 0;
}
```

### Range Constraint

```systemverilog
constraint c3 {
    addr inside {[4:12]};
}
```

---

## 4️⃣ `inside` Keyword (VERY COMMON)

```systemverilog
constraint c4 {
    data inside {8'h00, 8'hFF, [8'h10:8'h20]};
}
```

✔ Clean
✔ Readable
✔ Preferred in industry

---

## 5️⃣ `pre_randomize()` and `post_randomize()`

Used to:

* Prepare values
* Update reference models
* Log transactions

```systemverilog
function void post_randomize();
    $display("en=%0b d=%0b", en, d);
endfunction
```

---

## 6️⃣ Randomization in a Class (NOT in Module)

⚠️ Important rule:

> **Randomization only works in classes, not modules.**

### Minimal Transaction Class

```systemverilog
class dff_txn;
    rand bit en;
    rand bit d;

    constraint valid_c {
        en inside {0,1};
        if (en == 0) d == 0;
    }
endclass
```

---

## 7️⃣ Using Random Stimulus in Your TB

Integrate with your **existing Day-3 TB**.

```systemverilog
dff_txn txn = new();

repeat (10) begin
    assert(txn.randomize());
    drive_ip(txn.en, txn.d);
end
```

✔ This is already **UVM-style thinking**.

---

## 8️⃣ Reproducibility (SEEDS) — INTERVIEW FAVORITE

```bash
vvp a.out +ntb_random_seed=123
```

Or inside TB:

```systemverilog
initial begin
    std::randomize() with { };
end
```

🔑 Key phrase:

> “Random tests must be reproducible using seeds.”

---

## 9️⃣ Self-Checking + Random = REAL VERIFICATION

Your checker and reference model **DO NOT CHANGE**.

That’s the power:

* Stimulus changes
* Checking stays same

---

## 🧪 Day-4 Hands-On Task (MANDATORY)

### Task-1

Create a class:

* `rand en`
* `rand d`
* Constraint: if `en==0`, `d==0`

### Task-2

Replace directed stimulus with:

```systemverilog
repeat (20)
    randomize → drive_ip → check
```

### Task-3

Run with:

* default seed
* fixed seed
* confirm reproducibility

---

## 📚 High-Quality References (Only the Best)

* Doulos — Constrained Random
  👉 [https://www.doulos.com/knowhow/systemverilog/systemverilog-constrained-random/](https://www.doulos.com/knowhow/systemverilog/systemverilog-constrained-random/)

* Verification Academy (Free intro)
  👉 [https://verificationacademy.com/](https://verificationacademy.com/)

---

## ❌ Do NOT Do Today

* No UVM
* No covergroups yet
* No mailboxes

---

## 🟢 Day-4 Completion Criteria

You should be able to explain:

* Why constraints are needed
* Difference between `rand` and `randc`
* How to reproduce a random failure
* Why reference model stays unchanged

---

### Next Step

Implement Day-4 in **your existing DFF TB**.

When done, say:

> **“Day-4 random TB done”**

I’ll review it line-by-line like a real code review.

You’re moving exactly at **industry speed** 🚀
