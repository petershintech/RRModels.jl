
@testset "LinearBucket.jl" begin
    @testset "Constructors" begin
		model = LinearBucket()
		model2 = LinearBucket(model)
		@test model == model2
	end

    @testset "Check param or state values when creating new instance" begin
        @test_throws DomainError LinearBucket(-0.1, 0.0)
        @test_throws DomainError LinearBucket(1.1, 0.0)
        @test_throws DomainError LinearBucket(0.1, -0.5)
    end

    @testset "Check values when a parameter or state value is set" begin
        model = LinearBucket(0.1, 0.0)
        @test_throws DomainError model.K = -0.1
        @test_throws DomainError model.K = 1.1
        @test_throws DomainError model.S = -0.5
    end

    @testset "Stash and recover a model for hot start" begin
        model = LinearBucket(0.2, 0.5)
        d = stash(model)
        model2 = LinearBucket(d)
        @test model == model2
    end

    @testset "Print a model" begin
    	model = LinearBucket()
    	println(model)
	end
end