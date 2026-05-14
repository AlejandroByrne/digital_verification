Perfect — this log is **actually a GOOD sign**.
Your environment is now *correct enough to catch real bugs*.
What you’re seeing is **not random**; it’s a **temporal alignment problem** (classic Day-9 pitfall).

Let’s break it cleanly.

---

# Why you see **ASSERTION FAIL + SCOREBOARD FAIL**

## 🔴 Root Cause (single sentence)

You are **checking hold and data update in the SAME cycle**, but a DFF updates **on the next clock edge**, while your assertion and scoreboard assume **zero-cycle latency**.

This is the most important DV timing lesson so far.

---

# 1️⃣ Why the ASSERTION fails

### Your assertion

```sv
property hold_when_en_low;
  @(cb) disable iff (rst)
    !en |-> (cb.q == $past(cb.q));
endproperty
```

### What actually happens

* `en` changes **in the same cycle**
* `q` changes **at the clock edge**
* `$past(cb.q)` refers to **previous sampling**
* Because of clocking block skew + drive timing,
  the assertion sometimes evaluates **before q is stable**

📌 Result → **False hold violation**

---

### ✅ Correct HOLD assertion (cycle-accurate)

```sv
property hold_when_en_low;
  @(cb) disable iff (rst)
    !cb.en |=> (cb.q == $past(cb.q));
endproperty
```

🔑 **Key fix**

* `|=>` = *next cycle implication*
* Hold must be verified **one cycle later**

---

# 2️⃣ Why SCOREBOARD fails (this one is subtle)

### Failing log

```
[Monitor] en=1 d=1 q=0
[ScoreBoard] Fail, Actual=0, Expect=1
```

### Your scoreboard logic

```sv
if (t.en)
    exp_q = t.d;

if (t.q !== exp_q)
    $error(...)
```

### What’s wrong?

You assume:

> If en=1, q updates immediately

But **DFF updates on NEXT clock**, not same one.

So your scoreboard is **1 cycle early**.

---

### ✅ Correct reference model (cycle-accurate)

```sv
bit prev_en;
bit prev_d;

task run();
  dff_txn t;
  forever begin
    sb_mb.get(t);

    if (prev_en)
      exp_q = prev_d;

    if (t.q !== exp_q)
      $error("[ScoreBoard] Fail, Actual=%0b, Expect=%0b", t.q, exp_q);
    else
      $display("[ScoreBoard] Pass, Q=%0b", t.q);

    prev_en = t.en;
    prev_d  = t.d;
  end
endtask
```

📌 **Golden DV Rule**

> Scoreboard must model **sequential latency**

---

# 3️⃣ Why BOTH fail at same timestamps (55ns, 75ns, 115ns)

That’s **GOOD NEWS**.

It means:

* Monitor is sampling correctly
* Driver is aligned
* Assertion is active
* Scoreboard is meaningful

Your testbench is **finally deterministic**.

---

# 4️⃣ One more CRITICAL fix (monitor sampling)

You already fixed this — confirming correctness:

```sv
@(vif.cb);
t.en = vif.cb.en;
t.d  = vif.cb.d;
t.q  = vif.cb.q;
```

✅ Correct
❌ Never sample `vif.en` directly again

---

# ✅ After fixes — EXPECTED RESULT

* ❌ No assertion failures
* ❌ No scoreboard fails
* ✔ Only real DUT bugs will fail
* ✔ Randomization works
* ✔ Hold behavior verified correctly

---

# 🎯 Where you are in roadmap (important)

You have now **TRULY completed Day-9**:

✔ Clocking blocks
✔ Temporal assertions
✔ Cycle-accurate scoreboard
✔ Monitor/driver alignment
✔ Mailbox-based architecture

Most people never reach this level.

---

## 🔥 Next step (pick ONE)

**Day-10 options**
1️⃣ Functional coverage (covergroups from monitor)
2️⃣ Inject a DUT bug → prove assertion + scoreboard catch it

Say **1 or 2** — we move forward cleanly.
