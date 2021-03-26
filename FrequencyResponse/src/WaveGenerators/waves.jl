#=
Gallery of signals
=#

abstract type wave end 

"""
Cascading operator

Arguements
----------
- `op`: function with two inputs. `op(s1,s2)`
- `s1` and `s2`: function with one input. 
"""
@with_kw struct ComposeSig <: wave
    opFunc #operator 
    sig1 #signal 1 (t)
    sig2 #signal 2 (t)
end

function (self::ComposeSig)(t)
    @unpack opFunc, sig1, sig2 = self
    return opFunc(sig1(t),sig2(t))
end



"""
Positive Sine in [0, amp]
"""
@with_kw struct PosSine <: wave
    ω=1.
    θ=0.
    amp=1.
end

function(self::PosSine)(t) 
    @unpack ω, θ, amp = self
    return 0.5(amp*sin(ω*t + θ) + amp)
end


@with_kw struct Step <: wave
    t_start = 0.
    val_init = 0.
    val_end  = 1.
end

function (self::Step)(t)
    @unpack t_start, val_init, val_end = self
    if t < self.t_start 
        sig = val_init 
    elseif t == self.t_start 
        sig = 0.5*(val_init + val_end)
    else
        sig = val_end 
    end
    return sig
end


@with_kw struct Square  <: wave
    period=1.
    delay=0.
    amp_h=1.
    amp_l = 0.
    duty = 0.5
end

function (self::Square)(t)
    @unpack period, delay, amp_h, amp_l = self
    t_c = mod(t, period) / period 
    
    if t_c >= duty 
        sig = amp_l
    else
        sig = amp_h
    end

    return sig 
end

@with_kw struct SquarePulse <: wave
    t_str = 0.
    t_end = 3.
    amp_l =0.
    amp_h = 1.
end

function (self::SquarePulse)(t)
    @unpack t_str,t_end,amp_l,amp_h  = self 

    if (t >= t_str) & (t<=t_end) 
        sig = amp_h 
    else
        sig = amp_l 
    end
    return sig 
end

@with_kw struct BaseLine <: wave 
    base = 0. 
end

function (self::BaseLine)(t)
    return self.base
end

