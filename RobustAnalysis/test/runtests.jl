using RetroSignalModel 
using SteadyStateDiffEq
using StochasticDiffEq
using DiffEqNoiseProcess
using OrdinaryDiffEq
using ModelingToolkit
using Catalyst
using Latexify
using Test
using Parameters
using ProgressBars
using InformationMeasures
using Distributions
using KernelDensity
using QuadGK
using Random
using Pkg 
Pkg.build("PyPlot")
import Plots
import PyPlot 
plt = PyPlot

@testset "Stochastic Simulation" begin 
        include("screening_input.jl")
end