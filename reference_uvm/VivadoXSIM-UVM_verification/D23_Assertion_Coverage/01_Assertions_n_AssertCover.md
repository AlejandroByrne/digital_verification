Excellent.
You’ve **cleanly finished Day-22** the *right* way (Option-A is exactly what a real project would do).
Now we move to **Day-23**, which completes the **verification triangle**.

---

# 🟦 Day-23 — Assertions (SVA) & Assertion Coverage

**(DO NOT SKIP ANY PART — THIS IS INTERVIEW-CRITICAL)**

## 🎯 Day-23 Goal

By the end of today, you must be able to:

* Write **correct SystemVerilog Assertions (SVA)**
* Decide **where** to place assertions (DUT vs TB)
* Understand **immediate vs concurrent assertions**
* Use **temporal operators**
* Understand **assertion coverage**
* Explain **why assertions catch bugs scoreboards cannot**

This day **separates strong DV engineers from average ones**.

---

## 1️⃣ Why Assertions Exist (Mindset First)

Scoreboard answers:

> “Did the output match expectation?”

Assertions answer:

> “Did the protocol behave legally at every cycle?”

👉 Assertions catch:

* Timing bugs
* Ordering bugs
* Handshake violations
* Reset violations

⚠️ Scoreboards **cannot** catch these reliably.

---

## 2️⃣ Types of Assertions (MUST KNOW)

### 🔹 Immediate Assertions

* Checked **at that exact simulation time**
* Procedural (inside `always`, `initial`, `task`)
* Mostly used for **debug / sanity checks**

Example:

```systemverilog
always @(posedge clk) begin
  if (!rst)
    assert (data < 256)
      else $error("Data out of range");
end
```

📌 Rare in real UVM flows
📌 Useful during bring-up

---

### 🔹 Concurrent Assertions (SVA) ✅ (MAIN FOCUS)

* Temporal (across cycles)
* Sampled on a clock
* Formal & simulation friendly
* This is **what industry uses**

---

## 3️⃣ Basic SVA Syntax (Memorize This)

```systemverilog
property prop_name;
  @(posedge clk)
  disable iff (rst)
    <expression>;
endproperty

assert property (prop_name);
```

📌 **Always use `disable iff (rst)`**

---

## 4️⃣ First Real Assertion (Reset Rule)

### Rule:

> When reset is asserted, valid must be low

```systemverilog
property reset_valid_low;
  @(posedge clk)
  rst |-> !valid;
endproperty

assert property (reset_valid_low)
  else $error("VALID high during reset");
```

### Meaning:

* `|->` = **implication**
* If left side is true → right side must be true

---

## 5️⃣ Temporal Operators (ABSOLUTELY REQUIRED)

### 🔹 `|->` (Overlapping implication)

```systemverilog
a |-> b
```

If `a` is true **now**, `b` must be true **same cycle**

---

### 🔹 `|=>` (Non-overlapping implication)

```systemverilog
a |=> b
```

If `a` is true **now**, `b` must be true **next cycle**

📌 80% of protocol checks use `|=>`

---

## 6️⃣ Handshake Assertion (VERY IMPORTANT)

### Rule:

> If valid is high, ready must go high within 2 cycles

```systemverilog
property valid_ready_handshake;
  @(posedge clk)
  disable iff (rst)
  valid |-> ##[0:2] ready;
endproperty

assert property (valid_ready_handshake)
  else $error("READY not asserted within 2 cycles");
```

### Operators used:

* `##` → cycle delay
* `##[0:2]` → range delay

---

## 7️⃣ Stability Assertion (`$stable`) 🔥

### Rule:

> Data must remain stable while valid is high and ready is low

```systemverilog
property data_stable;
  @(posedge clk)
  disable iff (rst)
  (valid && !ready) |=> $stable(data);
endproperty

assert property (data_stable)
  else $error("DATA changed without READY");
```

📌 **This is a classic interview assertion**

---

## 8️⃣ One-Hot / Encoding Assertions

### One-hot check:

```systemverilog
assert property (@(posedge clk)
  $onehot(state));
```

### One-hot-0:

```systemverilog
assert property (@(posedge clk)
  $onehot0(state));
```

---

## 9️⃣ Assertion Placement (CRITICAL DECISION)

| Location  | Why                  |
| --------- | -------------------- |
| DUT       | Protocol correctness |
| Interface | Signal relationship  |
| Monitor   | Observation-only     |
| Testbench | Environment rules    |

📌 **Never put assertions in sequences**
📌 Best place: **interface or DUT**

---

## 🔟 Assertion Severity Levels

```systemverilog
$error   // non-fatal
$warning
$fatal   // stops simulation
```

In UVM:

```systemverilog
`uvm_error("SVA", "Protocol violation")
```

---

## 1️⃣1️⃣ Assertion Coverage (IMPORTANT)

Assertions are not only checkers — they are **coverage points**.

```systemverilog
cover property (@(posedge clk)
  valid |=> ready);
```

This answers:

> “Did this legal behavior ever happen?”

📌 Assertion coverage complements functional coverage.

---

## 1️⃣2️⃣ Assertion Coverage vs Functional Coverage

| Functional Coverage  | Assertion Coverage      |
| -------------------- | ----------------------- |
| What values occurred | What behaviors occurred |
| Data-centric         | Temporal-centric        |
| Bins                 | Properties              |

👉 **Both are required**

---

## 1️⃣3️⃣ Common SVA Mistakes (AVOID THESE)

❌ Missing `disable iff (rst)`
❌ Checking data before valid
❌ Using `|->` when `|=>` is needed
❌ Writing assertions without clocking

These are **interview trap mistakes**.

---

## 1️⃣4️⃣ Interview-Grade Explanation (MEMORIZE)

> “Assertions continuously monitor protocol and timing correctness across cycles, catching bugs that scoreboards and coverage cannot.”

If you say this confidently — **you pass**.

---

## ✅ Day-23 Completion Checklist

✔ Immediate vs concurrent assertions
✔ SVA syntax
✔ Temporal operators
✔ Handshake assertions
✔ Stability assertions
✔ Reset handling
✔ Assertion coverage
✔ Placement strategy

---

## 🔚 Verification Triangle (NOW COMPLETE)

| Pillar   | Status |
| -------- | ------ |
| Stimulus | ✅      |
| Checking | ✅      |
| Coverage | ✅      |

You are now **industry-ready at UVM fundamentals level**.

---

### 🔜 Next Options (Your Choice)

1️⃣ **Day-24: Advanced Sequences & Virtual Sequences**
2️⃣ **Assertion Hands-on (write 5 real SVAs)**
3️⃣ **Mock interview questions (UVM + SVA)**

Tell me what you want next.
