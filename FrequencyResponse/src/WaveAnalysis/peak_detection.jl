
"""
Get peaks from array
"""
function get_peaks(array; flip=false, kwags...)

    flip ? array = array * -1. : nothing 

    peaks, properties = sp.signal.find_peaks(array; kwags...)

    if length(peaks) == 0 
        @warn "No peak is found."
    end

    return peaks, properties
end

function get_peaks(signal::PosSine, tspan; flip=false)
    @unpack ω,  θ = signal
    # Find positive 
    flip ? OFFSET = base_min(signal) : OFFSET = base_max(signal)

    t_ext_0 = equal_or_beyond(tspan[1], 2*π; offset= OFFSET )

    t_exts =  t_ext_0:(2*π):tspan[end]

    properties = Dict(
        "peak_heights" => signal.(t_exts)
    )
    return t_exts, properties
end

"""
Find peaks within reference sine wave 
"""
function get_peaks(array, ts_arr, ref_sig::PosSine; flip=false, kwags...)

    t_tick = (ts_arr[end] - ts_arr[1]) / length(ts_arr)
    cycle_ticks =  fld( cycle(ref_sig) , t_tick)

    return get_peaks(array; flip=flip, distance=cycle_ticks, kwags...)
end

get_peaks(array::SimulatedSignal; kwags...) = get_peaks(array[:]; kwags...)


get_high_peaks(array; kwags...) = get_peaks(array; flip=false, kwags...)
get_high_peaks(array::SimulatedSignal; kwags...) = get_peaks(array[:]; flip=false, kwags...)
get_high_peaks(array, ts_arr, ref_sig::PosSine; kwags...) = get_peaks(array, ts_arr, ref_sig; flip=false, kwags...)
get_high_peaks(signal::PosSine, tspan) = get_peaks(signal, tspan; flip=false)


get_low_peaks(array; kwags...) = get_peaks(array; flip=true, kwags...)
get_low_peaks(array::SimulatedSignal; kwags...) = get_peaks(array[:]; flip=true, kwags...)
get_low_peaks(array, ts_arr, ref_sig::PosSine; kwags...) = get_peaks(array, ts_arr, ref_sig; flip=true, kwags...)
get_low_peaks(signal::PosSine, tspan) = get_peaks(signal, tspan; flip=true)

