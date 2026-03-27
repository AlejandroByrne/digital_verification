#!/usr/bin/env python3
"""
IEEE 754 Float32 Multiplier — Golden Reference Model

Format: 1 sign + 8 exponent + 23 mantissa (total 32 bits)
  [31]    sign
  [30:23] exponent (biased, bias=127)
  [22:0]  stored mantissa (implicit leading 1 for normals)

Special values:
  +0       = 0x00000000    -0       = 0x80000000
  +Inf     = 0x7F800000    -Inf     = 0xFF800000
  qNaN     = 0x7FC00000    (canonical quiet NaN)
  sNaN     = 0x7F800001    (signaling NaN, any nonzero frac with MSB=0)

Exception flags (IEEE 754 §7):
  NV  = invalid operation     (e.g., 0 × Inf, sNaN input)
  OF  = overflow              (result magnitude too large for finite representation)
  UF  = underflow             (result is subnormal or flushed to zero)
  NX  = inexact               (result was rounded)
  DZ  = divide-by-zero        (not applicable for multiply, always 0)

Usage:
    python3 golden_model.py                          # run all built-in tests
    python3 golden_model.py --encode 1.5             # float → hex
    python3 golden_model.py --decode 0x3FC00000      # hex → float
    python3 golden_model.py --mult 0x3F800000 0x40000000       # multiply (RNE)
    python3 golden_model.py --mult 0x3F800000 0x40000000 1     # multiply (RTZ)
"""

import struct
import sys
import math
from dataclasses import dataclass, field
from enum import IntEnum

# ── IEEE 754 float32 constants ──────────────────────────────────
SIGN_BIT   = 31
EXP_BITS   = 8
FRAC_BITS  = 23
TOTAL_BITS = 32
BIAS       = 127
EXP_MAX    = 255       # all-ones exponent = special
EXP_NORMAL_MAX = 254   # largest biased exponent for normals


class RoundingMode(IntEnum):
    RNE = 0   # round to nearest, ties to even
    RTZ = 1   # round toward zero (truncate)
    RDN = 2   # round down (toward −∞)
    RUP = 3   # round up   (toward +∞)


class FPClass(IntEnum):
    ZERO      = 0
    SUBNORMAL = 1
    NORMAL    = 2
    INFINITY  = 3
    QNAN      = 4
    SNAN      = 5


@dataclass
class ExceptionFlags:
    nv: bool = False   # invalid
    of: bool = False   # overflow
    uf: bool = False   # underflow
    nx: bool = False   # inexact
    dz: bool = False   # divide-by-zero (always False for multiply)

    def to_bits(self) -> int:
        """Pack as 5-bit vector: {NV, DZ, OF, UF, NX}  (same order as RISC-V fcsr)."""
        return (int(self.nv) << 4) | (int(self.dz) << 3) | \
               (int(self.of) << 2) | (int(self.uf) << 1) | int(self.nx)

    def __str__(self):
        flags = []
        if self.nv: flags.append("NV")
        if self.of: flags.append("OF")
        if self.uf: flags.append("UF")
        if self.nx: flags.append("NX")
        return "|".join(flags) if flags else "none"


@dataclass
class FPComponents:
    sign: int
    exp: int          # biased exponent
    frac: int         # stored mantissa (no implicit 1)
    fp_class: FPClass
    value: float

    @property
    def exp_unbiased(self):
        return self.exp - BIAS


# ── Canonical constants ─────────────────────────────────────────
PLUS_ZERO  = 0x00000000
MINUS_ZERO = 0x80000000
PLUS_INF   = 0x7F800000
MINUS_INF  = 0xFF800000
CANON_NAN  = 0x7FC00000   # canonical quiet NaN (positive, frac MSB set)


# ════════════════════════════════════════════════════════════════
#  Decode / Encode
# ════════════════════════════════════════════════════════════════

