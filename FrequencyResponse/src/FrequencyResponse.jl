module FrequencyResponse
using Parameters 
using RetroSignalModel 
using DifferentialEquations
using FindSteadyStates
using ModelingToolkit
using ForwardDiff
using Reexport
import PyPlot
const plt = PyPlot


include("dynamicalRN.jl")
include("WaveGenerators/WaveGenerators.jl")
@reexport using .WaveGenerators
include("WaveAnalysis/WaveAnalysis.jl")
@reexport using .WaveAnalysis
include("solve.jl")
include("summary.jl")
include("plot.jl")

export DynModel, DeInput!, DynModelCallBack, DynModelCont

export solve
export get_sum
export plotSol, Fig, save

end 