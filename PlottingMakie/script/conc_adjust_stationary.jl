using Pkg
Pkg.activate(dirname(@__DIR__))
Pkg.instantiate()

using Revise, Plots
import RetroSignalModel as rs 

include("utils.jl")

function solveOutput(RTGm, levels, prOb, prCh, ch, s)
    new_levels = mut_tuple(levels, prCh, ch)
    u_new = rs.init_u(RTGm; expLevels=new_levels)
    u_new[1] = s 

    u = rs.getSteadySol(RTGm, u_new)
    return u
end

RTGm = rs.rtgM4(i_sol_PLACE_HOLDER)
levels =rs.getExpLevels(;condition=rs.DefaultCondition)

prObs = [:Rtg1_n, :Rtg3_n]
prChs = keys(levels)
Chs = 0.01:10:100


u = solveOutput(RTGm, levels, prObs[1], prChs[1], Chs[1], 1.)

total_conc(u, RTGm, :Rtg1_n)