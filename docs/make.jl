using Resample
using Documenter
using PlutoStaticHTML

"""
Run all Pluto notebooks (".jl" files) in `tutorials_dir` and write output to Markdown files.
"""
function build_tutorials()
    println("Building tutorials")
    dir = joinpath(pkgdir(Resample), "docs", "src", "notebooks")
    # Evaluate notebooks in the same process to avoid having to recompile from scratch each time.
    # This is similar to how Documenter and Franklin evaluate code.
    # Note that things like method overrides may leak between notebooks!
    use_distributed = false
    output_format = documenter_output
    bopts = BuildOptions(dir; use_distributed, output_format)
    build_notebooks(bopts)
    return nothing
end

# Build the notebooks; defaults to "true".
if get(ENV, "BUILD_DOCS_NOTEBOOKS", "true") == "true"
    build_tutorials()
end

pages = [
    "Home" => "index.md",
    "Tutorials" => [
        "SMOTE" => "notebooks/smote.md"
    ]
]

makedocs(;
    modules=[Resample],
    sitename="Resample.jl",
    authors = "Rik Huijzer and contributors",
    format=Documenter.HTML(;
        canonical="https://rikhuijzer.github.io/Resample.jl",
        # Using MathJax3 since Pluto uses that engine too.
        mathengine=Documenter.MathJax3(),
        prettyurls=get(ENV, "CI", "false") == "true",
    ),
    pages
)

deploydocs(; repo="github.com/rikhuijzer/Resample.jl", devbranch="main")
