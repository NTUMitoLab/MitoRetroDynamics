
"""
Find multiplies between `val_str` and `val_end`
"""
function find_mul_between(val_str, val_end, seed)
    @assert val_end >= val_str 
    @assert seed != 0

    v_mulStr, v_mulEnd = [val_str, val_end] .÷ seed 
    v_modStr, v_modEnd = [val_str, val_end] .% seed 

    # if val_str is the multiplies of seed, then + 1
    (v_modStr != 0) & (val_str>0) ? v_mulStr += 1 : nothing
    (v_modEnd != 0) & (val_end<0) ? v_mulEnd -= 1 : nothing
    
    multiplies = collect( (v_mulStr*seed) : abs(seed) : (v_mulEnd*seed) )

    return multiplies

end


"""
Find the multiplies of base greater or equal to (val-offset)
"""
function equal_or_beyond(val, base; offset=0)
    v_ = val - offset 
    pin = cld(v_, base) * base
    return pin + offset
end



@with_kw struct AlignResult
    diff
    arg
end

"""
Wave alignment

Return:
- distance of two arrays: Positive value represents `ts` is leading to `ts_ref`
- properties
"""
function align_ts(ts, ts_ref, mov_range; loss_func=rms, tolerance=1e-1, kwags...)
    loss(mov) = sum(loss_func.(ts , ts_ref .+ mov  )) 
    op = optimize(loss, mov_range...; kwags...)

    if op.minimum > tolerance 
        @warn "Dismatch shifhted array (move step: $(op.minimizer)."
    end

    return AlignResult(op.minimizer, op)
end

"""
Root mean square
"""
rms(a, b) = sqrt((a-b)^2)

# Sine properties
cycle(sig::PosSine) = 2*π/sig.ω
base_max(sig::PosSine) = (π/2-sig.θ)/sig.ω
base_min(sig::PosSine) = (3*π/2-sig.θ)/sig.ω