module Diversity

using Foldseek_jll

export run_cluster, calc_diversity, run_diversity

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

function run_cluster(backbones_dir, output_dir)
    mkpath(output_dir)
    run(`$(foldseek().exec) easy-cluster $backbones_dir $(joinpath(output_dir, "diversity_result")) $(joinpath(output_dir, "tmp"))`)
end

function calc_diversity(output_dir)
    diversity_filename = joinpath(output_dir, "diversity_result_cluster.tsv")
    name2reprname = read_tsv(diversity_filename)
    num_clusters = length(unique(values(name2reprname)))
    num_backbones = length(keys(name2reprname))
    return num_clusters / num_backbones
end

function run_diversity(backbones_dir::AbstractString, output_dir::AbstractString)
    run_cluster(backbones_dir, output_dir)
    calc_diversity(output_dir)
end
run_diversity(backbones_dir) = mktempdir(tmpdir -> run_diversity(backbones_dir, tmpdir))

end