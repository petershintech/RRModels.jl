mutable struct GR4J

    X1::Float64     # Capacity of the production store (mm)
    X2::Float64     # Water exchange coefficient (mm/day)
    X3::Float64     # Capacity of the routing store (mm)
    X4::Float64     # Time base of the unit hydrograph (days)

    Sp::Float64     # Level in production store (mm)
    Sr::Float64     # level in routing store (mm)

    UH1::Array{Float64,1}
    UH2::Array{Float64,1}

    oUH1::Array{Float64,1}
    oUH2::Array{Float64,1}

    function GR4J(X1::Float64, X2::Float64, X3::Float64, X4::Float64,
                  Sp::Float64, Sr::Float64)
        X1 >= 0.0 || throw(DomainError(X1, "X1 should have non-negative value"))
        X3 >= 0.0 || throw(DomainError(X3, "X3 should have non-negative value"))
        X4 >= 0.0 || throw(DomainError(X4, "X1 should have non-negative value"))
        Sp <= X1  || throw(DomainError(Sp, "Sp should be less than or equal to X1, $X1"))
        Sr <= X3  || throw(DomainError(Sr, "Sr should be less than or equal to X3, $X3"))

        nUH1 = ceil(Int32, X4)
        nUH2 = ceil(Int32, 2.0 * X4)

        UH1 = zeros(Float64, nUH1)
        UH2 = zeros(Float64, nUH2)

        oUH1 = [SS1(i, X4) - SS1(i - 1, X4) for i in 1:nUH1]
        oUH2 = [SS2(i, X4) - SS2(i - 1, X4) for i in 1:nUH2]

        new(X1, X2, X3, X4, Sp, Sr, UH1, UH2, oUH1, oUH2)
    end
end

function GR4J()
    GR4J(350.0, 0.0, 40.0, 0.5, 0.0, 0.0)
end

function GR4J(X1::Float64, X2::Float64, X3::Float64, X4::Float64)
    GR4J(X1, X2, X3, X4, 0.0, 0.0)
end

function GR4J(m::GR4J)
    model = GR4J(m.X1, m.X2, m.X3, m.X4, m.Sp, m.Sr)
    model.UH1[:] = m.UH1
    model.UH2[:] = m.UH2
    return model
end

function GR4J(d::Dict)
    model = GR4J(d[:X1], d[:X2], d[:X3], d[:X4], d[:Sp], d[:Sr])
    model.UH1[:] = d[:UH1]
    model.UH2[:] = d[:UH2]
    return model
end

function ==(a::GR4J, b::GR4J)
    x = a.X1 == b.X1 && a.X2 == b.X2 && a.X2 == b.X2 && a.X2 == b.X2
    y = a.Sp == b.Sp && a.Sr == b.Sr
    z = all(a.UH1 .== b.UH1) && all(a.UH2 .== b.UH2)

    return x && y && z
end

function show(io::IO, model::GR4J)
    println("GR4J Model:")
    println(io, "X1 = $(model.X1)")
    println(io, "X2 = $(model.X2)")
    println(io, "X3 = $(model.X3)")
    println(io, "X4 = $(model.X4)")
    println(io, "Sp = $(model.Sp)")
    println(io, "Sr = $(model.Sr)")
    return
end

function Base.setproperty!(model::GR4J, field::Symbol, value)
    if field == :X1
        value >= 0.0 || throw(DomainError(value, "X1 should have non-negative value"))
    elseif field == :X3
        value >= 0.0 || throw(DomainError(value, "X3 should have non-negative value"))
    elseif field == :X4
        value >= 0.0 || throw(DomainError(value, "X4 should have non-negative value"))
    elseif field == :Sp
        value <= model.X1  || throw(DomainError(value, "Sp should be less than or equal to X1, $model.X1"))
    elseif field == :Sr
        value <= model.X3  || throw(DomainError(value, "Sr should be less than or equal to X3, $model.X3"))
    end

    setfield!(model, field, value)
end


