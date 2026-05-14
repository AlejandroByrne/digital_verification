Perfect.
We proceed **cleanly and correctly**.

---

# 📘 Day-10 — Functional Coverage (Monitor-based)

**Context:**
You already have a **correct driver → DUT → monitor → scoreboard** flow.
Now we **measure** whether meaningful scenarios actually happened.

> 🔑 **Assertions = correctness**
> 🔑 **Coverage = completeness**

They are **orthogonal**.

---

## 1️⃣ What we will cover (Day-10 scope)

We will add **functional coverage inside the Monitor** (industry standard).

### Coverage goals for DFF:

1. `en` values exercised
2. `d` values exercised
3. `en × d` combinations
4. Meaningful transitions:

   * `d: 0 → 1`, `1 → 0`
   * `en: 0 → 1`

❌ No UVM
❌ No phases
❌ No framework noise

---

## 2️⃣ Why coverage goes in the **Monitor**

| Component   | Role                         |
| ----------- | ---------------------------- |
| Driver      | Intent (what we tried)       |
| DUT         | Implementation               |
| **Monitor** | **What actually happened** ✅ |
| Scoreboard  | Correctness                  |
| Coverage    | Completeness                 |

👉 Coverage must observe **real DUT behavior**, not stimulus intent.

---

## 3️⃣ Add coverage to `dff_monitor`

### ✅ Updated `dff_monitor` (ONLY changes shown)

```systemverilog
class dff_monitor;
    virtual dff_if vif;
    mailbox #(dff_txn) mon_mb;

    // -----------------------------
    // Functional Coverage
    // -----------------------------
    covergroup dff_cg @(vif.cb);
        option.per_instance = 1;

        cp_en : coverpoint vif.en {
            bins en0 = {0};
            bins en1 = {1};
        }

        cp_d : coverpoint vif.d {
            bins d0 = {0};
            bins d1 = {1};
        }

        cp_en_d : cross cp_en, cp_d;

        cp_d_toggle : coverpoint vif.d {
            bins rise = (0 => 1);
            bins fall = (1 => 0);
        }
    endgroup

    dff_cg cg;

    function new(virtual dff_if vif,
                 mailbox #(dff_txn) mb);
        this.vif = vif;
        this.mon_mb = mb;
        cg = new();
    endfunction

    task run();
        dff_txn t;
        forever begin
            @(vif.cb);

            t = new();
            t.en = vif.en;
            t.d  = vif.d;
            t.q  = vif.q;

            t.display("Monitor");
            mon_mb.put(t);

            cg.sample();   // 👈 COVERAGE SAMPLE POINT
        end
    endtask
endclass
```

---

## 4️⃣ Why sampling on `@(vif.cb)` is CRITICAL

You used:

```systemverilog
clocking cb @(posedge clk);
```

So:

* Driver drives **before edge**
* DUT updates **on edge**
* Monitor samples **after edge**

✔ Race-free
✔ Deterministic
✔ Industry-correct

---

## 5️⃣ What coverage means for your sim

After simulation, run:

```tcl
report_coverage
```

You should see:

* `en = 0,1` covered
* `d = 0,1` covered
* `en × d` bins hit
* Toggle bins hit **only when en=1**

If toggles are missing → stimulus problem, **not DUT bug**.

---

## 6️⃣ Common beginner mistake (you avoided it)

❌ Sampling coverage in driver
❌ Sampling coverage using `@(posedge clk)` directly
❌ Expecting coverage to imply correctness

You did none of these. Good.

---

## 7️⃣ Interview-grade explanation (memorize)

> “Functional coverage is collected in the monitor because it observes the DUT’s actual behavior, while the driver only reflects stimulus intent.”

If you say this → **senior DV signal**.

---

## ✅ Day-10 Status

✔ Monitor-based functional coverage
✔ Coverpoints
✔ Cross coverage
✔ Transition coverage
✔ Correct sampling

---

## ▶️ Next step

### **Day-11: Assertions vs Coverage (Deep dive + fixes)**

We will:

* Fix your `hold_when_en_low` assertion properly
* Show why it was failing earlier
* Align assertion timing with clocking blocks

Say **“Proceed Day-11”** when ready.
