# Job 04: Fixed method @ T/R = 1.10
# Run:  julia runs/job_04_fixed_tr110.jl
# Each run: 5 sample sizes × 200 batches × 200 trials = 200,000 simulations

const JOB_ID       = 4
const JOB_METHOD   = "Fixed"
const JOB_TR_RATIO = 1.10
const JOB_TAG      = "fixed_tr110"

include(joinpath(@__DIR__, "_runner.jl"))
