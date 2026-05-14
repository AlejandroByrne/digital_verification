
## 🧠 Xsim Commands

XSIM has **3 distinct stages**:

1. **Compile** → `xvlog`
2. **Elaborate (create snapshot)** → `xelab`
3. **Simulate** → `xsim`

You did **step 1**, but **skipped step 2**.

So `xsim` looks for:

```
xsim.dir/work.tb_random/xsimk.exe
```

…but it doesn’t exist because **`xelab` was never run**.

---

## ✅ TWO CORRECT WAYS (Choose ONE)

---

## ✅ OPTION 1 (RECOMMENDED for learning): Explicit 3-step flow

### Step 1: Compile (SystemVerilog mode)

```bash
xvlog -sv tb_random.sv
```

### Step 2: Elaborate (THIS CREATES THE SNAPSHOT)

```bash
xelab work.tb_random
```

👉 This creates:

```
xsim.dir/work.tb_random/xsimk.exe
```

### Step 3: Run simulation

```bash
xsim work.tb_random -R
```

✔️ This is **industry-correct mental model**
✔️ Best for debugging later

---

## ✅ OPTION 2 (Quick run): Let xsim do it automatically

```bash
xvlog -sv tb_random.sv
xsim work.tb_random -R
```

Here, `-R` internally runs **xelab + xsim**.

✔️ Faster
❌ Less explicit (not ideal while learning)

---

## 🔥 IMPORTANT RULE (MEMORIZE)

| Tool    | Purpose        |
| ------- | -------------- |
| `xvlog` | Compile        |
| `xelab` | Build snapshot |
| `xsim`  | Run snapshot   |

If snapshot error appears → **`xelab` missing**

---

## ✅ What you should do NOW

Run **this exact sequence** (copy–paste):

```bash
xvlog -sv tb_random.sv
xelab work.tb_random
xsim work.tb_random -R
```

You should see `$display` output from your testbench in terminal.

---
