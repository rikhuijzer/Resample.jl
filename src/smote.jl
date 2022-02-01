"Default number of nearest neighbors for SMOTE"
const DEFAULT_K = 5

_npoints(data) = size(data, 2)

"""
Return one new point between the points A and B.
"""
function _new_point(A::AbstractVector, B::AbstractVector)
    @assert length(A) == length(B)
    l = length(A)
    dist = B .- A
    new_dist = dist .* rand(l)
    return A .+ new_dist
end

"""
Return one new point for some random point in `data`.
"""
function _new_point(rng::AbstractRNG, data::AbstractVecOrMat, tree, k)
    n_minority = _npoints(data)
    random_point_index = rand(1:n_minority)
    random_point = data[:, random_point_index]
    idxs, _ = knn(tree, random_point, k)
    random_neighbor_index = rand(idxs)
    random_neighbor = data[:, random_neighbor_index]
    new_point = _new_point(random_point, random_neighbor)
    return new_point
end

"The number of nearest neighbors is limited by the number of available datapoints"
_detect_k(data)::Int = min(DEFAULT_K, _npoints(data) - 1)

"""
    smote([rng=default_rng()], ...)

Return the sample obtained via Synthetic Minority Over-sampling TEchnique (SMOTE) (Chawla et al., [2002](https://doi.org/10.1613/jair.953)) for

- `data`: data where each column denotes a point
- `n`: number of synthetic points that should be created
- `k`: number of nearest neighbors to consider for each point

For each minority class, the algorithm creates synthetic points along the lines in between the `k` nearest neighbors.
The location of the point along the line is chosen randomly.

The implementation is based on the pseudocode from the paper, but do note that the paper has a weird API (especially `N`) and the implementation is full of indexing logic.
The essence is much simpler than the pseudocode:
To find `n` new points, take a random point `p` for each `n` from the minority group and for each `p` take a random point along the line to the nearest neighbor.
"""
function smote(
        rng::AbstractRNG,
        data::AbstractVecOrMat,
        n::Int;
        k::Int=_detect_k(data)
    )

    tree = KDTree(data)
    new_points = hcat([_new_point(rng, data, tree, k) for i in 1:n]...)
    return new_points
end

function smote(
        rng::AbstractRNG,
        data,
        n::Int;
        k::Int=_detect_k(data)
    )
    if !Tables.istable(data)
        T = typeof(data)
        msg = """
            Expected tabular data, matrix or vector.
            Got data of type $T.
            """
        error(ArgumentError(msg))
    end
    return smote(data, n; k)
end

smote(data, n; k::Int=_detect_k(data)) = smote(default_rng(), data, n; k)

