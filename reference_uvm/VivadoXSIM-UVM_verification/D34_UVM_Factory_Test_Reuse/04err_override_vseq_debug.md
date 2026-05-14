Perfect — this error is **100% clear and expected**, and it actually means your **Day-34 factory work is correct**.
This is a **basic but critical UVM sequencing rule**, not a factory issue.

---

## ❌ The exact problem (line 47)

```
Accessing non-static members of a null object is not allowed
```

This line:

```systemverilog
vseq.start(env.vseqr);
```

### Why it fails

You **declared** the handle:

```systemverilog
layered_vseq vseq;
```

…but you **never created the object**.

So at runtime:

```
vseq == null
```

Calling `.start()` on a null object → **fatal error**.

---

## ✅ Correct fix (MANDATORY in UVM)

You must **create** the sequence via the factory:

```systemverilog
vseq = layered_vseq::type_id::create("vseq");
```

---

## ✅ Correct `run_phase` (XSim-safe, UVM-correct)

```systemverilog
task run_phase(uvm_phase phase);

  layered_vseq vseq;

  phase.raise_objection(this);

  // ✅ CREATE the sequence
  vseq = layered_vseq::type_id::create("vseq");

  // ✅ Start on virtual sequencer
  vseq.start(env.vseqr);

  #100;   // allow monitor/scoreboard to finish

  phase.drop_objection(this);

endtask
```

---

## 🧠 VERY IMPORTANT RULE (LOCK THIS)

> **Declaring ≠ creating**

In UVM:

* `layered_vseq vseq;` → just a **handle**
* `type_id::create()` → actual **object**

You already knew this for components — **same rule applies to sequences**.

---

## 🔍 Why this proves Day-34 is working

Notice your log **before the crash**:

```
[CFG_SET] Mode set in Config DB
[FACTORY] SANITY replaced with ERROR traffic
```

✔ Config DB works
✔ Factory override executed
✔ Test-level reuse correct
✔ Crash happens **after** that — unrelated

So your **architecture is correct**.

---

## 🧩 Interview-ready explanation

> “In UVM, sequences must always be created via the factory before calling `start()`.
> A declared handle without `type_id::create()` results in a null object access at runtime.”

That’s a **green flag** answer.

---

## ✅ What you should see after fixing

Even though you set:

```systemverilog
mode = SANITY
```

You should now see:

```
[LAYERED_VSEQ] Policy: SANITY
[ERROR_SEQ] Error traffic running
```

👉 This confirms **Day-34: Test Reuse via Factory**.

---

## 📌 Day-34 Status

✅ Factory type override
✅ Test reuse without env changes
✅ Correct virtual sequence usage

---

## 🔜 Next (DO NOT SKIP)

📅 **Day-35: Scoreboard Architecture**

* Analysis ports
* Analysis FIFOs
* Phase-aligned sampling (as promised earlier)

Run once more, paste **first ~20 lines**, and we move forward.
