#!/usr/bin/env python3
"""
Golden reference model for the custom 16-bit floating point multiplier.

Format: 1 sign + 8 exponent + 7 fraction (P=8, E=8, bias=127)
  Bit layout: [15] sign | [14:7] exponent | [6:0] fraction

This is effectively bfloat16 (same exponent range as IEEE 754 single,
but only 7 fraction bits instead of 23).

Usage:
    python3 golden_model.py                  # run built-in test vectors
    python3 golden_model.py --encode 1.5     # encode a float to hex
    python3 golden_model.py --decode 0x3FC0  # decode hex to float
    python3 golden_model.py --mult 0x3F80 0x4000 0  # multiply two encoded values with rounding mode
"""

import struct
import sys
import math

# Format parameters (must match fp_pkg.sv)
P = 8           # fraction bits + 1 (implicit 1), so stored fraction = P-1 = 7 bits
E = 8           # exponent bits
BIAS = 127      # 2^(E-1) - 1
EXP_MAX = 255   # 2^E - 1 (all 1s = special)
FRAC_BITS = P - 1   # 7 stored fraction bits
TOTAL_BITS = P + E   # 16


def decode(bits: int) -> dict:
    """Decode a 16-bit FP value into its components and float value."""
    sign = (bits >> (TOTAL_BITS - 1)) & 1
    exp  = (bits >> FRAC_BITS) & ((1 << E) - 1)
    frac = bits & ((1 << FRAC_BITS) - 1)

    if exp == 0 and frac == 0:
        val = -0.0 if sign else 0.0
        category = "Zero"
    elif exp == 0 and frac != 0:
        # Subnormal: (-1)^s × 2^(1-BIAS) × 0.fraction
        val = ((-1) ** sign) * (2 ** (1 - BIAS)) * (frac / (1 << FRAC_BITS))
        category = "Subnormal"
    elif exp == EXP_MAX and frac == 0:
        val = float('-inf') if sign else float('inf')
        category = "Infinity"
    elif exp == EXP_MAX and frac != 0:
        val = float('nan')
        category = "NaN"
    else:
        # Normal: (-1)^s × 2^(exp-BIAS) × 1.fraction
        val = ((-1) ** sign) * (2 ** (exp - BIAS)) * (1 + frac / (1 << FRAC_BITS))
        category = "Normal"

    return {
        'bits': bits,
        'hex': f"0x{bits:04X}",
        'binary': f"{(bits >> 8):08b}_{(bits & 0xFF):08b}",
        'sign': sign,
        'exponent': exp,
        'fraction': frac,
        'value': val,
        'category': category,
    }


def encode(value: float) -> int:
    """Encode a Python float into the 16-bit FP format."""
    if math.isnan(value):
        # Canonical NaN: exp=all 1s, frac=all 1s
        return (EXP_MAX << FRAC_BITS) | ((1 << FRAC_BITS) - 1)

    sign = 0
    if value < 0 or (value == 0 and math.copysign(1, value) < 0):
        sign = 1
        value = -value

    if math.isinf(value):
        return (sign << (TOTAL_BITS - 1)) | (EXP_MAX << FRAC_BITS)

    if value == 0:
        return sign << (TOTAL_BITS - 1)

    # Normal encoding: find exponent and fraction
    # value = 2^exp_unbiased × 1.fraction
    exp_unbiased = math.floor(math.log2(value))
    mantissa = value / (2 ** exp_unbiased)  # 1.something

    # Check for overflow (exponent too large)
    biased_exp = exp_unbiased + BIAS
    if biased_exp >= EXP_MAX:
        # Saturate to max normal (match DUT output_assembler behavior)
        max_normal = (sign << (TOTAL_BITS - 1)) | (((EXP_MAX - 1) >> 1 << 1) << FRAC_BITS) | ((1 << FRAC_BITS) - 1)
        # Actually, let's just return infinity for now
        return (sign << (TOTAL_BITS - 1)) | (EXP_MAX << FRAC_BITS)

    if biased_exp <= 0:
        # Underflow → flush to zero
        return sign << (TOTAL_BITS - 1)

    # Extract fraction bits (round to nearest even)
    frac_val = (mantissa - 1.0) * (1 << FRAC_BITS)
    frac_int = int(round(frac_val))  # simple rounding for encoding

    # Handle rounding overflow (frac rounds up to next power)
    if frac_int >= (1 << FRAC_BITS):
        frac_int = 0
        biased_exp += 1
        if biased_exp >= EXP_MAX:
            return (sign << (TOTAL_BITS - 1)) | (EXP_MAX << FRAC_BITS)

    return (sign << (TOTAL_BITS - 1)) | (biased_exp << FRAC_BITS) | frac_int


