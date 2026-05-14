Perfect — this is a **classic Day-11 mistake**, and you actually hit the *exact* boundary between **assertions** and **coverage**. Good sign 👍

Let’s fix it cleanly.

---

## ❌ Error you’re seeing

```
syntax error near 'cover'
SystemVerilog keyword 'cover' used in incorrect context
```

This means **`cover` is being used where the simulator does not expect it**.

---

## 1️⃣ The ROOT CAUSE (important)

In SystemVerilog there are **two completely different “cover” concepts**:

### 🔴 A. `cover property`  (assertion coverage)

Used **with properties**

### 🟢 B. `covergroup` / `coverpoint` (functional coverage)

Used **inside covergroups only**

If you mix them → this exact error appears.

---

## 2️⃣ What you likely wrote (WRONG)

Something like this **inside interface or module**:

```systemverilog
cover (cb.en && cb.d);
```

or

```systemverilog
cover cb.en;
```

❌ This is **illegal SystemVerilog**

---

## 3️⃣ Correct ways to write COVERAGE

### ✅ OPTION 1: Assertion coverage (`cover property`)

*(This belongs to Day-11)*

```systemverilog
property en_high_loads_d;
    @(cb) disable iff (rst)
    cb.en |=> (cb.q == cb.d);
endproperty

cover property (en_high_loads_d);
```

✔ `cover property`
✔ Must reference a **property**
✔ Can live in module or interface

---

### ✅ OPTION 2: Functional coverage (`covergroup`)

*(This was Day-10)*

```systemverilog
covergroup dff_cg @(cb);
    coverpoint cb.en;
    coverpoint cb.d;
    coverpoint cb.q;
endgroup

dff_cg cg = new();
```

✔ `coverpoint` **only inside covergroup**
✔ Cannot be used standalone

---

## 4️⃣ What is NOT allowed (very important)

❌ **Standalone cover**

```systemverilog
cover(cb.en);        // ❌ illegal
```

❌ **coverpoint outside covergroup**

```systemverilog
coverpoint cb.en;    // ❌ illegal
```

❌ **cover inside procedural block**

```systemverilog
always @(cb) cover(cb.en);  // ❌ illegal
```

---

## 5️⃣ Why simulator error message is confusing

Vivado says:

```
keyword 'cover' used in incorrect context
```

But does NOT tell you **which kind of cover it expects**.

So remember:

> **If it’s not `cover property`, it MUST be inside a covergroup**

---

## 6️⃣ Day-11 mental model (lock this in)

| Feature             | Syntax                  | Purpose               |
| ------------------- | ----------------------- | --------------------- |
| Assertion           | `assert property`       | Check correctness     |
| Assertion coverage  | `cover property`        | Did scenario occur    |
| Functional coverage | `covergroup/coverpoint` | Stimulus completeness |

---

## 7️⃣ Quick fix checklist for YOU

Go to **line 88** and check:

* ❓ Is it `cover` without `property`? → ❌
* ❓ Is it `coverpoint` outside covergroup? → ❌
* ❓ Is it `cover property (some_property)`? → ✅

If you paste **just lines 80–95**, I’ll point to the exact fix in one reply.

---

### ✅ Status

* This error is **expected on Day-11**
* You are **not stuck**
* You are learning **correct boundaries between assertion & coverage**

---

### ▶️ Next (after fix)

We will:

* Add **reset assertion**
* Add **cover property for reset deassert**
* Show **100% coverage but still buggy design**

Say **Next** once this error is fixed.
