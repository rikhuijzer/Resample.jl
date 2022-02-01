rng = StableRNG(1)

# 2D points in some minority class.
data = [1.0 2.0 3.0;
        4.0 5.0 6.0]

@test Resample._detect_k(data) == 2

n = 2
new_points = smote(data, n)
@test Resample._npoints(new_points) == n