def classify(bits: int) -> int:
    """Return 4-bit OOR vector matching the DUT's oor_assembler: {zero, inf, nan, subnormal}."""
    exp  = (bits >> FRAC_BITS) & ((1 << E) - 1)
    frac = bits & ((1 << FRAC_BITS) - 1)
    e_min = (exp == 0)
    e_max = (exp == EXP_MAX)
    frac_zero = (frac == 0)

    zero_flag     = int(e_min and frac_zero)      # bit 3
    inf_flag      = int(e_max and frac_zero)       # bit 2
    nan_flag      = int(e_max and not frac_zero)   # bit 1
    subnormal_flag = int(e_min and not frac_zero)  # bit 0

    return (zero_flag << 3) | (inf_flag << 2) | (nan_flag << 1) | subnormal_flag


def multiply_fp(x_bits: int, y_bits: int, rnd_mode: int = 0) -> dict:
    """
    Bit-accurate golden model for FP multiplication.
    Mirrors the DUT's pipeline: multiply mantissas, add exponents,
    normalize, round, renormalize, handle special cases.

    Returns dict with expected p_out, oor_out, and intermediate values.
    """
    # Extract fields
    sign_x = (x_bits >> (TOTAL_BITS - 1)) & 1
    sign_y = (y_bits >> (TOTAL_BITS - 1)) & 1
    sign_r = sign_x ^ sign_y

    exp_x = (x_bits >> FRAC_BITS) & ((1 << E) - 1)
    exp_y = (y_bits >> FRAC_BITS) & ((1 << E) - 1)
    frac_x = x_bits & ((1 << FRAC_BITS) - 1)
    frac_y = y_bits & ((1 << FRAC_BITS) - 1)

    # Classify inputs
    cls_x = classify(x_bits)
    cls_y = classify(y_bits)

    # Special case detection (mirrors input_handler)
    x_is_zero = bool(cls_x & 0b1000)
    x_is_inf  = bool(cls_x & 0b0100)
    x_is_nan  = bool(cls_x & 0b0010)
    y_is_zero = bool(cls_y & 0b1000)
    y_is_inf  = bool(cls_y & 0b0100)
    y_is_nan  = bool(cls_y & 0b0010)

    is_nan  = x_is_nan or y_is_nan or (x_is_zero and y_is_inf) or (x_is_inf and y_is_zero)
    is_inf  = (x_is_inf or y_is_inf) and not is_nan
    is_zero = (x_is_zero or y_is_zero) and not is_nan

    if is_nan:
        # Canonical NaN: sign from XOR, exp all 1s, frac all 1s
        result = (sign_r << (TOTAL_BITS - 1)) | (EXP_MAX << FRAC_BITS) | ((1 << FRAC_BITS) - 1)
        return {
            'p_out': result,
            'oor_out': classify(result),
            'special': 'NaN',
            'decoded': decode(result),
        }

    if is_inf:
        result = (sign_r << (TOTAL_BITS - 1)) | (EXP_MAX << FRAC_BITS)
        return {
            'p_out': result,
            'oor_out': classify(result),
            'special': 'Infinity',
            'decoded': decode(result),
        }

    if is_zero:
        result = sign_r << (TOTAL_BITS - 1)
        return {
            'p_out': result,
            'oor_out': classify(result),
            'special': 'Zero',
            'decoded': decode(result),
        }

    # ---- Normal multiplication ----

    # Step 1: Multiply mantissas with implicit leading 1
    mant_x = (1 << FRAC_BITS) | frac_x   # P bits wide (8 bits)
    mant_y = (1 << FRAC_BITS) | frac_y
    product = mant_x * mant_y              # 2P bits wide (16 bits)

    # Step 2: Add exponents and subtract bias
    exp_sum_raw = exp_x + exp_y
    # Mirror the DUT's exponent_adder:
    #   adder: temp = a + b, carry = overflow
    #   then: result = {carry, sum} - bias
    #   where bias = {1'b0, {(D_SIZE-1){1'b1}}} = 0_1111111 = 127
    carry_add = 1 if exp_sum_raw >= (1 << E) else 0
    sum_add = exp_sum_raw & ((1 << E) - 1)

    temp_9bit = (carry_add << E) | sum_add
    temp_sub = temp_9bit - ((1 << (E - 1)) - 1)  # subtract 127
    carry_out = (temp_sub >> E) & 1
    if carry_out:
        exp_r_dut = (1 << E) - 1  # saturate to 0xFF
    else:
        exp_r_dut = temp_sub & ((1 << E) - 1)

    # Also compute the "correct" exponent for comparison
    exp_r_correct = exp_x + exp_y - BIAS

    # Step 3: First normalization
    # product is 2P bits. If MSB (bit 2P-1) is set, shift right (increment exp).
    # Otherwise shift left.
    msb = (product >> (2 * P - 1)) & 1
    if msb:
        # DUT increments exponent by calling exponent_adder with b_in = 1 + bias
        # exponent_adder(exp, 1+bias) = exp + 1 + bias - bias = exp + 1
        # But wait — let's trace the DUT's normalization module carefully
        #
        # The normalization module calls exponent_adder with:
        #   .b_in(1 + {1'b0, {(Q-1){1'b1}}})
        # That's 1 + 0_1111111 = 1 + 127 = 128 = 10000000
        #
        # exponent_adder(exp_r_dut, 128):
        #   adder: sum = exp_r_dut + 128, carry = ...
        #   then: result = {carry, sum} - 127
        #   This gives: exp_r_dut + 128 - 127 = exp_r_dut + 1   ← correct!
        exp_after_norm = exp_r_dut + 1
        if exp_after_norm >= (1 << E):
            exp_after_norm = (1 << E) - 1  # saturate
        # product stays as-is
    else:
        product = (product << 1) & ((1 << (2 * P)) - 1)
        exp_after_norm = exp_r_dut

    # Step 4: Rounding
    guard  = (product >> (P - 1)) & 1
    rnd_bit = (product >> (P - 2)) & 1
    sticky = 1 if (product & ((1 << (P - 2)) - 1)) else 0
    lsb    = (product >> P) & 1  # LSB of result fraction

    if rnd_mode == 1:    # RTZ
        do_round = False
    elif rnd_mode == 2:  # RD (toward -inf)
        do_round = bool(sign_r and (guard or rnd_bit or sticky))
    elif rnd_mode == 3:  # RU (toward +inf)
        do_round = bool((not sign_r) and (guard or rnd_bit or sticky))
    else:                # RNE (round to nearest, ties to even)
        if guard and not rnd_bit and not sticky:
            do_round = bool(lsb)  # tie: round to even
        else:
            do_round = bool(guard)

    exp_after_round = exp_after_norm
    round_overflow = False

    if do_round:
        # Add 1 at position P (increment fraction LSB)
        product_rounded = product + (1 << P)

        # Check if mantissa overflowed (bit 2P became 1)
        if product_rounded >= (1 << (2 * P)):
            # Mantissa overflow from rounding → renormalize
            product = (product_rounded >> 1) & ((1 << (2 * P)) - 1)
            product |= (1 << (2 * P - 1))  # set MSB
            round_overflow = True
            exp_after_round = exp_after_norm + 1
        else:
            product = product_rounded & ((1 << (2 * P)) - 1)
    else:
        # Zero out lower bits (match DUT: pa_bits & {P{1}, P{0}})
        mask = ((1 << P) - 1) << P
        product = product & mask

    # Step 5: Renormalization
    if round_overflow:
        # DUT shifts right and increments exponent (already done above)
        pass

    # Step 5.5: Extract fraction from product
    # product[2P-2 : P] = fraction bits (7 bits for P=8)
    final_frac = (product >> P) & ((1 << FRAC_BITS) - 1)

    # Step 6: Output assembly
    # Check if exponent hit all-1s → saturate to max normal
    if exp_after_round >= EXP_MAX:
        # output_assembler: {sign, {(Q-1){1'b1}}, 1'b0, {(P-1){1'b1}}}
        # = sign + 11111110 + 1111111 = max normal
        result = (sign_r << (TOTAL_BITS - 1)) | (((EXP_MAX - 1) & 0xFE) << FRAC_BITS) | ((1 << FRAC_BITS) - 1)
    elif exp_after_round <= 0:
        result = sign_r << (TOTAL_BITS - 1)  # flush to zero
    else:
        result = (sign_r << (TOTAL_BITS - 1)) | (exp_after_round << FRAC_BITS) | final_frac

    return {
        'p_out': result,
        'oor_out': classify(result),
        'special': None,
        'decoded': decode(result),
        'debug': {
            'exp_x': exp_x,
            'exp_y': exp_y,
            'exp_sum_raw': exp_sum_raw,
            'exp_r_dut': exp_r_dut,
            'exp_r_correct': exp_r_correct,
            'exp_after_norm': exp_after_norm,
            'exp_after_round': exp_after_round,
            'msb_set': bool(msb),
            'guard': guard,
            'round_bit': rnd_bit,
            'sticky': sticky,
            'do_round': do_round,
            'round_overflow': round_overflow,
            'final_frac': final_frac,
        }
    }


