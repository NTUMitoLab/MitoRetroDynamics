#=
Use User Define Function for solving DE

Reference: https://catalyst.sciml.ai/dev/#Illustrative-Example
=#
struct DeInput
    input_func! # function with u input. change value
end

function (self::DeInput)(u,t,integrator)
    self.input_func!(u,t)
end

function input!(u,t)
    u[1] = sin(t) + 1.
end


model = RetroSignalModel.rtgM4.model

param = RetroSignalModel.rtgM4.param()



op    = ODEProblem(model, param.u, (0.,100.), param.p )

sol   = solve(op, Rosenbrock23(), callback=FunctionCallingCallback(DeInput(input!)));      

# PLOTTING 
Plots.plot(sol)