sig_func = PosSine()
ts = 1:1.:30
ts_ = 1:1:30 

sim1 = simulate(sig_func, ts)
sim1_ = simulate(sig_func, ts_)

@test sim1.t == ts
@test length(sim1) == length(sim1_)
@test sim1[1] == sim1_[1]