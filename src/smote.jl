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
function _new_point(rng, A::AbstractVector, B::AbstractVector)
    @assert length(A) == length(B)
    # Avoids allocating a temporary matrix, unlike `(B .- A) .* rand() .+ A`.`
    x = rand(rng)
    return (1 - x) .* A .+ x .* B
end

_point(data::AbstractMatrix, index) = data[:, index]

"""
Return a random neighbor from the `k` nearest neighbors for `random_point`.
Since `NearestNeighbors.knn` also works for finding the nearest neighbor for points that are not in `data`, it will also return `random_point` as a nearest neighbor.
So, we call `knn(..., k + 1)` and throw away the first result.
We could avoid this by creating a new tree for each search, but that is more expensive.
"""
function _random_neighbor(rng, tree, data, random_point, k)
    sortres = true
    idxs, dists = knn(tree, random_point, k + 1, true)
    popfirst!(idxs)
    random_neighbor_index = rand(rng, idxs)
    random_neighbor = _point(data, random_neighbor_index)
    return random_neighbor
end

"""
Return one new point for some random point in `data`.
"""
function _new_point(rng::AbstractRNG, data::AbstractVecOrMat, tree, k)
    n_minority = _npoints(data)
    random_point_index = rand(rng, 1:n_minority)
    random_point = _point(data, random_point_index)
    random_neighbor = _random_neighbor(rng, tree, data, random_point, k)
    new_point = _new_point(rng, random_point, random_neighbor)
    return new_point
end

"The number of nearest neighbors is limited by the number of available datapoints"
_detect_k(data::AbstractVecOrMat)::Int = min(DEFAULT_K, _npoints(data) - 1)

"""
    smote([rng=default_rng()], data::AbstractVecOrMat, n::Int; k::Union{Nothing,Int}=nothing)
    smote([rng=default_rng()], data, n::Int; k::Union{Nothing,Int}=nothing)

Return the sample obtained via Synthetic Minority Over-sampling TEchnique (SMOTE) (Chawla et al., [2002](https://doi.org/10.1613/jair.953)) for

- `data`: Data as a matrix or satisfying the tables interface.
    For matices, each column denotes a point and for tables each row denotes a point.
- `n`: Number of synthetic points that should be created.
- `k`: Number of nearest neighbors to consider for each point.

For each minority class, the algorithm creates synthetic points along the lines in between one of the `k` nearest neighbors.
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
    if eltype(data) == Int
        data = convert(Matrix{Float64}, data)
    end
    tree = KDTree(data)
    dk = _detect_k(data)
    new_points = hcat([_new_point(rng, data, tree, dk) for i in 1:n]...)
    return new_points
end

function _check_table(data)
    if !Tables.istable(data)
        T = typeof(data)
        msg = """
            Expected tabular data, matrix or vector.
            Got data of type $T.
            """
        error(ArgumentError(msg))
    end
end

function smote(
        rng::AbstractRNG,
        data,
        n::Int;
        k::Union{Nothing,Int}=nothing
    )
    _check_table(data)
    mat = Tables.matrix(data; transpose=true)
    new_points = smote(rng, mat, n; k)

    header = Tables.columnnames(data)
    table = Tables.table(transpose(new_points); header)
    return table
end

smote(data, n::Int; k::Union{Nothing,Int}=nothing) = smote(default_rng(), data, n; k)

_col2int(data, col::Int) = col
function _col2int(data, col::Union{Symbol,AbstractString})
    colname = Symbol(col)::Symbol
    nms = Tables.columnnames(data)
    @assert eltype(nms) == Symbol
    index = findfirst(==(colname), nms)
    if isnothing(index)
        return error("Could not find `$colname` in data.")
    end
    return index
end

"""
    smote(rng::AbstractRNG, data, col::Union{Int,AbstractString,Symbol}; ratio::Real=1.0, k::Union{Nothing,Int}=nothing)
    smote(data, col::Union{AbstractString,Symbol}; ratio::Real=1.0, k::Union{Nothing,Int}=nothing)

This is a helper function to simplify balancing `data`.
Return the sample obtained via Synthetic Minority Over-sampling TEchnique (SMOTE) for

- `data`: Data as a matrix or satisfying the tables interface. For matices, each column denotes a point and for tables each row denotes a point.
- `col`: A column number or name specifying on which column the oversampling needs to be based.
- `ratio`:
    Here, `ratio` specifies the desired ratio between the element types in `col`.
    For example, when column `:class` contains 1200 elements of class 1 and 1400 elements of class 2, then `smote(data, :class; ratio=1.0)` will add 200 elements of class 1.
    With a ratio of 0.9, smote will add only 60 elements since class 1 comes first in the data and 1400 * 0.9 = 1260 assuming that class 1 comes first in the data and then class 2.
    If class 2 would come first, then the ratio of 0.9 will fail since it would need to remove elements from class 1.
- `k`: Number of nearest neighbors to consider for each point.

!!! note
    This functionality is currently only implemented for 2 classes.
"""
function smote(
        rng::AbstractRNG,
        data,
        col::Union{Int,AbstractString,Symbol};
        ratio::Real=1.0,
        k::Union{Nothing,Int}=nothing
    )
    _check_table(data)
    col_int = _col2int(data, col)
    mat = Tables.matrix(data; transpose=false)
    categories = @view mat[:, col_int]
    unique_cat = unique(categories)
    if length(unique_cat) != 2
        error("This functionality is currently only implemented for 2 classes.")
    end
    n_cat = [count(cat .== categories) for cat in unique_cat]
    actual_minority_class_size = n_cat[2]
    expected_minority_class_size = n_cat[1] * ratio
    n = round(Int, expected_minority_class_size - actual_minority_class_size)
    if n < 1
        error("SMOTE can only add elements; not remove them. Try changing the ratio.")
    end
    minority = let
        bitvec = categories .== unique_cat[2]
        minority_data = mat[bitvec, :]
        header = Tables.columnnames(data)
        Tables.table(minority_data; header)
    end
    return smote(rng, minority, n; k)
end
function smote(data, col::Union{AbstractString,Symbol}; ratio::Real=1.0, k::Union{Nothing,Int}=nothing)
    return smote(default_rng(), data, col; ratio, k)
end
