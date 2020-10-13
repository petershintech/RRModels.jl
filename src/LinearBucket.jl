mutable struct LinearBucket <: AbstractRRModel
    K::Float64
    S::Float64

    function LinearBucket(K::Float64, S::Float64)
        0.0 <= K <= 1.0 || throw(DomainError(K, "K parameter should have a value between 0 and 1"))
        S >= 0.0 || throw(DomainError(S, "S initial storage should have a non-negative value"))

        new(K, S)
    end
end

function LinearBucket()
    LinearBucket(0.1, 0.0)
end

function LinearBucket(d::Dict)
    LinearBucket(d[:K], d[:S])
end

function Base.setproperty!(obj::LinearBucket, field::Symbol, value)
    if field == :K
        0.0 <= value <= 1.0 || throw(DomainError(value, "K parameter should have a value between 0 and 1"))
    elseif field == :S
        value >= 0.0 || throw(DomainError(value, "S initial storage should have a non-negative value"))
    end
    setfield!(obj, field, value)
end

function simulate(model::LinearBucket, P::Array{Float64,1}, PET::Array{Float64,1})
    if size(P) != size(PET)
        throw(DimensionMismath("P and PET have different sizes"))
    end

    Q = zeros(Float64, size(P))
    AET = zeros(Float64, size(P))
    for i in 1:length(P)
        Q[i], AET[i] = simulate(model, P[i], PET[i])
    end
    return Q, AET
end

function simulate(model::LinearBucket, P::Float64, PET::Float64)
    Q = 0.0
    AET = 0.0
    for i in 1:length(P)
        model.S += P
        AET = model.S >= PET ? PET : model.S
        model.S -= AET
        Q = model.K * model.S
        model.S -= Q
    end
    return Q, AET
end

function stash(model::LinearBucket)::Dict
    return Dict(:K=>model.K, :S=>model.S)
end
