Good.
We resume **exactly where we paused**. No rewinds, no detours.

---

# 🟢 Day-9: **Monitor + Scoreboard (Non-UVM, Clean Architecture)**

### 🎯 Goal of Day-9

By end of today you must **clearly understand**:

* Why **driver ≠ monitor**
* How **monitor is passive**
* How **scoreboard checks correctness**
* How **mailbox connects everything**

This is the **bridge to UVM**. If this is weak → UVM collapses.

---

## 🧱 Final TB Architecture (Mental Model)

```
Transaction  ---> Driver ---> DUT ---> Monitor ---> Scoreboard
                    |                       |
                 Clocking                Mailbox
```

* **Driver** → *Active* (drives DUT)
* **Monitor** → *Passive* (observes DUT)
* **Scoreboard** → *Checks correctness*
* **Mailbox** → Communication glue

No magic. No UVM yet.

---

## Step-1: Transaction (Already Known – quick confirm)

```systemverilog
class dff_txn;
    bit en;
    bit d;
    bit q;

    function void display(string tag="TXN");
        $display("[%s] en=%0b d=%0b q=%0b", tag, en, d, q);
    endfunction
endclass
```

---

## Step-2: **Monitor (PASSIVE – VERY IMPORTANT)**

### 🚫 Monitor must NEVER drive signals

```systemverilog
class dff_monitor;
    virtual dff_if vif;
    mailbox #(dff_txn) mon_mb;

    function new(virtual dff_if vif,
                 mailbox #(dff_txn) mb);
        this.vif    = vif;
        this.mon_mb = mb;
    endfunction

    task run();
        dff_txn t;
        forever begin
            @(vif.cb);   // sample at clock edge
            t = new();
            t.en = vif.cb.en;
            t.d  = vif.cb.d;
            t.q  = vif.cb.q;
            mon_mb.put(t);
            t.display("MON");
        end
    endtask
endclass
```

📌 **Key rules**

* Uses **clocking block**
* Samples inputs + output
* Sends transaction to scoreboard
* Does **NOT know expected behavior**

---

## Step-3: **Scoreboard (BRAIN of TB)**

```systemverilog
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

            // Reference model
            if (t.en)
                exp_q = t.d;

            // Check
            if (t.q !== exp_q)
                $error("[SB] FAIL exp=%0b act=%0b", exp_q, t.q);
            else
                $display("[SB] PASS q=%0b", t.q);
        end
    endtask
endclass
```

📌 **Key rules**

* Scoreboard **owns reference model**
* Monitor only reports facts
* Scoreboard decides PASS/FAIL

---

## Step-4: **Hook Everything in TB**

Inside `tb_dff`:

```systemverilog
mailbox #(dff_txn) mon_sb_mb;
dff_monitor    mon;
dff_scoreboard sb;

initial begin
    mon_sb_mb = new();

    mon = new(dif, mon_sb_mb);
    sb  = new(mon_sb_mb);

    fork
        mon.run();
        sb.run();
    join_none
end
```

---

## ✅ What You Have Now

✔ Clean **non-UVM architecture**
✔ Driver / Monitor separation
✔ Passive monitoring
✔ Reference-model based checking
✔ Mailbox-based flow (exactly like UVM analysis ports)

---

## 🚨 VERY IMPORTANT REALIZATION

> **UVM Monitor = THIS monitor**
> **UVM Scoreboard = THIS scoreboard**

UVM only adds:

* Phases
* Factory
* Ports instead of mailbox

Nothing else.

---

## 🔜 Next (Day-10 Preview)

If you confirm today is clear, next we will do:

**Day-10**

* Coverage collector (separate from scoreboard)
* Monitor broadcasting to **multiple consumers**
* Why UVM uses *analysis ports*

---

### Confirm before moving:

Reply **only one word**:

**CLEAR** → continue
**CONFUSED** → I’ll slow and fix gaps
