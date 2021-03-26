#= 
Get value of df/dt.

Tasks:

1. Retrieve initial values from Dataframe 
2. Meausre the df/dt from Catalyst model
=#

"""Specie names to strings"""
function spec2str(catalyst_name; apped="(t)")
    return replace(catalyst_name, apped=>"")
end

"""Output agent names"""
function Base.names(model :: Catalyst.ReactionSystem, method)
    ns = string.(method(model))
    return spec2str.(ns)
end

function sysname(model :: Catalyst.ReactionSystem)
    return names(model, Catalyst.species)
end




dir_ = joinpath("..", "data", "steady_states_")
df = mergeCSV(dir_)

model = rtgM4.model
u_names = sysname(model)


dfp = filt_df(df, 0.,1e4)

dfp = @where(dfp , :s.<1, :s.>0)

