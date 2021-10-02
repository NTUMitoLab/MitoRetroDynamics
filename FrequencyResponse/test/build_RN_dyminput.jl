## Load parameter 
param= RetroSignalModel.rtgM4.param()


dynmodel = DynModel(
    model = RetroSignalModel.rtgM4.model,
    u = param.u,
    p = param.p,
    signal_func = PosSine(ω=0.3,θ=3., amp=1.),
    input_i = 1
)


# Convert 
dyb = DynModelCallBack(dynmodel)
dyk = DynModelCont(dynmodel)


# Solve
solve(dynmodel)
@time solve(dyb);
@time solve(dyk);


#=
rs = @reaction_network begin
    c1, X --> 2X
    c2, X --> 0
    c3, 0 --> X
  end c1 c2 c3
  p     = (1.0,2.0,50.)
  tspan = (0.,4.)
  u0    = [5.]   
  osys  = convert(ODESystem, rs)
  u0map = map((x,y) -> Pair(x,y), species(rs), u0)
  pmap  = map((x,y) -> Pair(x,y), params(rs), p)
  oprob = ODEProblem(osys, u0map, tspan, pmap)
  


dXdteq = equations(osys)[1]           
t      = independent_variable(osys)    
dXdteq = Equation(dXdteq.lhs, dXdteq.rhs + 10*sin(10*t))   
osys2  = ODESystem([dXdteq], t, states(osys), parameters(osys))
oprob  = ODEProblem(osys2, u0map, tspan, pmap)
osol   = solve(oprob, Tsit5())

@with_kw struct DynModelCont
    model 
    u 
    p
    signal_func
    dsignal_func 
    input_i 
    solver 
    tspan
end

function DynModelCont(DynModel)
    @unpack model, u, p, signal_func, input_i, solver, tspan = DynModel




    return DynModelCont(model, u, p, signal_func, dsignal_func, input_i, solver, tspan)
end
=#