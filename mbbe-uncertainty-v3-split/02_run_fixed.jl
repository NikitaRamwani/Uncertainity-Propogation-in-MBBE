# ──────────────────────────────────────────────────────────────────────────────
# 02_run_fixed.jl — Run batched BE simulations for the Fixed (plug-in) method
#
# Requires: model_fit_results.jls (from 01_model_fit.jl)
# Outputs:  batches_fixed.jls
# Run:      julia 02_run_fixed.jl
# ──────────────────────────────────────────────────────────────────────────────

include(joinpath(@__DIR__, "common.jl"))

# ── Load Model Fit Results ───────────────────────────────────────────────────
fit_data = Serialization.deserialize(joinpath(@__DIR__, "model_fit_results.jls"))

fixed_param_samples  = fit_data[:fixed_param_samples]
global AUC_COL       = fit_data[:auc_col]
global CMAX_COL      = fit_data[:cmax_col]

println("Loaded model fit results. AUC=$AUC_COL, Cmax=$CMAX_COL")
println("Grid: $(length(SAMPLE_SIZES)) sizes × $(length(TR_RATIOS)) ratios × $N_BATCHES batches × $N_SIMS_PER_BATCH trials\n")

# ── Run Fixed Method ─────────────────────────────────────────────────────────
println("Running Fixed method...")
batches_fixed = virtual_be_sim_batched(fixed_param_samples, "Fixed")

# ── Save ─────────────────────────────────────────────────────────────────────
outpath = joinpath(@__DIR__, "batches_fixed.jls")
Serialization.serialize(outpath, batches_fixed)
println("\nSaved $(nrow(batches_fixed)) rows to: $outpath")
println("Done with 02_run_fixed.jl")
