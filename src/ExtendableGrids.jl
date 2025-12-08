module ExtendableGrids

using DocStringExtensions
using ElasticArrays
using StaticArrays
using AbstractTrees
using WriteVTK
using Compat: @compat
using InteractiveUtils
using SparseArrays
using Printf
using Random
using Dates
using LinearAlgebra
import Graphs


include("adjacency.jl")
export Adjacency, VariableTargetAdjacency, FixedTargetAdjacency
export atranspose, num_targets, num_sources, num_links, append!, max_num_targets_per_source
export asparse, tryfix, makevar

include("serialadjacency.jl")
export SerialVariableTargetAdjacency

include("vectorofconstants.jl")
export VectorOfConstants

include("typehierarchy.jl")
export AbstractExtendableGridApexType
export typehierarchy

include("elementgeometry.jl")
export AbstractElementGeometry, ElementInfo
export elementgeometries, ElementGeometries

export AbstractElementGeometry0D
export Vertex0D

export AbstractElementGeometry1D
export Edge1D

export AbstractElementGeometry2D
export Polygon2D, Triangle2D, Quadrilateral2D, Pentagon2D, Hexagon2D, Parallelogram2D, Rectangle2D, Circle2D

export AbstractElementGeometry3D
export Polyhedron3D, Tetrahedron3D, Hexahedron3D, Parallelepiped3D, RectangularCuboid3D, Prism3D, TrianglePrism3D, Sphere3D

export AbstractElementGeometry4D
export Polychoron4D, HyperCube4D

export dim_element

include("coordinatesystem.jl")
export coordinatesystems, CoordinateSystems
export AbstractCoordinateSystem
export Cartesian1D, Cartesian2D, Cartesian3D
export Cylindrical2D, Cylindrical3D
export Polar2D, Polar1D, Spherical3D, Spherical1D

include("extendablegrid.jl")
export ExtendableGrid
export instantiate, veryform
export update!
export AbstractGridComponent
export AbstractGridAdjacency, AbstractElementGeometries, AbstractElementRegions
export Coordinates, CellNodes, BFaceNodes
export CellGeometries, BFaceGeometries
export CellRegions, BFaceRegions, BEdgeRegions
export NumCellRegions, NumBFaceRegions, NumBEdgeRegions
export CoordinateSystem
export AbstractGridFloatArray1D, AbstractGridFloatArray2D
export AbstractGridIntegerArray1D, AbstractGridIntegerArray2D
export index_type, coord_type
export dim_space, dim_grid
export num_nodes, num_cells, num_bfaces, num_bedges
export num_cellregions, num_bfaceregions, num_bedgeregions
export gridcomponents
export isconsistent, dangling_nodes
export seemingly_equal, numbers_match
export trim!, trim, explode

include("partitioning.jl")
export PColorPartitions, PartitionCells, PartitionBFaces, PartitionNodes, NodePermutation, PartitionEdges
export num_pcolors, num_partitions, pcolors, pcolor_partitions, partition_cells, partition_bfaces, partition_nodes, partition_edges
export partition, num_partitions_per_color, num_cells_per_color, check_partitioning, num_nodes_per_partition, num_edges_per_partition
export AbstractPartitioningAlgorithm, TrivialPartitioning, PlainMetisPartitioning, RecursiveMetisPartitioning


include("assemblytypes.jl")
export AssemblyType
export AT_NODES, ON_CELLS, ON_FACES, ON_IFACES, ON_BFACES, ON_EDGES, ON_BEDGES
export ItemType4AssemblyType
export GridComponentNodes4AssemblyType
export GridComponentVolumes4AssemblyType
export GridComponentGeometries4AssemblyType
export GridComponentRegions4AssemblyType
export GridComponentUniqueGeometries4AssemblyType
export GridComponentAssemblyGroups4AssemblyType

include("subgrid.jl")
export subgrid
export ParentGrid
export NodeParents, CellParents, FaceParents, BFaceParents, EdgeParents, BEdgeParents
export ParentGridRelation, SubGrid, RefinedGrid

include("shape_specs.jl")
export refcoords_for_geometry
export num_nodes
export num_faces
export num_edges
export local_cellfacenodes
export local_celledgenodes
export facetype_of_cellface
export Normal4ElemType!
export Tangent4ElemType!
export xrefFACE2xrefCELL
export xrefFACE2xrefOFACE


include("derived.jl")
export Coordinates
export CellVolumes, CellFaces, CellEdges, CellFaceSigns, CellFaceOrientations, CellEdgeSigns
export FaceNodes, FaceGeometries, FaceVolumes, FaceRegions, FaceCells, FaceEdges, FaceEdgeSigns, FaceNormals
export EdgeNodes, EdgeGeometries, EdgeVolumes, EdgeRegions, EdgeCells, EdgeTangents
export NodeCells, NodeFaces, NodeEdges
export BFaceFaces, BFaceCellPos, BFaceVolumes
export BEdgeNodes, BEdgeEdges, BEdgeVolumes, BEdgeGeometries
export NodePatchGroups
export unique, UniqueCellGeometries, UniqueFaceGeometries, UniqueBFaceGeometries, UniqueEdgeGeometries, UniqueBEdgeGeometries
export CellAssemblyGroups, FaceAssemblyGroups, BFaceAssemblyGroups, EdgeAssemblyGroups, BEdgeAssemblyGroups
export GridComponent4TypeProperty
export ITEMTYPE_CELL, ITEMTYPE_FACE, ITEMTYPE_BFACE, ITEMTYPE_EDGE, ITEMTYPE_BEDGE
export PROPERTY_NODES, PROPERTY_REGION, PROPERTY_VOLUME, PROPERTY_UNIQUEGEOMETRY, PROPERTY_GEOMETRY, PROPERTY_ASSEMBLYGROUP
export GridEGTypes
export GridRegionTypes

include("more.jl")
# export EdgeNodes, CellEdges, EdgeCells,
export BFaceCells, BFaceNormals, BFaceEdges, BEdgeNodes

include("voronoi.jl")
export tricircumcenter!, VoronoiFaceCenters

include("meshrefinements.jl")
export split_grid_into
export uniform_refine
export barycentric_refine

include("adaptive_meshrefinements.jl")
export bulk_mark
export RGB_refine

include("l2gtransformations.jl")
export L2GTransformer, update_trafo!, eval_trafo!, mapderiv!

include("cellfinder.jl")
export CellFinder
export gFindLocal!, gFindBruteForce!, interpolate, interpolate!

include("commongrids.jl")
export reference_domain
export grid_unitcube
export grid_lshape
export grid_unitsquare, grid_unitsquare_mixedgeometries
export grid_triangle
export ringsector

include("regionedit.jl")
export cellmask!, bfacemask!, bedgemask!, rect!

include("arraytools.jl")
export glue, geomspace, linspace

include("binnedpointlist.jl")
export BinnedPointList, findpoint

include("simplexgrid.jl")
export simplexgrid, geomspace, glue
export XCoordinates, YCoordinates, ZCoordinates

include("tokenstream.jl")
export TokenStream, gettoken, expecttoken, trytoken

include("io.jl")
export writeVTK

include("seal.jl")

include("deprecated.jl")

export simplexgrid_from_gmsh, simplexgrid_to_gmsh

end # module
