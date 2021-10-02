module WaveAnalysis 
using Parameters
using Statistics 
using Reexport
using Optim
using DSP
using ..WaveGenerators 
import SciPy as sp


include("utils.jl")
include("peak_detection.jl")
include("amplitude.jl")
include("phase.jl")

export get_peaks, get_amp, get_high_peaks, get_low_peaks, get_phase

end