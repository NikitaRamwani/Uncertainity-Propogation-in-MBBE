# Job 05: Fixed method @ T/R = 1.30
# Run:  julia runs/job_05_fixed_tr130.jl
# Each run: 5 sample sizes × 200 batches × 200 trials = 200,000 simulations

const JOB_ID       = 5
const JOB_METHOD   = "Fixed"
const JOB_TR_RATIO = 1.30
const JOB_TAG      = "fixed_tr130"

include(joinpath(@__DIR__, "_runner.jl"))
