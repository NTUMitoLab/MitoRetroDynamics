a = PosSine() 

@testset "Test all Sigs" for b in [PosSine(), Step(), BaseLine(),  SquarePulse()]
# Create Operation 
ab_a = ComposeSig(Base.:+, a,b)

@test ab_a(1) == a(1) + b(1)

# Addiction 
ab = a + b
ab2 = ab+ab

@test ab(0.) == a(0.) + b(0.)
@test ab2(10.) == ab(10.0) + ab(10.0) 

# Multiplication
abM = a*b
abMM = abM * abM

@test abM(3) == a(3)*b(3)
@test abMM(3) == abM(3) * abM(3)



# With Number 
bp_add = b + 1
bp_mul = b * 2
bp_sub = b - 1

end