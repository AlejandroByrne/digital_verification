// The sequencer is just a parameterized typedef — it passes
// fp_mult_txn objects between sequences and the driver.
// No custom behavior needed; uvm_sequencer handles the handshake.
typedef uvm_sequencer #(fp_mult_txn) fp_mult_sequencer;
