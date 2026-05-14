
## Interface
An **interface** bundles:

* Signals
* Clock
* Assertions
* Coverage
* Direction control

Think of it as a **verification socket** between TB and DUT.

---

## Clocking Block (MOST IMPORTANT PART)

### What is a Clocking Block?

It defines:

* **When** signals are driven
* **When** signals are sampled

This **eliminates races completely**.


### Meaning:

| Item           | Meaning                         |
| -------------- | ------------------------------- |
| `output #0`    | Drive signals BEFORE clock edge |
| `input #1step` | Sample AFTER DUT updates        |

---
## Modports (Direction Control)

Modports define **WHO can do WHAT**.

### Why this matters:

* DUT **cannot drive TB signals**
* TB **cannot accidentally drive q**
* Compile-time protection

Interview phrase:

> “Modports enforce signal ownership”

---

Once you introduce an interface:

* TB must drive **through the interface**
* DUT must connect **through modports**
---

### Correct Architecture

```
tb
 ├── interface (signals + clocking block + assertions)
 ├── DUT (connected via modport)
 ├── TB drives through cb
 ├── TB samples through cb
```

# ✅ FINAL FLOW (Mental Model)

### TB responsibilities

* Generate clock
* Drive via `dif.cb`
* Sample via `dif.cb`
* Maintain reference model

### Interface responsibilities

* Hold signals
* Define timing (clocking block)
* Hold protocol assertions

That’s **exactly how real DV code looks**.

---