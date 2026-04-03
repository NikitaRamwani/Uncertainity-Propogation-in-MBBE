# Job 13: Bootstrap method @ T/R = 1.00
# Run:  julia runs/job_13_bootstrap_tr100.jl
# Each run: 5 sample sizes × 200 batches × 200 trials = 200,000 simulations

const JOB_ID       = 13
const JOB_METHOD   = "Bootstrap"
const JOB_TR_RATIO = 1.00
const JOB_TAG      = "bootstrap_tr100"

include(joinpath(@__DIR__, "_runner.jl"))
