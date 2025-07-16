module Designability

using ProteinRefolding
using ProteinChains
using USalign_jll

export run_refold, calc_sctm, run_designability

function run_refold(proteinfiles::AbstractVector{<:String}, output_dir, args...; ntries=1, write_preprocessed=true, kws...)
    for nth_try in 1:ntries
        results = refold(proteinfiles, args...; kws...)

        nth_dir = joinpath(output_dir, "samples_$(nth_try)")

        for (prepped, predicted) in zip(results.preprocessed_proteins, results.predicted_proteins)
            if write_preprocessed
                mkpath(joinpath(nth_dir, "preprocessed"))
                writepdb(joinpath(nth_dir, "preprocessed", prepped.name), prepped)
            end
            mkpath(joinpath(nth_dir, "predicted"))
            writepdb(joinpath(nth_dir, "predicted", prepped.name), predicted)
        end
    end
end
run_refold(backbone_dir::AbstractString, output_dir, args...; kws...) = run_refold(readdir(backbone_dir; join=true), output_dir, args...; kws...)

function run_mmalign(prot1, prot2)
    # TODO handle error
    # TODO Is `-ter 0 -split 1` really correct?
    out_io = IOBuffer()
    err_io = IOBuffer()
    cmd = `$(MMalign().exec) "$(prot1)" "$(prot2)" -ter 0 -split 1 -outfmt 2 -mol protein`
    run(pipeline(cmd; stdout=out_io, stderr=err_io))
    output = String(take!(out_io))

    lines = split(output, "\n")
    header = split(lines[1])
    _values = split(lines[2])
    dict = Dict([key=>val for (key, val) in zip(header, _values)])

    @assert dict["TM1"] == dict["TM2"]
    return parse(Float64, dict["TM1"])
end

function calc_sctm(output_dir)
    cd(output_dir) do
        scTMs_dict = Dict()
        samples = filter(x -> isdir(x) && startswith(basename(x), "samples"), readdir(; join=true))
        for samp in samples
            prepped = readdir(joinpath(samp, "preprocessed"); join=true)
            predicted = readdir(joinpath(samp, "predicted"); join=true)
            for (prep, pred) in zip(prepped, predicted)
                scTMs = get!(scTMs_dict, basename(prep), Float64[])
                scTM = run_mmalign(prep, pred)
                push!(scTMs, scTM)
            end
        end
        return scTMs_dict
    end
end

function run_designability(proteinfiles::AbstractVector{<:String}, output_dir, args...; ntries=1, kws...)
    run_refold(proteinfiles::AbstractVector{<:String}, output_dir, args...; ntries, kws...)
    calc_sctm(output_dir)
end

end