Good. We continue **Day-9 exactly where we paused**
→ **Monitor + Scoreboard (non-UVM, clean, structured, no mess)**

I’ll be **very disciplined** now.

---

# 🔵 Day-9: Monitor + Scoreboard (NON-UVM)

### 🎯 Goal of Day-9

You must be able to answer **confidently in interviews**:

> “How do you build a self-checking testbench without UVM?”

---

## 0️⃣ Big Picture (VERY IMPORTANT)

Your TB will now have **5 clear roles**:

```
Transaction  →  Driver  →  DUT
                       ↘
                        Monitor → Scoreboard
```

| Component       | Responsibility                |
| --------------- | ----------------------------- |
| **Transaction** | Data container (already done) |
| **Driver**      | Drives pins                   |
| **Monitor**     | Observes DUT pins             |
| **Scoreboard**  | Compares expected vs actual   |
| **TB**          | Connects everything           |

⚠️ **Monitor NEVER drives**
⚠️ **Scoreboard NEVER touches DUT**

---

## 1️⃣ Transaction (already correct – reuse)

```systemverilog
class dff_txn;
  rand bit en;
  rand bit d;
       bit q;   // sampled output

  constraint valid_c {
    if (en == 0) d == 0;
  }

  function void display(string tag="");
    $display("[%s] en=%0b d=%0b q=%0b", tag, en, d, q);
  endfunction
endclass
```

✅ This is **perfect**
(No changes needed)

---

## 2️⃣ Monitor (MOST MISUNDERSTOOD — read carefully)

### What Monitor does

* Samples DUT signals
* Creates a transaction
* Sends it to Scoreboard via **mailbox**

### ❌ Monitor should NOT:

* Drive signals
* Predict expected values

---

### Monitor class

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
    dff_txn tx;
    forever begin
      @(vif.cb);   // sample at clocking block

      tx = new();
      tx.en = vif.cb.en;
      tx.d  = vif.cb.d;
      tx.q  = vif.cb.q;

      mon_mb.put(tx);
      tx.display("MON");
    end
  endtask
endclass
```

📌 **Key interview line**

> “Monitor uses virtual interface + mailbox to decouple sampling from checking.”

---

## 3️⃣ Scoreboard (Golden brain)

### What Scoreboard does

* Receives monitored transactions
* Computes **expected q**
* Compares expected vs actual

---

### Scoreboard class

```systemverilog
class dff_scoreboard;
  mailbox #(dff_txn) mon_mb;
  bit exp_q;

  function new(mailbox #(dff_txn) mb);
    this.mon_mb = mb;
    exp_q = 0;
  endfunction

  task run();
    dff_txn tx;
    forever begin
      mon_mb.get(tx);

      // Reference model
      if (tx.en)
        exp_q = tx.d;

      if (tx.q !== exp_q)
        $error("[SB] FAIL exp=%0b act=%0b", exp_q, tx.q);
      else
        $display("[SB] PASS q=%0b", tx.q);
    end
  endtask
endclass
```

📌 **Golden rule**

> Scoreboard = *reference model + comparison*

---

## 4️⃣ Driver (lightweight, already known)

```systemverilog
class dff_driver;
  virtual dff_if vif;

  function new(virtual dff_if vif);
    this.vif = vif;
  endfunction

  task drive(dff_txn tx);
    vif.cb.en <= tx.en;
    vif.cb.d  <= tx.d;
    @(vif.cb);
  endtask
endclass
```

---

## 5️⃣ Testbench Top (Glue logic)

```systemverilog
module tb_dff;
  logic clk;
  dff_if dif(clk);

  dff_driver     drv;
  dff_monitor    mon;
  dff_scoreboard sb;

  mailbox #(dff_txn) mon_mb;
  dff_txn tx;

  d_ff dut (dif.DUT);

  // Clock
  initial clk = 0;
  always #5 clk = ~clk;

  // Reset
  initial begin
    dif.rst <= 1;
    repeat (2) @(dif.cb);
    dif.rst <= 0;
  end

  initial begin
    mon_mb = new();

    drv = new(dif);
    mon = new(dif, mon_mb);
    sb  = new(mon_mb);

    fork
      mon.run();
      sb.run();
    join_none

    @(negedge dif.rst);

    repeat (10) begin
      tx = new();
      assert(tx.randomize());
      drv.drive(tx);
    end

    #20 $finish;
  end
endmodule
```

---

## 6️⃣ What you achieved (IMPORTANT)

You now know:

✅ How monitor samples DUT
✅ How scoreboard checks without touching DUT
✅ Mailbox-based decoupling
✅ **Non-UVM architecture identical to UVM conceptually**

This is **100% interview-valid**

---

## 7️⃣ Where we STOP today (as promised)

🚫 **NO UVM**
🚫 **NO coverage**
🚫 **NO agents**

We pause **after Monitor + Scoreboard** ✅

---

## Next (Day-10 – ONLY if you say go)

* Coverage collector (connected to monitor)
* Scoreboard corner cases
* “How this maps to UVM analysis ports”

Say **one word only**:
👉 **“Day-10”**
