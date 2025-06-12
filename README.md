# ProteinBenchmarkTools

[![Build Status](https://github.com/MurrellGroup/ProteinBenchmarkTools.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/MurrellGroup/ProteinBenchmarkTools.jl/actions/workflows/CI.yml?query=branch%3Amain)

# Quick start

```julia
using Pkg;
Pkg.activate("--temp")
Pkg.add(url="https://github.com/MurrellGroup/ProteinRefolding.jl")
Pkg.add(url="https://github.com/MurrellGroup/ProteinBenchmarkTools.jl")
using ProteinBenchmarkTools

backbone_dir = "demoinput"
output_dir = "demooutput"

# ntries is the number of times each backbone will get refolded. 
run_benchmark(backbone_dir, output_dir; ntries=10)
results = get_results(output_dir)
```