def decode(bits: int) -> FPComponents:
    """Decompose a 32-bit pattern into sign, exponent, fraction, class, and float value."""
    bits &= 0xFFFFFFFF
    sign = (bits >> SIGN_BIT) & 1
    exp  = (bits >> FRAC_BITS) & ((1 << EXP_BITS) - 1)
    frac = bits & ((1 << FRAC_BITS) - 1)

    if exp == 0 and frac == 0:
        return FPComponents(sign, exp, frac, FPClass.ZERO,
                            -0.0 if sign else 0.0)
    elif exp == 0:
        val = ((-1)**sign) * (2**(1 - BIAS)) * (frac / (1 << FRAC_BITS))
        return FPComponents(sign, exp, frac, FPClass.SUBNORMAL, val)
    elif exp == EXP_MAX and frac == 0:
        return FPComponents(sign, exp, frac, FPClass.INFINITY,
                            float('-inf') if sign else float('inf'))
    elif exp == EXP_MAX:
        qnan = bool(frac & (1 << (FRAC_BITS - 1)))
        cls = FPClass.QNAN if qnan else FPClass.SNAN
        return FPComponents(sign, exp, frac, cls, float('nan'))
    else:
        val = ((-1)**sign) * (2**(exp - BIAS)) * (1 + frac / (1 << FRAC_BITS))
        return FPComponents(sign, exp, frac, FPClass.NORMAL, val)


def encode(value: float) -> int:
    """Encode a Python float to IEEE 754 float32 bits (uses struct for exactness)."""
    return struct.unpack('>I', struct.pack('>f', value))[0]


def bits_to_float(bits: int) -> float:
    """Convert 32-bit pattern to Python float."""
    return struct.unpack('>f', struct.pack('>I', bits & 0xFFFFFFFF))[0]


# ════════════════════════════════════════════════════════════════
#  Multiplication — bit-accurate golden model
# ════════════════════════════════════════════════════════════════

