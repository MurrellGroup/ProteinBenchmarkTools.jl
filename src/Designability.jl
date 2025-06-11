module Designability

using ProteinRefolding
#using USalign_jll

export run_designability

function run_designability(proteinfiles::AbstractVector{<:String}, args...; ntries=10, kws...)
    all_runs = Dict{String, Vector{Float64}}()
    for nth_try in 1:ntries
        results = refold(proteinfiles, args...; kws...)
        for (tmresult, predictedprot) in zip(results.tmresults, results.predicted_proteins)
            @assert tmresult.isoptimal

            scTMs = get!(all_runs, predictedprot.name, Float64[])
            push!(scTMs, tmresult.tmresult.tmscore)
        end
    end

    best_run = Dict([key => maximum(val) for (key, val) in pairs(all_runs)])
    return best_run, all_runs
end
run_designability(backbone_dir::AbstractString, args...; kws...) = run_designability(readdir(backbone_dir; join=true), args...; kws...)

end