module RRModels

import Base.setproperty!
export AbstractRRModel, LinearBucket, simulate

include("AbstractRRModel.jl")
include("LinearBucket.jl")
# include("GR4J.jl")

end # module