def multiply(a_bits: int, b_bits: int, rnd: int = 0) -> tuple[int, ExceptionFlags]:
    """
    Multiply two IEEE 754 float32 values.

    This models what a correct single-cycle combinational multiplier should
    produce. It follows IEEE 754-2019 §6.3 (special cases) and §4.3 (rounding).

    Returns: (result_bits, exception_flags)
    """
    a_bits &= 0xFFFFFFFF
    b_bits &= 0xFFFFFFFF
    flags = ExceptionFlags()

    a = decode(a_bits)
    b = decode(b_bits)

    # ── Result sign is always XOR ──
    sign_r = a.sign ^ b.sign

    # ── Special-case handling (IEEE 754 §6.1, §6.2, §7.2) ──

    # Rule 1: Any sNaN input → invalid, return canonical qNaN
    if a.fp_class == FPClass.SNAN or b.fp_class == FPClass.SNAN:
        flags.nv = True
        return (CANON_NAN, flags)

    # Rule 2: Any qNaN input → return canonical qNaN (no exception)
    if a.fp_class == FPClass.QNAN or b.fp_class == FPClass.QNAN:
        return (CANON_NAN, flags)

    # Rule 3: Inf × 0 = NaN (invalid)
    if (a.fp_class == FPClass.INFINITY and b.fp_class == FPClass.ZERO) or \
       (a.fp_class == FPClass.ZERO and b.fp_class == FPClass.INFINITY):
        flags.nv = True
        return (CANON_NAN, flags)

    # Rule 4: Inf × anything (non-zero, non-NaN) = ±Inf
    if a.fp_class == FPClass.INFINITY or b.fp_class == FPClass.INFINITY:
        result = (sign_r << SIGN_BIT) | (EXP_MAX << FRAC_BITS)
        return (result, flags)

    # Rule 5: Zero × anything finite = ±Zero
    if a.fp_class == FPClass.ZERO or b.fp_class == FPClass.ZERO:
        result = sign_r << SIGN_BIT
        return (result, flags)

    # ── Normal / subnormal multiplication ──

    # Get true mantissas (with implicit bit)
    if a.fp_class == FPClass.SUBNORMAL:
        mant_a = a.frac                    # no implicit 1
        exp_a  = 1                         # true exponent for subnormals
    else:
        mant_a = (1 << FRAC_BITS) | a.frac  # 24 bits: 1.fraction
        exp_a  = a.exp

    if b.fp_class == FPClass.SUBNORMAL:
        mant_b = b.frac
        exp_b  = 1
    else:
        mant_b = (1 << FRAC_BITS) | b.frac
        exp_b  = b.exp

    # Step 1: Multiply mantissas
    #   mant_a is 24 bits, mant_b is 24 bits → product is 48 bits
    product = mant_a * mant_b   # up to 48 bits

    # Step 2: Compute result exponent (unbiased)
    #   For normals: true_exp = biased_exp - BIAS
    #   result_exp = exp_a + exp_b - BIAS (re-adding one bias)
    exp_r = exp_a + exp_b - BIAS

    # Step 3: Normalize
    #   Product of two 1.xxx numbers is in range [1.0, 4.0)
    #   Bit 47 of product tells us if product >= 2.0
    #   After normalization, the hidden bit is at position 46 (or 47 if shifted)
    if product == 0:
        # Both subnormals can underflow to zero
        return (sign_r << SIGN_BIT, flags)

    # Find the position of the MSB
    msb_pos = product.bit_length() - 1

    # We want the hidden bit at position 46 (for normal 1.xx × 1.xx products)
    # If msb_pos == 47: product >= 2.0, need to shift right (exp_r += 1)
    # If msb_pos == 46: product in [1.0, 2.0), already normalized
    # If msb_pos < 46:  subnormal inputs caused smaller product, shift left
    target_msb = 2 * FRAC_BITS   # 46

    if msb_pos > target_msb:
        # Product has MSB higher than expected — shift right
        shift_right = msb_pos - target_msb
        exp_r += shift_right
        # Before shifting, capture the bits we'll lose for rounding
        # We need 23 fraction bits from positions [msb_pos-1 : msb_pos-23]
        # Guard bit at msb_pos-24, round at msb_pos-25, sticky = OR of the rest
    elif msb_pos < target_msb:
        # Product MSB too low — shift left (subnormal case)
        shift_left = target_msb - msb_pos
        product <<= shift_left
        exp_r -= shift_left
        msb_pos = target_msb

    # Now product has its MSB at position `target_msb + (shift_right if shifted right else 0)`
    # Let's work with the actual bit positions

    # Recalculate after normalization
    actual_msb = product.bit_length() - 1

    # Extract fraction: 23 bits below the hidden bit
    # Guard, round, sticky for rounding
    if actual_msb >= FRAC_BITS + 2:
        frac_r = (product >> (actual_msb - FRAC_BITS)) & ((1 << FRAC_BITS) - 1)
        guard  = (product >> (actual_msb - FRAC_BITS - 1)) & 1
        round_bit = (product >> (actual_msb - FRAC_BITS - 2)) & 1 if (actual_msb - FRAC_BITS - 2) >= 0 else 0
        sticky_mask = (1 << max(actual_msb - FRAC_BITS - 2, 0)) - 1
        sticky = 1 if (product & sticky_mask) else 0
    else:
        # Very small product (extreme subnormal case)
        frac_r = product << (FRAC_BITS - actual_msb)
        guard = 0
        round_bit = 0
        sticky = 0

    lsb = frac_r & 1

    # Step 4: Handle underflow (result exponent too small)
    if exp_r <= 0:
        # Need to denormalize: shift fraction right by (1 - exp_r) positions
        denorm_shift = 1 - exp_r

        if denorm_shift > FRAC_BITS + 2:
            # Complete underflow → zero (but might be inexact)
            if product != 0:
                flags.uf = True
                flags.nx = True
                # For RDN with negative sign, or RUP with positive sign,
                # return the minimum subnormal instead of zero
                if (rnd == RoundingMode.RDN and sign_r == 1) or \
                   (rnd == RoundingMode.RUP and sign_r == 0):
                    result = (sign_r << SIGN_BIT) | 1
                    return (result, flags)
            return (sign_r << SIGN_BIT, flags)

        # Shift right, accumulating into sticky
        # Reconstruct the full fraction with hidden bit
        full_frac = (1 << FRAC_BITS) | frac_r   # 24 bits with hidden bit

        # We also need to account for guard/round/sticky from before
        # Combine into an extended representation
        extended = (full_frac << 2) | (guard << 1) | (round_bit | sticky)
        # extended is now (FRAC_BITS + 3) bits: fraction + G + R|S

        if denorm_shift < FRAC_BITS + 3:
            new_sticky = 1 if (extended & ((1 << denorm_shift) - 1)) else 0
            extended >>= denorm_shift
        else:
            new_sticky = 1 if extended else 0
            extended = 0

        frac_r = (extended >> 2) & ((1 << FRAC_BITS) - 1)
        guard  = (extended >> 1) & 1
        round_bit = extended & 1
        sticky = new_sticky | round_bit
        round_bit = 0   # folded into sticky
        lsb = frac_r & 1
        exp_r = 0   # subnormal
        flags.uf = True

    # Step 5: Rounding
    do_round = False
    if rnd == RoundingMode.RNE:
        # Round to nearest; ties to even
        if guard:
            if round_bit or sticky:
                do_round = True      # above midpoint → round up
            else:
                do_round = bool(lsb) # exact midpoint → round to even
    elif rnd == RoundingMode.RTZ:
        do_round = False  # always truncate
    elif rnd == RoundingMode.RDN:
        # Round toward −∞: round up magnitude if negative and any discarded bits
        do_round = bool(sign_r) and bool(guard or round_bit or sticky)
    elif rnd == RoundingMode.RUP:
        # Round toward +∞: round up magnitude if positive and any discarded bits
        do_round = (not sign_r) and bool(guard or round_bit or sticky)

    inexact = bool(guard or round_bit or sticky)
    if inexact:
        flags.nx = True

    if do_round:
        frac_r += 1
        if frac_r >= (1 << FRAC_BITS):
            # Fraction overflow from rounding
            frac_r = 0
            exp_r += 1

    # Step 6: Handle overflow
    if exp_r >= EXP_MAX:
        flags.of = True
        flags.nx = True
        # IEEE 754: overflow result depends on rounding mode and sign
        if rnd == RoundingMode.RTZ:
            # Toward zero → largest finite number
            result = (sign_r << SIGN_BIT) | (EXP_NORMAL_MAX << FRAC_BITS) | ((1 << FRAC_BITS) - 1)
        elif rnd == RoundingMode.RDN:
            if sign_r:
                result = MINUS_INF
            else:
                result = (0 << SIGN_BIT) | (EXP_NORMAL_MAX << FRAC_BITS) | ((1 << FRAC_BITS) - 1)
        elif rnd == RoundingMode.RUP:
            if sign_r:
                result = (1 << SIGN_BIT) | (EXP_NORMAL_MAX << FRAC_BITS) | ((1 << FRAC_BITS) - 1)
            else:
                result = PLUS_INF
        else:  # RNE
            result = (sign_r << SIGN_BIT) | (EXP_MAX << FRAC_BITS)  # ±Inf
        return (result, flags)

    # Step 7: Assemble result
    result = (sign_r << SIGN_BIT) | (exp_r << FRAC_BITS) | (frac_r & ((1 << FRAC_BITS) - 1))
    return (result, flags)


