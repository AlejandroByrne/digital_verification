Good catch — this is a **classic clocking block mistake**, and it’s actually a **very good learning point** 👍
You do **NOT** need to change simulator. xsim is behaving correctly.

---

## ❌ Why this error happened

```
clocking block output signal 'en' cannot be read
```

In SystemVerilog:

👉 **Clocking block directions are STRICT**

| Direction | Meaning                           |
| --------- | --------------------------------- |
| `output`  | Driven by TB → **cannot be read** |
| `input`   | Sampled from DUT → **read-only**  |
| `inout`   | Can be read & written             |

Your **monitor is trying to READ**:

```sv
tx.en = vif.cb.en;   // ❌ illegal if en is declared output
```

But your clocking block probably looks like this:

```sv
clocking cb @(posedge clk);
  output en;
  output d;
  input  q;
endclocking
```

That is **correct for DRIVER**, but **wrong for MONITOR**.

---

## ✅ Correct, industry-standard solution

### 🔑 Rule (memorize this)

> **Clocking block direction is from TB point of view**

So:

* Signals TB **drives** → `output`
* Signals TB **samples** → `input`

### Since Monitor *samples* en & d → they must be `input`

---

## ✅ FIXED `dff_if` (THIS IS THE KEY)

```systemverilog
interface dff_if (input logic clk);
  logic rst;
  logic en;
  logic d;
  logic q;

  // TB clocking block
  clocking cb @(posedge clk);
    input  en;   // 👈 monitor reads
    input  d;    // 👈 monitor reads
    input  q;    // 👈 monitor reads
    output rst;  // 👈 TB drives reset
  endclocking

  // DUT modport
  modport DUT (
    input  clk,
    input  rst,
    input  en,
    input  d,
    output q
  );
endinterface
```

---

## 🔧 Driver fix (important)

Since `en` and `d` are now **inputs** in clocking block, driver **must write via interface signals**, not cb.

### ✅ Correct Driver

```systemverilog
class dff_driver;
  virtual dff_if vif;

  function new(virtual dff_if vif);
    this.vif = vif;
  endfunction

  task drive(dff_txn tx);
    vif.en <= tx.en;
    vif.d  <= tx.d;
    @(posedge vif.clk);
  endtask
endclass
```

📌 **Golden rule**

> Clocking block is for *timing & sampling*, not mandatory for driving

---

## ✅ Monitor now becomes VALID

```sv
tx.en = vif.cb.en;   // OK
tx.d  = vif.cb.d;    // OK
tx.q  = vif.cb.q;    // OK
```

---

## 🧠 Interview-grade understanding (VERY IMPORTANT)

If interviewer asks:

> “Why can’t you read output clocking signals?”

Answer:

> “Clocking block directions are from TB perspective.
> `output` means TB drives, so simulator prevents reads to avoid race conditions.”

This answer = **senior-level**

---

## ✅ What to do NOW

1. **Fix `dff_if` as shown**
2. **Update driver to write via `vif.en` / `vif.d`**
3. Re-run:

   ```
   xvlog --sv *.sv
   xelab tb_dff
   xsim tb_dff
   ```

---

## ✅ Status check

✔ Roadmap intact
✔ Monitor + Scoreboard correct
✔ No topic skipped
✔ No restart needed

When this runs clean, reply with:
👉 **“Day-9 working”**

Then we move to **Day-10 (Coverage Collector + UVM mapping)** exactly as planned.
