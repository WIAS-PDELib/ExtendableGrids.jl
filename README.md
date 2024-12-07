# Extendable grid data container for numerical simulations

[![Build status](https://github.com/WIAS-PDELib/ExtendableGrids.jl/workflows/linux-macos-windows/badge.svg)](https://github.com/WIAS-PDELib/ExtendableGrids.jl/actions)
[![](https://img.shields.io/badge/docs-stable-blue.svg)](https://WIAS-PDELib.github.io/ExtendableGrids.jl/stable)
[![](https://img.shields.io/badge/docs-dev-blue.svg)](https://WIAS-PDELib.github.io/ExtendableGrids.jl/dev)
[![code style: runic](https://img.shields.io/badge/code_style-%E1%9A%B1%E1%9A%A2%E1%9A%BE%E1%9B%81%E1%9A%B2-black)](https://github.com/fredrikekre/Runic.jl)


Provide container structure `ExtendableGrid` with type stable content access and lazy content creation holding data for discretization
grids for finite element and finite volume methods.
Used by [VoronoiFVM](https://github.com/WIAS-PDELib/VoronoiFVM.jl) and  [ExtendableFEM](https://github.com/WIAS-PDELib/ExtendableFEM.jl),
a package for novel, gradient robust finite element methods.

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
