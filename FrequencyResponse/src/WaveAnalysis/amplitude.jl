"""
Get amplitude from a given array. The `kwags` arg
"""
function get_amp(array; kwags...)

    high_ps, _ = get_high_peaks(array; kwags...)
    low_ps, _ = get_low_peaks(array; kwags...) 

    amp = mean(array[high_ps]) - mean(array[low_ps])
    return amp
end


function get_amp(sig::PosSine)
    return sig.amp
end
