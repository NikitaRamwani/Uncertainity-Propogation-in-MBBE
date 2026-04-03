# Job 06: VCOV method @ T/R = 0.70
# Run:  julia runs/job_06_vcov_tr070.jl
# Each run: 5 sample sizes × 200 batches × 200 trials = 200,000 simulations

const JOB_ID       = 6
const JOB_METHOD   = "VCOV"
const JOB_TR_RATIO = 0.70
const JOB_TAG      = "vcov_tr070"

include(joinpath(@__DIR__, "_runner.jl"))
