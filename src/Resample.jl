module Resample

using Random:
    AbstractRNG,
    default_rng
using NearestNeighbors

include("smote.jl")

export smote

end # module
