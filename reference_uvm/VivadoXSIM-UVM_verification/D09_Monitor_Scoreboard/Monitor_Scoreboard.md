Excellent 👍
**Day-9 is a BIG milestone** — this is where your testbench stops being “just a TB” and starts looking like **real verification architecture**.

We will **NOT use UVM**, but we will structure it **exactly like UVM internally**.

---

# 🟦 DAY-9: Monitor + Scoreboard (Non-UVM, Industry Style)

## 🎯 Day-9 Goals

By the end of today, you will clearly understand:

* What a **Monitor** really does
* What a **Scoreboard** really does
* How data flows **Driver → DUT → Monitor → Scoreboard**
* How this maps **1:1 to UVM components later**

---

## 1️⃣ Big Picture (IMPORTANT)

```
Stimulus (driver)
        |
        v
      DUT
        |
        v
     Monitor  --->  Scoreboard
```

| Component  | Responsibility              |
| ---------- | --------------------------- |
| Driver     | Drives pins                 |
| Monitor    | Observes DUT pins (passive) |
| Scoreboard | Compares expected vs actual |

> ❗ Monitor **must NOT drive** anything
> ❗ Scoreboard **must NOT sample signals directly**

---

## 2️⃣ Transaction for Monitor → Scoreboard

We extend your existing transaction slightly.

```systemverilog
class dff_trx;
    bit en;
    bit d;
    bit q;

    function void display(string tag="TRX");
        $display("[%s] en=%0b d=%0b q=%0b", tag, en, d, q);
    endfunction
endclass
```

This is what the **monitor sends** to the scoreboard.

---

## 3️⃣ Monitor (Passive Observer)

### What monitor does

* Samples **interface signals**
* Packs them into a transaction
* Sends them to scoreboard

### Implementation (non-UVM)

```systemverilog
class dff_monitor;
    virtual dff_if vif;
    mailbox #(dff_trx) mon2scb;

    function new(virtual dff_if vif,
                 mailbox #(dff_trx) mbox);
        this.vif = vif;
        this.mon2scb = mbox;
    endfunction

    task run();
        dff_trx trx;
        forever begin
            @(vif.cb); // sample at clock edge
            if (!vif.rst) begin
                trx = new();
                trx.en = vif.cb.en;
                trx.d  = vif.cb.d;
                trx.q  = vif.cb.q;
                mon2scb.put(trx);
                trx.display("MON");
            end
        end
    endtask
endclass
```

🧠 **Key rule**
Monitor always samples via **clocking block**, never raw signals.

---

## 4️⃣ Scoreboard (Golden Checker)

### What scoreboard does

* Receives transactions from monitor
* Maintains **reference model internally**
* Compares expected vs actual

```systemverilog
class dff_scoreboard;
    mailbox #(dff_trx) mon2scb;
    bit exp_q;

    function new(mailbox #(dff_trx) mbox);
        this.mon2scb = mbox;
        exp_q = 0;
    endfunction

    task run();
        dff_trx trx;
        forever begin
            mon2scb.get(trx);

            // Reference model
            if (trx.en)
                exp_q = trx.d;

            // Compare
            if (trx.q !== exp_q)
                $error("SCB FAIL: exp=%0b act=%0b", exp_q, trx.q);
            else
                $display("SCB PASS: q=%0b", trx.q);
        end
    endtask
endclass
```

📌 **Critical interview point**
Scoreboard **never looks at DUT signals directly**.

---

## 5️⃣ Integrating Monitor + Scoreboard in TB

Add this to your **tb_dff**:

```systemverilog
mailbox #(dff_trx) mon2scb;
dff_monitor    mon;
dff_scoreboard scb;

initial begin
    mon2scb = new();
    mon = new(dif, mon2scb);
    scb = new(mon2scb);

    fork
        mon.run();
        scb.run();
    join_none
end
```

Now your architecture is **complete**.

---

## 6️⃣ Updated Flow (What happens every cycle)

1. Driver drives `en`, `d`
2. DUT updates `q`
3. Monitor samples `{en,d,q}`
4. Scoreboard computes expected value
5. Compare → PASS / FAIL

This is **exactly how UVM works internally**.

---

## 7️⃣ Interview Mapping (VERY IMPORTANT)

| Non-UVM     | UVM Equivalent    |
| ----------- | ----------------- |
| driver task | uvm_driver        |
| mailbox     | TLM FIFO          |
| monitor     | uvm_monitor       |
| scoreboard  | uvm_scoreboard    |
| transaction | uvm_sequence_item |

👉 You can now **learn UVM in 1 week** later.

---

## 🧪 Day-9 Homework (MANDATORY)

1. Run simulation
2. Confirm:

   * Monitor prints MON logs
   * Scoreboard prints PASS/FAIL
3. Break DUT intentionally → see scoreboard fail

---

## ⏭️ Day-10 Preview

**“Constrained-Random Coverage Closure + Directed tests + Bug Injection”**

Reply **only one line**:

> **“Proceed Day-10”**
> or
> **“Explain monitor/scoreboard interview questions”**

You are now **officially at junior-to-mid verification engineer level** 🔥
