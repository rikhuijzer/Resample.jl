"Default number of nearest neighbors for SMOTE"
const DEFAULT_K = 15

_npoints(data::AbstractMatrix) = size(data, 2)

function _npoints(data)
    @assert Tables.istable(data)
    return Tables.rowcount(data)
end

_ndims(data::AbstractMatrix) = size(data, 1)

function _ndims(data)
    @assert Tables.istable(data)
    return length(Tables.names(data))
end

_distance(x, y) = euclidean(x, y)

"Return whether point `a` is approximately in between `b` and `c`."
function _is_in_between(a, b, c; atol=0.01)::Bool
    dist_ab = _distance(b, a)
    dist_ac = _distance(c, a)
    dist_total = _distance(c, b)
    return isapprox(dist_ab + dist_ac, dist_total; atol)
end

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

_point(data::AbstractMatrix, index) = data[:, index]

"""
Return a random neighbor from the `k` nearest neighbors for `random_point`.
Since `NearestNeighbors.knn` also works for finding the nearest neighbor for points that are not in `data`, it will also return `random_point` as a nearest neighbor.
So, we call `knn(..., k + 1)` and throw away the first result.
We could avoid this by creating a new tree for each search, but that is more expensive.
"""
function _random_neighbor(tree, data, random_point, k)
    sortres = true
    idxs, dists = knn(tree, random_point, k + 1, true)
    popfirst!(idxs)
    random_result_index = rand(1:length(idxs))
    random_neighbor_index = idxs[random_result_index]
    random_neighbor = _point(data, random_neighbor_index)
    distance = dists[random_result_index]
    return random_neighbor, distance
end

"""
Return one new point for some random point in `data`.
"""
function _new_point(rng::AbstractRNG, data::AbstractVecOrMat, tree, k)
    n_minority = _npoints(data)
    random_point_index = rand(1:n_minority)
    random_point = _point(data, random_point_index)
    random_neighbor, distance = _random_neighbor(tree, data, random_point, k)
    new_point = _new_point(random_point, random_neighbor)
    return new_point
end

"The number of nearest neighbors is limited by the number of available datapoints"
_detect_k(data::AbstractVecOrMat)::Int = min(DEFAULT_K, _npoints(data) - 1)

"""
    smote([rng=default_rng()], ...)

Return the sample obtained via Synthetic Minority Over-sampling TEchnique (SMOTE) (Chawla et al., [2002](https://doi.org/10.1613/jair.953)) for

- `data`: Data where each column denotes a point.
- `n`: Number of synthetic points that should be created.
- `k`: Number of nearest neighbors to consider for each point.

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
        k::Union{Nothing,Int}=nothing
    )
    tree = KDTree(data)
    dk = _detect_k(data)
    new_points = hcat([_new_point(rng, data, tree, dk) for i in 1:n]...)
    return new_points
end

function smote(
        rng::AbstractRNG,
        data,
        n::Int;
        k::Union{Nothing,Int}=nothing
    )
    if !Tables.istable(data)
        T = typeof(data)
        msg = """
            Expected tabular data, matrix or vector.
            Got data of type $T.
            """
        error(ArgumentError(msg))
    end
    mat = Tables.matrix(data; transpose=true)
    new_points = smote(mat, n; k)

    header = Tables.columnnames(data)
    table = Tables.table(transpose(new_points); header)
    return table
end

smote(data, n; k::Union{Nothing,Int}=nothing) = smote(default_rng(), data, n; k)

