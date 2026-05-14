
> ✅ **Confirm your simulator + waveform + SystemVerilog setup is working**

No UVM. No classes. No complexity.

---

# 🧪 BASIC SYSTEMVERILOG TESTBENCH (ENVIRONMENT CHECK)

## 🎯 Goal of This Testbench

By the end, you should confirm:

* `iverilog` compiles SystemVerilog
* `vvp` runs simulation
* `gtkwave` shows waveforms
* You understand **what each line does**

---

## 📁 Step 1: Create a Working Directory

In **Ubuntu (WSL)**:

```bash
mkdir -p ~/vlsi-verification/day1_env_check
cd ~/vlsi-verification/day1_env_check
```

---

## 🧩 Step 2: Write a Simple DUT (2:1 MUX)

Create file:

```bash
nano mux2.sv
```

Paste this **exact code**:

```systemverilog
// 2:1 Multiplexer DUT
module mux2 (
    input  logic a,
    input  logic b,
    input  logic sel,
    output logic y
);

    // Combinational logic
    always_comb begin
        if (sel)
            y = b;
        else
            y = a;
    end

endmodule
```

### Why this DUT?

* Pure combinational
* No clocks
* Easy to reason
* Ideal for environment test

---

## 🧪 Step 3: Write the Basic Testbench

Create file:

```bash
nano tb_mux2.sv
```

Paste:

```systemverilog
// Basic testbench to verify environment setup
module tb_mux2;

    // Testbench signals
    logic a;
    logic b;
    logic sel;
    logic y;

    // Instantiate DUT
    mux2 dut (
        .a   (a),
        .b   (b),
        .sel (sel),
        .y   (y)
    );

    // Initial block: apply stimulus
    initial begin
        // Create waveform dump
        $dumpfile("mux2.vcd");
        $dumpvars(0, tb_mux2);

        // Apply test vectors
        a = 0; b = 0; sel = 0; #10;
        a = 0; b = 1; sel = 0; #10;
        a = 1; b = 0; sel = 1; #10;
        a = 1; b = 1; sel = 1; #10;

        // End simulation
        $display("Environment check PASSED");
        $finish;
    end

endmodule
```

---

## ▶️ Step 4: Compile the Testbench

Run:

```bash
iverilog -g2012 tb_mux2.sv mux2.sv
```

### What this means

* `-g2012` → enable SystemVerilog
* No errors = ✅ syntax + simulator OK

---

## ▶️ Step 5: Run Simulation

```bash
vvp a.out
```

Expected output:

```
Environment check PASSED
```

---

## 📊 Step 6: View Waveforms

```bash
gtkwave mux2.vcd
```

### In GTKWave:

* Add signals: `a`, `b`, `sel`, `y`
* Verify:

  * `y = a` when `sel=0`
  * `y = b` when `sel=1`

🎯 If waveform matches logic → **environment is 100% working**

---

## 🧠 Important Concepts (Understand These NOW)

### 🔹 Why `logic`?

* Replaces `reg` + `wire`
* Safe for testbenches

### 🔹 Why `always_comb`?

* Automatically sensitive to RHS signals
* Prevents latch bugs
* Industry preferred

### 🔹 Why `$dumpfile / $dumpvars`?

* Generates waveform file
* Essential for debugging (verification life skill)

---

## ✅ Success Criteria (Tick All)

* [ ] Compiles without error
* [ ] Simulation runs
* [ ] GTKWave opens
* [ ] Output waveform is correct

If all checked → **Day-1 environment setup is DONE** 🎉

---

## 🔜 What Comes Next (Day-2 Preview)

Next we will:

* Add **self-checking**
* Introduce **`if`-based pass/fail**
* Move from *manual eyeballing* → *automated checking*

---

👉 **Do this now**.
After you finish, reply with:

> **“Basic testbench working”**

Then I’ll continue as your tutor to **Day-2**.
