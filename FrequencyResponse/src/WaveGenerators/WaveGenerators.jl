module WaveGenerators

using Parameters
import Base

include("waves.jl")
include("cascade.jl")

export ComposeSig, PosSine, Square, SquarePulse, BaseLine, Step, simulate, SimulatedSignal

end