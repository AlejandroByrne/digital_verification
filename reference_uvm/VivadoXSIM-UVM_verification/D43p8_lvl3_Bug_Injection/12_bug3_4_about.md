Excellent catch 👍 — this is the **right question at the right time**.

Short answer first, then the nuance:

> **BUG-4 and BUG-5 are conceptually Level-3 bugs, but they are *boundary / thought-experiment bugs*, not mandatory hands-on injections.**
> You do **NOT** need to implement them again unless you want extra confidence.

Now let’s place them **precisely** in the roadmap so there’s no confusion.

---

## Where BUG-4 and BUG-5 belong

### 🧪 BUG-4: **Extra EXP transaction**

**Classification**

* ✔️ **Level-3 concept**
* ✔️ FIFO imbalance on EXP side
* ✔️ Scoreboard blocking behavior

**What it teaches**

* EXP FIFO can also overflow logically
* Scoreboard must *not* auto-complete just because ACTs ended
* Hanging is **correct behavior**

**Why you didn’t strictly need to code it**

* You already proved:

  * Blocking semantics
  * FIFO symmetry
  * No early test completion
* Extra EXP is the **mirror image** of Extra ACT
* Same mechanism, opposite side

👉 **Concept validated, implementation optional**

---

### 🧪 BUG-5: **Predictor lag (delayed EXP)**

**Classification**

* ✔️ **Level-3 timing tolerance**
* ✔️ Still within single-channel ordering
* ❌ Not phase-aware yet

**What it teaches**

* Level-3 scoreboards are **time-agnostic**
* Ordering matters, *latency does not*
* Blocking FIFOs naturally absorb lag

**Why this is important conceptually**

* Confirms Level-3 ≠ cycle-accurate
* Confirms scoreboard waits, not races

**Why we do NOT go further**

* If you start reasoning about *where* the lag occurs (phase / clock edge),
  you are **entering Day-44 territory**

👉 **This bug is a validation thought-experiment, not a required injection**

---

## Why we stopped at BUG-3 hands-on (this is deliberate)

You already demonstrated all **mechanically distinct failure modes**:

| Failure axis         | Covered by |
| -------------------- | ---------- |
| ACT missing          | Bug-1      |
| EXP missing          | Bug-2      |
| ACT duplication      | Bug-3      |
| FIFO imbalance       | Bugs 1–3   |
| Blocking correctness | Bugs 1–3   |

BUG-4 and BUG-5 do **not introduce a new mechanism**, only symmetry and timing intuition.

📌 **Day-44 rule (from roadmap memory):**

> *No new architecture, no new mechanisms — only failure analysis.*

That’s exactly why we **talk about** BUG-4/5 but don’t force code.

---

## Final authoritative placement

| Item                  | Day        | Status                |
| --------------------- | ---------- | --------------------- |
| BUG-1 (Missing ACT)   | Day-43.5   | ✅ Implemented         |
| BUG-2 (Missing EXP)   | Day-43.5   | ✅ Implemented         |
| BUG-3 (Extra ACT)     | Day-43.5   | ✅ Implemented         |
| BUG-4 (Extra EXP)     | Day-43.5   | ✅ Conceptually closed |
| BUG-5 (Predictor lag) | Day-43.5   | ✅ Conceptually closed |
| Phase/timing lies     | **Day-44** | ⏭️ Next               |

---

## Bottom line (very important)

❌ You did **nothing wrong**
❌ You did **not miss bugs**
❌ You do **not need to redo Level-3**

✅ Your Level-3 understanding is **correct and complete**
✅ Your architecture is **now canonical UVM**

---

When you’re ready, say:

**“Proceed to Day-44: Debugging & Failure Modes”**

That day is about **why things lie**, not how to build them.
