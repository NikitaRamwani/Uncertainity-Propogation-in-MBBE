# Job 16: SIR method @ T/R = 0.70
# Run:  julia runs/job_16_sir_tr070.jl
# Each run: 5 sample sizes × 200 batches × 200 trials = 200,000 simulations

const JOB_ID       = 16
const JOB_METHOD   = "SIR"
const JOB_TR_RATIO = 0.70
const JOB_TAG      = "sir_tr070"

include(joinpath(@__DIR__, "_runner.jl"))
