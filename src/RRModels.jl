module RRModels

import Base.setproperty!
import Base.==
export AbstractRRModel, LinearBucket, simulate, stash

include("AbstractRRModel.jl")
include("LinearBucket.jl")
# include("GR4J.jl")

end # module
