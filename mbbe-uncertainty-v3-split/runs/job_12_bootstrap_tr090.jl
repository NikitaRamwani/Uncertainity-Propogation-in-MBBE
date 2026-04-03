# Job 12: Bootstrap method @ T/R = 0.90
# Run:  julia runs/job_12_bootstrap_tr090.jl
# Each run: 5 sample sizes × 200 batches × 200 trials = 200,000 simulations

const JOB_ID       = 12
const JOB_METHOD   = "Bootstrap"
const JOB_TR_RATIO = 0.90
const JOB_TAG      = "bootstrap_tr090"

include(joinpath(@__DIR__, "_runner.jl"))
