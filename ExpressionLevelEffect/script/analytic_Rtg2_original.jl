using Pkg
Pkg.activate(dirname(@__DIR__))
Pkg.instantiate()

using Catalyst
using Interpolations
using Optim
import  PyPlot as plt
import RetroSignalModel as rs


function get_total_conc(concs, feature)
    Is = [ i for i in keys(RTGm.u) if occursin(feature,string(i))]
    return sum(concs[Is])
end

rtg2m = @reaction_network begin 
    (1), s→s
    (hill(s, ksV, ksD, n_s), k2I), Rtg2_ina_c ↔ Rtg2_act_c #[1]
    (k2M, kn2M), Rtg2_act_c + Mks ↔ Rtg2Mks_c
    (kBM, knBM), Bmh + Mks ↔ BmhMks
end n_s ksV ksD k2I k2M kn2M kBM knBM

RTGm = rs.rtgM4(1)
Catalyst.params(RTGm.model)
Catalyst.params(rtg2m)

ps = NamedTuple{tuple(Symbol.(params(RTGm.model))...)}(RTGm.p)
psR = NamedTuple{tuple(Symbol.(params(rtg2m))...)}(tuple([getindex(ps, Symbol(i)) for i in Catalyst.params(rtg2m)]...))


# Analytical solution

## Total concentration
A0 = get_total_conc(RTGm.u, "Rtg2")
B0 = get_total_conc(RTGm.u, "Bmh")
P0 = get_total_conc(RTGm.u, "Mks")

## Kinetic coefficients
hill(s, ksV,ksD,n_s) = ksV* (s^n_s/(s^n_s+ksD^n_s))
Ka = psR.kn2M / psR.k2M
Kb = psR.knBM / psR.kBM
Ks(s) = hill(s, psR.ksV, psR.ksD, psR.n_s) / psR.k2I
Ka_(s) = Ka*(1+1/Ks(s))


## Auxilliary coefficients 
a(s) = Ka_(s) + Kb + A0 + B0 - P0
b(s) = Kb*(A0-P0) + Ka_(s)*(B0-P0) + Ka_(s)*Kb
c(s) = -Ka_(s)*Kb*P0

a²3b(s) = a(s)^2 - 3*b(s)
sqrt_a²3b(s) = sqrt(a²3b(s))
cosθ3(s) = cos(θ(s)/3)

θ(s) = acos( (-2*a(s)^3 + 9*a(s)*b(s) - 27*c(s)) / (2*sqrt(a²3b(s)^3)))

## Steady state
P(s) = -(a(s)/3) + 2/3 * sqrt_a²3b(s)*cosθ3(s)
PA(s) = A0*P(s)/(Ka*(1+Ks(s))/Ks(s) + P(s))
PB(s) = P(s)*B0/(Kb + P(s))
A(s) = (A0 - PA(s))/(1+Ks(s))
A_(s) = (A0 - PA(s))*(Ks(s)/(1+Ks(s)))




## analysis 
function findIC50(A0, B0, P0; IC50_Bmh = ps.k13ID, psR=psR)
    ## Kinetic coefficients
    hill(s, ksV,ksD,n_s) = ksV* (s^n_s/(s^n_s+ksD^n_s))
    Ka = psR.kn2M / psR.k2M
    Kb = psR.knBM / psR.kBM
    Ks(s) = hill(s, psR.ksV, psR.ksD, psR.n_s) / psR.k2I
    Ka_(s) = Ka*(1+1/Ks(s))


    ## Auxilliary coefficients 
    a(s) = Ka_(s) + Kb + A0 + B0 - P0
    b(s) = Kb*(A0-P0) + Ka_(s)*(B0-P0) + Ka_(s)*Kb
    c(s) = -Ka_(s)*Kb*P0

    a²3b(s) = a(s)^2 - 3*b(s)
    sqrt_a²3b(s) = sqrt(a²3b(s))
    cosθ3(s) = cos(θ(s)/3)

    θ(s) = acos( (-2*a(s)^3 + 9*a(s)*b(s) - 27*c(s)) / (2*sqrt(a²3b(s)^3)))

    ## Steady state
    P(s) = -(a(s)/3) + 2/3 * sqrt_a²3b(s)*cosθ3(s)
    PB(s) = P(s)*B0/(Kb + P(s))

    # Analysis 
    f(s) = (PB(s) - IC50_Bmh)^2
    res = optimize(f, 0.,1., GoldenSection())
    s_swt = res.minimizer
    return s_swt
