rng = StableRNG(1)

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

for point in eachcol(new_points)
    x = point[1]
    @test p1_x ≤ x ≤ p2_x

    y = point[2]
    @test p2_x ≤ y ≤ p2_y
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

