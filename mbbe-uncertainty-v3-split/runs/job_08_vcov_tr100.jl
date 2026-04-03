# Job 08: VCOV method @ T/R = 1.00
# Run:  julia runs/job_08_vcov_tr100.jl
# Each run: 5 sample sizes × 200 batches × 200 trials = 200,000 simulations

const JOB_ID       = 8
const JOB_METHOD   = "VCOV"
const JOB_TR_RATIO = 1.00
const JOB_TAG      = "vcov_tr100"

include(joinpath(@__DIR__, "_runner.jl"))
