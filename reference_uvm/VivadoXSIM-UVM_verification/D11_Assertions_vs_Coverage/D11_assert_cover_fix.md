Good. **Day-11 starts now.**
This is an **important conceptual day**, not a coding-heavy one.

---

# ✅ Day-11: Assertions vs Coverage (Timing-Correct, Interview-Grade)

## What we will do today

1. **Explain why your `hold_when_en_low` assertion failed**
2. **Fix it correctly (not silencing it)**
3. **Align assertions with clocking blocks**
4. **Clarify: driver CB vs monitor CB**
5. **Tie assertions vs functional coverage (who checks what)**

---

## 1️⃣ First: What assertions are actually observing

### Golden Rule (very important)

> **Assertions observe design behavior, not testbench intent**

That means:

* Assertions should be aligned with **DUT visibility**
* NOT aligned with when the driver “thinks” it drove signals

---

## 2️⃣ Driver CB vs Monitor CB — which one assertions use?

### ❌ Driver clocking block (`drv_cb`)

* Used to **drive signals**
* Has output skew
* NOT stable for checking design behavior

### ✅ Monitor clocking block (`mon_cb` or `cb`)

* Used to **sample DUT outputs**
* Has input skew
* Represents **what the DUT actually sees**

🔑 **Assertions must always use the MONITOR clocking block**

✔ You already did the correct thing:

```systemverilog
property hold_when_en_low;
    @(cb) disable iff (rst)
    !en |-> (cb.q == $past(cb.q));
endproperty
```

But the **timing semantics were still wrong**.

---

## 3️⃣ Why your assertion FAILED (root cause)

Let’s walk cycle-by-cycle.

### Your DUT behavior (DFF with enable)

| Cycle | en | d | q |               |
| ----- | -- | - | - | ------------- |
| N-1   | 1  | 1 | 1 |               |
| N     | 0  | X | 1 | ← should HOLD |
| N+1   | 0  | X | 1 |               |

Correct.

### But your assertion:

```systemverilog
!en |-> (cb.q == $past(cb.q));
```

### Problem ❌

* `$past(cb.q)` refers to **previous sampled value**
* BUT sampling happens **after nonblocking assignments**
* So you are accidentally comparing:

  * new q vs already-updated q in some cycles

This creates **false hold violations**

👉 This is a **classic clocking-block + assertion pitfall**

---

## 4️⃣ The CORRECT assertion (timing-safe)

### ✅ Fix #1: Explicitly sample q before the edge

```systemverilog
property hold_when_en_low;
    @(cb) disable iff (rst)
    !cb.en |=> (cb.q == $past(cb.q, 1));
endproperty
```

### Why this works

* `|=>` → next-cycle implication
* `$past(cb.q,1)` → guaranteed previous cycle value
* Matches **DFF latency**

✔ This aligns with your scoreboard model

---

## 5️⃣ Even cleaner (recommended in real projects)

Use **sampled values**:

```systemverilog
property hold_when_en_low;
    logic q_prev;
    @(cb) disable iff (rst)
    (q_prev = cb.q, !cb.en) |=> (cb.q == q_prev);
endproperty
```

This avoids simulator-dependent `$past` quirks.

---

## 6️⃣ Why scoreboard and assertion must agree

### Scoreboard

* Temporal **reference model**
* Detects **functional mismatches**

### Assertion

* Detects **protocol violations**
* Should fire **before scoreboard breaks**

If assertion fires *after* scoreboard failure → assertion is wrong.

That’s exactly what you observed earlier.

---

## 7️⃣ Assertions vs Functional Coverage (big picture)

| Aspect              | Assertion   | Functional Coverage      |
| ------------------- | ----------- | ------------------------ |
| Purpose             | Detect bugs | Measure stimulus quality |
| Timing              | Precise     | Statistical              |
| Fails sim           | Yes         | No                       |
| Uses clocking block | YES         | Usually YES              |

👉 Assertions **protect correctness**
👉 Coverage **measures completeness**

They are complementary, not competitors.

---

## 8️⃣ Interview-level statement (memorize this)

> “Assertions must be aligned to monitor clocking blocks and DUT latency.
> Scoreboards model expected behavior; assertions guard protocol correctness.
> Misaligned assertions cause false failures.”

That’s a **senior DV answer**.

---

### ✅ Status Check

* Monitor/Scoreboard: **Mastered**
* Clocking blocks: **Clear**
* Assertion timing: **Now correct**
* Day-11: **50% done**

---

### ▶️ Next

We will:

* Rewrite **enable behavior assertion**
* Add **reset assertion**
* Show **why coverage can be 100% but design still broken**

Say **Next** when ready.
