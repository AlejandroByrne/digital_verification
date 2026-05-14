Excellent. ✅
**Day-32 is officially locked.** No rewinds, no mixing.

---

# 📅 **Day-33: Configuration DB + Env Configuration (Hands-On)**

## 🎯 Goal (VERY IMPORTANT)

> **Control behavior without touching test or sequence code**

This day answers:

> ❓ *How does the test choose SANITY vs STRESS **without** writing `vseq.mode = …`?*

Industry rule:

> **Tests configure. Sequences execute.**

---

## 🧠 Concept Reset (keep this straight)

| Item                            | Day-32                   | Day-33                 |
| ------------------------------- | ------------------------ | ---------------------- |
| Who sets mode?                  | Test (direct assignment) | Test (config_db)       |
| How does vseq get it?           | Variable access          | `uvm_config_db::get()` |
| Does test touch vseq internals? | ❌ (will stop now)        | ❌                      |
| Recompile needed?               | ❌                        | ❌                      |

---

## 🔑 What gets introduced TODAY

### 1️⃣ A **policy enum** (already exists)

You already have something like:

```systemverilog
typedef enum { SANITY, STRESS } mode_e;
```

✅ Keep it
❌ Do NOT redefine

---

### 2️⃣ Test sets mode via `uvm_config_db`

📍 **File: `my_test.sv`**

❌ REMOVE (this is now illegal):

```systemverilog
vseq.mode = STRESS;
```

✅ ADD (this is Day-33):

```systemverilog
uvm_config_db#(mode_e)::set(
  this,
  "env.vseqr.*",
  "mode",
  STRESS
);
```

📌 Meaning:

* Test **declares intent**
* Does not know who consumes it
* No sequence handle touched

---

### 3️⃣ Virtual sequence retrieves mode

📍 **File: `layered_vseq.sv`**

Add this in `body()` **before policy decision**:

```systemverilog
mode_e mode;

if (!uvm_config_db#(mode_e)::get(
      null,
      get_full_name(),
      "mode",
      mode)) begin
  `uvm_fatal("CFG", "mode not set via config_db")
end
```

Then use it exactly like Day-32:

```systemverilog
if (mode == STRESS) begin
  `uvm_info("LAYERED_VSEQ", "Policy: STRESS", UVM_MEDIUM)
  stress_seq.start(p_sequencer.seqr);
end
else begin
  `uvm_info("LAYERED_VSEQ", "Policy: SANITY", UVM_MEDIUM)
  sanity_seq.start(p_sequencer.seqr);
end
```

---

## 🔥 Why this is a **major professional jump**

Before (Day-32):

```systemverilog
vseq.mode = STRESS;   // ❌ tight coupling
```

Now (Day-33):

```systemverilog
config_db → virtual sequence → traffic
```

✔ Test is clean
✔ Sequences reusable
✔ Env untouched
✔ Regression-ready

---

## 🧪 Mandatory verification (you MUST see this)

### Run-1: SANITY

```systemverilog
uvm_config_db#(mode_e)::set(this, "env.vseqr.*", "mode", SANITY);
```

Expected log:

```
[LAYERED_VSEQ] Policy: SANITY
[SANITY_SEQ] Sanity traffic running
```

---

### Run-2: STRESS

```systemverilog
uvm_config_db#(mode_e)::set(this, "env.vseqr.*", "mode", STRESS);
```

Expected log:

```
[LAYERED_VSEQ] Policy: STRESS
[STRESS_SEQ] Stress traffic running
```

🚨 If **both** work without touching `layered_vseq` → Day-33 passed.

---

## 🧠 Lock this permanently

> **Day-31** → WHAT layers exist
> **Day-32** → WHICH traffic runs
> **Day-33** → HOW behavior is configured
> **Day-34** → HOW behavior is replaced (factory)

You are now doing **real UVM**, not tutorials.

---

### ⏭ Next step

Implement Day-33 exactly as above.

When done, reply with:

> **“Day-33 config_db verified for SANITY and STRESS.”**

Then we move to **Day-34 (Factory overrides — very powerful, very dangerous if unordered)**
