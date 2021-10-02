abstract type DynModelSolver end 

"""
Functor for functional calling back. transform function (u,t) to function(u,t,integrator)
"""
@with_kw struct DynModel 
    model 
    u 
    p 
    signal_func
    input_i = 1 # u[input_i]
    solver = Rosenbrock23()
    ss_solver = DynamicSS(AutoTsit5(Rosenbrock23()))
    tspan = (0.,100.)
    init_ss = false # Get steady state with input

    """
    Set the initial value equals to the input(t=0)
    """
    function DynModel(model, u, p, signal_func, input_i, solver, ss_solver,tspan, init_ss)
        if init_ss 
            u[input_i] != signal_func(tspan[1])
            u[input_i] = signal_func(tspan[1]) # set initial signal
            de = DEsteady(func=model, p=p, u0=u, method=ss_solver)
            sol = FindSteadyStates.solve(de)
            u_ = sol.u
        else
            u_ = u 
        end 

        return new(model, u_, p, signal_func, input_i, solver, ss_solver,tspan, init_ss)
    end
end

"""
Dynmodel with Callback method 
"""
@with_kw struct DynModelCallBack <:DynModelSolver
    DynModel  :: DynModel 
    callbackmethod = FunctionCallingCallback
end




function DynModelCallBack(dynmodel::DynModel; callbackmethod = FunctionCallingCallback)
    return DynModelCallBack(dynmodel, callbackmethod)
end

"""
Dynmodel with continous function 
"""
@with_kw struct DynModelCont <:DynModelSolver
    DynModel :: DynModel 
    dsignal_func 
end

function DynModelCont(dynmodel::DynModel)
    @unpack signal_func, model, input_i = dynmodel

    # Add Signal to model 
    osys = convert(ODESystem, model)

    eqs = equations(osys)
    dXdteq = eqs[input_i]
    t      = independent_variable(osys) 
    D = Differential(t)

    dsig =  ModelingToolkit.expand_derivatives(D(signal_func(t))) # Derivative of input signal

    eqs[input_i] = Equation(dXdteq.lhs, dXdteq.rhs + dsig)

    osys2  = ODESystem(eqs, t, states(osys), parameters(osys))

    dyn_dsig = DynModel(dynmodel, model=osys2, init_ss=false)
    
    return DynModelCont(dyn_dsig, dsig)
end




struct DeInput!
    signal_func # function (t)
    input_index 
end


function (self::DeInput!)(u,t,integrator)
    u[self.input_index] = self.signal_func(t)

end