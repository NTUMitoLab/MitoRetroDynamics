#' 
#' # Frequency Response Simulation and Analysis
#' 
#+ 

using Pkg
Pkg.activate("FrequencyResponse")


#+ 

Pkg.status()


#+ 

using FrequencyResponse
using RetroSignalModel
using DifferentialEquations
using LaTeXStrings
using ProgressBars
using DSP
import PyPlot
import Folds
const plt = PyPlot;


#+ 

function show_all(sol)
        prl = Dict(
        :name=> [:bmhmks, :Rtg1_n, :Rtg3_n, :Rtg13_n],
        :label=> [string("Output\n",i)   for i in ["Bmh/Mksp (nM)", "Nucleus Rtg1p (nM)", "Nucleus Rtg3p (nM)", "Nucleus Rtg1/3p (nM)"]  ]
    )
    
    figs, axes = [], []
    
    for (n,l) in zip(prl[:name], prl[:label])
        fig_,ax_ = plotSol(sol, n, dynmodel; ylabel_output= l)
        push!(figs, fig_)
        push!(axes, ax_)
    end
    return Fig.(figs, axes,  prl[:name])
end;

function output(us, inds)
    return [ sum(u[inds]) for u in us]
end


#+ 

pr_is = RetroSignalModel.rtgM4().protein_lookup
rtg13_n = pr_is[:Rtg13_n]
rtg3_n = pr_is[:Rtg3_n]

#' 
#' ## Setup
#' 
#+ 

i_sol_PLACE_HOLDER=1
# Load Model
RTGm = RetroSignalModel.rtgM4(i_sol_PLACE_HOLDER)
param= (; u=RTGm.u, p=RTGm.p);


#+ 

# Dynamical Signal
dynmodel = DynModel(
    model = RTGm.model,
    u = param.u,
    p = param.p,
    solver= Rosenbrock23(),
    signal_func = PosSine(ω=0.05,θ=(3/2)*π, amp=1),
    input_i = 1,
    tspan=(0.,500.),
    init_ss = true # Get steady state
);

#' 
#' ## Sinusoidal Response
#' 
#+ 

# Solve 
@time sol = solve(dynmodel;dtmax=1., reltol=1e-15,abstol=1e-8);
figsD_sin = show_all(sol)


#+ 

#[save.(figsD_sin, "Sine_5e-2rad", "FrequencyResponse/result/sine"; 
       # format= f) for f in ["pdf", "svg"]];

#' 
#' ## Hysteresis
#' 
#+ 

dynmodel_sq = DynModel(dynmodel; 
                       init_ss=false, 
                       signal_func= SquarePulse(
                                    t_str = 125.,
                                    t_end = 375,
                                    amp_l =0.,
                                    amp_h = 1.) 
                        );
sol = solve(dynmodel_sq;tmax=1.);

figsD_SqPulse = show_all(sol)


#+ 

[save.(figsD_SqPulse, "Pulse_150sec", "FrequencyResponse/result/pulse"; 
        format= f) for f in ["pdf", "svg"]];

#' 
#' ## Multiple Step Response 
#' 
#' - Follower
#' - No overshoot
#' 
#+ 

dynmodel_sq = DynModel(dynmodel; 
                       init_ss=false, 
                       signal_func= SquarePulse(
                                    t_str = 0.,
                                    t_end = 160,
                                    amp_l =0.,
                                    amp_h = 0.)  +
                                    SquarePulse(
                                    t_str = 160.1,
                                    t_end = 320,
                                    amp_l =0,
                                    amp_h = 0.5)  +
                                    SquarePulse(
                                    t_str = 320.1,
                                    t_end = 500,
                                    amp_l =0,
                                    amp_h = 1.) 
                        );
solPulses = solve(dynmodel_sq;tmax=1.);

figsD_SqPulses = show_all(solPulses)


#+ 

[save.(figsD_SqPulses, "Pulse_160sec320sec", "FrequencyResponse/result/pulse"; 
        format= f) for f in ["pdf", "svg"]];

#' 
#' ## Merging Pulse and Sinusoidal Response
#' 
#+ 

pulse = SquarePulse(t_str = 100.,t_end = 150.,amp_l =0., amp_h = 1.) 
sigFunc = pulse + SquarePulse(pulse; t_str=350, t_end=800.) * PosSine(ω=0.08, θ=π)

dynmodel_sq = DynModel(dynmodel; 
                       init_ss=false, 
                       signal_func= sigFunc,
                        tspan=(0.,800.)
                        );
sol = solve(dynmodel_sq;tmax=0.5);

figsD_SquareSine = show_all(sol)


#+ 

[save.(figsD_SquareSine, "SquareSine_150sec", "FrequencyResponse/result/squareSine"; format= f) for f in ["pdf", "svg"]];

