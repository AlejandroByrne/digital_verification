Good question — this is exactly the right checkpoint to ask 👍
Short answer: **some are already done implicitly, some are intentionally postponed, and none are *taught* as primary topics on Day-37.** Let me be precise.

---

## How to interpret that list correctly

### The list you quoted is **NOT** saying:

> “These topics are unfinished or missing.”

It is saying:

> “These topics are **out of scope for Day-37’s learning objective**.”

Day-37 has a **single responsibility**:
👉 **analysis dataflow architecture**

Anything that distracts from that is *deliberately deferred*.

---

## Item-by-item clarity

### ❌ Phase-aligned sampling (comes later)

**Status:**
✔ You have **conceptual exposure** already
❌ You have **not formally placed it yet**

**Why not Day-37?**
Phase-aligned sampling depends on:

* Correct shutdown (Day-36 ✅)
* Correct dataflow topology (Day-37 ✅)

It belongs **after** analysis architecture is stable.

📌 **Planned placement:** later day (after analysis FIFOs are revisited properly)

---

### ❌ Analysis FIFOs in depth (already used correctly)

**Status:**
✔ You already **used them correctly**

* Single consumer
* Blocking in scoreboard
* Count-based exit
* No drain-wait hacks

❌ But we have **not done a deep taxonomy lesson** yet

**Why not Day-37?**
Because today is:

> *“Where does data flow?”*
> not
> *“How does each buffer behave in every corner?”*

📌 **Deep dive comes later**, once multiple FIFOs exist.

---

### ❌ Performance tuning

**Status:**
✔ Not required at this stage
✔ Correctly excluded

Performance tuning without correctness is meaningless.

📌 Comes only after:

* Stable architecture
* Regression-scale environments

---

### ❌ Coverage bin design

**Status:**
✔ You conceptually understand coverage
❌ You have not structured coverage *components* yet

**Why not Day-37?**
Coverage is a **consumer**, not an architecture driver.

First we decide:

* How data flows
* Who consumes it
* How isolation works

📌 Coverage design comes **after** separation of concerns (next days).

---

## So what exactly IS Day-37 responsible for?

### ✅ Fully completed on Day-37

You now understand:

✔ Analysis port vs FIFO
✔ Push vs pull semantics
✔ Broadcast vs point-to-point
✔ Why monitors must never block
✔ Why multi-consumer FIFO is wrong
✔ Canonical monitor → port → consumers topology

That is **100% of Day-37**.

---

## Mental model to keep

Think of days as **load-bearing layers**:

```
Day-36 → lifecycle correctness
Day-37 → dataflow correctness
Day-38 → responsibility correctness
Day-39 → timing / phase correctness
```

Nothing is missing.
Nothing is skipped.
Nothing is prematurely mixed.

---

## Clear answer to your question

> **“These already done or not belong to Day-37?”**

**Answer:**
✔ They are either **already handled implicitly**
✔ or **intentionally postponed**
❌ They are **not Day-37 topics**

Day-37 is **complete and cleanly closed**.

---

### ✅ Ready to proceed to **Day-38** when you are

(No pressure — this is the correct pace.)
