
using Pkg
Pkg.activate(dirname(@__DIR__))
Pkg.instantiate()

using Catalyst
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




Kr = psR.kn2M/psR.k2M 
Kb = psR.knBM/psR.kBM 
Kt(s) = psR.k2I/ (psR.ksV * s^psR.n_s / (psR.ksD^psR.n_s + s^psR.n_s))
Kr_(s) = Kr*(1+1/Kt(s))


Rtg2₀ = get_total_conc(RTGm.u, "Rtg2")
Bmh₀ = get_total_conc(RTGm.u, "Bmh")
Mks₀ = get_total_conc(RTGm.u, "Mks")

a(s) = Kr_(s) + Kb + Rtg2₀ + Bmh₀ - Mks₀
b(s) = Kb*(Rtg2₀ - Mks₀) + Kr_(s)*(Bmh₀ - Mks₀)+Kr_(s)*Kb 
c(s) = -Kr_(s)*Kb*Mks₀

θ(s) = acos( (-2*a(s)^3 + 9*a(s)*b(s) - 27*c(s)) / (2*sqrt((a(s)^2-3*b(s))^3)))

Mks(s) = -a(s)/3 + 2/3*sqrt(a(s)^2 - 3*b(s)) * cos(θ(s)/3)

function auxB(s)
    2*sqrt(a(s)^2-3*b(s))*cos(θ(s)/3) - a(s)
end
function BmhMks(s) 
    return Bmh₀*aux(s) / (3*Kb + aux(s))
end

Mks(1)
BmhMks(0.)
BmhMks(0.01)