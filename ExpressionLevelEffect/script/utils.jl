function total_conc(sol::ODESolution, m, prN; oper=sum)
    ids = m.protein_lookup[Symbol(prN)]
    pr = [sum(u[ids]) for u in sol.u]
    return pr
end

function total_conc(sol_u, m, prN; oper=sum)
    ids = m.protein_lookup[Symbol(prN)]
    pr = sum(sol_u[ids]) 
    return pr
end


function mut_tuple(tup, i, mul)

    vs = NamedTuple{tuple(i)}(tuple(tup[i]*mul))
    return LVector(merge(tup, vs))
end