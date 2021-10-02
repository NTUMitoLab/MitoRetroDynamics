
"""
Solve time series.

Optional Arguments
---------
- 'init_ss'{Bool}: To Calculate the steady state with input signal at t=0.
"""
function DifferentialEquations.solve(dynmodel::DynModel;dtmax=1., kwags...)
    
    dynback = DynModelCallBack(dynmodel, FunctionCallingCallback)

    return DifferentialEquations.solve(dynback;dtmax=dtmax,kwags...)
end


function DifferentialEquations.solve(dynback::DynModelCallBack;dtmax=1., kwags...)
    @unpack solver, signal_func, input_i = dynback.DynModel
    @unpack callbackmethod = dynback
    
    deinput! = DeInput!(signal_func, input_i)

    op = ODEProblem(dynback.DynModel; kwags...)

    sol = solve(op,  solver; dtmax=dtmax, callback=callbackmethod(deinput!; func_everystep = true, func_start = true, tdir=1))

    return sol
end

function DifferentialEquations.solve(dyncont::DynModelCont;dtmax=1., kwags...)
    @unpack solver = dyncont.DynModel
   
    op = ODEProblem(dyncont.DynModel; kwags...)
    sol = solve(op, solver;dtmax=dtmax)
    return sol
end

"""
Create ODEproblem from DynModel
"""
function DifferentialEquations.ODEProblem(dynmodel::DynModel; kwags...)
    @unpack model, u, p, tspan = dynmodel
    
    op = ODEProblem(model, u, tspan, p; kwags...) 

    return op
end