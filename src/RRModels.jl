module RRModels

using DataFrames
using CSV

import Base.setproperty!
import Base.==
import Base.show
export AbstractRRModel
export LinearBucket, GR4J
export simulate, stash, dataset

include("AbstractRRModel.jl")
include("LinearBucket.jl")
include("GR4J.jl")

function dataset(name::AbstractString)::DataFrame
    data_path = joinpath(@__DIR__, "..", "data", string(name, ".csv"))

    ispath(data_path) || error("Unable to locate dataset file $data_path")
    isfile(data_path) || error("Not a file, $data_path")

    return DataFrame(CSV.File(data_path, header=true, comment="#"))
end

end # module
