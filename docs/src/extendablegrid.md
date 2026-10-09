# Extendable grid


An ExtendableGrid in form of a dictionary with types as keys and type stable value access.
This means that grid components are accessed as dict entries, e.g. `grid[Coordinates]`.
The rationale behind this decision is described [below](@ref TDict).

```@contents
Pages = ["extendablegrid.md"]
Depth = 2:6
```

## Extendable grid notations
A grid is assumed to be a subset of components of a polyhedral complex in d-dimensional space.
We distinguish the following element classes characterized by their dimension:

| Element class | Meaning                                                                    |
| :--           | :--                                                                        |
| Node          | 0-dimensional node                                                         |
| Edge          | 1-dimensional line connecting two neighboring nodes                         |
| Face          | codimension 1 object separating a cell from outer space or neighboring cell |
| Cell          | codimension 0 object                                                       |
| BFace         | Face situated at inner or domain boundary                                  |
| Region        | number to be used to characterize subdomains, contacts etc.                |
 
## Grid components

Grid components are accessed like Dict entries, the keys must be subtypes of [`AbstractGridComponent`](@ref).

### Basic set of grid components
Upon construction, an ExtendableGrid needs to be provided with the basic set of grid components denoted by
the following component type keys:

| Component type key          | Meaning                                                                                              |
| :---------------            | :--------------------------------------------------------------------------------------------------- |
| [`Coordinates`](@ref)       | Coordinates of the vertices of the grid cells                                                        |
| [`CellNodes`](@ref)         | Adjacency describing the nodes of grid cell                                                          |
| [`CellGeometries`](@ref)    | Abstract array of subtypes of AbstractElementGeometry describing the geometry of each cell           |
| [`CellRegions`](@ref)       | Abstract array of integers describing region numbers                                                 |
| [`BFaceNodes`](@ref)        | Adjacency structure describing the nodes corresponding to each grid boundary face                    |
| [`BFaceGeometries`](@ref)   | Abstract array of subtypes of AbstractElementGeometry describing the geometry of each boundary face  |
| [`BFaceRegions`](@ref)      | Abstract array of integers describig region numbers                                                  |
| [`CoordinateSystem `](@ref) | Abstract type describing the coordinate system to be used                                            |



### Hierarchy of component type keys

The list of components can be printed using the [`gridcomponents`](@ref) method.
```@example
using ExtendableGrids # hide
gridcomponents() #hide
```

### Additional components
Additional components can be added by defining  a subtype of [`AbstractGridComponent`](@ref) or
a fitting subtype thereof, and assigning the value to the corresponding Dict entry:

```@example
using ExtendableGrids # hide
g=simplexgrid([1,2,3,4.0])
abstract type MyComponent <: AbstractGridComponent end
g[MyComponent]=13
show(g)
```

Alternatively, component creation can be performed lazily. For this
purpose one needs to define an `instantiate` method:


```@example
using ExtendableGrids # hide
abstract type NodeCells <: AbstractGridAdjacency end
ExtendableGrids.instantiate(grid, ::Type{NodeCells})=atranspose(grid[CellNodes])
g=simplexgrid([1,2,3,4.0])
show(g[NodeCells])
```


## Grid API

```@autodocs
Modules = [ExtendableGrids]
Pages = ["extendablegrid.jl"]
```
