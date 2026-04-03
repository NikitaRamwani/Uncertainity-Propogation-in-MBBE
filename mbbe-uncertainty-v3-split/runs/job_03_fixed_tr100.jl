# Job 03: Fixed method @ T/R = 1.00
# Run:  julia runs/job_03_fixed_tr100.jl
# Each run: 5 sample sizes × 200 batches × 200 trials = 200,000 simulations

const JOB_ID       = 3
const JOB_METHOD   = "Fixed"
const JOB_TR_RATIO = 1.00
const JOB_TAG      = "fixed_tr100"

include(joinpath(@__DIR__, "_runner.jl"))
