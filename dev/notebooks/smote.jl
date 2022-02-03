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

# ╔═╡ 29dd924c-8f29-422f-84cf-ddb393e01fb2
# hideall
try using Revise; catch end # For development purposes.

# ╔═╡ bc9d5fb8-2f76-4b09-b770-29a95ad4dabe
begin
    using CairoMakie
    using DataFrames
    using Resample
    using StableRNGs: StableRNG
end

# ╔═╡ 62e550fe-aa36-4f11-ade8-d7262cbb228f
md"""
# SMOTE

This is a tutorial walking through the basic functionality of the `smote` function of this package which implements the Synthetic Minority Over-sampling TEchnique (SMOTE) (Chawla et al., [2002](https://doi.org/10.1613/jair.953)).

This technique is useful when the accuracy of a statistical model is low due to class imbalances.
For example, when fitting a model on an outcome variable with 2 classes and one class has 10 items and the other 90 items, then a model can score very well by always predicting a sample to be in the biggest class.
These biggest and smallest classes are respectively known as the majority and minority class.

The idea of SMOTE is to fix the class imbalance by generating random points in between points in the minority group.
This will be shown below in more detail.

## In between

In the first part of this tutorial, a few random points in a minority class are generated.
Next, we plot these points, generate a few synthetic (new) points and show that the synthetic points lay between the original points.
"""

# ╔═╡ c35d1118-9caf-469a-a437-ab3436d89bb6
md"Let's start by generating some random data:"

# ╔═╡ 566a54ec-3731-4b1b-be80-ce3a814202f4
df = let
    rng = StableRNG(2)
    DataFrame(; A=rand(rng, 4), B=rand(rng, 4))
end

# ╔═╡ 3ee34b73-8394-4f0e-ad93-4f8f20ced692
md"Which looks as follows when plotted:"

# ╔═╡ 8398cc7a-d927-4beb-8f5b-0b342f1a59e6
# hideall
resolution = (1000, 800);

# ╔═╡ 7b36f122-a63d-43f7-9861-73c6b65da5fa
# hideall
let
    fig = Figure(; resolution)
    ax = Axis(fig[1, 1])
    scatter!(ax, df.A, df.B; label="Minority")
    Legend(fig[1, 2], ax)
    fig
end

# ╔═╡ f643a1a0-0683-4051-8f88-427ef5cfa3e7
md"To generate new synthetic points (`new_points`), we use the `smote` function from this package:"

# ╔═╡ 8349ef02-26c7-4e22-a146-2528b6bc5d88
new_data = let
    rng = StableRNG(1)
    new_points = smote(rng, df, 4)
    DataFrame(new_points)
end

# ╔═╡ 336c44ef-5248-4588-8db4-4fcee24cdfcc
md"
Plotting these 2-dimensional points with the synthetic points looks as follows:
"

# ╔═╡ e617e094-567b-4425-8409-d8513902ad92
# hideall
let
    fig = Figure(; resolution)
    ax = Axis(fig[1, 1])

    scatter!(ax, df.A, df.B; label="Minority")
    scatter!(ax, new_data.A, new_data.B; label="Synthetic")

    for i in 1:nrow(df)
        for j in 1:nrow(df)
            if i < j
                kwargs = (; color=:black, linestyle=:dash, linewidth=1)
                lines!(ax, [df.A[i], df.A[j]], [df.B[i], df.B[j]]; kwargs...)
            end
        end
    end

    Legend(fig[1, 2], ax)
    fig
end

# ╔═╡ 2934cfb2-36fa-4969-9bc8-007ee24274aa
md"
where the dashed lines are straight lines in between all the points.
As expected, the synthetic points lay in between the minority points.

Next, we do this for a point cloud.
"

# ╔═╡ 1edf932f-61b8-411e-812d-ef455b3b0d28
md"""
## Cloud

When doing this for many points, we will see that the cloud of points gets thicker due when the synthetic points are added.
In the first part of this tutorial, we passed the data as a DataFrame (or any other `Tables.istable` object), but we can also pass a matrix:
"""

# ╔═╡ c102759b-40f1-45a0-ab04-99ccd28cabf5
mat = randn(2, 400) .* 100

# ╔═╡ fdd2f703-45c7-4867-b248-7639cdb69119
md"which looks as follows when plotted:"

# ╔═╡ c4dc370b-98db-412c-8d9f-c181d4ad623e
# hideall
let
    fig = Figure(; resolution)
    ax = Axis(fig[1, 1])
    scatter!(ax, mat[1, :], mat[2, :]; label="Minority")
    Legend(fig[1, 2], ax)
    fig
end

# ╔═╡ d3259ee5-34ab-4f94-a7ea-e6a590f51cb5
md"Now, we can generate a bunch of synthetic data:"

# ╔═╡ a451ea0f-8118-4865-b058-da14a394f23e
new_mat = smote(mat, 300)

# ╔═╡ 15d68355-0a57-48ef-91d8-e2644eaf6d4b
md"which looks as follows:"

# ╔═╡ 5678cc5f-00ac-4425-af1f-2174da9ba1f3
# hideall
let
    fig = Figure(; resolution)
    ax = Axis(fig[1, 1])
    scatter!(ax, mat[1, :], mat[2, :]; label="Minority")
    scatter!(ax, new_mat[1, :], new_mat[2, :]; label="Synthetic")
    Legend(fig[1, 2], ax)
    fig
end

# ╔═╡ Cell order:
# ╠═7c904df4-8434-11ec-119d-0117ccc4d0ae
# ╠═29dd924c-8f29-422f-84cf-ddb393e01fb2
# ╠═62e550fe-aa36-4f11-ade8-d7262cbb228f
# ╠═bc9d5fb8-2f76-4b09-b770-29a95ad4dabe
# ╠═c35d1118-9caf-469a-a437-ab3436d89bb6
# ╠═566a54ec-3731-4b1b-be80-ce3a814202f4
# ╠═3ee34b73-8394-4f0e-ad93-4f8f20ced692
# ╠═8398cc7a-d927-4beb-8f5b-0b342f1a59e6
# ╠═7b36f122-a63d-43f7-9861-73c6b65da5fa
# ╠═f643a1a0-0683-4051-8f88-427ef5cfa3e7
# ╠═8349ef02-26c7-4e22-a146-2528b6bc5d88
# ╠═336c44ef-5248-4588-8db4-4fcee24cdfcc
# ╠═e617e094-567b-4425-8409-d8513902ad92
# ╠═2934cfb2-36fa-4969-9bc8-007ee24274aa
# ╠═1edf932f-61b8-411e-812d-ef455b3b0d28
# ╠═c102759b-40f1-45a0-ab04-99ccd28cabf5
# ╠═fdd2f703-45c7-4867-b248-7639cdb69119
# ╠═c4dc370b-98db-412c-8d9f-c181d4ad623e
# ╠═d3259ee5-34ab-4f94-a7ea-e6a590f51cb5
# ╠═a451ea0f-8118-4865-b058-da14a394f23e
# ╠═15d68355-0a57-48ef-91d8-e2644eaf6d4b
# ╠═5678cc5f-00ac-4425-af1f-2174da9ba1f3
