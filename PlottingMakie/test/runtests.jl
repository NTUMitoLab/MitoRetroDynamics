
using CairoMakie
using AbstractPlotting
using Test 

CairoMakie.activate!() 

@testset "Plotting" begin 
    include("plot_heatmap.jl")
end