# ════════════════════════════════════════════════════════════════
#  Pretty printing
# ════════════════════════════════════════════════════════════════

def print_decode(bits: int, label: str = "") -> FPComponents:
    d = decode(bits)
    prefix = f"[{label}] " if label else ""
    print(f"{prefix}0x{bits:08X}  sign={d.sign} exp={d.exp}({d.exp_unbiased:+d}) "
          f"frac=0x{d.frac:06X}  {d.fp_class.name}  val={d.value}")
    return d


def run_test(a_bits: int, b_bits: int, rnd: int = 0, label: str = ""):
    print(f"\n{'─'*65}")
    print(f"  {label}" if label else "  TEST")
    print(f"{'─'*65}")

    da = print_decode(a_bits, "A")
    db = print_decode(b_bits, "B")

    result_bits, flags = multiply(a_bits, b_bits, rnd)
    dr = print_decode(result_bits, "R")

    # Cross-check with Python float arithmetic
    py_result = da.value * db.value
    py_bits = encode(py_result) if not (math.isnan(da.value) or math.isnan(db.value)) else CANON_NAN

    match = "✓ MATCH" if result_bits == py_bits else f"✗ MISMATCH (python gives 0x{py_bits:08X} = {bits_to_float(py_bits)})"

    print(f"  rounding={RoundingMode(rnd).name}  flags={flags}  {match}")
    return result_bits, flags


