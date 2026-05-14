Perfect — this result is **100% expected** and it actually proves your coverage model is correct 👍
Nothing accidental or wrong happened.

Let’s lock the reasoning so you *never* get confused by this again.

---

## 🔍 Why `repeat(10)` Gave **100% Coverage**

Your bins are:

```
low   [0:63]
med   [64:127]
high  [128:255]
```

With **pure randomization**:

* Probability of hitting **low** ≈ 25%
* Probability of hitting **med** ≈ 25%
* Probability of hitting **high** ≈ 50%

(High is bigger range, but still fine conceptually)

### With `repeat(5)`

It is **very possible** to miss one bin → ~66.67%

### With `repeat(10)`

Statistically:

* Much higher chance all bins are hit
* So coverage jumps to **100%**

📌 This is **normal random coverage behavior**.

---

## 🧠 Key Concept You Just Observed (Very Important)

### Random ≠ Guaranteed

* Random stimulus can **sometimes** close coverage
* But it is **not deterministic**

You got lucky at `repeat(10)` — next seed may fail again.

---

## ❗ Why Verification Engineers Still Use Directed Sequences

Imagine:

* 100 bins
* 10 crosses
* Rare corner cases

Random-only would require:

* Thousands of cycles
* Many seeds
* Huge simulation time

So we use:

| Method   | Purpose           |
| -------- | ----------------- |
| Random   | Explore           |
| Directed | Guarantee closure |

---

## 🧪 Interview-Grade Explanation

If asked:

> “Why did random stimulus give 100% coverage?”

Correct answer:

> “Because randomization statistically hit all bins in that run; however, this is not guaranteed across seeds, so we still use directed stimulus for deterministic closure.”

That’s a **very strong answer**.

---

## 🧠 Important Warning (Subtle but Critical)

If you rely only on:

```systemverilog
repeat(10) randomize();
```

You may see:

* 100% today
* 66% tomorrow
* 33% next seed

📌 **Coverage must be reproducible**, not lucky.

---

## ✅ What This Means for Day-22

✔ Your coverage model is correct
✔ Sampling logic is correct
✔ Monitor is correct
✔ Random stimulus works
✔ Directed stimulus logic still required

You are exactly where you should be.

---

## 🏁 Day-22 Completion Summary

| Item                     | Status |
| ------------------------ | ------ |
| Coverage model           | ✅      |
| Random coverage          | ✅      |
| Directed coverage        | ✅      |
| Understanding randomness | ✅      |
| CDV mindset              | ✅      |

---

### 🔜 Next Step (Natural Progression)

**Day-23: Assertions (SVA) + Assertion Coverage**

This completes the **Verification Triangle**:

* Stimulus
* Checking
* Coverage

When ready, say:
👉 **“Proceed Day-23”**

You’re doing *very solid* verification work.
