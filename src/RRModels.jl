module RRModels

import Base.setproperty!
import Base.==
import Base.show
export AbstractRRModel, LinearBucket, simulate, stash

include("AbstractRRModel.jl")
include("LinearBucket.jl")
# include("GR4J.jl")

end # module
