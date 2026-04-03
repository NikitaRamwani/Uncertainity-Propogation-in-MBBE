# Job 19: SIR method @ T/R = 1.10
# Run:  julia runs/job_19_sir_tr110.jl
# Each run: 5 sample sizes × 200 batches × 200 trials = 200,000 simulations

const JOB_ID       = 19
const JOB_METHOD   = "SIR"
const JOB_TR_RATIO = 1.10
const JOB_TAG      = "sir_tr110"

include(joinpath(@__DIR__, "_runner.jl"))
