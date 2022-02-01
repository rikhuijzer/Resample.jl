"""
    smote([rng=default_rng()], ...)

Return the sample obtained via Synthetic Minority Over-sampling TEchnique (SMOTE) (Chawla et al., [2002](https://doi.org/10.1613/jair.953)) for

- `data`: data where each column denotes a point
- `t`: minority class samples
- `n`: amount of SMOTE `n` (in percentage)
- `k`: number of nearest neighbors
Here, `n == 0.0` means that no data will be added an `n == 1.0` means that the sample size of the minority class will double.

For each minority class, the algorithm creates synthetic examples along the lines in between the `k` nearest neighbors.
The location of the point along the line is chosen randomly.
"""
function smote(
        rng::AbstractRNG,
        data::AbstractVecOrMat,
        t::Int,
        n::Real;
        k::Int=5
    )

    if n < 100
        1
    end

end

function smote(
        rng::AbstractRNG,
        data,
        t::Int,
        n::Real;
        k::Int=5
    )
    if !Tables.istable(data)
        T = typeof(data)
        msg = """
            Expected tabular data, matrix or vector.
            Got data of type $T.
            """
        error(ArgumentError(msg))
    end
    return smote(rng, data, t, n; k)
end

smote(data, t, n; k::Int=5) = smote(default_rng(), data, t, n; k)

