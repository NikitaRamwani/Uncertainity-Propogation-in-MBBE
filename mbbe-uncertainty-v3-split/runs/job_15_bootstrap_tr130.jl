# Job 15: Bootstrap method @ T/R = 1.30
# Run:  julia runs/job_15_bootstrap_tr130.jl
# Each run: 5 sample sizes × 200 batches × 200 trials = 200,000 simulations

const JOB_ID       = 15
const JOB_METHOD   = "Bootstrap"
const JOB_TR_RATIO = 1.30
const JOB_TAG      = "bootstrap_tr130"

include(joinpath(@__DIR__, "_runner.jl"))