#' 
#' ## Impuse
#' #' 
#' ### Short Impulse
#' 
#' - Short Impuse Injection (duration=1 sec)
#' 
#+ 

dynmodel_sq = DynModel(dynmodel; 
                       init_ss=false, 
                       signal_func= SquarePulse(t_str = 100.,t_end = 101,amp_l =0., amp_h = 1.) ,
                        tspan=(0.,500.)
                        );
sol = solve(dynmodel_sq;tmax=0.5);

figsD_PulseShort = show_all(sol)


#+ 

[save.(figsD_PulseShort, "Impulse_1ec", "FrequencyResponse/result/Impulse"; 
format= f) for f in ["pdf", "svg"]];


#+ 

dynmodel_sq = DynModel(dynmodel; 
                       init_ss=false, 
                       signal_func= SquarePulse(t_str = 100.,t_end = 120,amp_l =0., amp_h = 1.) ,
                        tspan=(0.,500.)
                        );
sol = solve(dynmodel_sq;tmax=0.2);

figsD_PulseLong = show_all(sol);

[save.(figsD_PulseLong, "Impulse_20ec", "FrequencyResponse/result/Impulse"; 
format= f) for f in ["pdf", "svg"]];


#+ 

fig_, ax_ = plt.subplots(figsize=(5,5))
pr = pr_is
ax_.plot(sol.t, [sum(u[pr[:Rtg13_n]]) for u in sol.u], linewidth=3, color="blue")
ax_.xaxis.set_ticks([0,500])
ax_.set_xlim([0,500])
ax_.set_ylim([70,110])
ax_.yaxis.set_ticks([70,110])


#+ 

fig_.savefig("FrequencyResponse/result/synthetic_wave/output_Rtg13_n.pdf", box_inches="tight")


#+ 

plt.rc("font", size="20")
function plotwave(ax, t, func;linewidth=1, linecolor="black")
    ydata = func.(t)
    ax.plot(t, ydata, linewidth=linewidth, color=linecolor)
    ax.set_xticks([minimum(t), maximum(t)])
    ax.set_yticks([minimum(ydata), maximum(ydata)])
    return ax
end

fig1,ax1=plt.subplots(figsize=(5,5))
fig2,ax2=plt.subplots(figsize=(5,5))
plotwave.([ax1,ax2], [0:0.1:500], [p1,p2])


ax1.set_xlim([0,250])
ax1.xaxis.set_ticks([0, 250])
ax2.set_xlim([0,250])
ax2.xaxis.set_ticks([0, 250])

#[a.set_xlabel("Time (seconds)") for a in [ax1,ax2]]
#[a.set_ylabel("Mitochondrial Damage (AU)") for a in [ax1,ax2]]


#+ 

fig1.savefig("FrequencyResponse/result/synthetic_wave/sine_low_freq.pdf")
fig2.savefig("FrequencyResponse/result/synthetic_wave/sine_high_freq.pdf")


#+ 

p12 = p1 + p2
fig_2, ax_2 = plt.subplots(figsize=(5,5))
ax_2.plot(sol.t, [ p12(t) for t in sol.t], linewidth=1, color="black" )
ax_2.set_xlim([0,500])
ax_2.xaxis.set_ticks([0,500])
ax_2.yaxis.set_ticks([0,1])


#+ 

fig_2.savefig("FrequencyResponse/result/synthetic_wave/input.pdf", box_inches="tight")


#+ 

fig_, ax_ = plt.subplots(figsize=(5,5))
pr = pr_is
ax_.plot(sol.t, [sum(u[pr[:Rtg13_n]]) for u in sol.u], linewidth=3, color="blue")
ax_.xaxis.set_ticks([0,500])
ax_.set_xlim([0,500])
ax_.set_ylim([70,110])
ax_.yaxis.set_ticks([70,110])

fig_.savefig("FrequencyResponse/result/synthetic_wave/output_Rtg13_n.pdf", box_inches="tight")


#+ 

p12 = p1 + p2
fig_2, ax_2 = plt.subplots(figsize=(5,5))
ax_2.plot(sol.t, [ p12(t) for t in sol.t], linewidth=1, color="black" )
ax_2.set_xlim([0,500])
ax_2.xaxis.set_ticks([0,500])
ax_2.yaxis.set_ticks([0,1])

fig_2.savefig("FrequencyResponse/result/synthetic_wave/input.pdf", box_inches="tight")

#' 
#' ## Plotting for Graphical Abstact
#' 
#+ 

plotSol(solPulses, :Rtg3_n, dynmodel_sq;)

#' 
#' ### Increasing frequency of sine wave
#' 
#+ 

function SINEV(t; t_start=0., t_end=600., ω_str=0.02, ω_end=0.7, amp=1.0, ϕ=π /2*3)
    ω_c = ω_str + (ω_end - ω_str)* (t-t_start)/(t_end-t_start)
    
    SIGNAL = 0.5*amp + 0.5*amp*sin(ω_c*t + ϕ)
    return SIGNAL
