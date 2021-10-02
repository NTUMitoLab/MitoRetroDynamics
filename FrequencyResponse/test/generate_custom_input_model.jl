#=
Sample usage of solving reaction network with continuouse callback
=#

## Load parameter 
param= RetroSignalModel.rtgM4.param()


dynmodel = DynModel(
    model = RetroSignalModel.rtgM4.model,
    u = param.u,
    p = param.p,
    signal_func = PosSine(ω=0.3,θ=3., amp=1.),
    input_i = 1
)

# Solve 
sol1 = solve(dynmodel)

# Change signal
sol2 = solve(DynModel(dynmodel, signal_func=PosSine(ω=1., θ=3., amp=2.)))

# PLOTTING
plotSol(sol, :Rtg1_n, dynmodel)
plotSol(sol2, :Rtg1_n, dynmodel)