Good.
Now we are **cleanly moving forward** — no overlap, no confusion.

---

# 📅 **Day-41 — Config DB (Configuration as Architecture)**

### **HOW behavior is configured without coupling**

This day is **not about syntax**.
It is about **who is allowed to know what** in a UVM system.

---

## 🧠 Mental Model (Read this first)

> **Config DB is NOT a parameter store**
> **Config DB is NOT a convenience API**

💡 **Config DB = Architectural boundary enforcer**

If used correctly:

* Tests know **policy**
* Environment knows **structure**
* Sequences know **nothing**
* Components adapt **without rewiring**

---

## 🔴 What you have already done (but not *consciously*)

From your logs and code:

```systemverilog
uvm_config_db#(test_mode_e)::set(
    null,
    "uvm_test_top.env.vseqr",
    "mode",
    SANITY
);
```

```systemverilog
if (!uvm_config_db#(test_mode_e)::get(
        p_sequencer, "", "mode", mode))
    `uvm_fatal(...)
```

You already **used config_db** —
Day-41 is about **formalizing correct usage rules** and **locking them**.

---

## 🎯 Day-41 Learning Objectives

You must be able to answer **YES** to all of these:

✔ Can I change behavior without recompiling?
✔ Can I add a new policy without touching env/sequences?
✔ Can I prevent illegal configuration access?
✔ Can I explain *why* config_db lookup happens where it does?

---

## 🧩 Correct Config DB Ownership Model

| Layer              | Allowed to SET | Allowed to GET       |
| ------------------ | -------------- | -------------------- |
| **Test**           | ✅ YES          | ❌ NO                 |
| **Env**            | ❌ NO           | ✅ YES                |
| **Virtual Seq**    | ❌ NO           | ✅ YES                |
| **Leaf Seq**       | ❌ NO           | ❌ NO                 |
| **Driver/Monitor** | ❌ NO           | ✅ (only local knobs) |

**This table is interview-grade.**

---

## 🔥 Day-41 Hands-On (NO new files)

You will do **3 controlled experiments**.

---

## 🧪 HANDS-ON #1 — Enforce “Test sets, others get”

### ❌ ILLEGAL (Do NOT keep)

Inside `layered_vseq`:

```systemverilog
uvm_config_db#(test_mode_e)::set(
    null, "", "mode", STRESS
);
```

### 🧠 Why this is wrong

* Sequence mutating global policy
* Order-dependent bugs
* Impossible regressions

👉 **Remove it**

---

## 🧪 HANDS-ON #2 — Local vs Global configuration

### Add a LOCAL knob (legal)

In `my_driver`:

```systemverilog
bit drive_delay;

function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_config_db#(bit)::get(
        this, "", "drive_delay", drive_delay);
endfunction
```

In test:

```systemverilog
uvm_config_db#(bit)::set(
    null, "uvm_test_top.env.drv", "drive_delay", 1
);
```

### 🧠 Lesson

* Config DB can be **scoped**
* Local knobs ≠ global policy

✔ This is correct usage.

---

## 🧪 HANDS-ON #3 — Prove decoupling power

### Add a new policy WITHOUT touching env or sequences

```systemverilog
typedef enum { SANITY, STRESS, BURST } test_mode_e;
```

In `layered_vseq`:

```systemverilog
case (mode)
    SANITY: san_s.start(p_sequencer.seqr);
    STRESS: str_s.start(p_sequencer.seqr);
    BURST : repeat (5) san_s.start(p_sequencer.seqr);
endcase
```

In test:

```systemverilog
uvm_config_db#(test_mode_e)::set(
    null, "uvm_test_top.env.vseqr", "mode", BURST
);
```

### 🧠 Lesson

> Behavior changed
> Topology untouched
> Architecture preserved

This is **Config DB as architecture**.

---

## ❗ Common Traps (You are now immune)

❌ Sequences calling `set()`
❌ Deep wildcard paths (`*`)
❌ Drivers reading global policy
❌ Tests reading config_db

---

## ✅ Day-41 Exit Criteria (VERY IMPORTANT)

You should now be able to say:

> “I can reconfigure system behavior
> without touching environment wiring
> and without sequences knowing topology.”

If yes → you are **industry-ready at architecture level**.

---

## ⏭️ Next

When you are ready, say:

> **“Proceed Day-42”**

Day-42 is **Factory — replacement without rewiring**,
and it builds **directly** on what you learned today.