end


dynmodel_freq = DynModel(dynmodel; 
                       init_ss=false, 
                       tspan=(0.,600.),
                       signal_func= SINEV
                        );

sol = solve(dynmodel_freq;tmax=0.1);


#+ 

## Plotting
out = get_sum(sol,:Rtg3_n, dynmodel_freq)
input = get_sum(sol,:s, dynmodel_freq)




fig,ax = plt.subplots(2,1; gridspec_kw= Dict(:height_ratios=> [1, 3]))

ax[1].plot(0:0.1:600, SINEV.(0:0.1:600); color="darkred", linewidth=1.5) # Input
ax[2].plot(sol.t, out;color="black", linewidth=1.5) #Output 


# Axis
ax[1].axis("off")

ax[2].yaxis.set_ticks([])
ax[2].xaxis.set_ticks([30, 450])

ax[2].set_xticklabels(["",""])
ax[2].set_xlim(30,450)
ax[1].set_xlim(30,450)
ax[2].set_ylim(250,350)


#ax[2].set_ylabel("Output", fontsize="20")
#ax[2].set_xlabel("Time", fontsize="20")




fig.subplots_adjust(
    hspace=0.
)

f = Fig(fig, ax, "Freq_low_high")


#+ 

[save(f,"FreqVariant", "FrequencyResponse/result/GraphicalAbstract";format=i) for i in ["pdf", "svg"]]

#' 
#' ## Bode Plot
#' #' 
#' ### Amplitude Estimation
#' 
#+ 

function gain(ω, dynmodel)
    sig = PosSine(ω=ω)
    tspan = (-100.,500. * 0.1 / ω)
    dynmodel_ = DynModel(dynmodel; 
                           tspan=tspan,
                           init_ss=false, 
                           signal_func= sig
                            );

    sol = solve(dynmodel_;tmax=1.);
    
    out = get_sum(sol,:Rtg3_n, dynmodel_)
    input_sig = sig.(sol.t)
    
    t0_tick = findfirst(x->x>=0, sol.t)
    maxO= maximum(out[t0_tick:end])
    minO = minimum(out[t0_tick:end])
    
    maxI = maximum(input_sig[t0_tick:end])
    minI = minimum(input_sig[t0_tick:end])
    
    return maxO, minO, maxI, minI,  input_sig, out,sol
    
end


#+ 

range(0,3;step=3)


#+ 

#[0.01, 0.1, 1, 10]
for ω in ProgressBar([0.01, 0.1, 1, 10, 100])
   
    # Gain
    maxO, minO, maxI, minI,  input_sig, out, sol = gain(ω, dynmodel)
    
    # Delay
    t_ran = (2*π/ω)*6
    tspan_ = sol.t[end] - t_ran: t_ran/100. : sol.t[end]
    

    t_shift = range(0,t_ran; length=length(tspan_) )
    
    tspan_crr = vcat(-t_shift[end:-1:2], t_shift)
   
    cross_cor = xcorr( [sol(i, idxs=1) for i in tspan_] , [ sum(sol.(i, idxs=rtg3_n)) for i in tspan_]   )
    

    
    max_t_tick = argmax(cross_cor)
    max_t = tspan_crr[max_t_tick]
    

    fig, ax = plt.subplots(1,3, figsize=(15,4))
    ax[1].plot(sol.t, input_sig)
    ax[1].axhline(maxI)
    ax[1].axhline(minI)
    ax[1].set_title("Input: ω=$(ω) rad/s")

    ax[2].plot(sol.t, out)
    ax[2].axhline(maxO)
    ax[2].axhline(minO)
    ax[2].set_title("Output (Rtg3_n)")
    
    ax[3].plot( tspan_crr ,cross_cor)
    ax[3].axvline(max_t)
    ax[3].set_title("Cross Correlation")
end


#+ 

ωs = 10 .^(-2.:0.1:1.)

amps = zeros(length(ωs))


for i in ProgressBar(1:length(ωs))
    maxO, minO, maxI, minI,  input_sig, out, sol = gain(ωs[i], dynmodel)
    amps[i] = maxO-minO
end


#+ 

figg, axg = plt.subplots()
axg.plot(ωs, amps)
axg.set_yscale("log")
axg.set_xscale("log")


#+ 

figg.savefig("FrequencyResponse/result/Bode/GainPlot.pdf";box_inches="tight", tranparent="true")

#' 
#' ## Phase 
#' 
#+ 

maxO, minO, maxI, minI,  input_sig, out, sol = gain(0.4, dynmodel);


#+ 

maxO, minO, maxI, minI


#+ 

plt.plot(xcorr( [sol(i, idxs=1) for i in 0:0.01:10] , [ sum(sol.(i, idxs=rtg3_n)) for i in 0:0.1:100]   ) )