function stash(model::GR4J)::Dict
    return Dict(:X1=>model.X1, :X2=>model.X2, :X3=>model.X3, :X4=>model.X4,
                :Sp=>model.Sp, :Sr=>model.Sr,
                :UH1=>copy(model.UH1), :UH2=>copy(model.UH2))
end

function simulate(model::GR4J, P::Array{Float64,1}, PET::Array{Float64,1})
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

function simulate(model::GR4J, P::Float64, PET::Float64)
    X1 = model.X1
    X2 = model.X2
    X3 = model.X3
    X4 = model.X4

    Sp = model.Sp
    Sr = model.Sr

    UH1 = model.UH1
    UH2 = model.UH2

    oUH1 = model.oUH1
    oUH2 = model.oUH2

    Rp = Sp / X1

    # Production store:
    if P >= PET
        ES = 0.0
        AET = PET
        WS = (P - PET) / X1
        if (WS > 13.0) WS = 13.0 end
        TWS = tanh(WS)

        PS = X1 * (1.0 - Rp * Rp) * TWS / (1.0 + Rp * TWS)
        PR = P - PET - PS
    else
        WS = (PET - P) / X1
        if (WS > 13.0) WS = 13.0 end
        TWS = tanh(WS)

        ES = Sp * (2.0 - Rp) * TWS / (1.0 + (1.0 - Rp) * TWS)
        AET = ES + P
        PS = 0.0
        PR = 0.0
    end
    Sp = Sp - ES + PS

    @assert Sp >= 0.0

    Rp = Sp / X1

    @debug "PS: $PS"
    @debug "Es: $ES"
    @debug "Sp/X1: $Rp"

    # Percolation:
    r = Rp / 2.25
    PERC = Sp - Sp / sqrt(sqrt(1.0 + r * r * r * r))
    Sp = Sp - PERC
    @assert Sp >= 0.0
    PR = PR + PERC

    @debug "PERC: $PERC"
    @debug "Sp/X1: $(Sp / X1)"
    @debug "PR: $PR"

    B = 0.9
    for i in 1:(length(UH1) - 1)
        UH1[i] = UH1[i + 1] + oUH1[i] * B * PR
    end
    UH1[end] = oUH1[end] * B * PR

    for i in 1:(length(UH2) - 1)
        UH2[i] = UH2[i + 1] + oUH2[i] * (1.0 - B) * PR
    end
    UH2[end] = oUH2[end] * (1.0 - B) * PR

    @debug "oUH1: $oUH1"
    @debug "oUH2: $oUH2"
    @debug "UH1: $UH1"
    @debug "UH2: $UH2"

    # Water exchange:
    Rr = Sr / X3
    ECH = X2 * Rr * Rr * Rr * sqrt(Rr)
    @debug "ECH(F): $ECH"

    # QR calculation [routing store]:
    # Different from MS Excel. In Excel, no 0.9 *
    # Also ECH added not multiplied
    Sr = max(0.0, Sr + UH1[1] + ECH)
    Rr = Sr / X3
    @debug "Sr/X3: $Rr"
    QR = Sr - Sr / sqrt(sqrt(1.0 + Rr * Rr * Rr * Rr))
    @debug "QR: $QR"
    Sr = Sr - QR
    @assert Sr >= 0.0
    @debug "Sr/X3: $(Sr / X3)"
    # QD calculation:
    QD = max(0.0, UH2[1] + ECH)
    @debug "QD: $QD"
    # Total streamflow:
    Q = QR + QD
    @debug "Q: $Q"

    model.Sp = Sp
    model.Sr = Sr

    return Q, AET

end


function SS1(I, X4)
    if I <= 0
        return 0.0
    elseif I < X4
        r = I / X4
        return r * r * sqrt(r)
    else
        return 1.0
    end
end

function SS2(I, X4)
    if I <= 0
        return 0.0
    elseif I < X4
        r = I / X4
        return 0.5 * r * r * sqrt(r)
    elseif I < 2 * X4
        r = 2.0 - I / X4
        return 1.0 - 0.5 * r * r * sqrt(r)
    else
        return 1.0
    end
end
