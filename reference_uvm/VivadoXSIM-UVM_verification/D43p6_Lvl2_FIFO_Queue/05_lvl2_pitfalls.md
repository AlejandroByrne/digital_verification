
---

## ⚠ Why Level-2 can false-pass

### Key idea

> **Scoreboard compares first-available expected vs first-available actual**
> It does **not** enforce one-to-one causality or detect missing/extra transactions reliably.

---

### Typical Level-2 false-pass cases

1️⃣ **Dropped transaction** (DUT “loses” a value)

* Predictor: `[A, B, C]`
* Actual FIFO (bugged): `[A, C]`
* Scoreboard sees:

  ```
  A vs A → MATCH
  B vs C → ??? (may not compare if expected count ends or test finishes)
  ```
* Result: **test may PASS** even though one transaction is missing

2️⃣ **Duplicate transaction**

* Predictor: `[A, B, C]`
* Actual FIFO: `[A, A, B, C]`
* Extra `A` may never be checked if expected FIFO drains first
* Result: **false-pass**

3️⃣ **Late transaction / cycle mismatch**

* FIFO produces data late
* Level-2 compares only order, not time
* Test sees `A → B → C` matched eventually → PASS
* **Protocol violation undetected**

4️⃣ **Predictor lag**

* Expected FIFO fills slower than actual
* Scoreboard blocks on expected, comparison eventually succeeds → PASS
* **Hidden timing bug remains**

---

### ✅ Deep truth

Level-2 **only answers one question**:

> Did the DUT eventually produce the correct sequence of values?

It **does not answer**:

* When each value should appear
* If any values were dropped or duplicated silently
* Cycle-accurate causality

**This is intentional** for Day‑43.5 — unsafe by design.

---

### 🔵 Why this is correct for Level-2

* Protocol-agnostic
* DUT unchanged
* TLM FIFO–Queue comparison only
* Teaches **mechanics of predictor vs actual FIFO**
* Sets up the **need for Level-3 FIFO–FIFO** to detect missing/extra transactions

---

## ✅ Status check

* Your current output ✔ VALID
* Ordering illusions ✔ ALLOWED
* Level-2 false-pass cases ✔ INTENTIONALLY ILLUSTRATED
* No DUT or protocol changes ✔ LOCKED

---

### ✅ Correct next options

1. **Option B:** Minimal bug injection (mechanics-level only, not DUT) → shows false-pass
2. **Option C:** Proceed to Level-3 FIFO–FIFO

---

### 🔑 Key takeaway

Even though **mechanically everything passes**, Level-2 **cannot detect**:

* dropped transactions
* duplicated transactions
* timing/order violations

**That’s why it can false-pass even with a “real FIFO bug”** — but the bug **must be interpreted at the checking/fifo-stream level**, not DUT RTL logic.

---

I can now do **Option B: minimal bug injection in Level-2**, showing **why TLM FIFO → Queue false-passes**, without touching DUT RTL — fully in scope.

Do you want me to proceed with that?
