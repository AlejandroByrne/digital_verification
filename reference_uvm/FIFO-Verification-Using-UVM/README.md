Project Description:
This project focuses on the verification of a FIFO (First-In-First-Out) design using Universal Verification Methodology (UVM). The goal was to ensure the FIFO operates correctly under various conditions such as normal data flow, underflow, overflow, and reset scenarios. A structured UVM testbench was developed, which includes sequences, a scoreboard, and assertions to verify the DUT (Design Under Test).

Key Components:
FIFO Design:
A First-In, First-Out buffer that manages sequential data writing and reading.
The design handles edge cases like empty (underflow) and full (overflow) conditions.
UVM Testbench:
Sequences: Write-only, Read-only, Reset, and Main sequences to stimulate the FIFO and test its functionality.
Driver & Monitor: Generated transactions are driven to the DUT, while the monitor observes the outputs.
Assertions (SVA): Ensures correct data ordering and flags violations in expected FIFO behavior.
Scoreboard: Tracks the expected vs. actual FIFO behavior, validating the correctness of the design.
Features:
Write-Only Sequence: Simulates continuous write operations into the FIFO.
Read-Only Sequence: Simulates reading data out of the FIFO.
Reset Sequence: Tests the FIFO's behavior under reset conditions.
Main Sequence: Combines different sequences to test the complete functionality.
Assertions (SVA): Provides formal checks for correct FIFO operations.
Scoreboard: Ensures the correctness of the read/write operations.
Learning Objectives:
Understand and implement FIFO Verification using UVM.
Apply SystemVerilog Assertions (SVA) for formal verification.
Develop a robust UVM testbench with sequences, drivers, monitors, and scoreboards.
Learn how to handle edge cases like FIFO underflow and overflow.
Acknowledgment:
Special thanks to Eng. Kareem Waseem for guidance throughout the project.

Technologies Used:
SystemVerilog
UVM (Universal Verification Methodology)
SystemVerilog Assertions (SVA)
Usage:
Clone the repository and follow the steps below to run the verification:

Set up your environment with SystemVerilog and UVM.
Compile the design and testbench files.
Run the simulations to verify the FIFO functionality.
This project serves as a learning resource and a base for verifying similar FIFO or queue structures in digital systems.
