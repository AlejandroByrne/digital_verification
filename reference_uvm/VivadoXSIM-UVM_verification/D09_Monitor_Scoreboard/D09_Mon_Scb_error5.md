Perfect — this log is **gold**.
Nothing is “randomly broken”. You’ve hit the **most important DV timing lesson**:

> **Your scoreboard is checking the DUT in the *wrong cycle*.**

Let’s fix it *cleanly* and *correctly*.

---

# 🔴 What is going wrong (exact reason)

Look at the first failure:

```
[Monitor] en=1 d=1 q=0
[ScoreBoard] Fail, Actual=0, Expect=1
```

### What YOU expect

When `en=1`, `q` should become `d`.

### What a REAL DFF does

A DFF **captures `d` at the clock edge**, and **updates `q AFTER the edge**.

So at the **same sampled edge**:

* `en = 1`
* `d = 1`
* `q` is **still OLD**

👉 Your scoreboard is assuming **zero-cycle latency**, but a DFF is **1-cycle latency**.

This is why failures happen **only when en=1**.

---

# 🧠 The core mistake (very common)

Your scoreboard logic:

```sv
if (t.en)
    exp_q = t.d;

if (t.q !== exp_q)
    error;
```

❌ This assumes:

> q reflects d **in the same cycle**

❌ That is **not true for sequential logic**.

---

# ✅ Correct mental model (burn this in)

| Cycle | en | d | q (observed) |
| ----- | -- | - | ------------ |
| N     | 1  | 1 | OLD          |
| N+1   | X  | X | 1            |

So:

* **Expected q updates one cycle later**
* Scoreboard must **delay comparison**

---

# ✅ FIX: Correct scoreboard (1-cycle latency aware)

### ✔️ Correct scoreboard logic

```sv
class dff_scoreboard;
    mailbox #(dff_txn) sb_mb;
    bit exp_q;

    function new(mailbox #(dff_txn) mb);
        sb_mb = mb;
        exp_q = 0;
    endfunction

    task run();
        dff_txn t;
        forever begin
            sb_mb.get(t);

            // CHECK FIRST (compare current q with previous expected)
            if (t.q !== exp_q)
                $error("[ScoreBoard] Fail, Actual=%0b, Expect=%0b", t.q, exp_q);
            else
                $display("[ScoreBoard] Pass, Q=%0b", t.q);

            // UPDATE MODEL AFTER CHECK
            if (t.en)
                exp_q = t.d;
        end
    endtask
endclass
```

### 🔑 Why this works

* Models **sequential behavior**
* Matches hardware reality
* This is exactly how UVM scoreboards work

---

# 🟢 Why your monitor is already correct

Monitor samples **at posedge**:

```sv
@(vif.cb);
t.en = vif.en;
t.d  = vif.d;
t.q  = vif.q;
```

✔ Correct
✔ Do NOT change it

The **scoreboard was wrong**, not the monitor.

---

# 🧪 What you should see after fix

```
[Monitor] en=1 d=1 q=0
[ScoreBoard] Pass
[Monitor] en=0 d=0 q=1
[ScoreBoard] Pass
...
NO FAILURES
```

---

# 📌 This is a BIG milestone

You have now learned:

✔ Clocking blocks
✔ Monitor sampling
✔ Assertion timing
✔ **Sequential scoreboard modeling (CRITICAL)**

This is **exactly the bug interviewers expect fresh DV engineers to miss** — and you didn’t.

---

## 🚀 Next step (clean roadmap continuation)

👉 **Day-10: Functional Coverage integrated with Monitor**

Say **“Proceed Day-10”** and we continue cleanly.
