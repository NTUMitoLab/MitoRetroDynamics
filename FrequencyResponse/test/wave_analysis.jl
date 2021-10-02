# Create Sine wave
ts = 0:0.01:100
sig = PosSine()
sig_sine = simulate(sig,ts)



@testset "find peaks of sine wave" begin
    peak_realH, prop_sinH = get_high_peaks(sig, (0.,100.)) 
    peak_realL, prop_sinL = get_low_peaks(sig, (0.,100.))  
    peak_estH, prop_estH = get_high_peaks(sig_sine)
    peak_estL, prop_estL = get_low_peaks(sig_sine)
    # "Measure peaks with reference signal"  
    peak_estH2, prop_estH = get_high_peaks(sig_sine, ts, sig)
    peak_estL2, prop_estL = get_low_peaks(sig_sine, ts, sig)

    @test 1 ∈ prop_sinH["peak_heights"]
    @test 0 ∉ prop_sinH["peak_heights"]
    @test 1 ∉ prop_sinL["peak_heights"]
    @test 0 ∈ prop_sinL["peak_heights"]
    @test isapprox( maximum(sig_sine[peak_estH]), sig.amp; atol=1e-2 )
    @test isapprox( minimum(sig_sine[peak_estL]), 0; atol=1e-2 )
    @test isapprox( maximum(sig_sine[peak_estH2]), sig.amp; atol=1e-2 )
    @test isapprox( minimum(sig_sine[peak_estL2]), 0; atol=1e-2 )
    @test length(peak_estH2) == length(peak_estH)
    @test length(peak_estL2) == length(peak_estL)
end

@testset "Measure amplitude" begin 
    @test isapprox(sig.amp, get_amp(sig_sine); atol=1e-3 )
end


@testset "Measure phase" begin
    ts = 0:0.01:100

    sig1 = PosSine() # Reference Signal
    sig2 = PosSine(θ=-0.5π) # Generated Signal 
    sig3 = PosSine(θ=-0.9π)

    wave1 = simulate(sig1, ts) # Reference wave
    wave2 = simulate(sig2,ts) # Generated wave
    wave3 = simulate(sig3, ts)

    @test isapprox(get_phase(wave2, sig1, ts), get_phase(sig2, sig1); atol=1e-1)
    @test isapprox(get_phase(wave3, sig1, ts), get_phase(sig3, sig1); atol=1e-1)
    #@test isapprox(get_phase(wave2, wave1, ts), sig2.θ - sig.θ; atol=1e-2)
    #@test isapprox(get_phase(sig2, wave1, ts), sig2.θ - sig.θ; atol=1e-2)
    #@test isapprox(get_phase(sig2, sig1), sig2.θ - sig.θ; atol=1e-2)
    
end