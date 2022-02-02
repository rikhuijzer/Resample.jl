### A Pluto.jl notebook ###
# v0.17.7

using Markdown
using InteractiveUtils

# ╔═╡ 7c904df4-8434-11ec-119d-0117ccc4d0ae
# hideall
let
    docs_dir = dirname(dirname(@__DIR__))
    pkg_dir = dirname(docs_dir)

    using Pkg: Pkg
    Pkg.activate(docs_dir)
    Pkg.develop(; path=pkg_dir)
    Pkg.instantiate()
end

# ╔═╡ bc9d5fb8-2f76-4b09-b770-29a95ad4dabe
begin
    using CairoMakie
    using DataFrames
	using Resample
    using StableRNGs: StableRNG
end

# ╔═╡ c35d1118-9caf-469a-a437-ab3436d89bb6
md"Lorem ipsum

# ╔═╡ 566a54ec-3731-4b1b-be80-ce3a814202f4
df = let
	rng = StableRNG(1)
	DataFrame(; A=rand(rng, 6), B=rand(rng, 6))
end

# ╔═╡ 12e5086d-ab5b-4ae4-a931-36ca4a0f01e3
# hideall
marker = :utriangle;

# ╔═╡ 1d80b325-fd60-4f13-96bc-2d6dbf4ca3cb
# hideall
markersize = 14;

# ╔═╡ 8398cc7a-d927-4beb-8f5b-0b342f1a59e6
# hideall
resolution = (1000, 1000);

# ╔═╡ 7b36f122-a63d-43f7-9861-73c6b65da5fa
# hideall
let
	fig = Figure(; resolution)
	ax = Axis(fig[1, 1])
	scatter!(ax, df.A, df.B)
	fig
end

# ╔═╡ 8349ef02-26c7-4e22-a146-2528b6bc5d88
new_data = let
	rng = StableRNG(1)
	new_points = smote(rng, df, 4)
	DataFrame(new_points)
end

# ╔═╡ 336c44ef-5248-4588-8db4-4fcee24cdfcc
md"Some text"

# ╔═╡ e617e094-567b-4425-8409-d8513902ad92
# hideall
let
	fig = Figure(; resolution=(1000, 1000))
	ax = Axis(fig[1, 1])

	scatter!(ax, df.A, df.B; label="Original")
	scatter!(ax, new_data.A, new_data.B; label="Synthetic")

	for i in 1:nrow(df)
		for j in 1:nrow(df)
			if i < j
				kwargs = (; color=:black, linestyle=:dash)
				lines!(ax, [df.A[i], df.A[j]], [df.B[i], df.B[j]]; kwargs...)
			end
		end
	end

	Legend(fig[1, 2], ax)
	fig
end	

# ╔═╡ Cell order:
# ╠═7c904df4-8434-11ec-119d-0117ccc4d0ae
# ╠═bc9d5fb8-2f76-4b09-b770-29a95ad4dabe
# ╠═c35d1118-9caf-469a-a437-ab3436d89bb6
# ╠═566a54ec-3731-4b1b-be80-ce3a814202f4
# ╠═12e5086d-ab5b-4ae4-a931-36ca4a0f01e3
# ╠═1d80b325-fd60-4f13-96bc-2d6dbf4ca3cb
# ╠═8398cc7a-d927-4beb-8f5b-0b342f1a59e6
# ╠═7b36f122-a63d-43f7-9861-73c6b65da5fa
# ╠═8349ef02-26c7-4e22-a146-2528b6bc5d88
# ╠═336c44ef-5248-4588-8db4-4fcee24cdfcc
# ╠═e617e094-567b-4425-8409-d8513902ad92
