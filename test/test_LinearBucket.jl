
@testset "LinearBucket.jl" begin
    @testset "Test with invalid values" begin
        @test_throws DomainError LinearBucket(-0.1, 0.0)
        @test_throws DomainError LinearBucket(1.1, 0.0)
        @test_throws DomainError LinearBucket(0.1, -0.5)
    end
end