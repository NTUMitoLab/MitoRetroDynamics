modulesN = ["ExpressionLevel", "FrequencyResponse", "PlottingMakie", "RetroSignalModel", "RobustAnalysis", "SteadyStates"]
ENV["PYTHON"] = "" # avoid using internal python
using Pkg 
Pkg.activate(dirname(@__FILE__))
root = dirname(dirname(@__FILE__))
for n in modulesN 
    @show joinpath(root,n)
    Pkg.develop(path=joinpath(root,n))
end
Pkg.add("Documenter")
Pkg.instantiate()

using ExpressionLevel
using FrequencyResponse
using PlottingMakie
using RetroSignalModel
using RobustAnalysis
using SteadyStates
using Documenter
using FindSteadyStates

modules = [ExpressionLevel, FrequencyResponse, PlottingMakie, RetroSignalModel, RobustAnalysis, SteadyStates]

repoName = "MitochannelAnalysis"

makedocs(;
    modules=modules,
    authors="Steven Shao-Ting Chiu",
    repo="https://github.com/stevengogogo/$(repoName)/blob/{commit}{path}#L{line}",
    sitename="MitochannelAnalysis",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://stevengogogo.github.io/$(repoName)",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "Installation"=>"installation.md",
        "Function Index" => "FunctionIndex.md"
    ]
)

deploydocs(;
    branch = "gh-pages",
    repo="github.com/stevengogogo/$(repoName).git",
)