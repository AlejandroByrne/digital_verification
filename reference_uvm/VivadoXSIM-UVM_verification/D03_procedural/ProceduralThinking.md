
**Day-3 is a critical day** — this is where you stop writing “student testbenches” and start writing **industry-grade verification code**.

---

# 📘 DAY-3 — PROCEDURAL THINKING FOR VERIFICATION

## 🎯 Day-3 Goal

By the end of Day-3, you should be able to:

* Control **time and concurrency** in a testbench
* Choose **blocking vs non-blocking** correctly
* Write **reusable tasks & functions**
* Run **parallel stimulus**
* Build **self-checking logic**

Still **NO UVM**.
But your code will already **look like UVM under the hood**.

---

## 1️⃣ `initial` vs `always`

### `initial`

* Runs **once**
* Starts at time 0
* Used for:

  * Stimulus
  * Reset
  * Test sequences

```systemverilog
initial begin
  reset = 1;
  #10 reset = 0;
end
```

✔ Most testbench stimulus lives here.

---

### `always`

* Runs **forever**
* Used for:

  * Clocks
  * Monitors
  * Repeating behavior

```systemverilog
always #5 clk = ~clk;
```

---

### 🔑 Industry Rule

| Use case              | Block     |
| --------------------- | --------- |
| Clock generation      | `always`  |
| Reset & stimulus      | `initial` |
| One-time setup        | `initial` |
| Continuous monitoring | `always`  |

---

## 2️⃣ Blocking vs Non-Blocking (VERY IMPORTANT)

### Blocking (`=`)

```systemverilog
a = 1;
b = a;
```

* Executes **sequentially**
* Used in:

  * Testbenches
  * Tasks
  * Functions
  * Scoreboards

---

### Non-Blocking (`<=`)

```systemverilog
q <= d;
```

* Scheduled update
* Used in:

  * Sequential RTL (`always_ff`)

---

### 🔑 Golden Industry Rule

> **TB → Blocking (`=`)**
> **DUT → Non-blocking (`<=`)**

Using `<=` in testbench stimulus is a **red flag** in interviews.

---

## 3️⃣ Tasks vs Functions (INTERVIEW FAVORITE)

### 🔹 Function

* Returns a value
* **No timing** (`#`, `@` not allowed)
* Used for:

  * Calculations
  * Predictions
  * Scoreboard reference model

```systemverilog
function int add(int a, int b);
  return a + b;
endfunction
```

---

### 🔹 Task

* No return value
* **Timing allowed**
* Used for:

  * Driving signals
  * Waiting for events
  * Complex stimulus

```systemverilog
task drive(input logic d);
  data = d;
  #10;
endtask
```

---

### 🔑 Interview One-Liner

> “Functions are for computation without time, tasks are for actions that consume time.”

---

## 4️⃣ `fork…join` — Parallel Stimulus

Verification requires **concurrency**.

### Example

```systemverilog
fork
  drive_data();
  monitor_output();
join
```

### Variants

* `fork…join` → wait for all
* `fork…join_any` → wait for one
* `fork…join_none` → don’t wait

---

### Industry Usage

* Parallel drivers
* Timeout watchdogs
* Concurrent stimulus & checking

---

## 5️⃣ Passing Arguments (input / output / ref)

### `input`

* Read-only

### `output`

* Write back value

### `ref` (IMPORTANT)

* Pass by reference
* Directly modifies original variable

```systemverilog
task incr(ref int count);
  count++;
endtask
```

✔ Very useful in scoreboards and counters.

---

## 6️⃣ Writing Reusable Checkers (CORE VERIFICATION SKILL)

### ❌ Bad style (manual checking)

```systemverilog
if (y != expected)
  $display("ERROR");
```

---

### ✅ Industry style — Checker Task

```systemverilog
task check(
  input logic actual,
  input logic expected,
  input string msg
);
  if (actual !== expected)
    $error("FAIL: %s exp=%0b got=%0b", msg, expected, actual);
  else
    $display("PASS: %s", msg);
endtask
```

✔ Reusable
✔ Scalable
✔ Self-checking

---

## ✍️ Day-3 Hands-On (MANDATORY)

Create folder:

```bash
day3_procedural_tb/
```

### Task-1: Clock & Reset

* Generate clock using `always`
* Apply reset in `initial`

### Task-2: Stimulus Task

* Write a task to drive DUT inputs

### Task-3: Checker Function/Task

* Write checker for DUT output

### Task-4: Parallel Execution

* Use `fork…join` to:

  * Drive stimulus
  * Monitor output

🎯 Goal: **No manual waveform checking**

---

## 📚 High-Quality References (Selective)

### 📘 Doulos (Clear & Industry-Focused)

* Tasks & Functions
  👉 [https://www.doulos.com/knowhow/systemverilog/systemverilog-tasks-and-functions/](https://www.doulos.com/knowhow/systemverilog/systemverilog-tasks-and-functions/)

* fork/join
  👉 [https://www.doulos.com/knowhow/systemverilog/systemverilog-fork-join/](https://www.doulos.com/knowhow/systemverilog/systemverilog-fork-join/)

---

## ❌ Do NOT Do Today

* No classes
* No randomization
* No mailboxes yet
* No UVM

---

## ✅ Day-3 Completion Checklist

You should confidently explain:

* Why TB uses blocking assignments
* When to use task vs function
* How `fork…join_any` differs from `join`
* Why reusable checkers matter

---

## 🔜 Day-4 Preview

**Constrained Randomization**

* `rand`
* `constraint`
* `inside`
* Random stability & reproducibility

This is where verification becomes **powerful and scalable**.
