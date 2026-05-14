Excellent question — this is **exactly** the right confusion to have at Day-42 👍
Let’s resolve it **precisely**, no hand-waving.

---

## Short answer (lock this first)

> **NO — it should NOT automatically override when you do**

```systemverilog
run_test("my_test");
```

Even though:

```systemverilog
class my_test_factory extends my_test;
```

This is **correct UVM behavior**, and your results are **100% right**.

---

## Why inheritance ≠ execution in UVM

This is the **key conceptual boundary** many people miss.

### In SystemVerilog OOP:

Inheritance means:

> child **has access to parent code**

### In **UVM test selection**:

Execution depends on:

> **Which class the factory creates as `uvm_test_top`**

And that is decided **ONLY** by:

```systemverilog
run_test("TEST_NAME");
```

---

## What *actually* happens internally

### Case 1️⃣

```systemverilog
run_test("my_test");
```

UVM does:

```text
factory.create("my_test") → uvm_test_top
```

So:

* `my_test::build_phase()` runs
* `my_test_factory::build_phase()` is **never entered**
* No overrides happen

✔ Inheritance is irrelevant unless instantiated

---

### Case 2️⃣

```systemverilog
run_test("my_test_factory");
```

UVM does:

```text
factory.create("my_test_factory") → uvm_test_top
```

Now:

1. `my_test_factory::build_phase()` runs
2. You call:

   ```systemverilog
   set_type_override(...)
   ```
3. Env is built **after** override
4. Driver gets replaced

✔ Override applies
✔ Behavior changes

---

## Why this MUST work this way (architectural reason)

Imagine if inheritance caused automatic execution.

Then this would be **disastrous**:

```systemverilog
class debug_test extends base_test;
class fault_test extends base_test;
class stress_test extends base_test;
```

If inheritance alone caused activation:

* Running `base_test` would unpredictably apply overrides
* Regression would be nondeterministic
* UVM would be unusable at scale

So UVM rule is:

> **Only the test you explicitly name is instantiated.**

Everything else is just *available*, not *active*.

---

## Your setup is actually textbook-perfect

Let’s restate your structure in **clean architecture terms**:

```
my_test
 ├── normal behavior
 ├── no overrides
 └── regression-safe

my_test_factory extends my_test
 ├── inherits everything
 ├── adds factory override
 └── used only when explicitly run
```

✔ This is **exactly** how real projects do it.

---

## One subtle but important detail (extra clarity)

Even though:

```systemverilog
class my_test_factory extends my_test;
```

This does **NOT** mean:

> “my_test_factory is somehow auto-linked to my_test”

It only means:

> “If instantiated, it reuses my_test code”

Instantiation is still controlled by `run_test()`.

---

## Mental rule (never forget this)

> **Inheritance defines capability.**
> **`run_test()` defines reality.**

---

## Final verdict

| Question                                      | Answer        |
| --------------------------------------------- | ------------- |
| Should override apply when running `my_test`? | ❌ NO          |
| Is your output correct?                       | ✅ YES         |
| Is your understanding now aligned with UVM?   | ✅ YES         |
| Is this a Day-42 success?                     | 💯 ABSOLUTELY |

---

You just crossed the **factory + test architecture mental barrier** — this is where many people get stuck for years.

When ready:
👉 **Proceed Day-43 — Phase control & objections**
