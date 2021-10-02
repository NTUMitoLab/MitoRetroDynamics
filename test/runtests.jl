using Pkg 

@show pwd()
Pkg.activate("test")
Pkg.instantiate()

using Test 
using NBInclude


function testpkg(pkgname)
    @info "🧪 Start Testing Package: $(pkgname) \n"
    Pkg.activate(pkgname)
    Pkg.instantiate()
    Pkg.build()
    Pkg.test()
    @info "Test Complete \n"
end

notebooks = [
    #"PlottingMakie",
    "RobustAnalysis",
    #"SteadyStates",
    #"FrequencyResponse"
]

@testset "Test simulation envs" for nb in notebooks 
    testpkg(nb)
end

Pkg.activate(".")
Pkg.instantiate()

# Test Notebooks
begin 
    for nb in notebooks
        nb == "RobustAnalysis" ? continue : nothing # Skip. This simulation takes lots of times
        @info "Run $(nb).ipynb"
        @nbinclude("../$(nb).ipynb")
    end
end