// ============================================================
//  FP32 — Weighted Constrained-Random Sequence
// ============================================================

class fp32_constrained_seq extends uvm_sequence #(fp32_txn);
    `uvm_object_utils(fp32_constrained_seq)

    int num_items = 1000;

    function new(string name = "fp32_constrained_seq");
        super.new(name);
    endfunction : new

    task body();
        repeat (num_items) begin
            fp32_cls_t a_cls, b_cls;
            
            req = fp32_txn::type_id::create("req");
            start_item(req);

            // Procedurally pick classes to avoid xsim complex constraint issues
            if (!std::randomize(a_cls, b_cls) with {
                a_cls dist { FP_NORMAL := 40, FP_SUBNORMAL := 20, FP_ZERO := 10, FP_INFINITY := 10, FP_QNAN := 10, FP_SNAN := 10 };
                b_cls dist { FP_NORMAL := 40, FP_SUBNORMAL := 20, FP_ZERO := 10, FP_INFINITY := 10, FP_QNAN := 10, FP_SNAN := 10 };
            }) `uvm_error("SEQ", "Class rand failed")

            if (!req.randomize() with {
                (a_cls == FP_ZERO)      -> (a_in[30:0] == 0);
                (a_cls == FP_INFINITY)  -> (a_in[30:23] == 8'hFF && a_in[22:0] == 0);
                (a_cls == FP_QNAN)      -> (a_in[30:23] == 8'hFF && a_in[22] == 1);
                (a_cls == FP_SNAN)      -> (a_in[30:23] == 8'hFF && a_in[22] == 0 && a_in[21:0] != 0);
                (a_cls == FP_SUBNORMAL) -> (a_in[30:23] == 8'h00 && a_in[22:0] != 0);
                (a_cls == FP_NORMAL)    -> (a_in[30:23] > 8'h00 && a_in[30:23] < 8'hFF);

                (b_cls == FP_ZERO)      -> (b_in[30:0] == 0);
                (b_cls == FP_INFINITY)  -> (b_in[30:23] == 8'hFF && b_in[22:0] == 0);
                (b_cls == FP_QNAN)      -> (b_in[30:23] == 8'hFF && b_in[22] == 1);
                (b_cls == FP_SNAN)      -> (b_in[30:23] == 8'hFF && b_in[22] == 0 && b_in[21:0] != 0);
                (b_cls == FP_SUBNORMAL) -> (b_in[30:23] == 8'h00 && b_in[22:0] != 0);
                (b_cls == FP_NORMAL)    -> (b_in[30:23] > 8'h00 && b_in[30:23] < 8'hFF);
            }) begin
                `uvm_error("SEQ", "Randomization failed")
            end

            finish_item(req);
        end
    endtask : body

endclass : fp32_constrained_seq
