Good — that’s **exactly the right thing to do** 👍
Now let’s interpret the behavior **correctly** (this is subtle but important).

---

## What your code guarantees (and what it does NOT)

```systemverilog
vseqr.set_arbitration(UVM_SEQ_ARB_WEIGHTED);
```

✅ This means:

* **When multiple sequences request the sequencer at the same time**,
  the one with **higher priority weight is MORE LIKELY to win**.

❌ This does **NOT** mean:

* High-priority sequence will **block** low-priority one
* Low-priority sequence will **never run**
* High-priority sequence owns the sequencer for its entire lifetime

---

## Why you still see interleaving (EXPECTED & CORRECT)

Key rule (very important):

> **Arbitration happens per item, not per sequence.**

What’s happening internally:

1. `rand_s` and `low_s` are both started in **parallel**
2. Both call `start_item()` repeatedly
3. For **each item**, arbitration occurs
4. Weighted arbitration:

   * High priority → **more chances**
   * Low priority → **still allowed**

So output like:

```
rand → rand → low → rand → low
```

is **100% correct** behavior.

If low priority *never* ran → **that would be a bug**.

---

## How to prove priority is actually working (important check)

Add prints:

```systemverilog
rand_s.set_priority(100);
low_s.set_priority(10);

`uvm_info("PRIO", $sformatf("rand=%0d low=%0d",
           rand_s.get_priority(), low_s.get_priority()), UVM_MEDIUM)
```

Run multiple times with random seed → you’ll observe:

* **rand_s dominates statistically**
* low_s still makes progress

That’s **correct arbitration fairness**.

---

## If your expectation was:

> “High priority must completely suppress low priority”

Then the **tool** is correct and the **expectation is wrong**.

For that behavior you need:

### 🔒 Day-29 Topic (Next)

```systemverilog
rand_s.lock(seqr);
// or
rand_s.grab(seqr);
```

This gives **exclusive control**.

---

## Interview-level summary (remember this line)

> **Arbitration decides *who goes next*, not *who owns the sequencer*.**
> Priority ≠ exclusivity.

You’ve implemented **Day-28 perfectly** ✅
Next day is **exactly** where exclusivity is covered.

👉 **Proceed Day-29: lock / grab / preemption**
