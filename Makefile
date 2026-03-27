# ============================================================
#  digital_verification — Shared UVM Docker Build
#
#  Usage:
#    make build    # Build the uvm-sim Docker image (first time / Dockerfile changes)
# ============================================================

IMAGE := uvm-sim

.PHONY: build

build:
	docker build -t $(IMAGE) .
