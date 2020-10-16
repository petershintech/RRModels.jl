@testset "GR4J.jl" begin
    @testset "Constructors" begin
		model = GR4J()
		model2 = GR4J(model)
		@test model == model2
	end

    @testset "Check param or state values when creating new instance" begin
        @test_throws DomainError GR4J(-350.0, 0.0, 40.0, 0.5)
        @test_throws DomainError GR4J(350.0, 0.0, -40.0, 0.5)
        @test_throws DomainError GR4J(350.0, 0.0, 40.0, -0.5)
        @test_throws DomainError GR4J(350.0, 0.0, 40.0, 0.5, 351.0, 30.0)
        @test_throws DomainError GR4J(350.0, 0.0, 40.0, 0.5, 0.0, 41.0)
    end

    @testset "Check values when a parameter or state value is set" begin
        model = GR4J()
        @test_throws DomainError model.X1 = -350.0
        @test_throws DomainError model.X3 = -0.1
        @test_throws DomainError model.X4 = -0.1
        @test_throws DomainError model.Sp = 500.0
        @test_throws DomainError model.Sr = 50.0
    end

    @testset "Stash and recover a model for hot start" begin
        model = GR4J()
        d = stash(model)
        model2 = GR4J(d)
        @test model == model2
    end

    @testset "Print a model" begin
    	model = GR4J()
    	println(model)
	end

    @testset "Test one step running" begin
        model = GR4J()
        Q1, AET1 = simulate(model, 10.0, 5.0)
        Q2, AET2 = simulate(model, 0.0, 5.0)

        model = GR4J()
        Qs, AETs = simulate(model, [10.0, 0.0], [5.0, 5.0])

        @test Qs[2] == Q2
        @test AETs[2] == AET2
    end

    @testset "Check againt GR4J MS Excel modelling results" begin
        data = dataset("gr4j_sample")

        X1 = 320.0
        X2 = 2.5
        X3 = 69.5
        X4 = 1.5

        Sp0 = 0.60*X1
        Sr0 = 0.70*X3

        model = GR4J(X1, X2,X3, X4, Sp0, Sr0)

        Q, AET = simulate(model, data.P, data.PET)
        dQ = Q - data.Qsim
        @test maximum(abs.(dQ)) < 1E-3
  	end

end