end

# Rtg 2
half(arr) = (maximum(arr)-minimum(arr))/2 + minimum(arr)

As = 1.:10:A0
IC50s = similar(As)
for i in eachindex(As) 
    IC50s[i] = findIC50(As[i],B0,P0)
end


fig2,ax2=plt.subplots()
ax2.plot(As, IC50s)
ax2.set_xlabel("Rtg2 Concentration (AU)")
ax2.set_ylabel("Mitochondrial damage that cause Bmh to IC50")
plt.display_figs()
fig.savefig(joinpath(dirname(@__DIR__),"result", "S_IC50_Bmh_and_Rtg2_conc.pdf"))



# Hill 
n_s = 1.:1:9.
IC50ns = similar(n_s)
for i in eachindex(n_s)
    IC50ns[i] = findIC50(A0,B0,P0; psR=merge(psR, (;n_s=n_s[i])))
end

plt.plot(n_s, IC50ns)
plt.display_figs()


# Multiple factors
paramSpace = (;
    n_s = 1.:0.5:9.,
    A0 = 10.:10:A0,
    B0 = 30.:10:B0,
    P0 = 10.:10:P0
)

alias = (;
    A0 = :Rtg2,
    B0 = :Bmh,
    P0 = :Mks
)

IC50 = Dict(keys(paramSpace) .=> [similar(collect(i)) for i in paramSpace])
concs = (;A0, B0, P0)
for k in [:A0,:B0,:P0]
    for i in eachindex(paramSpace[k])
        conT = merge(concs, NamedTuple{(k,)}((paramSpace[k][i],)))
        IC50[k][i] = findIC50(conT...)
    end
end

for k in [:n_s]
    for i in eachindex(paramSpace[k])
        conT = merge(psR, NamedTuple{(k,)}((paramSpace[k][i],)))
        IC50[k][i] = findIC50(A0,B0,P0;psR=conT)
    end
end  


# Plot 
figT, axs = plt.subplots(2,2, figsize=(11,11))
for (i,k) in enumerate(keys(IC50))
    axs[i].plot(paramSpace[k], IC50[k])
    k ∈ keys(alias) ? k = alias[k] : nothing
    axs[i].set_xlabel(string("Expression level of ",k))
    axs[i].set_ylabel("IC\$_{50}\$ of s on BmhMks inhibition")
end
axs[end].set_xlabel("n\$_s\$")
plt.display_figs()
figT.savefig(joinpath(dirname(@__DIR__),"result", "Thrshold_Bmh.pdf"))



# Simulation
s_ic50 = findIC50(A0, B0, P0; IC50_Bmh = ps.k13ID, psR=psR)
S = 0.1:0.01:1
fig, ax = plt.subplots(2,2, figsize=(11,11))
ax[1].plot(S, P.(S), label="Mks")
ax[2].plot(S, PA.(S), label="Rtg2Mks")
ax[3].plot(S, PB.(S), label="BmhMks")
ax[4].plot(S, A.(S), label="Rtg2_act")
#ax[5].plot(S, A_.(S), label="Rtg2_ina")
#ax[6].plot(S, A_.(S) .+ PA.(S) .+ A.(S), label="Rtg2_total")
#ax[7].plot(S, P.(S) .+ PA.(S) .+ PB.(S), label="Mks_total")
ax[3].axhline(ps.k13ID, xmin=0,xmax=s_ic50-0.01,color="black", linestyle="--")
ax[3].axvline(s_ic50, ymin=0,ymax=PB(s_ic50)/200,color="black", linestyle="--")
ax[3].text(0-0.1, PB(s_ic50)-5, "K\$^{13}_{DI}\$")
ax[3].text(s_ic50-0.05, -30, "IC\$_{50}\$")

[a.legend(loc="upper right") for a in ax]
[a.xaxis.set_ticks([0,1]) for a in ax]
[a.set_xlabel("Mitochondrial Damage (\$s\$, AU)") for a in ax]
[a.set_ylabel("Concentration (AU)") for a in ax]
plt.display_figs()
fig.savefig(joinpath(dirname(@__DIR__),"result", "analytical_Rtg2.pdf"))