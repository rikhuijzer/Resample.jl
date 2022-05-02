# 2D points in some minority class.
p1_x = 0.0
p1_y = 2.0
p2_x = 1.0
p2_y = 3.0

data = [p1_x p2_x;
        p1_y p2_y]

@test Resample._detect_k(data) == 1

n = 2
new_points = smote(data, n)
@test Resample._npoints(new_points) == n

for p in eachcol(new_points)
    @test Resample._is_in_between(p, [p1_x, p1_y], [p2_x, p2_y]) == true
end

n = 100
ndims = 30
data = rand(ndims, 10_000)
new_points = smote(data, n)
@test Resample._npoints(new_points) == n
@test Resample._ndims(new_points) == ndims

n = 4
ndims = 2
data = (; x=[p1_x, p2_x], y=[p1_y, p2_y])
new_points = smote(data, n)
@test Resample._npoints(new_points) == n
@test Resample._ndims(new_points) == ndims

# 10D
data = rand(10, 2)
n = 6
new_points = smote(data, n)
for p in eachcol(new_points)
    p1, p2 = Resample._point.(Ref(data), [1, 2])
    @test Resample._is_in_between(p, p1, p2)
end

@testset "integers" begin
    data = (; X=1:2, Y=2:3)
    n = 3
    @test length(smote(data, n).X) == n
end

@testset "auto balance" begin
    data = (; X=[1, 2, 1, 2, 1], class=[1, 2, 1, 2, 1])
    if v"1.7" ≤ VERSION
        @inferred Resample._col2int(data, :class)
    end

    out = smote(data, :class)
    @test out.X == [2.0]
    @test out.class == [2.0]
end

@testset "dataframes" begin
    data = DataFrame(; X=[1, 2, 1, 2, 1], class=[1, 2, 1, 2, 1])
    out = DataFrame(smote(data, :class))
    combined = vcat(data, out)
    @test combined.class == [1, 2, 1, 2, 1, 2]
end

@testset "rng" begin
    rng() = StableRNG(3)
    data = (; X=rand(5), Y=[1, 1, 1, 2, 2])
    @test smote(rng(), data, :Y).X == smote(rng(), data, :Y).X
end
