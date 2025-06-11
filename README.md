# ProteinBenchmarkTools

[![Build Status](https://github.com/MurrellGroup/ProteinBenchmarkTools.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/MurrellGroup/ProteinBenchmarkTools.jl/actions/workflows/CI.yml?query=branch%3Amain)

# Quick start

```julia
using Pkg;
Pkg.activate(--temp)
Pkg.add("")
using ProteinBenchmarkTools

backbone_dir = "demoinput"

# ntries is the number of times each backbone will get refolded. 
# best_scTMs includes only the maximum scTM for each backbone
# all_scTMs includes scTM from every try
best_scTMs, all_scTMs = run_designability(backbone_dir; ntries=10)

diversity_score = run_diversity(backbone_dir)

# optionally pass a foldseek database
pdbTMs = run_novelty(backbone_dir)
```