def print_decode(bits: int, label: str = ""):
    """Pretty-print the decode of a 16-bit FP value."""
    d = decode(bits)
    prefix = f"[{label}] " if label else ""
    print(f"{prefix}0x{bits:04X} = {d['binary']}")
    print(f"  sign={d['sign']}, exp={d['exponent']} (unbiased={d['exponent']-BIAS}), "
          f"frac=0b{d['fraction']:07b} ({d['fraction']}/{1 << FRAC_BITS})")
    print(f"  category={d['category']}, value={d['value']}")
    return d


def run_test(x_bits, y_bits, rnd_mode=0, label=""):
    """Run a single multiplication test and print results."""
    print(f"\n{'='*60}")
    print(f"TEST: {label}" if label else "TEST")
    print(f"{'='*60}")

    dx = print_decode(x_bits, "X")
    dy = print_decode(y_bits, "Y")

    print(f"\n  Python float result: {dx['value']} × {dy['value']} = {dx['value'] * dy['value']}")

    result = multiply_fp(x_bits, y_bits, rnd_mode)

    print(f"\n  Golden model output:")
    print(f"    p_out  = 0x{result['p_out']:04X}")
    print(f"    oor_out = {result['oor_out']:04b}")
    if result['special']:
        print(f"    special case: {result['special']}")
    else:
        print(f"    debug info:")
        for k, v in result['debug'].items():
            print(f"      {k}: {v}")

    dr = print_decode(result['p_out'], "Result")
    print(f"\n  Summary: {dx['value']} × {dy['value']} = {dr['value']}")

    return result


