"""
    smote([rng=GLOBAL_RNG], ...)

Return the sample obtained via Synthetic Minority Over-sampling TEchnique (SMOTE) (Chawla et al., [2002](https://doi.org/10.1613/jair.953)) for minority class samples `t`, amount of SMOTE `n` (in percentage) and number of nearest neighbors `k`.
Here, `n == 0.0` means that no data will be added an `n == 1.0` means that the sample size of the minority class will double.

For each minority class, the algorithm creates synthetic examples along the lines in between the `k` nearest neighbors.
The location of the point along the line is chosen randomly.
"""
function smote(rng::AbstractRNG, t::Int, n::Real, data; k::Int=5)
    if !Tables.istable(data)
        error(ArgumentError("Expected tabular data."))
    end

    if n < 100
    end

end

smote(t, n, data; k::Int=5) = smote(default_rng(), n, data; k)

