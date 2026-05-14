Good catch 👍
This is **not a bug in your code** — it’s a **simulation behavior issue**.

Let’s fix it **cleanly**.

---

## 🔴 Why you are getting SAME values every run

XSIM uses a **fixed random seed by default**.

So:

* `pkt.randomize()` **is working**
* But the **seed is identical** every simulation run
* Hence → **same random values**

This is simulator behavior, not SV syntax.

---

## ✅ Correct & INDUSTRY way to fix this

### Option 1️⃣ — Set random seed from command line (BEST)

Run **xsim** like this:

```tcl
xsim a2_1 -R --sv_seed random
```

or explicitly:

```tcl
xsim a2_1 -R --sv_seed 12345
```

Each different seed → different values.

---

### Option 2️⃣ — Set seed inside testbench (OK for learning)

Modify `initial` block:

```systemverilog
initial begin
    int seed;
    seed = $urandom();
    $display("Seed = %0d", seed);
    std::randomize(seed);

    pkt = new();

    if (!pkt.randomize())
        $fatal("Randomization failed");

    pkt.display();

    #10 $finish;
end
```

⚠️ In **real projects**, seed is controlled from command line, not TB.

---

## 🧠 Important Concept (INTERVIEW GOLD)

> **Randomization is deterministic unless seed changes**

This allows:

* Bug reproducibility
* Regression control

Interview question:
❓ *“Why would you want same random values sometimes?”*
✔️ To reproduce failures.

---

## ✅ What I want you to do now

1️⃣ Re-run with:

```tcl
xsim a2_1 -R --sv_seed random
```

2️⃣ Confirm values change across runs

Reply with:

> **“Seed issue understood, A2.1 confirmed”**

Then we move to **A2.2 — Constructors (`new()` deep dive)**
