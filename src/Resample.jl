module Resample

using Distances: euclidean
using Random:
    AbstractRNG,
    default_rng
using NearestNeighbors
using Tables

include("smote.jl")

export smote

end # module
