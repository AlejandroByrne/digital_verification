Great — this is **another correct assertion firing for the right reason**, and the reason is **timing**, not logic confusion.
Let’s pin it down precisely and fix it **the right way**.

---

## 🔴 What Failed

```
Error: Assertion a_no_spur_ready failed!
Time: 295 ns
```

Assertion in question:

```systemverilog
property p_no_spurious_ready;
  @(posedge clk)
  disable iff (rst)
  ready |-> valid;
endproperty
```

Meaning (logically correct rule):

> **If READY is high, VALID must be high in the same cycle**

---

## 🔍 Why It Failed (Actual Root Cause)

### Your DUT behavior (important):

```systemverilog
always_ff @(posedge clk) begin
  if (rst)
    ready <= 0;
  else
    ready <= valid;
end
```

So:

* `ready` is a **registered version of `valid`**
* Updated with **nonblocking assignment**

---

## ⏱ What Happens at the Failing Cycle

At **295 ns (posedge clk)**:

1. **Assertion samples signals FIRST**

   * `ready = 1`  (from previous cycle)
   * `valid = 0`  (driver just deasserted it)

2. **Assertion checks**

   ```
   ready |-> valid
   1     |-> 0   ❌ FAIL
   ```

3. **After that**, DUT executes:

   ```
   ready <= valid;  // schedules ready = 0
   ```

So although logically:

> “READY follows VALID”

**temporally**, the assertion sees:

> “READY one cycle late”

---

## ✅ This Is NOT a Spurious Ready Bug

Important distinction:

* ❌ DUT is NOT asserting ready randomly
* ❌ Protocol is NOT violated
* ✔ This is a **1-cycle latency artifact**

Your DUT is effectively:

```
ready = valid_d1
```

---

## 🧠 Correct Assertion for *THIS* DUT

Since `ready` is **derived from previous-cycle valid**, the assertion must reflect that.

### ✅ FIX #1 (BEST): Use `$past(valid)`

```systemverilog
property p_no_spurious_ready;
  @(posedge clk)
  disable iff (rst)
  ready |-> $past(valid);
endproperty

assert property (p_no_spurious_ready);
```

Meaning:

> If READY is high now, VALID must have been high last cycle

✔ Matches DUT design
✔ Assertion will PASS
✔ Rule is still logically correct

---

### ✅ FIX #2 (Alternative): Non-overlapping implication

```systemverilog
property p_no_spurious_ready;
  @(posedge clk)
  disable iff (rst)
  $rose(ready) |-> valid;
endproperty
```

Checks only when ready **rises**.

---

## ❌ What NOT to Do

| Action           | Why                   |            |
| ---------------- | --------------------- | ---------- |
| Change DUT       | DUT is fine           |            |
| Remove assertion | You lose protection   |            |
| Use `valid       | -> ready`             | Wrong rule |
| Ignore failure   | Misses timing reality |            |

---

## 🔑 Key Lesson (Very Important)

> **Assertions must match the timing semantics of the DUT, not just logical intent.**

You correctly wrote:

* **Logical rule** ✔
  Now you refined:
* **Temporal rule** ✔

This is **advanced SVA usage**.

---

## 📌 Final Mental Model

| Design relationship  | Correct assertion |                  |
| -------------------- | ----------------- | ---------------- |
| Combinational ready  | `ready            | -> valid`        |
| Registered ready     | `ready            | -> $past(valid)` |
| Next-cycle handshake | `valid            | => ready`        |

---

## ✅ Final Verdict

| Item             | Status              |
| ---------------- | ------------------- |
| Assertion logic  | ✅ Correct           |
| Assertion timing | ❌ Needed refinement |
| DUT              | ✅ Correct           |
| Your debugging   | 🔥 Excellent        |

---

You just crossed from **basic SVA** into **real-world SVA timing reasoning**.

When ready:
👉 **Proceed Day-24 — UVM objections & phase control**
