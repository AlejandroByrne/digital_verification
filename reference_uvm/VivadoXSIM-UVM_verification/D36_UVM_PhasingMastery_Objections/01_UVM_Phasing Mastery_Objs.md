Perfect.
I will **restart Day-36 cleanly**, assuming **solid understanding up to Day-35 only** — nothing more, nothing less.

No references to anything “already discussed”.
No shortcuts.
No future topics leaked.

---

# 📅 **Day-36: UVM Phasing Mastery & Objections (Shutdown Correctness)**

> **Single mental question for the entire day:**
>
> **“How does UVM *know* it is SAFE to end simulation?”**

If you deeply understand Day-36, you will **never**:

* add `#100` to “fix” shutdown
* wonder why a sim exits early
* struggle with flaky regressions
* fear UVM phasing questions in interviews

---

## 🧠 What you already know (assumed from Day-35)

You already understand:

✔ UVM component hierarchy
✔ `uvm_env`, `agent`, `driver`, `monitor`, `sequencer`
✔ Sequences generate items, drivers consume them
✔ Analysis ports → scoreboard / coverage
✔ FIFOs exist (conceptually)
✔ Basic UVM phases exist (build, connect, run, etc.)

**What you do NOT yet know** (this is Day-36):

❌ Who controls simulation end
❌ Why `run_phase` is special
❌ Why sequences finishing does NOT end simulation
❌ Why time delays are logically wrong
❌ How scoreboards affect shutdown
❌ What “draining” really means

---

## 1️⃣ Fundamental Truth (Most Important Rule)

### ❗ UVM does NOT end simulation because:

* sequences are done ❌
* drivers are idle ❌
* scoreboard is quiet ❌
* time passed ❌

### ✅ UVM ends simulation ONLY when:

> **All objections raised in `run_phase` are dropped**

This is the **entire shutdown mechanism**.

Nothing else.

---

## 2️⃣ Why `run_phase` is SPECIAL

All other phases are **function-like**:

```systemverilog
function void build_phase(...);
```

They execute and return.

### `run_phase` is different:

```systemverilog
task run_phase(uvm_phase phase);
```

It is **time-consuming**, **concurrent**, and **objection-controlled**.

---

## 3️⃣ Objections — The Core Mechanism

Think of objections as:

> **“I am not done yet — do NOT end simulation”**

### Basic API

```systemverilog
phase.raise_objection(this);
phase.drop_objection(this);
```

### Global rule

> Simulation ends when objection count reaches **ZERO**

---

## 4️⃣ Who is *allowed* to raise objections?

This is critical.

### Valid places:

* `uvm_test::run_phase`
* Sequences (via `starting_phase`)
* Environment-level controllers

### Invalid thinking:

* Drivers deciding shutdown ❌
* Scoreboards deciding shutdown ❌
* Monitors deciding shutdown ❌

Why?

Because **they don’t know system-level completeness**.

---

## 5️⃣ The CORRECT Ownership Model

### 🧠 Ownership Principle

> **The component that knows “what done means” owns the objection**

In real projects:

| Component  | Role                                  |
| ---------- | ------------------------------------- |
| **Test**   | Knows test intent                     |
| Sequence   | Knows stimulus completion             |
| Driver     | Executes orders (no authority)        |
| Monitor    | Observes only                         |
| Scoreboard | Verifies correctness (reports status) |

👉 **Test owns shutdown authority**

---

## 6️⃣ Minimal Correct Day-36 Test Skeleton

```systemverilog
class my_test extends uvm_test;
  `uvm_component_utils(my_test)

  my_env env;
  my_sequence seq;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    env = my_env::type_id::create("env", this);
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);

    seq = my_sequence::type_id::create("seq");
    seq.start(env.agent.sequencer);

    // ❌ Do NOT drop objection here blindly
    // We have no idea if results are processed yet

    phase.drop_objection(this);
  endtask
endclass
```

⚠️ This **looks** correct — but it is **still wrong**.

Why?

---

## 7️⃣ Sequence Completion ≠ Test Completion

Sequence finishing only means:

> “All items have been *sent*”

It does NOT mean:

❌ Driver finished
❌ Monitor observed all transactions
❌ Scoreboard compared everything
❌ FIFOs are empty

This is the **root cause** of early-exit bugs.

---

## 8️⃣ Why Time Delays Are a Logical Bug

Bad code:

```systemverilog
seq.start(seqr);
#100;
phase.drop_objection(this);
```

Why this is WRONG:

* Simulator speed varies
* Regression machines differ
* Protocol latency is variable
* Coverage affects timing

👉 Time has **zero semantic meaning** for correctness.

---

## 9️⃣ Correct Mental Model of Data Flow

```
Sequence
   ↓
Driver
   ↓
DUT
   ↓
Monitor
   ↓
Analysis FIFO
   ↓
Scoreboard
```

### Shutdown must guarantee:

✔ No more stimulus
✔ No in-flight transactions
✔ FIFOs are drained
✔ Scoreboard finished comparing

---

## 🔟 What “FIFO Drain” REALLY Means (Conceptually)

Not:

```systemverilog
wait (fifo.is_empty());
```

Because:

* Empty ≠ no more coming
* Race condition exists

Correct meaning:

> **“All expected transactions have been observed and processed”**

This requires **knowledge**, not polling.

---

## 1️⃣1️⃣ Scoreboard’s TRUE Responsibility

Scoreboard must be able to say:

> “I have seen N expected items and processed N actual items”

But it must **NOT**:

* raise/drop objections itself
* end simulation
* control phases

It only **reports status**.

---

## 1️⃣2️⃣ Who decides shutdown then?

### ✅ The Test does.

But the test must rely on **signals**, not time.

Typical mechanisms:

* Expected count reached
* Event triggered by scoreboard
* Completion flag

(We will code this next)

---

## 1️⃣3️⃣ Phase Transitions After `run`

Once objections drop:

```
run  → extract → check → report → final
```

Key idea:

* **NO time advances after run**
* All checking must be completed before run ends

---

## 🔚 Day-36 — Current State

At this point, you should clearly understand:

✔ Why objections exist
✔ Why `run_phase` controls life/death
✔ Why sequences finishing is insufficient
✔ Why delays are fundamentally wrong
✔ Why shutdown is a *system-level decision*

---

## 🔜 Next (still Day-36 — NOT Day-37)

If you say:

> **“Continue Day-36 (shutdown completeness)”**

Next we will **hands-on**:

* Scoreboard completion signaling
* Test-driven objection drop
* FIFO drain without polling
* Real early-exit & hang bugs
* Correct patterns used in industry

No roadmap drift.
No premature factory / config DB topics.
No abstraction leaks.

You are exactly where a **mid-level DV engineer becomes senior**.
