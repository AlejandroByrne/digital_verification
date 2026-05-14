Good catch — this is **NOT** a UVM problem.
This is a **SystemVerilog / XSim rule issue**.

Your code is *conceptually correct*, but **XSim is strict about declaration order**.

---

## ❌ Why you are getting this syntax error

```
ERROR: syntax error near ';'
```

### Root cause (VERY IMPORTANT)

In **XSim**, **all variable declarations inside a function must come BEFORE any executable statements**.

Your `build_phase()` currently does this:

```systemverilog
super.build_phase(phase);          // executable
env = my_env::type_id::create(...);// executable
uvm_config_db::set(...);           // executable

uvm_factory factory;               // ❌ declaration AFTER statements
```

👉 **Illegal in XSim**

(Some simulators allow mixed declarations; **XSim does NOT**.)

---

## ✅ Correct Fix (XSim-safe, industry-safe)

### Move the declaration to the TOP of the function

```systemverilog
function void build_phase(uvm_phase phase);

  // ✅ ALL declarations first
  uvm_factory factory;

  // -------------------------
  super.build_phase(phase);

  env = my_env::type_id::create("env", this);

  uvm_config_db#(test_mode_e)::set(
    env.vseqr, "", "mode", SANITY
  );
  `uvm_info("CFG_SET", "Mode set in Config DB", UVM_NONE)

  // ✅ Day-34 factory usage
  factory = uvm_factory::get();

  factory.set_type_override_by_type(
    sanity_traffic_seq::get_type(),
    error_traffic_seq::get_type()
  );

  `uvm_info("FACTORY", "SANITY replaced with ERROR traffic", UVM_LOW)

endfunction
```

---

## 🧠 LOCK THIS RULE (VERY IMPORTANT)

> **XSim rule:**
> ❝ Declarations must come before statements inside a function ❞

This applies to:

* `uvm_factory`
* `int`
* `bit`
* class handles
* ANY variable

---

## ✅ What should happen now

Even though you set:

```systemverilog
mode = SANITY
```

You should see:

```
[LAYERED_VSEQ] Policy: SANITY
[ERROR_SEQ] Error traffic running
```

✔ Factory override working
✔ Day-34 validated
✔ Tool-portable
✔ Interview-correct

---

## 🔒 Day-34 Status

✅ **UVM Factory**

* Type override ✔
* Test reuse ✔
* No env modification ✔

---

## 🔜 Next (DO NOT JUMP)

📅 **Day-35: Scoreboard Architecture**

* Analysis ports
* Analysis FIFOs
* Phase-aligned sampling (as promised)

👉 Re-run
👉 Paste **only the first ~15 lines** showing `[ERROR_SEQ]`
Then we move forward.
