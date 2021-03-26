#=
Cascading waves: Using overloading and add method to merge multiple signal sources.
=#

#=Addition=#

"""Addition of two waves"""
function Base.:+(s1::wave, s2::wave)
    return ComposeSig(Base.:+, s1, s2)
end

"""Addition with baseline"""
function Base.:+(s1::wave, s2::Number)
    return ComposeSig(Base.:+, s1, BaseLine(s2))
end 

function Base.:+(s1::Number, s2::wave)
    return Base.:+(s2, s1)
end 


#= Substraction =#

"""Substraction of two waves"""
function Base.:-(s1::wave, s2::wave)
    return ComposeSig(Base.:-, s1, s2)
end

function Base.:-(s1::wave, s2::Number)
    return ComposeSig(Base.:-, s1, BaseLine(s2))
end 

function Base.:-(s1::Number, s2::wave)
    return Base.:-(s2, s1)
end 

#=Multiplication=#

"""Multiplication of two waves"""
function Base.:*(s1::wave, s2::wave)
    return ComposeSig(Base.:*, s1, s2)
end

function Base.:*(s1::wave, s2::Number)
    return ComposeSig(Base.:*, s1, BaseLine(s2))
end 

function Base.:*(s1::Number, s2::wave)
    return Base.:*(s2, s1)
end 


#=
function Base.:^(s1::wave, n::Number)
    # To DO 
    return (power of S1)
end
=#