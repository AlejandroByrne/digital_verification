# ============================================================
#  SA4 / Half Adder — UVM Simulation via Docker + Verilator
#
#  Prerequisites:
#    cd .. && make build   (one-time Docker image build)
#
#  Usage:
#    make compile         # Verilate + compile (incremental)
#    make smoke           # Compile + run ha_smoke_test
#    make random          # Compile + run ha_random_test
#    make test T=<name>   # Compile + run any test by class name
#    make run T=<name>    # Run only (skip compile — use existing obj_dir)
#    make recompile       # Force full clean + compile
#    make clean           # Remove compiled artifacts
#
#  First compile takes ~15 min (Verilator converts entire UVM library to C++).
#  Subsequent compiles use ccache (~30s). Re-runs with no code changes: <1s.
# ============================================================

IMAGE   := uvm-sim
WORKDIR := /work
CCACHE  := uvm-ccache

# Mount source into container; persist ccache across runs
DOCKER  := docker run --rm -v $(CURDIR):$(WORKDIR) -v $(CCACHE):/root/.cache/ccache $(IMAGE)

UVM_SRC := /opt/uvm-core/src
VFLAGS  := -Wno-fatal --binary -j $$(nproc) --top-module top \
           +incdir+$(UVM_SRC) +define+UVM_NO_DPI \
           $(UVM_SRC)/uvm_pkg.sv

# ── Source files ──
# DUT + testbench top (add full_adder.sv, sa4.sv etc. here as you build up)
SRC     := half_adder.sv ha_tb_top.sv

# Default test
T       ?= ha_smoke_test

.PHONY: compile recompile smoke random test run clean

# Incremental compile — only rebuilds if .sv/.svh changed
compile:
	$(DOCKER) bash -c "verilator $(VFLAGS) $(SRC) 2>&1"

# Force full recompile
recompile: clean compile

# Compile + run smoke test
smoke: compile
	$(DOCKER) bash -c "./obj_dir/Vtop +UVM_TESTNAME=ha_smoke_test +UVM_NO_RELNOTES 2>&1"

# Compile + run random test
random: compile
	$(DOCKER) bash -c "./obj_dir/Vtop +UVM_TESTNAME=ha_random_test +UVM_NO_RELNOTES 2>&1"

# Compile + run any test by name
test: compile
	$(DOCKER) bash -c "./obj_dir/Vtop +UVM_TESTNAME=$(T) +UVM_NO_RELNOTES 2>&1"

# Run only — skip compile, use existing binary
run:
	$(DOCKER) bash -c "./obj_dir/Vtop +UVM_TESTNAME=$(T) +UVM_NO_RELNOTES 2>&1"

clean:
	rm -rf obj_dir
