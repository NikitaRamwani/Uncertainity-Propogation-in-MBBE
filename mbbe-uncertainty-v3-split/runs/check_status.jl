# ──────────────────────────────────────────────────────────────────────────────
# check_status.jl — Show which jobs have been completed
#
# Run:  julia runs/check_status.jl
# ──────────────────────────────────────────────────────────────────────────────

using Dates

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

outdir = joinpath(@__DIR__, "output")

println("=" ^ 72)
println("  JOB STATUS — $(Dates.now())")
println("=" ^ 72)
println()

n_done = 0
n_total = length(JOBS)
total_elapsed = 0.0

for (id, method, tr, tag) in JOBS
    id_str   = lpad(id, 2, '0')
    donefile = joinpath(outdir, "job_$(id_str)_$(tag).done")
    jlsfile  = joinpath(outdir, "job_$(id_str)_$(tag).jls")

    if isfile(donefile)
        # Parse elapsed time from .done file
        elapsed_str = ""
        completed_str = ""
        for line in readlines(donefile)
            if startswith(line, "elapsed_min:")
                elapsed_str = strip(split(line, ":"; limit=2)[2])
            elseif startswith(line, "completed")
                completed_str = strip(split(line, ":"; limit=2)[2])
            end
        end
        elapsed_min = tryparse(Float64, elapsed_str)
        if elapsed_min !== nothing
            total_elapsed += elapsed_min
        end
        status = "✓ DONE  ($(elapsed_str) min, $(completed_str))"
        n_done += 1
    elseif isfile(jlsfile)
        status = "? PARTIAL (.jls exists but no .done marker)"
    else
        status = "· PENDING"
    end

    println("  Job $(id_str) | $(rpad(method, 9)) | T/R=$(tr) | $status")
end

println()
println("-" ^ 72)
println("  Progress: $n_done / $n_total jobs completed")
if n_done > 0
    avg_min = round(total_elapsed / n_done, digits=1)
    remaining = n_total - n_done
    est_remaining = round(avg_min * remaining, digits=0)
    println("  Avg time per job: $(avg_min) min")
    println("  Est. remaining  : ~$(est_remaining) min (~$(round(est_remaining/60, digits=1)) hours)")
end
println("=" ^ 72)
