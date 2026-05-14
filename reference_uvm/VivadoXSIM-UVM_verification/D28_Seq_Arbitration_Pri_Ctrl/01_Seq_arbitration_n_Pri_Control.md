Great — **yes, what you’ve done is enough** 👍
Your Day-27 coverage is solid and complete.

---

# 📅 Day-28: Sequencer Arbitration & Priority Control (HANDS-ON)

### 🎯 Goal

Understand **who wins when multiple sequences compete** for the same sequencer — and how **you control it deliberately**, not accidentally.

This is **very important for real projects & interviews**.

---

## 1️⃣ What problem are we solving?

You already saw this:

* Two sequences run **in parallel**
* Only **one transaction reaches DUT at a time**

👉 **WHY that one?**
👉 **HOW to control it?**
👉 **WHAT if one sequence starves the other?**

That’s Day-28.

---

## 2️⃣ Default behavior (what you already observed)

By default, UVM sequencer uses:

```
FIFO arbitration
```

Meaning:

* First sequence that requests → gets served first
* No priority awareness
* Can cause **starvation**

✅ Your Day-27 logs already demonstrate this implicitly.

---

## 3️⃣ Arbitration modes (concept)

UVM supports multiple arbitration schemes:

| Mode                        | Meaning                          |
| --------------------------- | -------------------------------- |
| `UVM_SEQ_ARB_FIFO`          | First come first serve (default) |
| `UVM_SEQ_ARB_RANDOM`        | Random winner                    |
| `UVM_SEQ_ARB_WEIGHTED`      | Priority-based                   |
| `UVM_SEQ_ARB_STRICT_FIFO`   | FIFO + priority                  |
| `UVM_SEQ_ARB_STRICT_RANDOM` | Random + priority                |

Day-28 = **HANDS-ON with WEIGHTED / STRICT**

---

## 4️⃣ Step-1: Set sequencer arbitration mode

👉 In your **agent / env build_phase**

```systemverilog
function void build_phase(uvm_phase phase);
  super.build_phase(phase);
  seqr = my_sequencer::type_id::create("seqr", this);

  seqr.set_arbitration(UVM_SEQ_ARB_WEIGHTED);
endfunction
```

⚠️ No DUT changes
⚠️ No driver changes
⚠️ Same sequences

---

## 5️⃣ Step-2: Assign priorities to sequences

In your **virtual sequence**:

```systemverilog
rand_s = random_seq::type_id::create("rand_s");
low_s  = dir_bin_seq::type_id::create("low_s");

rand_s.set_priority(100);   // HIGH priority
low_s.set_priority(10);     // LOW priority
```

Then run them **in parallel**:

```systemverilog
fork
  rand_s.start(p_sequencer);
  low_s.start(p_sequencer);
join
```

---

## 6️⃣ What you should observe (EXPECTED)

Logs will show:

* Random sequence **dominates traffic**
* Directed sequence **waits**
* No protocol break
* No assertion failure

This proves:

> Priority affects **sequencer grant**, not driver timing.

---

## 7️⃣ Starvation experiment (IMPORTANT)

Now push it:

```systemverilog
rand_s.set_priority(1000);
low_s.set_priority(1);
```

👉 Observe:

* `dir_bin_seq` may barely run
* Or never runs (starvation)

🎯 This is **real verification debugging knowledge**

---

## 8️⃣ Interview-level explanation (memorize this)

> “Parallel sequences compete at the sequencer.
> Arbitration mode and priority decide which sequence is granted.
> Driver always serializes traffic.
> Starvation is possible and must be controlled.”

If you say this — **you pass**.

---

## Day-28 Status

| Item                     | Status |
| ------------------------ | ------ |
| Arbitration concepts     | ✅      |
| Priority control         | ✅      |
| Starvation understanding | ✅      |
| No roadmap deviation     | ✅      |

---

### 🔜 Next (Day-29 – FINAL SEQUENCING TOPIC)

**Lock / Grab / Sequence Control (Advanced UVM)**
→ How to *force exclusive access* to DUT

When ready, say:

**“Proceed Day-29”**