def generate_sv_vectors(vectors: list[tuple]) -> str:
    """Generate SystemVerilog assignments for a list of (a, b, rnd, label) tuples."""
    lines = []
    for i, (a, b, rnd, label) in enumerate(vectors):
        result_bits, flags = multiply(a, b, rnd)
        da = decode(a)
        db = decode(b)
        dr = decode(result_bits)
        lines.append(f"")
        lines.append(f"// [{i}] {label}")
        lines.append(f"//   {da.value} × {db.value} = {dr.value}")
        lines.append(f"//   expected: result=0x{result_bits:08X}, flags=5'b{flags.to_bits():05b} ({flags})")
        var = f"txn{i}" if i > 0 else "txn"
        lines.append(f"send({i}, 32'h{a:08X}, 32'h{b:08X}, 2'd{rnd}, 32'h{result_bits:08X}, 5'b{flags.to_bits():05b});")
    return "\n".join(lines)


# ════════════════════════════════════════════════════════════════
#  Test suite
# ════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "--encode":
        val = float(sys.argv[2])
        bits = encode(val)
        print_decode(bits, f"encode({val})")
        sys.exit(0)

    if len(sys.argv) > 1 and sys.argv[1] == "--decode":
        bits = int(sys.argv[2], 0)
        print_decode(bits, "decode")
        sys.exit(0)

    if len(sys.argv) > 1 and sys.argv[1] == "--mult":
        a = int(sys.argv[2], 0)
        b = int(sys.argv[3], 0)
        rnd = int(sys.argv[4]) if len(sys.argv) > 4 else 0
        run_test(a, b, rnd, "manual")
        sys.exit(0)

    print("═" * 65)
    print("  IEEE 754 Float32 Multiplier — Golden Model Test Suite")
    print("═" * 65)

    # ── Category 1: Basic normal × normal ──
    print("\n\n▸ BASIC NORMAL MULTIPLICATION")
    run_test(encode(1.0),  encode(2.0),  0, "1.0 × 2.0 = 2.0")
    run_test(encode(1.5),  encode(3.0),  0, "1.5 × 3.0 = 4.5")
    run_test(encode(-2.0), encode(3.0),  0, "-2.0 × 3.0 = -6.0")
    run_test(encode(0.5),  encode(0.5),  0, "0.5 × 0.5 = 0.25")
    run_test(encode(1.0),  encode(1.0),  0, "1.0 × 1.0 = 1.0")
    run_test(encode(1.0),  encode(-1.0), 0, "1.0 × -1.0 = -1.0")
    run_test(encode(-1.0), encode(-1.0), 0, "-1.0 × -1.0 = 1.0")

    # ── Category 2: Sign combinations ──
    print("\n\n▸ SIGN COMBINATIONS")
    run_test(encode(3.0),  encode(5.0),  0, "(+) × (+) = (+)")
    run_test(encode(3.0),  encode(-5.0), 0, "(+) × (-) = (-)")
    run_test(encode(-3.0), encode(5.0),  0, "(-) × (+) = (-)")
    run_test(encode(-3.0), encode(-5.0), 0, "(-) × (-) = (+)")

    # ── Category 3: Zero interactions ──
    print("\n\n▸ ZERO INTERACTIONS")
    run_test(PLUS_ZERO,  encode(5.0),  0, "+0 × 5.0 = +0")
    run_test(MINUS_ZERO, encode(5.0),  0, "-0 × 5.0 = -0")
    run_test(encode(5.0), PLUS_ZERO,   0, "5.0 × +0 = +0")
    run_test(MINUS_ZERO, MINUS_ZERO,   0, "-0 × -0 = +0")
    run_test(PLUS_ZERO,  MINUS_ZERO,   0, "+0 × -0 = -0")

    # ── Category 4: Infinity interactions ──
    print("\n\n▸ INFINITY INTERACTIONS")
    run_test(PLUS_INF,  encode(2.0),  0, "+Inf × 2.0 = +Inf")
    run_test(MINUS_INF, encode(2.0),  0, "-Inf × 2.0 = -Inf")
    run_test(PLUS_INF,  MINUS_INF,    0, "+Inf × -Inf = -Inf")
    run_test(PLUS_INF,  PLUS_ZERO,    0, "+Inf × 0 = NaN (INVALID)")
    run_test(MINUS_INF, PLUS_ZERO,    0, "-Inf × 0 = NaN (INVALID)")
    run_test(PLUS_ZERO, PLUS_INF,     0, "0 × +Inf = NaN (INVALID)")

    # ── Category 5: NaN propagation ──
    print("\n\n▸ NaN PROPAGATION")
    run_test(CANON_NAN, encode(2.0),     0, "qNaN × 2.0 = qNaN (no exception)")
    run_test(encode(2.0), CANON_NAN,     0, "2.0 × qNaN = qNaN (no exception)")
    run_test(0x7F800001, encode(2.0),    0, "sNaN × 2.0 = qNaN (INVALID)")
    run_test(CANON_NAN,  CANON_NAN,      0, "qNaN × qNaN = qNaN")
    run_test(CANON_NAN,  PLUS_INF,       0, "qNaN × Inf = qNaN")
    run_test(0x7F800001, PLUS_ZERO,      0, "sNaN × 0 = qNaN (INVALID)")

    # ── Category 6: Overflow ──
    print("\n\n▸ OVERFLOW")
    big = encode(1.5e38)
    run_test(big, encode(4.0),  0, "1.5e38 × 4.0 → overflow (RNE → +Inf)")
    run_test(big, encode(4.0),  1, "1.5e38 × 4.0 → overflow (RTZ → max finite)")
    run_test(big, encode(-4.0), 2, "1.5e38 × -4.0 → overflow (RDN → -Inf)")
    run_test(big, encode(-4.0), 3, "1.5e38 × -4.0 → overflow (RUP → max neg finite)")

    # ── Category 7: Rounding mode differences ──
    print("\n\n▸ ROUNDING MODES")
    # 1.00000011920928955078125 × 1.00000011920928955078125
    # This product is inexact and exercises rounding
    a = encode(1.0000001192092896)  # smallest float > 1.0
    b = encode(1.0000001192092896)
    for mode in [0, 1, 2, 3]:
        run_test(a, b, mode, f"(1+ulp) × (1+ulp) with {RoundingMode(mode).name}")

    # Rounding with different signs
    a_neg = encode(-1.0000001192092896)
    for mode in [0, 1, 2, 3]:
        run_test(a_neg, b, mode, f"-(1+ulp) × (1+ulp) with {RoundingMode(mode).name}")

    # ── Category 8: Subnormals ──
    print("\n\n▸ SUBNORMALS")
    min_subnormal = 0x00000001   # smallest positive subnormal
    max_subnormal = 0x007FFFFF   # largest positive subnormal
    min_normal    = 0x00800000   # smallest positive normal (1.0 × 2^-126)
    run_test(min_normal, min_normal,  0, "min_normal × min_normal → underflow")
    run_test(min_subnormal, encode(2.0), 0, "min_subnormal × 2.0")
    run_test(max_subnormal, encode(2.0), 0, "max_subnormal × 2.0 → becomes normal")
    run_test(min_subnormal, min_subnormal, 0, "min_sub × min_sub → zero")

    # ── Category 9: Exponent boundaries ──
    print("\n\n▸ EXPONENT BOUNDARIES")
    run_test(encode(2.0), encode(2.0), 0, "2×2=4 (exp boundary)")
    run_test(0x7F7FFFFF, encode(1.0), 0, "max_normal × 1.0 = max_normal")
    run_test(0x7F7FFFFF, encode(0.5), 0, "max_normal × 0.5")

    # ── Generate SV test vectors ──
    print("\n\n" + "═" * 65)
    print("  SYSTEMVERILOG TEST VECTORS")
    print("═" * 65)
    vectors = [
        (encode(1.0),  encode(2.0),  0, "1.0 × 2.0 = 2.0"),
        (encode(1.5),  encode(3.0),  0, "1.5 × 3.0 = 4.5"),
        (encode(-2.0), encode(3.0),  0, "-2.0 × 3.0 = -6.0"),
        (encode(0.5),  encode(0.5),  0, "0.5 × 0.5 = 0.25"),
        (PLUS_ZERO,    encode(5.0),  0, "+0 × 5.0 = +0"),
        (PLUS_INF,     PLUS_ZERO,    0, "Inf × 0 = NaN (invalid)"),
        (CANON_NAN,    encode(2.0),  0, "qNaN × 2.0 = qNaN"),
        (PLUS_INF,     encode(2.0),  0, "Inf × 2.0 = Inf"),
        (encode(1.5e38), encode(4.0), 0, "overflow → Inf (RNE)"),
        (encode(1.5e38), encode(4.0), 1, "overflow → max finite (RTZ)"),
    ]
    print(generate_sv_vectors(vectors))
