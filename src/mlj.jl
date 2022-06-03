Base.@kwdef struct Smote <: MLJModelInterface.Static
    col::Union{Int,AbstractString,Symbol}
    rng::AbstractRNG=default_rng()
    ratio::Real=1.0
    k::Union{Nothing,Int}=nothing
end

function MLJModelInterface.transform(m::Smote, verbosity, data)
    return smote(m.rng, data, m.col; m.ratio, m.k)
end
