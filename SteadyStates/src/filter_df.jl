#= 
filtering dataframe
=#
export filt_df, valid

"""
Filter dataframe with given domain.
"""
function filt_df(df, low, high)
    df_ = deepcopy(df)
    for i in 1:size(df)[2]
        df_ = df_[ df_[:,i] .>= low, :]
        df_ = df_[ df_[:,i] .<= high, :]
    end
    return df_
end

"""Return valid dataframe"""
function valid(df; low=0.,high=1e4, s_low=0., s_high=1.0)
    df_ = filt_df(df, low, high) # Domain of protein concentration
    return  @where(df_ , :s.<s_high, :s.>s_low)
end