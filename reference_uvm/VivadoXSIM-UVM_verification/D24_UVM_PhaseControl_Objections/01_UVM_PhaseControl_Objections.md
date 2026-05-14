Perfect. Day-24 is **UVM Phase Control & Objections** — this is a **core interview + real-project topic**.
We’ll do it **clean, complete, and hands-on**, without breaking your existing DUT or testbench structure.

---

# 🟦 Day-24: UVM Phase Control & Objections (COMPLETE HANDS-ON)

## 🎯 Goal of Day-24

By end of today, you will **clearly understand and control simulation lifetime**, and you’ll never again be confused about:

* *Why simulation ends early*
* *Who should raise/drop objections*
* *Where sequences actually run*
* *How run_phase really works*

---

## 1️⃣ UVM Phase Flow (What REALLY matters)

### 🔹 Build-time phases (NO time)

```
build_phase
connect_phase
end_of_elaboration
start_of_simulation
```

Used for:

* Creating components
* Connecting TLM ports
* Printing topology

🚫 **No delays allowed**

---

### 🔹 Run-time phases (TIME ADVANCES)

```
run_phase
reset_phase
configure_phase
main_phase
shutdown_phase
```

Used for:

* Driving stimulus
* Monitoring
* Checking

✔ These phases **require objections**

---

## 2️⃣ Why Objections Exist (CRITICAL)

Without objections:

* `run_phase` ends immediately
* Simulation jumps to extract → report → finish
* Your test **does nothing**

👉 Objections tell UVM:

> “Hold simulation alive, I am still working.”

---

## 3️⃣ Objection Lifecycle (Core Concept)

```
raise_objection(this);
   // do time-consuming work
drop_objection(this);
```

If objection count becomes **0** → phase ends.

---

## 4️⃣ Where Objections MUST Be Raised

| Component | Raise objection? |
| --------- | ---------------- |
| test      | ✅ YES (PRIMARY)  |
| env       | ❌ NO             |
| agent     | ❌ NO             |
| driver    | ❌ NO             |
| monitor   | ❌ NO             |
| sequence  | ❌ NO (important) |

📌 **Golden rule**

> Objections belong in **test**, not in sequences or drivers.

---

## 5️⃣ HANDS-ON: Correct `my_test.sv`

### ✅ This is the **ONLY correct pattern**

```systemverilog
class my_test extends uvm_test;
    `uvm_component_utils(my_test)

    my_env env;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        env = my_env::type_id::create("env", this);
    endfunction

    task run_phase(uvm_phase phase);
        my_sequence seq;

        phase.raise_objection(this);

        seq = my_sequence::type_id::create("seq");
        seq.start(env.agent.seqr);

        #100;   // allow monitor/scoreboard to finish

        phase.drop_objection(this);
    endtask
endclass
```

✔ Simulation ends **only after sequence + checking complete**

---

## 6️⃣ What Happens If You Remove Objection?

Try this experiment:

```systemverilog
// phase.raise_objection(this);  ❌ removed
seq.start(env.agent.seqr);
// phase.drop_objection(this);   ❌ removed
```

### ❌ Result

* No stimulus
* No monitor activity
* Simulation ends at time 0

📌 This is a **very common interview trap**

---

## 7️⃣ Phases vs Sequences (BIG CONFUSION CLEARED)

| Question                      | Correct Answer      |
| ----------------------------- | ------------------- |
| Do sequences have phases?     | ❌ NO                |
| Where do sequences run?       | Inside `run_phase`  |
| Can sequence raise objection? | ❌ NEVER             |
| Who controls time?            | Test via objections |

---

## 8️⃣ Common Interview Questions (YOU NOW KNOW)

### Q1: Why simulation ends early in UVM?

➡️ No objections raised

### Q2: Can driver raise objection?

➡️ No, only test should

### Q3: Difference between run_phase and main_phase?

➡️ `run_phase` exists in **all components**, others are optional refinements

### Q4: Can we use delays in build_phase?

➡️ ❌ NEVER

---

## 9️⃣ Your Current Setup Status

✔ DUT unchanged
✔ Sequences unchanged
✔ Driver unchanged
✔ Monitor unchanged
✔ Scoreboard unchanged

We **only added correct objection handling in test**

---

## ✅ Day-24 Status

**COMPLETED FULLY**
No pending hands-on
No skipped topics
No future dependency broken

---

## 🔜 What Comes Next (FIXED ORDER)

➡️ **Day-25: Advanced Sequences**

* pre_body / post_body
* Sequence arbitration
* Layered sequences
* Priority & locking

Say: **“Proceed Day-25”** when ready.
