# ──────────────────────────────────────────────────────────────────────────────
# combine_results.jl — Merge all completed job outputs into final .jls files
#
# This recreates the same output format as the original 02_run_*.jl scripts:
#   batches_fixed.jls, batches_vcov.jls, batches_bootstrap.jls, batches_sir.jls
#
# These are saved to the parent directory so that 03_results_tables.qmd and
# 04_visualizations.qmd work without changes.
#
# Run:  julia runs/combine_results.jl
# ──────────────────────────────────────────────────────────────────────────────

using Serialization
using DataFrames

# Job table: (id, method, tr_ratio, tag)
const JOBS = [
    ( 1, "Fixed",     0.70, "fixed_tr070"),
    ( 2, "Fixed",     0.90, "fixed_tr090"),
    ( 3, "Fixed",     1.00, "fixed_tr100"),
    ( 4, "Fixed",     1.10, "fixed_tr110"),
    ( 5, "Fixed",     1.30, "fixed_tr130"),
    ( 6, "VCOV",      0.70, "vcov_tr070"),
    ( 7, "VCOV",      0.90, "vcov_tr090"),
    ( 8, "VCOV",      1.00, "vcov_tr100"),
    ( 9, "VCOV",      1.10, "vcov_tr110"),
    (10, "VCOV",      1.30, "vcov_tr130"),
    (11, "Bootstrap", 0.70, "bootstrap_tr070"),
    (12, "Bootstrap", 0.90, "bootstrap_tr090"),
    (13, "Bootstrap", 1.00, "bootstrap_tr100"),
    (14, "Bootstrap", 1.10, "bootstrap_tr110"),
    (15, "Bootstrap", 1.30, "bootstrap_tr130"),
    (16, "SIR",       0.70, "sir_tr070"),
    (17, "SIR",       0.90, "sir_tr090"),
    (18, "SIR",       1.00, "sir_tr100"),
    (19, "SIR",       1.10, "sir_tr110"),
    (20, "SIR",       1.30, "sir_tr130"),
]

outdir    = joinpath(@__DIR__, "output")
parentdir = joinpath(@__DIR__, "..")

# Method → output filename
method_files = Dict(
    "Fixed"     => "batches_fixed.jls",
    "VCOV"      => "batches_vcov.jls",
    "Bootstrap" => "batches_bootstrap.jls",
    "SIR"       => "batches_sir.jls",
)

println("Combining job outputs...")
println()

# Collect per-method DataFrames
method_dfs = Dict{String, DataFrame}()
missing_jobs = Tuple[]

for (id, method, tr, tag) in JOBS
    id_str  = lpad(id, 2, '0')
    jlsfile = joinpath(outdir, "job_$(id_str)_$(tag).jls")

    if !isfile(jlsfile)
        push!(missing_jobs, (id, method, tr, tag))
        continue
    end

    df = Serialization.deserialize(jlsfile)
    if haskey(method_dfs, method)
        method_dfs[method] = vcat(method_dfs[method], df)
    else
        method_dfs[method] = df
    end
    println("  Loaded job $(id_str) — $(method) @ T/R=$(tr) ($(nrow(df)) rows)")
end

if !isempty(missing_jobs)
    println()
    println("WARNING: $(length(missing_jobs)) job(s) not yet completed:")
    for (id, method, tr, tag) in missing_jobs
        println("  Job $(lpad(id, 2, '0')) — $(method) @ T/R=$(tr)")
    end
    println()
    print("Continue with partial results? (y/n): ")
    resp = readline()
    if lowercase(strip(resp)) != "y"
        println("Aborted.")
        exit(0)
    end
end

println()

for (method, filename) in method_files
    if !haskey(method_dfs, method)
        println("  SKIP $(filename) — no data for $(method)")
        continue
    end
    df = method_dfs[method]
    outpath = joinpath(parentdir, filename)
    Serialization.serialize(outpath, df)
    println("  Saved $(filename) — $(nrow(df)) rows")
end

println()
println("Done! Combined results saved to parent directory.")
println("You can now run 03_results_tables.qmd and 04_visualizations.qmd.")
