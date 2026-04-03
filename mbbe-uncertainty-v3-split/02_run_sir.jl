# ──────────────────────────────────────────────────────────────────────────────
# 02_run_sir.jl — Run batched BE simulations for the SIR method
#
# Requires: model_fit_results.jls (from 01_model_fit.jl)
# Outputs:  batches_sir.jls
# Run:      julia 02_run_sir.jl
# ──────────────────────────────────────────────────────────────────────────────

include(joinpath(@__DIR__, "common.jl"))

# ── Load Model Fit Results ───────────────────────────────────────────────────
fit_data = Serialization.deserialize(joinpath(@__DIR__, "model_fit_results.jls"))

sir_param_samples    = fit_data[:sir_param_samples]
global AUC_COL       = fit_data[:auc_col]
global CMAX_COL      = fit_data[:cmax_col]

println("Loaded model fit results. AUC=$AUC_COL, Cmax=$CMAX_COL")
println("Grid: $(length(SAMPLE_SIZES)) sizes × $(length(TR_RATIOS)) ratios × $N_BATCHES batches × $N_SIMS_PER_BATCH trials\n")

# ── Run SIR Method ───────────────────────────────────────────────────────────
println("Running SIR method...")
batches_sir = virtual_be_sim_batched(sir_param_samples, "SIR")

# ── Save ─────────────────────────────────────────────────────────────────────
outpath = joinpath(@__DIR__, "batches_sir.jls")
Serialization.serialize(outpath, batches_sir)
println("\nSaved $(nrow(batches_sir)) rows to: $outpath")
println("Done with 02_run_sir.jl")
