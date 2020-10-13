
@testset "LinearBucket.jl" begin
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
end