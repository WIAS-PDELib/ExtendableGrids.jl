# Extendable grid data container for numerical simulations

[![Build status](https://github.com/WIAS-PDELib/ExtendableGrids.jl/actions/workflows/ci.yml/badge.svg?branch=master)](https://github.com/WIAS-PDELib/ExtendableGrids.jl/actions/workflows/ci.yml?query=branch%3Amaster)
[![](https://img.shields.io/badge/docs-stable-blue.svg)](https://WIAS-PDELib.github.io/ExtendableGrids.jl/stable)
[![](https://img.shields.io/badge/docs-dev-blue.svg)](https://WIAS-PDELib.github.io/ExtendableGrids.jl/dev)
[![code style: runic](https://img.shields.io/badge/code_style-%E1%9A%B1%E1%9A%A2%E1%9A%BE%E1%9B%81%E1%9A%B2-black)](https://github.com/fredrikekre/Runic.jl)


Provide container structure `ExtendableGrid` with type stable content access and lazy content creation holding data for discretization
grids for finite element and finite volume methods.
Used by [VoronoiFVM](https://github.com/WIAS-PDELib/VoronoiFVM.jl) and  [ExtendableFEM](https://github.com/WIAS-PDELib/ExtendableFEM.jl),
a package for novel, gradient robust finite element methods.


## Showcase

### Create a grid and discover basic adjacencies

```julia
using ExtendableGrids

# create a 3D unit cube made of tetrahedra
unitcube = grid_unitcube(Tetrahedron3D)

@show num_cells(unitcube) # = 6 (the unit cube consists of 6 tetrahedra)
@show num_nodes(unitcube) # = 8 (the unit cube has 8 corners)

cellnodes = unitcube[CellNodes]  # this is the mapping cell index -> node indices
typeof(cellnodes) <: Matrix # true: each cell (tetrahedron!) has 4 nodes:
                            # store mapping as a matrix!

@show cellnodes[: , 2] # = [1,3,4,7], the nodes of the second cell

# create a 2D unit square made of triangles
unitsquare = grid_unitsquare(Triangle2D)

nodecells = unitsquare[NodeCells] # the node index -> cell indices mapping
typeof(cellnodes) <: Matrix # false!
                            # each node has a different number of adjacent cells:
                            # stored as `VariableTargetAdjacency`

@show nodecells[: , 2] # = [1,2]
@show nodecells[: , 5] # = [1,2,3,4] # (center node)
```
Other adjacency mappings are constructed by combining grid components, see [Notations](https://wias-pdelib.github.io/ExtendableGrids.jl/stable/extendablegrid/#Notations). For example `FaceCells`, `BFaceNodes`, `NodeEdges`, ...

### Grid data and plotting

```julia
using ExtendableGrids

unitsquare = grid_unitsquare(Triangle2D)

coords = unitsquare[Coordinates] # matrix of all node coordinates
@show coords[: , 5]              # = [ 0.5, 0.5 ] (center node)

regions = unitsquare[CellRegions] # mapping cell index -> region number
@show all( ==(1), regions)        # in this grid, all cell regions are = 1

 # mapping boundary face index -> boundary region number
bfaceregions = unitsquare[BFaceRegions]
@show bfaceregions # = [1,2,3,4], the four boundary regions are labeled by 1,2,3,4

# Plotting is done via GridVisualize.jl and a Plotter (PythonPlot.jl,
# GLMakie.jl, Plutovista.jl, ...)
using GridVisualize, PythonPlot
gridplot(unitsquare, Plotter=PythonPlot) # this opens a window with a plot
```

Example plots are shown in [GridVisualize.jl](https://wias-pdelib.github.io/GridVisualize.jl/stable/script_examples/plotting/#2D-grids).




## Additional functionality:


- Tools to create tensor product grids
- Tools for grid modification

## Companion packages:
- [Gmsh.jl](https://github.com/JuliaFEM/Gmsh.jl) extension. Please be aware about the fact that, while this package
  and  [Gmsh.jl](https://github.com/JuliaFEM/Gmsh.jl) are MIT licensed, the underlying binary code of Gmsh is
  distributed under the [GPLv2 license](https://gmsh.info/LICENSE.txt).
- Visualization of these grids and of functions on them is available in [GridVisualize.jl](https://github.com/WIAS-PDELib/GridVisualize.jl).
- [SimplexGridFactory](https://github.com/WIAS-PDELib/SimplexGridFactory.jl) contains an API which allows to
  create `ExtendableGrid` objects with  [Triangulate.jl](https://github.com/JuliaGeometry/Triangulate.jl) which wraps the Triangle mesh generator
  by J. Shewchuk and [TetGen.jl](https://github.com/JuliaGeometry/TetGen.jl) which wraps the  TetGen mesh generator by H. Si.
- [Triangulate.jl](https://github.com/JuliaGeometry/Triangulate.jl) and  [TetGen.jl](https://github.com/JuliaGeometry/TetGen.jl) extensions
- [Metis.jl](https://github.com/JuliaSparse/Metis.jl) extension and partitioning for multithreading (under development)

## Recent changes
- Please look up the list of recent [changes](https://WIAS-PDELib.github.io/ExtendableGrids.jl/stable/changes)
