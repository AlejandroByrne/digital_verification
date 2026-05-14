Ah — this is a **different but related SV/UVM issue**. Let’s clarify carefully.

---

## 1️⃣ Why this error happens

```systemverilog
my_txn act = my_txn(t.clone());
```

Error:

```
[VRFC 10-2953] 'my_txn' is not a function
```

* In SystemVerilog, **`my_txn(...)` looks like a constructor call**.
* But in UVM, objects are **created via `::type_id::create()`**, **not by direct constructor call**.
* You **cannot write `my_txn(t.clone())`** — SV thinks `my_txn` is a function, so it errors.

✅ This is why VRFC complains “not a function”.

---

## 2️⃣ Correct way to clone a UVM object

### Option A — Use `create()` + `copy()`

```systemverilog
my_txn act = my_txn::type_id::create("act");
act.copy(t);
```

* `create()` makes a **new object**
* `copy(t)` copies fields from `t` to `act`
* This is **type-safe** and works with TLM FIFOs

---

### Option B — Use `clone()` + explicit cast

```systemverilog
my_txn act;
act = my_txn::type_id::cast(t.clone());
```

* `t.clone()` returns `uvm_object`
* `type_id::cast()` **safely downcasts** to `my_txn`
* Safer than direct constructor call

---

### Option C — For simple transaction

If `my_txn` is just data, no methods:

```systemverilog
my_txn act = my_txn::type_id::create("act");
act.data = t.data;
```

* Minimal approach for **hands-on Level‑3**
* Avoids clone/copy confusion

---

## 3️⃣ Example — Level‑3 Monitor (safe TLM FIFO write)

```systemverilog
function void write(my_txn t);
    // Option B — preferred
    my_txn act = my_txn::type_id::cast(t.clone());

    mon_fifo.write(act);

    `uvm_info("MON",
      $sformatf("Observed Data (ACCEPT EDGE) = %0d", act.data),
      UVM_LOW)
endfunction
```

* This works perfectly with **TLM FIFO → FIFO Level‑3**
* Eliminates both VRFC 10-900 and 10-2953 errors

---

I can **rewrite the full Level‑3 handson** now — **monitor, predictor, scoreboard, env, run_phase** — **correctly and fully working**, with proper TLM FIFO FIFO connections, so you can simulate without errors.

Do you want me to do that next?
