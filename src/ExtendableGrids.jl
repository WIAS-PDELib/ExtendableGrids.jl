module ExtendableGrids

using DocStringExtensions
using ElasticArrays
using StaticArrays
using ExtendableSparse
using AbstractTrees


using InteractiveUtils
using SparseArrays
using Printf
using Random
using Dates


# for plotting
using Colors
using ColorSchemes
using GeometryBasics
using LinearAlgebra



include("adjacency.jl")
export Adjacency,VariableTargetAdjacency,FixedTargetAdjacency
export atranspose,num_targets,num_sources,num_links,append!, max_num_targets_per_source



include("vectorofconstants.jl")
export VectorOfConstants

include("typehierarchy.jl")
export AbstractExtendableGridApexType
export typehierarchy

include("elementgeometry.jl")
export AbstractElementGeometry, ElementInfo
export elementgeometries

export AbstractElementGeometry0D
export Vertex0D

export AbstractElementGeometry1D
export Edge1D

export AbstractElementGeometry2D
export Polygon2D,Triangle2D,Quadrilateral2D,Pentagon2D,Hexagon2D,Parallelogram2D,Circle2D

export AbstractElementGeometry3D
export Polyhedron3D,Tetrahedron3D, Hexahedron3D,Parallelepiped3D,Prism3D,TrianglePrism3D,Sphere3D

export AbstractElementGeometry4D
export Polychoron4D,HyperCube4D

export dim_element


include("coordinatesystem.jl")
export coordinatesystems
export AbstractCoordinateSystem
export Cartesian1D,Cartesian2D,Cartesian3D
export Cylindrical2D,Cylindrical3D
export Polar2D,Polar1D ,Spherical3D,Spherical1D  



include("extendablegrid.jl")
export ExtendableGrid
export instantiate, veryform
export AbstractGridComponent
export AbstractGridAdjacency,AbstractElementGeometries,AbstractElementRegions
export Coordinates,CellNodes,BFaceNodes,CellGeometries,BFaceGeometries,CellRegions,BFaceRegions
export NumCellRegions,NumBFaceRegions,CoordinateSystem
export AbstractGridFloatArray1D,AbstractGridFloatArray2D
export AbstractGridIntegerArray1D,AbstractGridIntegerArray2D
export index_type, coord_type
export dim_space, dim_grid
export num_nodes, num_cells, num_bfaces
export gridcomponents
export seemingly_equal 

include("subgrid.jl")
export subgrid

include("more.jl")
export EdgeNodes, CellEdges,EdgeCells
export local_celledgenodes,num_edges

include("regionedit.jl")
export cellmask!,bfacemask!

include("simplexgrid.jl")
export simplexgrid, geomspace,glue
export XCoordinates, YCoordinates, ZCoordinates
export writefile

include("tokenstream.jl")
export TokenStream, gettoken, expecttoken,trytoken

include("plot.jl")
include("plotters/common.jl")
include("plotters/pyplot.jl")
include("plotters/makie.jl")
include("plotters/vtkview.jl")
include("plotters/meshcat.jl")

# Plots is unable to handle triangulations, so
# maintenence of this does not make much sense.
# include("plotters/plots.jl")

export gridplot,gridplot!,save
export isplots,isvtkview,ispyplot,ismakie
export GridPlotContext, SubPlotContext
export plottertype
export displayable
export PyPlotType,MakieType,PlotsType,VTKViewType 

end # module
