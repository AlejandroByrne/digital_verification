Perfect. We’ll **continue the same roadmap** and **start Day-14: UVM Basics** — no directory changes, no reset, no mess.
This is exactly the right decision 👍

Given your background (strong SV, HDLBits rank-1, verification focus), we’ll keep this **lean, job-oriented, and hands-on**.

---

# 📅 **Day-14 — UVM BASICS (Foundation Day)**

🎯 **Goal of Day-14**
Understand **why UVM exists**, its **architecture**, and **minimum set of concepts** needed to start writing UVM code *tomorrow*.
👉 **No full environment today** — only mental model + skeleton familiarity.

⏱️ Time: **6–8 hours**

---

## 1️⃣ Why UVM? (30 min) — *Critical mindset shift*

You already know SV testbenches. UVM is:

| SV TB          | UVM               |
| -------------- | ----------------- |
| Ad-hoc         | Standardized      |
| Hard to scale  | Scalable          |
| Reusable? ❌    | Reusable ✅        |
| Manual control | Transaction-based |

🔑 **Key idea**

> *UVM separates **WHAT to send** from **HOW it is driven***.

---

## 2️⃣ UVM Architecture (VERY IMPORTANT) (1.5 hrs)

Learn this **hierarchy by heart**:

```
uvm_test
 └── uvm_env
      └── uvm_agent
           ├── uvm_sequencer
           ├── uvm_driver
           └── uvm_monitor
```

### Roles (Interview-critical)

| Component     | Purpose                         |
| ------------- | ------------------------------- |
| **Sequence**  | Generates transactions          |
| **Sequencer** | Arbitrates sequences            |
| **Driver**    | Drives DUT pins                 |
| **Monitor**   | Samples DUT pins                |
| **Agent**     | Groups driver/sequencer/monitor |
| **Env**       | Groups agents                   |
| **Test**      | Top-level control               |

📌 **Golden rule**

> Sequences never touch signals. Drivers never randomize.

---

## 3️⃣ UVM Class Hierarchy (1 hr)

Understand inheritance (no need to memorize entire tree):

```
uvm_object
 └── uvm_sequence_item
      └── transaction

uvm_component
 ├── uvm_driver
 ├── uvm_monitor
 ├── uvm_sequencer
 ├── uvm_agent
 ├── uvm_env
 └── uvm_test
```

🧠 **Key difference**

| uvm_object    | uvm_component        |
| ------------- | -------------------- |
| No phases     | Has phases           |
| Lightweight   | Part of TB hierarchy |
| Used for data | Used for structure   |

---

## 4️⃣ UVM Phases (CORE CONCEPT) (1.5 hrs)

Memorize **only these today**:

### Build-time phases

```
build_phase
connect_phase
end_of_elaboration
```

### Run-time phases

```
run_phase
```

📌 **Rules**

* `new()` → constructor only
* `build_phase()` → create components
* `connect_phase()` → connect TLM ports
* `run_phase()` → stimulus

🚨 **Interview trap**

> *You must not create components in run_phase.*

---

## 5️⃣ Factory Concept (Conceptual Only) (1 hr)

For now, understand **why**, not syntax.

### Problem UVM solves:

```systemverilog
drv = new();
```

❌ Cannot replace later

### UVM solution:

```systemverilog
drv = my_driver::type_id::create("drv", this);
```

✔ Enables override without changing code
✔ Used heavily in real projects

📌 **Today:** understand idea
📌 **Tomorrow:** use it

---

## 6️⃣ Minimal UVM Skeleton (Read Only) (1 hr)

Read this **slowly** — do NOT memorize yet:

```systemverilog
class my_test extends uvm_test;
  `uvm_component_utils(my_test)

  my_env env;

  function new(string name="my_test", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    env = my_env::type_id::create("env", this);
  endfunction
endclass
```

Understand:

* Why macro?
* Why `this`?
* Why not `new()`?

---

## 7️⃣ What NOT to Do Today ❌

❌ Don’t jump into:

* TLM ports
* Analysis ports
* Objections
* Scoreboards
* Config DB

Those come **Day-16+**

---

## ✅ Day-14 Deliverables (Must-check)

By end of today, you should be able to **answer verbally**:

✔ Why UVM exists
✔ Difference between sequence & driver
✔ uvm_object vs uvm_component
✔ When build_phase vs run_phase is used
✔ Why factory is needed

If you can **explain**, you’re on track.

---

## 🔜 Day-15 Preview (Tomorrow)

**“First Working UVM Testbench”**

* sequence_item
* sequence
* driver
* simple DUT
* run simulation

No theory — **only code**.

---

If you want, next message I’ll:

* Start **Day-15 hands-on immediately**, or
* Do a **15-minute Day-14 self-test (interview style)**

You’re back on the right path. Let’s keep it clean and ruthless 💪
