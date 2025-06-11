module Diversity

using Foldseek_jll

export run_diversity

function read_tsv(filename)
    name2reprname = Dict{String, String}()
    open(filename, "r") do f
        for line in eachline(f)
            reprname, name = split(line)
            @assert name ∉ keys(name2reprname)
            name2reprname[name] = reprname
        end
    end
    name2reprname
end

function run_diversity(backbones_dir::AbstractString, tmpdir::AbstractString)
    mkpath(tmpdir)
    run(`$(foldseek().exec) easy-cluster $backbones_dir $(joinpath(tmpdir, "result")) $(joinpath(tmpdir))`)

    # Read out_cluster.tsv
    name2reprname = read_tsv(joinpath(tmpdir, "result") * "_cluster.tsv")
    num_clusters = length(unique(values(name2reprname)))
    num_backbones = length(keys(name2reprname))

    return num_clusters / num_backbones
end
run_diversity(backbones_dir) = mktempdir(tmpdir -> run_diversity(backbones_dir, tmpdir))

end