"""
$(TYPEDEF)

Common supertype of all element geometry types that can be used for cells and faces of a grid.
"""
abstract type AbstractElementGeometry <: AbstractExtendableGridApexType end

"""
$(TYPEDSIGNATURES)

List supported element geometries.
"""
elementgeometries() = AbstractTrees.print_tree(AbstractElementGeometry)


"""
$(TYPEDEF)

Supertype of all element geometries of dimension 0.
"""
abstract type AbstractElementGeometry0D <: AbstractElementGeometry end
"""
$(TYPEDEF)

Supertype of all element geometries of dimension 1.
"""
abstract type AbstractElementGeometry1D <: AbstractElementGeometry end
"""
$(TYPEDEF)

Supertype of all element geometries of dimension 2.
"""
abstract type AbstractElementGeometry2D <: AbstractElementGeometry end
"""
$(TYPEDEF)

Supertype of all element geometries of dimension 3.
"""
abstract type AbstractElementGeometry3D <: AbstractElementGeometry end
"""
$(TYPEDEF)

Supertype of all element geometries of dimension 4.
"""
abstract type AbstractElementGeometry4D <: AbstractElementGeometry end

"""
$(TYPEDEF)

Vertex element geometry with a single node.
"""
abstract type Vertex0D <: AbstractElementGeometry0D end

"""
$(TYPEDEF)

Line segment element geometry with two nodes.
"""
abstract type Edge1D <: AbstractElementGeometry1D end

"""
$(TYPEDEF)

Supertype of 2D element geometries with polygonal shape.
"""
abstract type Polygon2D <: AbstractElementGeometry2D end
"""
$(TYPEDEF)

Triangle element geometry with three nodes and three edges.
"""
abstract type Triangle2D <: Polygon2D end
"""
$(TYPEDEF)

Quadrilateral element geometry with four nodes and four edges.
"""
abstract type Quadrilateral2D <: Polygon2D end
"""
$(TYPEDEF)

Pentagon element geometry with five nodes and five edges (no explicit shape specs implemented yet).
"""
abstract type Pentagon2D <: Polygon2D end
"""
$(TYPEDEF)

Hexagon element geometry with six nodes and six edges (no explicit shape specs implemented yet).
"""
abstract type Hexagon2D <: Polygon2D end
"""
$(TYPEDEF)

Parallelogram element geometry with four nodes and four edges.
"""
abstract type Parallelogram2D <: Quadrilateral2D end

"""
$(TYPEDEF)

Rectangle element geometry with four nodes and four edges.
"""
abstract type Rectangle2D <: Parallelogram2D end

"""
$(TYPEDEF)

Circle as element geometry type (no explicit shape specs implemented yet).
"""
abstract type Circle2D <: AbstractElementGeometry2D end

"""
$(TYPEDEF)

Supertype of 3D element geometries with polyhedral shape.
"""
abstract type Polyhedron3D <: AbstractElementGeometry3D end
"""
$(TYPEDEF)

Tetrahedron element geometry with four nodes, six edges and four triangular faces.
"""
abstract type Tetrahedron3D <: Polyhedron3D end
"""
$(TYPEDEF)

Hexahedron element geometry with eight nodes, twelve edges and six quadrilateral faces.
"""
abstract type Hexahedron3D <: Polyhedron3D end
"""
$(TYPEDEF)

Parallelepiped element geometry with eight nodes, twelve edges and six parallelogram faces.
"""
abstract type Parallelepiped3D <: Hexahedron3D end
"""
$(TYPEDEF)

Rectangular cuboid element geometry with eight nodes, twelve edges and six rectangular faces.
"""
abstract type RectangularCuboid3D <: Parallelepiped3D end
"""
$(TYPEDEF)

Supertype of prismatic 3D element geometries (no explicit shape specs implemented yet).
"""
abstract type Prism3D <: Polyhedron3D end
"""
$(TYPEDEF)

Prism with triangular base (wedge) with six nodes, nine edges, two triangular and three quadrilateral faces (no explicit shape specs implemented yet).
"""
abstract type TrianglePrism3D <: Prism3D end
"""
$(TYPEDEF)

Sphere as element geometry type (no explicit shape specs implemented yet).
"""
abstract type Sphere3D <: AbstractElementGeometry3D end

"""
$(TYPEDEF)

Supertype of 4D element geometries with polychoron shape (no explicit shape specs implemented yet).
"""
abstract type Polychoron4D <: AbstractElementGeometry4D end
"""
$(TYPEDEF)

Hypercube (tesseract) element geometry with sixteen nodes (no explicit shape specs implemented yet).
"""
abstract type HyperCube4D <: AbstractElementGeometry4D end

"""
$(TYPEDSIGNATURES)

Spatial dimension of the element geometry (`0` for 0D geometries).
"""
dim_element(::Type{<:AbstractElementGeometry0D}) = 0
"""
$(TYPEDSIGNATURES)

Spatial dimension of the element geometry (`1` for 1D geometries).
"""
dim_element(::Type{<:AbstractElementGeometry1D}) = 1
"""
$(TYPEDSIGNATURES)

Spatial dimension of the element geometry (`2` for 2D geometries).
"""
dim_element(::Type{<:AbstractElementGeometry2D}) = 2
"""
$(TYPEDSIGNATURES)

Spatial dimension of the element geometry (`3` for 3D geometries).
"""
dim_element(::Type{<:AbstractElementGeometry3D}) = 3
"""
$(TYPEDSIGNATURES)

Spatial dimension of the element geometry (`4` for 4D geometries).
"""
dim_element(::Type{<:AbstractElementGeometry4D}) = 4


const allgeometrytypes = vcat(
    allsubtypes(AbstractElementGeometry0D),
    allsubtypes(AbstractElementGeometry1D),
    allsubtypes(AbstractElementGeometry2D),
    allsubtypes(AbstractElementGeometry3D)
)

"""
````
const ElementGeometries = Union{[Type{t} for t in allgeometrytypes]...}
````

Union type of the types of all supported element geometries.
"""
const ElementGeometries = Union{[Type{t} for t in allgeometrytypes]...}
