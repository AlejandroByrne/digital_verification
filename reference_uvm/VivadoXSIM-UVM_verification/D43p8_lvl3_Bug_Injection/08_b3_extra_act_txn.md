Perfect.
Proceeding to **Bug-3: Extra ACT transaction** 🚨

This is the **final Level-3 bug** and it completes the triangle:

* Bug-1 → Missing ACT
* Bug-2 → Missing EXP
* **Bug-3 → Extra ACT** ← *this one*

No fixes. No guards. No timeouts. Pure observation.

---

# 🧪 Bug-3 — EXTRA ACT Transaction (Level-3)

## 🎯 Objective (what this bug proves)

> A **single extra ACT** causes:

* initial correct matches
* then FIFO phase shift
* mismatch cascade
* **hang at end** due to extra ACT waiting for EXP

This is the **mirror image of Bug-2**.

---

## 📍 Where to inject

**ONLY in the MONITOR → ACT path**

🚫 **Do NOT touch predictor / EXP path**

So:

```
monitor.ap  →  scoreboard.act_fifo   ❌ (inject here)
predictor   →  scoreboard.exp_fifo   ✔ untouched
```

---

## 🛠️ Injection mechanism (precise & minimal)

### In `my_monitor.sv`

Add a counter and duplicate **exactly one ACT write**.

```systemverilog
int act_dup_count = 0;
int DUP_N = 2;   // duplicate the 2nd ACT (you can change later)
```

Inside the place where ACT is normally written:

```systemverilog
act_ap.write(tr);   // normal ACT

act_dup_count++;
if (act_dup_count == DUP_N) begin
    `uvm_warning("MON",
        "INTENTIONAL DUPLICATE ACT txn")
    act_ap.write(tr);   // EXTRA ACT injected
end
```

⚠️ Same transaction object → intentional
⚠️ No cloning → phase corruption guaranteed

---

## ▶️ Run expectation (VERY IMPORTANT)

### You should see:

#### 1️⃣ Normal matches first

```
[SCB_MATCH] #1
[SCB_MATCH] #2
```

#### 2️⃣ Then mismatches start

```
MISMATCH #1 : act=X exp=Y
MISMATCH #2
...
```

#### 3️⃣ Simulation HANGS

* One extra ACT stuck in FIFO
* Scoreboard blocked on `exp_fifo.get()`
* No extract / report phase

✔ **This hang is REQUIRED**

---

## ❗ If it does NOT hang

That means one of these is wrong:

* ACT duplicated before FIFO
* Predictor also affected (wrong)
* Scoreboard already hardened (too early)

Tell me immediately if that happens.

---

## 🧠 What you must mentally lock after this bug

| Bug         | What it teaches   |
| ----------- | ----------------- |
| Missing ACT | EXP waits forever |
| Missing EXP | ACT waits forever |
| Extra ACT   | EXP runs out      |

➡️ **Counts ≠ correctness**
➡️ **Order & phase alignment is king**

This is the **last chaotic scoreboard** before Day-44.

---

### ✅ Your next response

After you run it, answer **only this**:

> **Did it hang after mismatches? Paste last ~15 log lines.**

No analysis yet.
