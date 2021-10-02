"""
Estimate the phase of a wave (`gen_sig`) with reference signal (`ref_sig`)
"""
get_phase(gen_sig::PosSine, ref_sig::PosSine) = gen_sig.θ - ref_sig.θ


function get_phase(gen_sig, ref_func::PosSine, ts; move_range=nothing, kwags...)
    
    ref_sig = ref_func.(ts)

    xc = xcorr(gen_sig[:], ref_sig[:])
    lag_tick =  abs(argmax(xc) - length(ref_sig))
    lag_t = ts[lag_tick] - ts[1]
    θ =  lag_t* ref_func.ω
    return  -θ 
end


function get_phase(gen_sig, ref_sig, ts; move_range=nothing, kwags...)
    
    # TODO 
    # Need Fourier Transform
end