
include("path2data.jl")


@testset "Check format" begin
    @test SteadyStates.check_format("test.csv", ".csv") == true
    @test SteadyStates.check_format("test_csv.pdf", ".csv") == false
end

@testset "Filter list of filenames" begin

    fns = SteadyStates.filter_files(filenames, ".csv")

    @test length(fns) == 3

end


@testset "Merge function" begin 

    fns = readdir(dir_; join=true)
    
    fns = SteadyStates.filter_files(fns, ".csv")


    lens = zeros(length(fns))
    cols = zeros(length(fns))

    for i in eachindex(fns)
        f = CSV.read(fns[i], DataFrame)
        lens[i], cols[i] = size(f)
    end

    df_sum = mergeCSV(dir_)

    @test size(df_sum)[1] == sum(lens)
    @test size(df_sum)[2] == cols[1]

end