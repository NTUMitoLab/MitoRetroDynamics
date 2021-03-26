#=
Convert Biological systems to Chemical Langevin Model, and simulate it

Reference
---------
- Model Simulation Guideline: https://catalyst.sciml.ai/stable/tutorials/models/#Model-Simulation
- SDE usage: https://github.com/SciML/Catalyst.jl/blob/master/test/solve_SDEs.jl
=#

# Load Model 
rn = RetroSignalModel.rtgM4.NoInputModel
param = RetroSignalModel.rtgM4.param() 

# Rearrange parameter for NoInputModel
u, p = collect.([param.u, param.p])
pushfirst!(p, 0.5)
u = u[2:end]

# Get steady State
prob = SteadyStateProblem(rn,u,p)
sol = solve(prob, DynamicSS(AutoTsit5(Rosenbrock23())))
u = sol.u

# Create SDE problem 
p[1] = 1.0
tspan=(0.,100.)
prob = SDEProblem(rn, u, tspan, vcat(p,10.), noise_scaling= (@variables η1)[1])
sol  = solve(prob, LambaEM() )


# Plot
Plots.plot(sol)
plt.plot(sol.t, [i[3] for i in sol.u])
plt.display_figs()


# stochastic simulation

function do_nothing(arg)
    return arg
end



@with_kw struct stochastic_simulation 
    input_var  # input s 
    noise_var # noise scaling 
    output_indexes 
    model = RetroSignalModel.rtgM4.NoInputModel
    u = collect(RetroSignalModel.rtgM4.param_NoInputModel().u)
    p = collect(RetroSignalModel.rtgM4.param_NoInputModel().p)
end


function (self::stochastic_simulation)(trajectory; analysis_method = Base.sum, tspan=(0.0,2.0), SDEsolver=LambaEM())
    p_ = deepcopy(self.p)


    prob = SDEProblem(self.model, self.u, tspan, vcat(p,self.noise_var), noise_scaling= (@variables η1)[1])

    ensembleprob = EnsembleProblem(prob)

    sols = solve(ensembleprob,EnsembleThreads(),trajectories=trajectory)
    
    res = analysis_ensemble(sols, analysis_method, self.output_indexes)

    return res
end

function analysis_ensemble(sols, method, indexes)
    res = []
    for sol in sols 
        for u in sol.u 
            append!(res, method(u[indexes]))
        end
    end
    return res
end


function (self::stochastic_simulation)(;  tspan=(0.0,2.0), SDEsolver=LambaEM())
    

    prob = SDEProblem(self.model, self.u, tspan, vcat(self.p,self.noise_var), noise_scaling= (@variables η1)[1])


    sol = solve(prob, SDEsolver)
   
    return sol
end



# run
sim = stochastic_simulation(
        input_var = 0.5,
        noise_var = 1.,
        output_indexes = [1]
)

success = []
for i in 0.: 0.1 :1
    for s in [EM, SOSRA, LambaEM, EulerHeun, LambaEulerHeun,RKMil, RKMilCommute, RKMilGeneral, WangLi3SMil_A, WangLi3SMil_B , WangLi3SMil_C,WangLi3SMil_D, WangLi3SMil_E, WangLi3SMil_F, SRA,SRI, SRIW1, SRIW2,SOSRI, SOSRI2, SRA1,  SRA2, SRA3 ,  SOSRA, SOSRA2  ]

        sol = sim(;SDEsolver=s() )
        if sol.retcode == :DtLessThanMin
            @show "$s : Fail with $i"
        else
            @show "$s: Success. with noise = $i"
            append!(success, (i, s))
        end
    end 
end

#################################
function condition(u,t,integrator) 
    (minimum(integrator.u) < 0.) | (minimum(u) < 0. )
end 

function affect!(integrator)
    neg_is = findall(x-> x<0., integrator.u)
    for i in neg_is 
        integrator.u[i] = 0.
    end
end

cb = DiscreteCallback(condition,affect!)

u_ = collect(RetroSignalModel.rtgM4.param_NoInputModel().u)
p_ = collect(RetroSignalModel.rtgM4.param_NoInputModel().p)

prob = SDEProblem(sim.model, u_, (0.,10.), vcat(p_, 0.001), noise_scaling= (@variables η1)[1])
sol = solve(prob, LambaEM(); callback=cb)

######################

@show success


sol = sim(2; tspan=(0.0,20.0))


## Screening
IN = []
out = []
for i in 0:0.1:1
    sim = stochastic_simulation(
        input_var = i,
        noise_var = 10.,
        output_indexes = [15,16]
)
    sol = sim(7;tspan=(0.,10.))
    append!(IN, i)
    #append!(out, sol)
    @show (maximum(sol) - minimum(sol))
end