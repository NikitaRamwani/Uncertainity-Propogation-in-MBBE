# Job 02: Fixed method @ T/R = 0.90
# Run:  julia runs/job_02_fixed_tr090.jl
# Each run: 5 sample sizes × 200 batches × 200 trials = 200,000 simulations

const JOB_ID       = 2
const JOB_METHOD   = "Fixed"
const JOB_TR_RATIO = 0.90
const JOB_TAG      = "fixed_tr090"

include(joinpath(@__DIR__, "_runner.jl"))
