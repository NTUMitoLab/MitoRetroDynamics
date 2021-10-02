rn = @reaction_network begin
    p, ∅ → X
    d, X → ∅
  end p d
  p = [1.0,2.0]
  u0 = [0.1]
  tspan = (0.,1.)
  prob = ODEProblem(rn,u0,tspan,p)
  sol = solve(prob, Tsit5())



  prob = SDEProblem(rn, u0, tspan, p, noise_scaling= (@variables η1)[1])

  ssol  = solve(prob, LambaEM(), reltol=1e-3)

  Plots.plot(ssol)



# model 2 
  rs = @reaction_network begin
    c1, X --> 2X
    c2, 2X --> X
  end c1 c2 
  p = (1.0,1.0) # [c1,c2,c3]
  tspan = (0.,10.)
  u0 = [5.]         # [X]
  sprob = SDEProblem(rs, u0, tspan, p)
  ssol  = solve(sprob, LambaEM(), reltol=1e-3)
  Plots.plot(ssol,lw=2,title="Adaptive SDE: Birth-Death Process")