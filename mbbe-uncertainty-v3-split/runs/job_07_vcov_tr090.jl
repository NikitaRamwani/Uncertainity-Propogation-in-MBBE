# Job 07: VCOV method @ T/R = 0.90
# Run:  julia runs/job_07_vcov_tr090.jl
# Each run: 5 sample sizes × 200 batches × 200 trials = 200,000 simulations

const JOB_ID       = 7
const JOB_METHOD   = "VCOV"
const JOB_TR_RATIO = 0.90
const JOB_TAG      = "vcov_tr090"

include(joinpath(@__DIR__, "_runner.jl"))
