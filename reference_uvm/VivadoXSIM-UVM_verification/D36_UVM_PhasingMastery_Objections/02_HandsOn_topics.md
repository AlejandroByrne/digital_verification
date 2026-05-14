Very good question — and I’m glad you asked **now**, because this is exactly where many roadmaps cheat.

### Short, direct answer

**Yes — Day-36 absolutely has hands-on.**
And **no — it is NOT pushed to later days.**

If it were postponed, Day-36 would be **theoretically incomplete** and practically useless.

---

## 🔒 Clear commitment (no ambiguity)

**Day-36 includes hands-on.**
Specifically, hands-on that proves **shutdown correctness**.

What we *do not* do:

* ❌ toy examples
* ❌ artificial delays
* ❌ “just trust the theory”
* ❌ move it to Day-37

What we *do* do:

* ✅ real shutdown failure reproduction
* ✅ real fix using objections + signaling
* ✅ scoreboard-aware completion
* ✅ FIFO drain without polling

---

## 🧠 Why Day-36 MUST have hands-on

Because **shutdown bugs only show up in simulation**, not in slides.

Industry reality:

* Early exit bugs → **false pass**
* Hanging sims → **regression killers**
* Flaky behavior → **hardest bugs to debug**

You **cannot internalize Day-36 without seeing sims fail and then fixing them**.

So yes — hands-on is mandatory **inside Day-36**.

---

## 🧪 What the Day-36 hands-on will cover (concretely)

All of this happens **before we move to Day-37**.

### 🧩 Hands-on Lab 1 — *Early Exit Bug*

* Sequence finishes
* Test drops objection immediately
* Scoreboard misses transactions
* Simulation “passes” incorrectly

👉 You will **see the bug**, not just hear about it.

---

### 🧩 Hands-on Lab 2 — *Why `#delay` is Wrong*

* Add artificial delay
* Change DUT latency
* Watch test randomly fail/pass

👉 This burns the lesson permanently.

---

### 🧩 Hands-on Lab 3 — *Scoreboard Completion Signaling*

* Scoreboard tracks expected vs actual
* Emits a completion event/flag
* Test waits on **knowledge**, not time

👉 This is the **correct industry pattern**.

---

### 🧩 Hands-on Lab 4 — *FIFO Drain Without Polling*

* Analysis FIFO receives late transactions
* Polling fails
* Count-based completion succeeds

👉 You understand what “drain” really means.

---

### 🧩 Hands-on Lab 5 — *Correct Phase Shutdown*

* Objection dropped only after:

  * No stimulus left
  * No in-flight transactions
  * Scoreboard done
* Clean transition to `extract/check/report`

👉 This is what interviewers expect you to reason about.

---

## 🧭 Why this is NOT pushed to next days

Later days (Day-37+) assume:

* You already **trust** objections
* You already **understand** shutdown authority
* You already **know** how sims end correctly

If Day-36 is weak, **everything after becomes fragile**.

---

## ✅ Final answer (crisp)

> **Day-36 = Theory + Hands-on (mandatory)**
> **Shutdown correctness is fully implemented and validated here.**

Nothing leaks to Day-37.

---

If you want, say:

> **“Start Day-36 hands-on (shutdown correctness lab)”**

I’ll:

* write runnable UVM code
* deliberately break it
* show wrong behavior
* then fix it properly
* and explain *why* each fix works

This is exactly the right point to slow down and go deep.
