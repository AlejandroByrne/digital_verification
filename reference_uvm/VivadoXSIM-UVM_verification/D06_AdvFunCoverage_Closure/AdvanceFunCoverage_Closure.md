Perfect — we’ll **formally start Day-6 now**, step-by-step, **hands-on**, and strictly aligned with **industry expectations**.

You already *used* coverage.
Day-6 is about **making coverage intelligent**.

---

# 🟦 DAY-6 — ignore_bins & Transition Coverage

## 🎯 Day-6 Objective (Lock this in your head)

By end of Day-6, you must be able to explain:

> “Not all legal scenarios are interesting, and not all interesting behavior is static — coverage must reflect **intent and time**.”

That sentence alone sounds **mid-level DV**.

---

## PART-1: `ignore_bins` — Filtering Noise

### ❓ Why `ignore_bins` exists

Coverage answers:

> *Did this scenario occur?*

But **some scenarios are valid yet useless** for verification progress.

If you don’t ignore them:

* Coverage percentage becomes misleading
* Closure becomes meaningless
* You chase noise instead of bugs

---

## 🧠 Your DFF Example (Re-evaluate Behavior)

| en | d | Meaning   | Action         |
| -- | - | --------- | -------------- |
| 1  | 1 | Capture 1 | ✅ MUST cover   |
| 1  | 0 | Capture 0 | ✅ MUST cover   |
| 0  | 1 | Illegal   | ❌ illegal_bins |
| 0  | 0 | Idle      | ⚠️ ignore_bins |

👉 Idle is **legal**
👉 Idle is **boring**
👉 Idle should **not count against coverage**

---

## ✅ Correct Use of `ignore_bins` (Industry Style)

Update your cross like this:

```systemverilog
cross en, d {

    illegal_bins illegal_idle =
        binsof(en) intersect {0} &&
        binsof(d)  intersect {1};

    ignore_bins idle_case =
        binsof(en) intersect {0} &&
        binsof(d)  intersect {0};
}
```

### 🧠 What This Says Clearly

* Illegal case → **never allowed**
* Idle case → **allowed but ignored**
* Only meaningful behavior affects coverage

---

## 🔥 Interview Trap (Very Common)

**Q:** Why not make idle case illegal?
**Correct answer:**

> Because idle is valid design behavior; it simply does not contribute to verification goals.

This separates **DV engineers from beginners**.

---

## PART-2: Transition Coverage — Time Matters

So far, you covered **values**.
But hardware bugs hide in **transitions**.

---

## ❓ What Transition Coverage Really Checks

> “Did a signal change as expected across clock cycles?”

Examples:

* Did `d` toggle?
* Did `en` assert then deassert?
* Did behavior change *only when allowed*?

---

## ✅ Transition Coverage on `d`

Add this coverpoint:

```systemverilog
coverpoint d {
    bins d_0 = {0};
    bins d_1 = {1};

    bins d_toggle[] = (0 => 1), (1 => 0);
}
```

### 🧠 Meaning

* Ensures data is not stuck
* Confirms stimulus diversity
* Prevents false coverage confidence

---

## ✅ Transition Coverage on `en` (More Important)

```systemverilog
coverpoint en {
    bins en_toggle = (0 => 1 => 0);
}
```

This checks:

> “Did enable assert and later deassert?”

That is **protocol-level behavior**, not just signal toggling.

---

## ⭐ Advanced (Very Interview-Relevant)

### Transition coverage **with condition**

```systemverilog
coverpoint d iff (en) {
    bins capture_toggle[] = (0 => 1), (1 => 0);
}
```

🧠 Meaning:

> Count data transitions **only when enable is active**

This directly maps to **real design intent**.

---

## PART-3: Temporal Coverage Thinking (Mindset Shift)

You are now thinking in **time**, not values.

Ask yourself:

* Did this happen?
* Did it happen in the right order?
* Did it happen under the right condition?

That’s **temporal verification**.

---

## PART-4: Coverage Closure Strategy (Mini-Intro)

Coverage closure is **not**:
❌ “Hit 100% randomly”

Coverage closure **is**:
✔ Decide what matters
✔ Ignore what doesn’t
✔ Prove meaningful behavior happened

You just learned how.

---

## ✅ Day-6 Checklist

You should now be able to:

* [ ] Explain `ignore_bins` vs `illegal_bins`
* [ ] Write transition bins
* [ ] Use `iff` correctly
* [ ] Explain temporal coverage in words
* [ ] Justify coverage decisions logically

If yes → **you are mid-level DV ready in coverage**

---

## 🎤 Interview-Ready One-Liner (Memorize)

> “I use `illegal_bins` for forbidden behavior, `ignore_bins` for uninteresting valid behavior, and transition bins to verify temporal correctness.”

🔥 That is a **strong** answer.

---

## 👉 Your Next Action (Very Important)

Modify **only your covergroup** to include:

1. `ignore_bins` for idle case
2. One transition bin (`d` or `en`)

Paste **just the updated covergroup** here.

I’ll review it like a **design sign-off**.

Once done → Day-6 ✅ complete, then we move to **Day-7: Assertions + Coverage synergy** 🚀
