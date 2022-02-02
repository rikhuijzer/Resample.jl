module Resample

using Random:
    AbstractRNG,
    default_rng
using NearestNeighbors
using Tables

include("smote.jl")

export smote

end # module
