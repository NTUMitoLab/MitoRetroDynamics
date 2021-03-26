#=
Create filenames
=#

export create_null_dataframe, find_undef_name

"""
Create null dataframe with given keys (`ks`)
"""
function create_null_dataframe(ks; value=[[]])
    d = Dict( ks .=> value )
    df = DataFrame(d)
    return df
end


"""
Find undefined filename
"""
function find_undef_name(filepath, replace_tag)
    function replace_name(name, tag, num)
        replace(name, tag=> num, count=1)
    end
    
    i = 1
    
    while isfile( replace_name(filepath, replace_tag, i) )
        i = i + 1    
    end
    
    return  replace_name(filepath, replace_tag, i)        
end