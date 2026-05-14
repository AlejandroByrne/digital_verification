Sure — here’s the **quick, clean explanation** with no extra noise.

---

## 🔹 Property: **No Spurious Ready**

```systemverilog
property p_no_spurious_ready;
  @(posedge clk)
  disable iff (rst)
  ready |-> valid;
endproperty

assert property (p_no_spurious_ready);
```

---

## 🧠 What This Means (Plain English)

> **If `ready` is HIGH in a cycle, then `valid` must also be HIGH in the SAME cycle.**

In other words:
👉 **DUT must NOT assert `ready` unless the testbench is asserting `valid`.**

---

## 🔍 Why This Exists

In a valid–ready style protocol:

* `valid` = “I am sending data”
* `ready` = “I am able to accept data”

It makes **no sense** for the DUT to say “I’m ready” when:

* No one is sending data (`valid = 0`)

That would be a **spurious (meaningless) ready**.

---

## ⏱ Why `|->` (Overlapping Implication)

* `ready |-> valid`
* Both are checked **in the same clock cycle**

So this catches:

```
ready = 1
valid = 0   ❌  → assertion FAIL
```

---

## 🟢 When This Assertion PASSES

| valid | ready | Result |
| ----- | ----- | ------ |
| 0     | 0     | ✅ OK   |
| 1     | 0     | ✅ OK   |
| 1     | 1     | ✅ OK   |

---

## 🔴 When This Assertion FAILS

| valid | ready | Result                  |
| ----- | ----- | ----------------------- |
| 0     | 1     | ❌ FAIL (spurious ready) |

---

## 🧩 Why `disable iff (rst)`

During reset:

* Signals may be forced low or transitioning
* Protocol rules don’t apply

So we **disable the check during reset**.

---

## 📌 One-Line Interview Answer

> “This assertion ensures the DUT never asserts `ready` unless `valid` is also asserted, preventing spurious handshake signaling.”

That’s it. Clean and correct.
