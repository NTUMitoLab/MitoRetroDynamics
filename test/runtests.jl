using Pkg 

function testpkg(pkgname)
    @info "🧪 Start Testing Package: $(pkgname) \n"
    Pkg.activate(pkgname)
    Pkg.instantiate()
    Pkg.build()
    Pkg.test()
    @info "🐕 Test Complete \n"
end

testpkg.([
    "PlottingMakie",
    "RobustAnalysis",
    "SteadyStates",
    "FrequencyResponse"
])


# Test Notebooks
@testset "🧪Run Notebooks" begin 

end