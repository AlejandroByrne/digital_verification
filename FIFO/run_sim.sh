#!/bin/bash

# ============================================================
#  Vivado Simulation Script for FIFO Testbench
# ============================================================

# Default values
TEST_NAME="fifo_rand_test"

# Parse arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -t|--test) TEST_NAME="$2"; shift ;;
        -h|--help) 
            echo "Usage: ./run_sim.sh [options]"
            echo "Options:"
            echo "  -t, --test <name>    Specify UVM test name (default: fifo_rand_test)"
            echo "  -h, --help           Show this help"
            exit 0
            ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

echo "============================================================"
echo " Starting Simulation: $TEST_NAME"
echo "============================================================"

# --- Compilation ---
echo "[1/3] Compiling RTL and TB..."
xvlog -sv fifo.v fifo_tb_top.sv -L uvm

# --- Elaboration ---
echo "[2/3] Elaborating..."
xelab -L uvm work.top -s top_sim -timescale 1ns/1ps

# --- Simulation ---
echo "[3/3] Simulating $TEST_NAME..."
xsim top_sim -testplusarg "UVM_TESTNAME=$TEST_NAME" -R

# Check for failures in log
if [ -f xsim.log ]; then
    if grep -q "UVM_ERROR :    0" xsim.log && grep -q "UVM_FATAL :    0" xsim.log; then
        echo "============================================================"
        echo " SIMULATION PASSED"
        echo "============================================================"
    else
        echo "============================================================"
        echo " SIMULATION FAILED - CHECK xsim.log"
        echo "============================================================"
    fi
else
    echo "============================================================"
    echo " SIMULATION FAILED - xsim.log NOT FOUND"
    echo "============================================================"
fi
