module ProteinBenchmarkTools

# Write your package code here.
include("Designability.jl")
include("Diversity.jl")
include("Novelty.jl")

using .Designability, .Diversity, .Novelty

export run_benchmark,
    get_results, 
    run_refold,
    run_cluster,
    run_search, 
    calc_sctm,
    calc_diversity,
    get_novelty

function run_benchmark(backbone_dir, output_dir; kws...)
    run_refold(backbone_dir, output_dir; kws...)
    run_cluster(backbone_dir, output_dir)
    run_search(backbone_dir, output_dir)
end

function get_results(output_dir)
    (; designability=calc_sctm(output_dir), diversity=calc_diversity(output_dir), novelty=get_novelty(output_dir))
end

end
