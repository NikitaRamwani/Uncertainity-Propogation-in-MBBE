# Job 20: SIR method @ T/R = 1.30
# Run:  julia runs/job_20_sir_tr130.jl
# Each run: 5 sample sizes × 200 batches × 200 trials = 200,000 simulations

const JOB_ID       = 20
const JOB_METHOD   = "SIR"
const JOB_TR_RATIO = 1.30
const JOB_TAG      = "sir_tr130"

include(joinpath(@__DIR__, "_runner.jl"))
