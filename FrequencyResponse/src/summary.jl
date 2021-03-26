"""
Get Time series summation of given protein name. `n_pr` is a protein name defined in DynModel.model.
"""
function get_sum(sol, n_pr, modelMeta::DynModel)

    pl_table = RetroSignalModel.get_protein_lookup(modelMeta.model)

    ids = pl_table[n_pr]

    return get_sum(sol, ids)
end

function get_sum(sol, ids)

    output = [ sum(sol[i][ids]) for i in 1:length(sol)]

    return output
end