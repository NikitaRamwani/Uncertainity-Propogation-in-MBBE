# ──────────────────────────────────────────────────────────────────────────────
# 01_model_fit.jl — Fit PK model and extract uncertainty (VCOV, Bootstrap, SIR)
#
# This script:
#   1. Simulates a reference BE trial and fits the PK model with FOCE
#   2. Runs single-trial NCA to detect AUC/Cmax column names
#   3. Extracts parameter uncertainty via three methods:
#      - VCOV (asymptotic normal)
#      - Bootstrap (100 samples)
#      - SIR (200 samples, 100 resamples)
#   4. Estimates %CV for AUC and Cmax
#   5. Saves all results to model_fit_results.jls
#
# Run:  julia 01_model_fit.jl
# ──────────────────────────────────────────────────────────────────────────────

include(joinpath(@__DIR__, "common.jl"))

# ── Set Random Seed ──────────────────────────────────────────────────────────
Random.seed!(142)

# ── Simulate Reference Trial and Fit ─────────────────────────────────────────
println("Simulating reference trial...")
ref_sim = simulate_be_trial(θ_true; n_per_arm = 30)

sim_pop = read_pumas(
    DataFrame(ref_sim);
    id = :id, time = :time, observations = [:dv],
    amt = :amt, evid = :evid, covariates = [:TRT], cmt = :cmt
)

init = (
    tvcl  = 4.5,
    tvv   = 45.0,
    tvka  = 1.0,
    tvbio = 1.0,
    Ω     = Diagonal([0.1, 0.1, 0.1]),
    σ     = 0.3
)

println("Fitting model with FOCE...")
fit_res = fit(pkmodel, sim_pop, init, Pumas.FOCE())
θ̂ = coef(fit_res)

# ── Single-Trial BE (Reference Check) — detect NCA column names ─────────────
println("Running reference NCA to detect column names...")
simdf_ref = DataFrame(ref_sim)
simdf_ref.route .= "ev"
simdf_ref.dv .= max.(simdf_ref.dv, 0.0)

nca_tbl_ref = with_logger(NullLogger()) do
    ncapop_ref = read_nca(simdf_ref;
        id = :id, time = :time, amt = :amt,
        observations = :dv, route = :route, group = [:TRT]
    )
    nca_ref = run_nca(ncapop_ref)
    nca_ref.reportdf
end

# Set global NCA column names
global AUC_COL  = find_col(nca_tbl_ref, ["aucinf_obs", "aucinf", "auclast", "AUC", "auc"])
global CMAX_COL = find_col(nca_tbl_ref, ["cmax", "Cmax", "CMAX"])
println("Using NCA columns: AUC = $AUC_COL, Cmax = $CMAX_COL")

# ── Method 1: VCOV (Asymptotic Normal) ──────────────────────────────────────
println("Extracting VCOV uncertainty...")
vcov_param_samples = sample_from_vcov(θ̂, vcov(fit_res), 200)

# ── Method 2: Bootstrap ─────────────────────────────────────────────────────
println("Running Bootstrap inference (100 samples)...")
boot_settings = Bootstrap(
    samples = 100,
    stratify_by = nothing,
    ensemblealg = EnsembleThreads()
)
boot_inf = infer(fit_res, boot_settings; level = 0.95)
boot_param_samples = sample_from_vcov(coef(boot_inf), vcov(boot_inf), 200)

# ── Method 3: SIR ───────────────────────────────────────────────────────────
println("Running SIR inference (200 samples, 100 resamples)...")
sir_settings = SIR(samples = 200, resamples = 100)
sir_inf = infer(fit_res, sir_settings; level = 0.95)
sir_param_samples = sample_from_vcov(coef(sir_inf), vcov(sir_inf), 200)

# ── Fixed parameter samples ─────────────────────────────────────────────────
fixed_param_samples = fill(θ̂, 100)

# ── %CV Estimation ───────────────────────────────────────────────────────────
println("Estimating %CV (100 reps at n=60 per arm)...")
cv_estimates = estimate_cv(fixed_param_samples; n_per_arm = 60, n_reps = 100)
println("AUC  %CV = $(round(cv_estimates.auc_cv, digits=1))%")
println("Cmax %CV = $(round(cv_estimates.cmax_cv, digits=1))%")

# ── Save Results ─────────────────────────────────────────────────────────────
results = Dict(
    :θ̂                   => θ̂,
    :fixed_param_samples  => fixed_param_samples,
    :vcov_param_samples   => vcov_param_samples,
    :boot_param_samples   => boot_param_samples,
    :sir_param_samples    => sir_param_samples,
    :auc_col              => AUC_COL,
    :cmax_col             => CMAX_COL,
    :cv_estimates         => cv_estimates,
)

outpath = joinpath(@__DIR__, "model_fit_results.jls")
Serialization.serialize(outpath, results)
println("\nSaved model fit results to: $outpath")
println("Done with 01_model_fit.jl")
