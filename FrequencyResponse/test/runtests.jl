using FrequencyResponse
using RetroSignalModel
using Catalyst
using DifferentialEquations
using Parameters
using Test 
import PyPlot as plt
import SciPy as sp
import Plots


@testset "Wave generator" begin 
    #include("wavegenerator.jl")
end
@testset "DE with Oscillation" begin 
    #include("CustomInputDE.jl")
end

@testset "Custom input model constructor" begin
    #include("generate_custom_input_model.jl")
end

@testset "Generate Dynamical function with ModelingToolkit" begin 
    #include("build_RN_dyminput.jl")
end

@testset "Signal Cascading" begin 
    #include("signal_cascading.jl")
end 

@testset "Wave Analysis" begin 
    include("wave_analysis.jl")
end