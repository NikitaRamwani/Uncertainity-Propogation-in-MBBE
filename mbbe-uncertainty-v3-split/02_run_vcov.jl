# ──────────────────────────────────────────────────────────────────────────────
# 02_run_vcov.jl — Run batched BE simulations for the VCOV method
#
# Requires: model_fit_results.jls (from 01_model_fit.jl)
# Outputs:  batches_vcov.jls
# Run:      julia 02_run_vcov.jl
# ──────────────────────────────────────────────────────────────────────────────

include(joinpath(@__DIR__, "common.jl"))

# ── Load Model Fit Results ───────────────────────────────────────────────────
fit_data = Serialization.deserialize(joinpath(@__DIR__, "model_fit_results.jls"))

vcov_param_samples   = fit_data[:vcov_param_samples]
global AUC_COL       = fit_data[:auc_col]
global CMAX_COL      = fit_data[:cmax_col]

println("Loaded model fit results. AUC=$AUC_COL, Cmax=$CMAX_COL")
println("Grid: $(length(SAMPLE_SIZES)) sizes × $(length(TR_RATIOS)) ratios × $N_BATCHES batches × $N_SIMS_PER_BATCH trials\n")

# ── Run VCOV Method ──────────────────────────────────────────────────────────
println("Running VCOV method...")
batches_vcov = virtual_be_sim_batched(vcov_param_samples, "VCOV")

# ── Save ─────────────────────────────────────────────────────────────────────
outpath = joinpath(@__DIR__, "batches_vcov.jls")
Serialization.serialize(outpath, batches_vcov)
println("\nSaved $(nrow(batches_vcov)) rows to: $outpath")
println("Done with 02_run_vcov.jl")
