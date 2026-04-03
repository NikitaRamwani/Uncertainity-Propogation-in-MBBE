# Job 18: SIR method @ T/R = 1.00
# Run:  julia runs/job_18_sir_tr100.jl
# Each run: 5 sample sizes × 200 batches × 200 trials = 200,000 simulations

const JOB_ID       = 18
const JOB_METHOD   = "SIR"
const JOB_TR_RATIO = 1.00
const JOB_TAG      = "sir_tr100"

include(joinpath(@__DIR__, "_runner.jl"))
