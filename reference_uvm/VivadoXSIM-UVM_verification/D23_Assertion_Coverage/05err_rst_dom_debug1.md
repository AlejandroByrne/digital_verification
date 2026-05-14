Perfect — thanks for correcting the log. Now we can be **precise**, and this is a **very common (and important) SVA timing nuance**.

---

## ✅ What the Error ACTUALLY Means

```
ASSERTION FAILED: READY high during reset
Time: 5 ns
```

This assertion fired **ON `ready`**, not `valid`.
So the question becomes:

> **Why did the assertion see `ready == 1` during reset, even though later we see `Ready? = 0`?**

---

## 🔍 Root Cause (This Is the Key Insight)

### 👉 **Sampling happens BEFORE the DUT updates `ready`**

Your DUT code (simplified):

```systemverilog
always_ff @(posedge clk) begin
  if (rst)
    ready <= 0;
  else
    ready <= valid;
end
```

Your assertion:

```systemverilog
assert property (@(posedge clk) rst |-> !ready);
```

### Timeline at **5 ns (posedge clk)**

1. **Assertion samples signals FIRST**

   * `rst = 1`
   * `ready` still has its **previous value** (possibly `1` or `X`)

2. **Then** DUT executes `always_ff`

   * `ready <= 0` (scheduled via nonblocking assignment)

3. Later (after NBA update)

   ```
   Ready? = 0
   ```

So:

✅ DUT behavior is correct
❌ Assertion is sampling **too early**

This is **NOT a DUT bug**.

---

## 🧠 Why This Happens (Conceptually)

* **Concurrent assertions sample in the Observed region**
* **Nonblocking assignments update in the NBA region**
* At the **first reset clock edge**, `ready` may still reflect **pre-reset state**

This is **classic reset-entry race**, not a mistake.

---

## ✅ CORRECT WAY TO WRITE RESET ASSERTIONS

### 🔵 Option 1 (BEST PRACTICE): Use `disable iff`

```systemverilog
property p_reset_ready_low;
  @(posedge clk)
  disable iff (!rst)
  rst |-> !ready;
endproperty

assert property (p_reset_ready_low)
  else $error("READY high during reset");
```

This avoids sampling on reset **entry edge**.

---

### 🔵 Option 2: Delay Check by 1 Cycle (Also Valid)

```systemverilog
property p_reset_ready_low;
  @(posedge clk)
  rst |=> !ready;
endproperty
```

Meaning:

> One cycle **after reset is asserted**, ready must be low

This aligns with flop behavior.

---

## ❌ What NOT To Do

* ❌ Do NOT weaken DUT reset logic
* ❌ Do NOT remove assertion
* ❌ Do NOT assume DUT is wrong

The DUT is behaving correctly.

---

## 🟢 Why This Is a GOOD Failure

You just learned:

✔ Assertion sampling regions
✔ Reset entry vs steady-state reset
✔ Why `|->` vs `|=>` matters
✔ How NBA interacts with SVA

This is **senior-level DV understanding**.

---

## ✅ Final Verdict

| Item                | Status             |
| ------------------- | ------------------ |
| DUT reset logic     | ✅ CORRECT          |
| Assertion intent    | ✅ CORRECT          |
| Assertion timing    | ❌ Needs adjustment |
| Your interpretation | ✅ EXCELLENT        |

---

## 🔒 Recommended Final Assertion (Use This)

```systemverilog
assert property (@(posedge clk) rst |=> !ready)
  else $error("READY not low after reset");
```

This will **pass cleanly** and still enforce reset dominance.

---

If you want, next we can:

* ✔ Finalize **Day-23 assertion checklist**
* ✔ Or move to **Day-24 (objections, test end control)**
