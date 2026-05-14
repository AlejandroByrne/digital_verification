Good. 👍
Phase A1 is **closed**.

Now we **strictly follow the roadmap** and **cleanly branch**.

---

# 🔵 Phase A2 — OOP in SystemVerilog (FOUNDATION, NO SHORTCUTS)

> This is the **Week-2 CRITICAL block** you were worried about.
> We will **not touch mailbox / monitor / scoreboard** yet.
> Only **pure OOP + transactions**, step by step, **using XSIM**.

---

## 🎯 Phase A2 Goal (Very Clear)

By the end of Phase A2, you must be able to:

* Explain **what a class is vs module**
* Write a **transaction class from scratch**
* Use:

  * constructor
  * inheritance
  * virtual methods
  * polymorphism
  * deep vs shallow copy
* Compile & run **class-based TBs in XSIM** without errors

❌ No mailbox
❌ No driver/monitor
❌ No UVM

---

## 🧱 Phase A2 Breakdown (Clean & Ordered)

### **A2.1 — Classes & Objects (ABSOLUTE BASICS)**

**Topics**

* class syntax
* object creation (`new`)
* class variables vs module variables
* methods (function/task inside class)

**Hands-on**

* Simple `packet` class
* Randomize fields
* Display contents

📌 Output:

* One class
* One `initial` block using it

---

### **A2.2 — Constructors (`new`)**

**Topics**

* default constructor
* custom constructor with arguments
* initialization rules

**Hands-on**

* Initialize packet with size / id
* Compare default vs custom constructor

📌 Output:

* Same class behaving differently based on constructor

---

### **A2.3 — Inheritance**

**Topics**

* `extends`
* base vs derived class
* reusing fields & methods

**Hands-on**

* `base_txn`
* `dff_txn extends base_txn`

📌 Output:

* Polymorphic assignment (`base handle → child object`)

---

### **A2.4 — Virtual Methods (VERY IMPORTANT)**

**Topics**

* method overriding
* `virtual` keyword
* runtime dispatch

**Hands-on**

* Override `display()` in child
* Call via base handle

📌 Output:

* Observe **runtime behavior change**

---

### **A2.5 — Polymorphism (INTERVIEW FAVORITE)**

**Topics**

* base handle → derived object
* why UVM depends on this

**Hands-on**

* Array of base handles
* Each pointing to different child objects

📌 Output:

* Same method call → different behavior

---

### **A2.6 — Shallow vs Deep Copy**

**Topics**

* object handles
* assignment vs copy
* cloning objects

**Hands-on**

* Copy transaction
* Modify one
* Observe impact

📌 Output:

* Clear proof of shallow vs deep copy

---

## 🛠 Tool Rules (LOCKED)

* Simulator: **Vivado XSIM only**
* Compile: `xvlog -sv`
* Elaborate: `xelab`
* Run: `xsim -R`
* One file per concept (clean documentation)

---

## 📁 Suggested Folder Structure

```
Phase_A2_OOP/
 ├── A2_1_class_basics.sv
 ├── A2_2_constructor.sv
 ├── A2_3_inheritance.sv
 ├── A2_4_virtual_methods.sv
 ├── A2_5_polymorphism.sv
 └── A2_6_copy.sv
```

---

## ⏸ What is PAUSED (as you requested)

* ❌ Mailbox
* ❌ Monitor
* ❌ Scoreboard
* ❌ Driver

We resume those **only after Phase A2 is complete**.

---

## ✅ NEXT STEP (DO THIS NOW)

Reply with:

> **“Start A2.1 – Classes & Objects (XSIM hands-on)”**

I will then give **clean code + exact XSIM commands**, no mess, no jumping.
