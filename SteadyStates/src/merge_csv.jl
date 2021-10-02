#=
Merge multiple CSVs
=#

export mergeCSV

"""Merge csv files under a directory (first layer)."""
function mergeCSV(dirname; format=".csv")

    fns_ = readdir(dirname)

    fns = filter_files(fns_, format)

    length(fns) == 0  ? @warn("No file is found.") : nothing

    fns = joinpath.(dirname, fns)
    
    df = CSV.read(fns[1], DataFrame)
    for fn in fns[2:end]
        df_ = CSV.read(fn, DataFrame)
        df = vcat(df, df_)
    end

    return df
end


"""
Check the format of the filename

Example
-------
```
check_format("test.csv", ".csv")
```
"""
function check_format(filename, format)
    return occursin(format, filename)
end

"""Filter list of filenames with a given format"""
function filter_files(filenames, format) 
    return filter(fn -> check_format(fn,format), filenames)
end