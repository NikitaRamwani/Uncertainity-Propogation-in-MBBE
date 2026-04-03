# ──────────────────────────────────────────────────────────────────────────────
# 02_run_bootstrap.jl — Run batched BE simulations for the Bootstrap method
#
# Requires: model_fit_results.jls (from 01_model_fit.jl)
# Outputs:  batches_bootstrap.jls
# Run:      julia 02_run_bootstrap.jl
# ──────────────────────────────────────────────────────────────────────────────

include(joinpath(@__DIR__, "common.jl"))

# ── Load Model Fit Results ───────────────────────────────────────────────────
fit_data = Serialization.deserialize(joinpath(@__DIR__, "model_fit_results.jls"))

boot_param_samples   = fit_data[:boot_param_samples]
global AUC_COL       = fit_data[:auc_col]
global CMAX_COL      = fit_data[:cmax_col]

println("Loaded model fit results. AUC=$AUC_COL, Cmax=$CMAX_COL")
println("Grid: $(length(SAMPLE_SIZES)) sizes × $(length(TR_RATIOS)) ratios × $N_BATCHES batches × $N_SIMS_PER_BATCH trials\n")

# ── Run Bootstrap Method ─────────────────────────────────────────────────────
println("Running Bootstrap method...")
batches_boot = virtual_be_sim_batched(boot_param_samples, "Bootstrap")

# ── Save ─────────────────────────────────────────────────────────────────────
outpath = joinpath(@__DIR__, "batches_bootstrap.jls")
Serialization.serialize(outpath, batches_boot)
println("\nSaved $(nrow(batches_boot)) rows to: $outpath")
println("Done with 02_run_bootstrap.jl")
