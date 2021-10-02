using Test

using SteadyStates
using DataFrames
using CSV
using Catalyst
using DataFramesMeta

using RetroSignalModel


@testset "Merge CSVs" begin
    include("merge_csv.jl")
end

@testset "Filtering dataset" begin
    include("filter_df.jl")
end

@testset "get derivatives" begin
    include("get_dt.jl")
end