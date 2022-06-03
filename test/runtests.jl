include("preliminaries.jl")

@testset "smote" begin
    include("smote.jl")
end

@testset "mlj" begin
    include("mlj.jl")
end
