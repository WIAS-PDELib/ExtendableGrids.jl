#
# Create multiscene plots for Makie, PyPlot and VTKView
#

import Pkg
Pkg.activate(mktempdir())
Pkg.add(["GLMakie", "PyPlot", "ExtendableGrids"])
Pkg.Registry.add(Pkg.RegistrySpec(url = "https://github.com/j-fu/PackageNursery"))
Pkg.add(Pkg.PackageSpec(name = "VTKView", uuid = "63b67fce-66f7-11ea-1808-1361d8c55bf4"))

import PyPlot
import GLMakie
import VTKView

using ExtendableGrids

include("../plotting.jl")

function test_multiscene()
    plotting_multiscene(Plotter = PyPlot)
    plotting__multiscene(Plotter = VTKView)
    return plotting__multiscene(Plotter = GLMakie)
end
