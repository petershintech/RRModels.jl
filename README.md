# RRModels

| **Build Status**                                                                                |
|:----------------------------------------------------------------------------------------------- |
 [![][travis-img]][travis-url] [![][codecov-img]][codecov-url]

A collection of rainfall-runoff models. The package provides Linear Bucket, GR4J and other models.

## Installation

The package can be installed with the Julia package manager. From the Julia REPL, type `]` to enter the Pkg REPL mode and run:

````julia
pkg> add RRModels
````

If you want to install the package directly from its github development site,

````julia
pkg> add http://github.com/petershintech/RRModels.jl
````

And load the package using the command:

````julia
using RRModels
````

## How to run a rainfall-runoff simulation?
````julia
julia> data = dataset("gr4j_sample")
julia> model = GR4J(350.0, 0.0, 40.0, 0.5, 0.0, 0.0)
GR4J Model:
X1 = 350.0
X2 = 0.0
X3 = 40.0
X4 = 0.5
Sp = 0.0
Sr = 0.0
julia> Q, AET = simulate(model, data.P, data.PET)
````

## Disclaimer


[travis-img]: https://travis-ci.org/petershintech/RRModels.jl.svg?branch=master
[travis-url]: https://travis-ci.org/petershintech/RRModels.jl

[codecov-img]: https://codecov.io/gh/petershintech/RRModels.jl/branch/master/graph/badge.svg
[codecov-url]: https://codecov.io/gh/petershintech/RRModels.jl
