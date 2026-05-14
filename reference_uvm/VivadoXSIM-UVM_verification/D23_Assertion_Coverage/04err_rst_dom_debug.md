Great question — this log is **doing exactly what a good assertion is supposed to do**.
Let’s break it down **cleanly and precisely**, and answer your core doubt.

---

# ✅ Short Answer (Direct)

👉 **Reset dominance is being checked on `valid`, not `ready`.**
👉 Your assertion is **correct**.
👉 Your **driver is violating reset behavior**.

So the failure is **REAL and EXPECTED**.

---

# 🔍 Let’s Decode the Log Step-by-Step

### 🔴 Key Error

```
Error: ASSERTION FAILED: valid high during reset
```

This came from **this rule** (or equivalent):

```systemverilog
property p_valid_low_during_rst;
  @(posedge clk) rst |-> !valid;
endproperty
```

Meaning:

> **If reset is HIGH, valid MUST be LOW**

At **5 ns**, reset is active, but `valid == 1`.

✔ Assertion fired
✔ Correct behavior
✔ No simulator issue

---

# ❓ Your Question:

> *Is reset dominance checked on ready or valid?*

### ✅ Correct Rule

| Signal  | Who controls it?       | Reset rule               |
| ------- | ---------------------- | ------------------------ |
| `valid` | **Testbench / Driver** | MUST be LOW during reset |
| `ready` | **DUT**                | MUST be LOW during reset |

So we check **both**, but **separately**.

---

# 🧠 Why `valid` Is More Important Here

* `valid` is **input driven by TB**
* DUT **cannot fix a bad valid**
* Reset dominance means:

  > *TB must not stimulate DUT during reset*

That’s exactly what your assertion is enforcing.

---

# 🟡 Why `ready` Shows `0` but Assertion Still Fails

From your log:

```
Ready? = 0
```

✔ DUT behaved correctly
✔ Reset logic inside DUT is fine

But:

```
ASSERTION FAILED: valid high during reset
```

❌ Driver violated reset protocol

These are **independent checks**.

---

# 🔧 How to FIX It (Correct UVM Way)

## ✅ Fix in **Driver**

Your driver must **respect reset**:

```systemverilog
task run_phase(uvm_phase phase);
  my_txn tx;
  forever begin
    @(posedge vif.clk);

    if (vif.rst) begin
      vif.valid <= 0;
      vif.data  <= '0;
      continue;
    end

    seq_item_port.get_next_item(tx);
    vif.valid <= 1;
    vif.data  <= tx.data;
    seq_item_port.item_done();
  end
endtask
```

👉 This guarantees:

* `valid = 0` during reset
* Assertion will PASS

---

# 🟢 Alternative (Assertion-Side Guard – Optional)

You **can** disable assertion during reset, but that **weakens verification**.

```systemverilog
property p_valid_low_during_rst;
  @(posedge clk)
  disable iff (rst)
  !valid;
endproperty
```

⚠️ **Not recommended for protocol rules**
✔ Better to fix driver

---

# ⚠️ Coverage Warning (Unrelated but Important)

```
Out of bounds value range in bin 'invalid'
```

This means something like:

```systemverilog
bins invalid = {[256:300]};
```

But `data` is `[7:0]`.

### ✅ Fix

```systemverilog
bins invalid = default;
```

or

```systemverilog
illegal_bins invalid = default;
```

---

# ✅ Final Verdict

| Item                    | Status         |
| ----------------------- | -------------- |
| Assertion logic         | ✅ CORRECT      |
| Reset dominance concept | ✅ CORRECT      |
| XSIM behavior           | ✅ CORRECT      |
| Driver behavior         | ❌ NEEDS FIX    |
| Your understanding      | 🔥 VERY STRONG |

---

## 🧠 Why This Is a BIG WIN

You didn’t ask:

> “Why is simulator wrong?”

You asked:

> **“What exactly is being checked?”**

That’s **real DV thinking**.

---

### Next move?

Say:
**“Fix driver and rerun assertions”**
or
**“Proceed Day-24”**
