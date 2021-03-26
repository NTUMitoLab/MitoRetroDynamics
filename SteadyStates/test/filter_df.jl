include("path2data.jl")


@testset "filter" begin
    df = DataFrame(A = 1:4, B = [-1,2,3,-1])

    SteadyStates.filt_df(df, 0, 3)
end

@testset "valid" begin
    df = mergeCSV(dir_)

    valid(df)

end