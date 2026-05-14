Excellent choice 👍
I’ll give you **Day-3 interview questions strictly based on the testbench YOU wrote** — this is exactly how real interviews feel.

I’ll split them into **Basic, Core, and Trap questions**, and for each I’ll also tell you **what the interviewer is really checking**.

---

# 🔹 DAY-3 INTERVIEW QUESTIONS (BASED ON YOUR TB)

---

## 🟢 BASIC (Warm-up)

### Q1. Why does your testbench have **no ports**?

**Expected answer:**

> A testbench is the top-level module and does not interface with external hardware, so it should not expose ports.

**What interviewer checks:**
TB vs DUT separation.

---

### Q2. Why did you use `logic` instead of `wire`?

**Expected answer:**

> `logic` can be driven by procedural blocks, which is required in testbenches and sequential logic.

---

### Q3. Why is the clock generated using `always #5 clk = ~clk;`?

**Expected answer:**

> To create a free-running clock that continuously consumes simulation time.

---

## 🟡 CORE (Main Evaluation)

### Q4. Why does your `drive_ip` task contain `@(posedge clk)`?

**Expected answer:**

> To ensure stimulus is applied synchronously and consumes time, otherwise all transactions would occur at time 0.

**Red-flag answer:**

> “Just to wait.”

---

### Q5. What happens if you remove `@(posedge clk)` from the stimulus task?

**Expected answer:**

> All input updates occur in zero time, the DUT never samples them correctly, and the test becomes invalid.

---

### Q6. Why did you use **blocking assignments (`=`)** in the testbench?

**Expected answer:**

> Testbenches are procedural and sequential; blocking assignments give deterministic execution order.

---

### Q7. Why does the DUT use **non-blocking assignments (`<=`)**?

**Expected answer:**

> To model real sequential hardware and avoid race conditions.

---

### Q8. Why is `exp_q` updated in a separate `always` block?

**Expected answer:**

> It acts as a reference model (golden model) to independently predict expected behavior.

---

### Q9. Why did you use `!==` instead of `!=` in the checker?

**Expected answer:**

> `!==` detects X/Z mismatches, which are critical in verification.

**This is a strong differentiator question.**

---

### Q10. Why did you use `fork…join`?

**Expected answer:**

> To allow stimulus and checking to run concurrently, mimicking real hardware behavior.

---

## 🔴 TRAP / DEPTH QUESTIONS (Very Important)

### Q11. Why doesn’t the checker run inside the stimulus task?

**Expected answer:**

> Stimulus and checking should be decoupled to avoid race conditions and to allow parallel execution.

---

### Q12. What race condition would occur if both stimulus and checker were in the same `always` block?

**Expected answer:**

> The checker might sample outputs before the DUT updates them on the clock edge.

---

### Q13. Why does the checker wait on `@(posedge clk)` instead of using `#delay`?

**Expected answer:**

> Clock-based synchronization is deterministic and cycle-accurate; delays are fragile.

---

### Q14. What happens if reset is deasserted very close to a clock edge?

**Expected answer:**

> It may cause metastability in real hardware; in simulation, ordering depends on event scheduling.

(Shows real hardware awareness.)

---

### Q15. How would you extend this testbench to test **multiple scenarios**?

**Expected answer:**

> By parameterizing tasks, adding loops, and later using constrained randomization.

---

## 🟣 ADVANCED (OPTIONAL BUT IMPRESSIVE)

### Q16. How does this TB map to UVM components?

**Expected answer:**

> `drive_ip` → driver
> checker task → monitor/scoreboard
> fork…join → parallel sequences

---

### Q17. How would you add a timeout to avoid hanging simulation?

**Expected answer:**

> Use a parallel watchdog thread inside `fork…join` that calls `$fatal` after a fixed number of cycles.

---

### Q18. How would you make this TB reusable?

**Expected answer:**

> Convert tasks into class-based components or parameterize timing and widths.

---

## 🔑 ONE-LINE ANSWERS YOU SHOULD MEMORIZE

* **TB has no ports**
* **Blocking in TB, non-blocking in DUT**
* **Tasks consume time**
* **Checker ≠ waveform**
* **Reference model is mandatory**
* **fork…join enables concurrency**

If you can say these confidently, you’re **interview-ready for Day-3 topics**.

---

## 🟢 What This Means for You

Based on your TB and your questions:

* You are **already at junior-to-mid verification level**
* Your age or gap is **not a technical disadvantage**
* You just need consistency + Day-4 & Day-5 topics

---

### Next step (your choice):

* **“Day-3 done — start Day-4 constrained randomization”**
* **“Give mock interview: you ask, I answer”**

You’re doing excellent work — keep this momentum 🔥
