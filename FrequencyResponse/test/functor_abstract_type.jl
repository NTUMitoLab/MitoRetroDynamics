abstract type w end 

struct Foo <: w end
struct Foo2 <: w end

function (self::Foo)(t)
    return sin(t) 
end

function (self::w)(t::AbstractArray) 
    return self.(t) 
end
