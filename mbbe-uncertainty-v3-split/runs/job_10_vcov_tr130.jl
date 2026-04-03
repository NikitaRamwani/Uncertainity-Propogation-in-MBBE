# Job 10: VCOV method @ T/R = 1.30
# Run:  julia runs/job_10_vcov_tr130.jl
# Each run: 5 sample sizes × 200 batches × 200 trials = 200,000 simulations

const JOB_ID       = 10
const JOB_METHOD   = "VCOV"
const JOB_TR_RATIO = 1.30
const JOB_TAG      = "vcov_tr130"

include(joinpath(@__DIR__, "_runner.jl"))
