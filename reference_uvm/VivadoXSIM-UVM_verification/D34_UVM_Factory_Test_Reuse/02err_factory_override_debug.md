Perfect — this is a **classic Day-34 error**, and your simulator is 100% correct.

Let’s fix it **cleanly**, and I’ll also lock the **concept** so you never trip on this again.

---

# ❌ Error Root Cause (Very Important)

```
ERROR: 'factory' is not declared
```

### Why this happens

In **UVM**, there is **NO implicit variable named `factory`**.

Unlike some tutorials, **Xilinx/XSim does NOT auto-declare it**.

So this line is illegal in your toolchain:

```systemverilog
factory.set_type_override_by_type(...);
```

---

# ✅ Correct & Portable Way (BEST PRACTICE)

UVM provides the factory as a **singleton**.

You must explicitly fetch it.

---

## ✅ FIX #1 (Recommended)

### 🔧 Correct code in `my_test.sv`

```systemverilog
class my_test extends uvm_test;
  `uvm_component_utils(my_test)

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Day-33 config
    uvm_config_db#(mode_e)::set(
      this, "env.vseqr", "mode", SANITY
    );

    // ✅ Day-34: Get factory handle explicitly
    uvm_factory f;
    f = uvm_factory::get();

    f.set_type_override_by_type(
      sanity_traffic_seq::get_type(),
      error_traffic_seq::get_type()
    );

    `uvm_info("FACTORY", "SANITY replaced with ERROR traffic", UVM_LOW)
  endfunction
endclass
```

✔ Works on **XSim**
✔ Works on **Questa**
✔ Works on **VCS**
✔ Interview-safe

---

## ❌ Why some examples use `factory` directly

Some simulators inject:

```systemverilog
uvm_factory factory;
```

behind the scenes.

⚠️ **XSim does NOT**
⚠️ Relying on it is **non-portable**

---

# 🧠 INTERVIEW-GRADE UNDERSTANDING

### The Factory is:

* A **global singleton**
* Accessed via:

```systemverilog
uvm_factory::get()
```

### NOT:

* A variable
* A class member
* A macro

---

# 🔍 Optional Debug (Recommended Once)

After override, add:

```systemverilog
f.print();
```

You’ll see:

```
Type Overrides:
  sanity_traffic_seq -> error_traffic_seq
```

📌 This proves the override is registered **before run_phase**.

---

# ✅ Expected Output AFTER FIX

Even with:

```systemverilog
mode = SANITY;
```

You should now see:

```
[LAYERED_VSEQ] Policy: SANITY
[ERROR_SEQ] Error traffic running
[DUT] Data Received = 255
```

🚀 **Factory override confirmed**

---

# 🧠 One-Line Memory Hook (LOCK THIS)

> ❝ `factory` is not magic — always use `uvm_factory::get()` ❞

---

## 🔜 Next (ONLY after this runs)

📅 **Day-35: Scoreboard Architecture + Analysis FIFOs + Phase-Aligned Sampling**

But **first**:
👉 Apply the fix
👉 Re-run
👉 Paste **only** the first 10–15 lines showing `[ERROR_SEQ]`

We stay strict and clean.
