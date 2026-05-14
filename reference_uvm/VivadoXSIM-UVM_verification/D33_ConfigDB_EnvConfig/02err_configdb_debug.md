Perfect — this failure is **expected** on the first try of Day-33, and it tells us **exactly** what is wrong.
Nothing is broken conceptually. This is a **scope/path issue**, not a UVM misunderstanding.

Let’s fix it cleanly.

---

## 🔴 The Exact Problem (no guessing)

Error:

```
UVM_FATAL [CFG] Mode not set via config_db
```

This means:

> `uvm_config_db::set()` **did not reach** the virtual sequence instance that is calling `get()`.

So either:

1. The **set path is wrong**
2. Or the **get path is wrong**
3. Or both are too strict

---

## 🧠 Key Rule (CRITICAL)

### ❗ Sequences are **not components**

They **do not sit in the component hierarchy** like `env`, `agent`, etc.

So this is the **mistake**:

```systemverilog
uvm_config_db#(mode_e)::set(
  this,
  "env.vseqr.*",
  "mode",
  STRESS
);
```

That path **does NOT automatically reach a running sequence**.

---

## ✅ Correct & Industry-Standard Fix

### 🔑 Rule for sequences:

> **SET from component hierarchy
> GET using `null` (global lookup)**

---

## ✅ STEP 1: FIX `my_test.sv` (SET)

📍 **my_test.sv**

Use **component-based scope**, NOT sequence names:

```systemverilog
uvm_config_db#(mode_e)::set(
  this,
  "*",
  "mode",
  STRESS
);
```

✔ This publishes `mode` globally
✔ Any sequence can retrieve it
✔ Clean and safe for regressions

---

## ✅ STEP 2: FIX `layered_vseq.sv` (GET)

📍 **layered_vseq.sv**

Use **global lookup** (this is the key change):

```systemverilog
mode_e mode;

if (!uvm_config_db#(mode_e)::get(
      null,      // GLOBAL
      "",
      "mode",
      mode)) begin
  `uvm_fatal("CFG", "Mode not set via config_db")
end
```

🚫 Do **NOT** use:

```systemverilog
get_full_name()
```

That only works reliably for **components**, not sequences.

---

## 🧪 Why this works (important mental model)

| Item                  | Why                         |
| --------------------- | --------------------------- |
| `set(this, "*", ...)` | Component hierarchy anchor  |
| `get(null, "", ...)`  | Global sequence-safe lookup |
| No hard path          | Avoids fragile naming       |

This is **how real UVM regressions are written**.

---

## ✅ Expected Output After Fix

You **must** see:

```
[LAYERED_VSEQ] Policy: STRESS
[STRESS_SEQ] Stress traffic running
```

(or SANITY if configured)

No CFG fatal.

---

## 🧠 Lock this permanently (very important)

> **Config DB + sequences rule**
> 🔹 Components → scoped paths
> 🔹 Sequences → global get
> 🔹 Never rely on sequence full names

If you remember only one thing from Day-33, remember this.

---

## ✅ What to do now

1. Apply the **two exact fixes above**
2. Run with `SANITY`
3. Run with `STRESS`

Then reply with:

> **“Day-33 config_db verified after global set/get fix.”**

Once you say that, we move to **Day-34: Factory overrides** (this is where 90% people break UVM — we’ll do it safely).
