# Job 17: SIR method @ T/R = 0.90
# Run:  julia runs/job_17_sir_tr090.jl
# Each run: 5 sample sizes × 200 batches × 200 trials = 200,000 simulations

const JOB_ID       = 17
const JOB_METHOD   = "SIR"
const JOB_TR_RATIO = 0.90
const JOB_TAG      = "sir_tr090"

include(joinpath(@__DIR__, "_runner.jl"))
