# ──────────────────────────────────────────────────────────────────────────────
# _runner.jl — Shared engine for individual job files
#
# Each job_XX_*.jl file sets JOB_ID, JOB_METHOD, JOB_TR_RATIO, JOB_TAG
# before including this file.
#
# This script:
#   1. Loads common.jl and model_fit_results.jls
#   2. Runs virtual_be_sim_batched for the ONE (method, T/R ratio) pair
#   3. Saves output to runs/output/job_XX_<tag>.jls
#   4. Writes a .done marker with timing info
# ──────────────────────────────────────────────────────────────────────────────

# ── If run directly, parse command-line arguments ────────────────────────────
if !isdefined(Main, :JOB_METHOD)
    _VALID_METHODS = ["Fixed", "VCOV", "Bootstrap", "SIR"]
    _VALID_RATIOS  = [0.70, 0.90, 1.00, 1.10, 1.30]

    if length(ARGS) < 2
        error(
            "Usage:  julia runs/_runner.jl <method> <tr_ratio>\n" *
            "  Methods  : $(join(_VALID_METHODS, ", "))\n" *
            "  TR ratios: $(join(_VALID_RATIOS, ", "))\n" *
            "Example: julia runs/_runner.jl Fixed 0.90"
        )
    end

    global JOB_METHOD   = ARGS[1]
    global JOB_TR_RATIO = parse(Float64, ARGS[2])

    if JOB_METHOD ∉ _VALID_METHODS
        error("Unknown method '$(JOB_METHOD)'. Must be one of: $(join(_VALID_METHODS, ", "))")
    end
    if JOB_TR_RATIO ∉ _VALID_RATIOS
        error("Unknown T/R ratio $(JOB_TR_RATIO). Must be one of: $(join(_VALID_RATIOS, ", "))")
    end

    # Auto-derive JOB_ID and JOB_TAG
    _method_offset = Dict("Fixed" => 0, "VCOV" => 5, "Bootstrap" => 10, "SIR" => 15)
    _ratio_index   = findfirst(==(JOB_TR_RATIO), _VALID_RATIOS)
    global JOB_ID  = _method_offset[JOB_METHOD] + _ratio_index
    global JOB_TAG = lowercase(JOB_METHOD) * "_tr" * replace(string(Int(round(JOB_TR_RATIO * 100))), "." => "")
end

include(joinpath(@__DIR__, "..", "common.jl"))
using Dates

# ── Configuration ─────────────────────────────────────────────────────────────
# Reduced sample sizes: removed 12 and 50 (5 values instead of 7)
const JOB_SAMPLE_SIZES = [24, 30, 40, 60, 80]

# ── Load Model Fit Results ────────────────────────────────────────────────────
fit_data = Serialization.deserialize(joinpath(@__DIR__, "..", "model_fit_results.jls"))

global AUC_COL  = fit_data[:auc_col]
global CMAX_COL = fit_data[:cmax_col]

# Select the right parameter samples for this method
param_key = Dict(
    "Fixed"     => :fixed_param_samples,
    "VCOV"      => :vcov_param_samples,
    "Bootstrap" => :boot_param_samples,
    "SIR"       => :sir_param_samples,
)[JOB_METHOD]

param_samples = fit_data[param_key]

# ── Print Job Info ────────────────────────────────────────────────────────────
outdir  = joinpath(@__DIR__, "output")
outfile = joinpath(outdir, "job_$(lpad(JOB_ID, 2, '0'))_$(JOB_TAG).jls")
donefile = joinpath(outdir, "job_$(lpad(JOB_ID, 2, '0'))_$(JOB_TAG).done")

println("=" ^ 70)
println("JOB $JOB_ID: $(JOB_METHOD) @ T/R = $(JOB_TR_RATIO)")
println("=" ^ 70)
println("  Sample sizes : $(JOB_SAMPLE_SIZES)")
println("  Batches      : $N_BATCHES")
println("  Trials/batch : $N_SIMS_PER_BATCH")
println("  Total sims   : $(length(JOB_SAMPLE_SIZES) * N_BATCHES * N_SIMS_PER_BATCH)")
println("  Output       : $outfile")
println("  AUC col      : $AUC_COL")
println("  Cmax col     : $CMAX_COL")
println("-" ^ 70)

# ── Run ───────────────────────────────────────────────────────────────────────
t_start = time()

batches = virtual_be_sim_batched(
    param_samples, JOB_METHOD;
    tr_ratios  = [JOB_TR_RATIO],
    n_per_arms = JOB_SAMPLE_SIZES,
    n_batches  = N_BATCHES,
    n_sims     = N_SIMS_PER_BATCH
)

elapsed = time() - t_start
elapsed_min = round(elapsed / 60, digits=1)

# ── Save Results ──────────────────────────────────────────────────────────────
mkpath(outdir)
Serialization.serialize(outfile, batches)
println("\nSaved $(nrow(batches)) rows to: $outfile")

# ── Write .done marker ───────────────────────────────────────────────────────
open(donefile, "w") do io
    println(io, "job_id     : $JOB_ID")
    println(io, "method     : $JOB_METHOD")
    println(io, "tr_ratio   : $JOB_TR_RATIO")
    println(io, "n_rows     : $(nrow(batches))")
    println(io, "elapsed_s  : $(round(elapsed, digits=1))")
    println(io, "elapsed_min: $elapsed_min")
    println(io, "completed  : $(Dates.now())")
end

println("Done! Job $JOB_ID completed in $(elapsed_min) minutes.")
println("=" ^ 70)
