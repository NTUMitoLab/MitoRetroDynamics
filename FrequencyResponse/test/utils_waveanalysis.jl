testargs = [
    [4,9,3],

]

ans = [
    [6,9]
]

@testset "Between" for (arg,a) in zip(testargs, ans)
  
    @test FrequencyResponse.WaveAnalysis.find_mul_between(arg...) == a

end

# 

# 10-2 is the minimal multilis of 4
@test equal_or_beyond(7,4;offset=2) == 10