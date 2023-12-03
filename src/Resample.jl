module Resample

import MLJModelInterface

using Distances: euclidean
using Random:
    AbstractRNG,
    default_rng
using NearestNeighbors
using Tables


include("smote.jl")
export smote

include("mlj.jl")
export Smote

# Trigger precomilation on some functions by running a minimal workload.
if ccall(:jl_generating_output, Cint, ()) == 1
    data = (; X=[1, 2, 1, 2, 1], class=[1, 2, 1, 2, 1])
    smote(data, :class)
end

end # module