def generate_sv_test_vectors(vectors):
    """Generate SystemVerilog-ready test vector assignments."""
    print(f"\n{'='*60}")
    print("SYSTEMVERILOG TEST VECTORS")
    print(f"{'='*60}")
    for i, (x, y, rnd, label) in enumerate(vectors):
        result = multiply_fp(x, y, rnd)
        dx = decode(x)
        dy = decode(y)
        dr = decode(result['p_out'])
        print(f"\n// {label}: {dx['value']} × {dy['value']} = {dr['value']}")
        print(f"// Expected p_out=0x{result['p_out']:04X}, oor_out=4'b{result['oor_out']:04b}")
        var = f"req{i}" if i > 0 else "req"
        print(f"{var}.x_in     = 16'h{x:04X};")
        print(f"{var}.y_in     = 16'h{y:04X};")
        print(f"{var}.round_in = 2'b{rnd:02b};")


if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "--encode":
        val = float(sys.argv[2])
        bits = encode(val)
        print_decode(bits, f"encode({val})")

    elif len(sys.argv) > 1 and sys.argv[1] == "--decode":
        bits = int(sys.argv[2], 0)
        print_decode(bits, "decode")

    elif len(sys.argv) > 1 and sys.argv[1] == "--mult":
        x = int(sys.argv[2], 0)
        y = int(sys.argv[3], 0)
        rnd = int(sys.argv[4]) if len(sys.argv) > 4 else 0
        run_test(x, y, rnd, "manual")

    else:
        print("=" * 60)
        print("GOLDEN MODEL — FP Multiplier (P=8, E=8, bias=127)")
        print("=" * 60)

        # First: let's decode what your smoke test values ACTUALLY are
        print("\n--- DECODING YOUR SMOKE TEST VALUES ---")
        print_decode(0x3F80, "1.0?")
        print_decode(0x4000, "2.0?")
        print_decode(0xC204, "1.5e20?")
        print_decode(0xBC0A, "2.4e18?")
        print_decode(0xDD31, "5.5e18?")

        # Encode what those values SHOULD be
        print("\n--- CORRECT ENCODINGS ---")
        for val in [1.0, 2.0, 1.5, 3.0, -1.0, 0.5, 1.5e20, 2.4e18, 5.5e18]:
            bits = encode(val)
            d = decode(bits)
            print(f"  {val:>12} → 0x{bits:04X} (decodes back to {d['value']})")

        # Run your smoke test vectors
        print("\n--- SMOKE TEST RESULTS ---")
        run_test(0x3F80, 0x4000, 0, "1.0 × 2.0 (RNE)")
        run_test(0xC204, 0xBC0A, 0, "YOUR req1: 0xC204 × 0xBC0A (RNE)")
        run_test(0xDD31, 0xBC0A, 0, "YOUR req2: 0xDD31 × 0xBC0A (RNE)")

        # What the correct large-value tests should be
        print("\n\n--- CORRECTED LARGE-VALUE TESTS ---")
        x1 = encode(1.5e20)
        y1 = encode(2.4e18)
        run_test(x1, y1, 0, f"CORRECT: 1.5e20 × 2.4e18 (should overflow)")

        x2 = encode(5.5e18)
        run_test(x2, y1, 0, f"CORRECT: 5.5e18 × 2.4e18")

        # Simple test cases that are easy to verify by hand
        print("\n\n--- RECOMMENDED SIMPLE SMOKE TESTS ---")
        tests = [
            (encode(1.0), encode(2.0), 0, "1.0 × 2.0 = 2.0"),
            (encode(1.5), encode(3.0), 0, "1.5 × 3.0 = 4.5"),
            (encode(-2.0), encode(3.0), 0, "-2.0 × 3.0 = -6.0"),
            (encode(1.0), encode(-1.0), 0, "1.0 × -1.0 = -1.0"),
            (encode(1.0), encode(1.0), 0, "1.0 × 1.0 = 1.0"),
            (encode(0.5), encode(0.5), 0, "0.5 × 0.5 = 0.25"),
        ]
        for x, y, rnd, label in tests:
            run_test(x, y, rnd, label)

        generate_sv_test_vectors(tests)
