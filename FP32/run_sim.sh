#!/bin/bash

# ============================================================
#  Vivado Simulation Script for FP32 Multiplier
# ============================================================

# Default values
TEST_NAME="fp32_constrained_test"
VERBOSITY="UVM_MEDIUM"

# Parse arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -t|--test) TEST_NAME="$2"; shift ;;
        -v|--verbosity) VERBOSITY="$2"; shift ;;
        -h|--help) 
            echo "Usage: ./run_sim.sh [options]"
            echo "Options:"
            echo "  -t, --test <name>       UVM test name (default: fp32_constrained_test)"
            echo "  -v, --verbosity <level> UVM verbosity (UVM_LOW, UVM_MEDIUM, UVM_HIGH, UVM_FULL)"
            echo "  -h, --help              Show this help"
            exit 0
            ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

echo "============================================================"
echo " Starting FP32 Simulation: $TEST_NAME"
echo "============================================================"

# --- 1. Compile C DPI Code ---
echo "[1/5] Compiling DPI C code..."
# Compile into a shared object named 'dpi' in the current directory
xsc fp32_dpi.c -o dpi

# --- 2. Compile RTL and TB ---
echo "[2/5] Compiling SystemVerilog..."
xvlog -sv fp32_mult.sv fp32_tb_top.sv -L uvm

# --- 3. Elaboration ---
echo "[3/5] Elaborating..."
# Link the 'dpi' shared object
xelab -L uvm work.top -s top_sim \
      -sv_lib dpi -timescale 1ns/1ps \
      -cov_db_name ${TEST_NAME}_cov

# --- 4. Simulation ---
echo "[4/5] Simulating..."
xsim top_sim -testplusarg "UVM_TESTNAME=$TEST_NAME" \
             -testplusarg "UVM_VERBOSITY=$VERBOSITY" \
             -R -cov_db_name ${TEST_NAME}_cov

# --- 5. Coverage Report ---
echo "[5/5] Generating Coverage Report..."
if [ -d xsim.covdb ]; then
    xcrg -report_format text -db_name ${TEST_NAME}_cov -report_dir ./cov_report
    echo "============================================================"
    echo " Coverage report generated in ./cov_report/dashboard.txt"
    echo "============================================================"
    if [ -f ./cov_report/dashboard.txt ]; then
        cat ./cov_report/dashboard.txt | grep -A 20 "Type Breakdown"
    fi
fi

# Check for failures in log
if [ -f xsim.log ]; then
    if grep -q "UVM_ERROR :    0" xsim.log && grep -q "UVM_FATAL :    0" xsim.log; then
        echo "============================================================"
        echo " TEST PASSED"
        echo "============================================================"
    else
        echo "============================================================"
        echo " TEST FAILED - CHECK xsim.log"
        echo "============================================================"
    fi
fi
