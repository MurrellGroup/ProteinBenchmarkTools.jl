module Novelty

using Foldseek_jll

export run_novelty

function getpdb(dir)
    if !isfile(joinpath(dir, "pdb"))
        @info "Downloading pdb foldseek database"
        cd(dir) do
            run(`$(foldseek().exec) databases PDB pdb tmp`)
        end
    else 
        @info "Database already exists. Skipping downlaod"
    end
end

function run_novelty(backbone_dir::AbstractString, tmpdir::AbstractString; foldseek_database=nothing)
    mkpath(tmpdir)
    if isnothing(foldseek_database)
        @info "Defaulting to PDB as foldseek database"
        mkpath(joinpath("foldseek_databases", "pdb"))
        getpdb(joinpath("foldseek_databases", "pdb"))
        foldseek_database = joinpath("foldseek_databases", "pdb", "pdb")
    end

    pdbTMs = Dict()
    for f in readdir(backbone_dir; join=true)
        @info "running"
        resultpath = joinpath(tmpdir, basename(f) * "_result")
        run(`$(foldseek().exec) easy-search $(f) $(foldseek_database) $(resultpath) $(joinpath(tmpdir, "tmp")) --format-output alntmscore`)
        pdbTMs[basename(f)] = open(resultpath, "r") do io
            # Shouldn't have to do maximum, since it seems to be sorted, but that's alright
            maximum(parse.(Float64, eachline(io)))
        end
    end

    return pdbTMs
end
run_novelty(backbone_dir) = mktempdir(tmpdir -> run_novelty(backbone_dir, tmpdir))

end