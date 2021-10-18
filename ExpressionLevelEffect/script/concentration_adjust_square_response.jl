"""
Manipulate concentration to investigate the effect of concentration on dynamics
"""

using Pkg
Pkg.activate(dirname(@__DIR__))
Pkg.instantiate()


using Revise, FrequencyResponse, DifferentialEquations, LabelledArrays, Plots, ProgressMeter, Distributed
import RetroSignalModel as rs

include("utils.jl")

# Load librarys to workers
#addprocs(length(Sys.cpu_info()) - nprocs() - 1, exeflags="--project=$(Base.active_project())")
#@everywhere begin 
    using Revise, FrequencyResponse, DifferentialEquations, LabelledArrays, Plots, ProgressMeter
    import RetroSignalModel as rs
#end

#@everywhere begin 


    # Load Model 
    i_sol_PLACE_HOLDER=1
    RTGm = rs.rtgM4(i_sol_PLACE_HOLDER)
    param= (; u=RTGm.u, p=RTGm.p);

    # Dynamical Signal
    dynmodel = DynModel(
    model = RTGm.model,
    u = param.u,
    p = param.p,
    solver= Rosenbrock23(),
    signal_func = PosSine(ω=0.05,θ=(3/2)*π, amp=1),
    input_i = 1,
    tspan=(0.,500.),
    init_ss = true # Get steady state
    );

    sol = solve(dynmodel;tmax=1.);


    function sim_square(RTGm, levels)
        dynmodel = DynModel(
            model = RTGm.model,
            u = rs.init_u(RTGm; expLevels=levels),
            p = RTGm.p,
            solver= Rosenbrock23(),
            signal_func= SquarePulse(
                                            t_str = 125.,
                                            t_end = 375,
                                            amp_l =0.,
                                            amp_h = 1.),
            input_i = 1,
            tspan=(0.,500.),
            init_ss = true # Get steady state
        );
        sol = solve(dynmodel;tmax=1.);
        return sol
    end

    function mut_tuple(tup, i, mul)
        vs = NamedTuple{tuple(i)}(tuple(tup[i]*mul))
        return LVector(merge(tup, vs))
    end

    """
    pr: protein to change
    ch: change fold
    obs: observe protein
    """
    function ch_cmp(pr, ch, obs;i = i_sol_PLACE_HOLDER)
        RTGm = rs.rtgM4(i)
        levels =rs.getExpLevels(;condition=rs.DefaultCondition)

        #simulation
        sol = sim_square(RTGm, levels)
        sol2 = sim_square(RTGm, mut_tuple(levels, pr, ch)) 


        p = Plots.plot(sol.t,total_conc(sol, RTGm, obs), label="Control")
        Plots.plot!(p, sol2.t,total_conc(sol2, RTGm, obs), label=string(pr,":",ch,"x"))

        Plots.xlabel!(p, "time")
        Plots.ylabel!(p, "Concentration ($(obs))")
        return p
    end

    function ch_cmp!(p, pr, ch, obs;i = i_sol_PLACE_HOLDER, plot_control=false)
        RTGm = rs.rtgM4(i)
        levels =rs.getExpLevels(;condition=rs.DefaultCondition)

        #simulation
        sol2 = sim_square(RTGm, mut_tuple(levels, pr, ch)) 


        if plot_control 
            sol = sim_square(RTGm, levels)
            Plots.plot!(p, sol.t,total_conc(sol, RTGm, obs), label="Control") 
        end

        Plots.plot!(p, sol2.t,total_conc(sol2, RTGm, obs), label=string(pr,":",ch,"x"))

        Plots.xlabel!(p, "time")
        Plots.ylabel!(p, "Concentration ($(obs))")
        return p
    end

    """
    ob: name of observe protein; chs: list of changes
    """
    function simulation(ob, pr, chs)
        plot_control = false
        p_ = Plots.plot()
        for c in chs 
            if plot_control == false 
                ch_cmp!(p_, pr, c, ob;plot_control=true)
                plot_control = true
            end
            ch_cmp!(p_, pr, c, ob;plot_control=false) 
        end
        name = string(pr,"_","foldChange" ,"_","obs_",ob)
        @show name
        Plots.savefig(p_, joinpath(dirname(@__DIR__),"result","$(name).pdf"))
        p_ = nothing
    end
#end 

levels =rs.getExpLevels(;condition=rs.DefaultCondition)
prs = keys(levels)
obs = [:Rtg1_n, :Rtg3_n]
chs = [0.001,0.01,0.1,0.2,0.5,1.,2.,4. ,8., 16.,50.,100.]

sims = [(b,pr,chs)  for b in obs for pr in prs]

#@showprogress map(x->simulation(x...), sims)
@showprogress for sim in sims 
    simulation(sim...)
end