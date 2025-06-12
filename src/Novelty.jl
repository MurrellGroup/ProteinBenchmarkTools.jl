module Novelty

using Foldseek_jll

export run_search, get_novelty, run_novelty

const STANDARD_FORMAT_OUTPUT = "query,target,alntmscore,qtmscore,ttmscore"
const FORMAT_OUTPUT_COLUMNS = Dict([x=>i for (i, x) in enumerate(split(STANDARD_FORMAT_OUTPUT, ","))])

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

function get_novelty(output_dir; tmscore_col="alntmscore")
    novelty_dir = joinpath(output_dir, "novelty")
    result_files = filter(f -> isfile(f) && endswith(f, "_result"), readdir(novelty_dir; join=true))

    dict = Dict()
    for filename in result_files
        name = basename(filename)[1 : end-length("_result")]
        targets = open(filename, "r") do f
            map(eachline(f)) do line
                row = split(line)
                (; target=row[FORMAT_OUTPUT_COLUMNS["target"]], tmscore=parse(Float64, row[FORMAT_OUTPUT_COLUMNS[tmscore_col]]))
            end
        end
        sort!(targets; by=x->x.tmscore)
        dict[name] = isempty(targets) ? nothing : last(targets)
    end
    dict
end

function run_search(backbone_dir::AbstractString, output_dir::AbstractString; foldseek_database=nothing)
    if isnothing(foldseek_database)
        @info "Defaulting to PDB as foldseek database"
        mkpath(joinpath("foldseek_databases", "pdb"))
        getpdb(joinpath("foldseek_databases", "pdb"))
        foldseek_database = joinpath("foldseek_databases", "pdb", "pdb")
    end
    novelty_dir = mkpath(joinpath(output_dir, "novelty"))


    for f in readdir(backbone_dir; join=true)
        resultpath = joinpath(novelty_dir, basename(f) * "_result")
        run(`$(foldseek().exec) easy-search $(f) $(foldseek_database) $(resultpath) $(joinpath(novelty_dir, "tmp")) --format-output "$(STANDARD_FORMAT_OUTPUT)" --alignment-type 1 -e inf`)
    end
end

function run_novelty(backbone_dir::AbstractString, output_dir::AbstractString; foldseek_database=nothing)
    run_search(backbone_dir, output_dir; foldseek_database)
    get_novelty(output_dir)
end


end