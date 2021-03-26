rtg13_n = [11,12,15,16]

# get total concentration of rtg3 
rn = RetroSignalModel.rtgM4.NoInputModel
u_ = collect(RetroSignalModel.rtgM4.param_NoInputModel().u)
p_ = collect(RetroSignalModel.rtgM4.param_NoInputModel().p)

pr_is = RetroSignalModel.get_protein_lookup(rn)
rtg3_total = sum(u_[pr_is[:Rtg3]])

function output(us, inds)
    return [ sum(u[inds]) for u in us]
end

function condition(u,t,integrator) 
    (minimum(integrator.u) < 0.) | (minimum(u) < 0. )
end 

function affect!(integrator)
    neg_is = findall(x-> x<0., integrator.u)
    for i in neg_is 
        integrator.u[i] = -integrator.u[i]
    end
end

cb = DiscreteCallback(condition,affect!)



## Get HeatMap
noise = 0.000001
out = []
IN  = []
s = 0.1:0.01:1.
for i in ProgressBar(s)
    
    # Assign new input 
    p_[1] = i

    # Get steady state
    probss = SteadyStateProblem(rn,u_,p_)
    solss = solve(probss, DynamicSS(AutoTsit5(Rosenbrock23())))
    u_ = solss.u

    # SDE 
    prob = SDEProblem(rn, u_, (0.,100.), vcat(p_, noise), noise_scaling= (@variables η1)[1])
    sol = solve(prob, LambaEM(); callback=cb)
    ot = output(sol.u, rtg13_n)
    
    push!(out, kde(convert.(Float64, ot)))
    #append!(out, kde(convert.(Float64, ot)))
    #append!(IN, fill(i, length(ot)) )
end


# Calculate map
heatmap = zeros(length(s), length(s))

ys = range(1, rtg3_total, length=length(s))
for i in ProgressBar(1:length(s))
    PDF = out[i]
    for j in 1:(length(s)-1)
        integral, err = quadgk(X -> pdf(PDF,X), ys[j], ys[j+1], rtol=1e-8)
        heatmap[(length(s) - j),i] = integral 
    end
end

fig, ax = plt.subplots()
ax.imshow(heatmap, extent=[0,1,0,1] )
fig.savefig("RobustAnalysis/test/data/heatmap_rtg13_n_1e-6.svg", transparent=true, bbox_inches = "tight" )
plt.display_figs()

#=
p = Plots.histogram2d(IN, out;bins=80)
Plots.savefig(p,"RobustAnalysis/test/data/dose_response_sde.svg" )

=#





