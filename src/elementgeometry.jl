"""
$(TYPEDEF)
"""
abstract type AbstractElementGeometry <: AbstractExtendableGridApexType end

"""
$(TYPEDSIGNATURES)

List supported element geometries.
"""
elementgeometries() = AbstractTrees.print_tree(AbstractElementGeometry)


"""
$(TYPEDEF)
"""
abstract type AbstractElementGeometry0D <: AbstractElementGeometry end
"""
$(TYPEDEF)
"""
abstract type AbstractElementGeometry1D <: AbstractElementGeometry end
"""
$(TYPEDEF)
"""
abstract type AbstractElementGeometry2D <: AbstractElementGeometry end
"""
$(TYPEDEF)
"""
abstract type AbstractElementGeometry3D <: AbstractElementGeometry end
"""
$(TYPEDEF)
"""
abstract type AbstractElementGeometry4D <: AbstractElementGeometry end

"""
$(TYPEDEF)
"""
abstract type Vertex0D <: AbstractElementGeometry0D end

"""
$(TYPEDEF)
"""
abstract type Edge1D <: AbstractElementGeometry1D end

"""
$(TYPEDEF)
"""
abstract type Polygon2D <: AbstractElementGeometry2D end
"""
$(TYPEDEF)
"""
abstract type Triangle2D <: Polygon2D end
"""
$(TYPEDEF)
"""
abstract type Quadrilateral2D <: Polygon2D end
"""
$(TYPEDEF)
"""
abstract type Pentagon2D <: Polygon2D end
"""
$(TYPEDEF)
"""
abstract type Hexagon2D <: Polygon2D end
"""
$(TYPEDEF)
"""
abstract type Parallelogram2D <: Quadrilateral2D end

"""
$(TYPEDEF)
"""
abstract type Rectangle2D <: Parallelogram2D end

"""
$(TYPEDEF)
"""
abstract type Circle2D <: AbstractElementGeometry2D end

"""
$(TYPEDEF)
"""
abstract type Polyhedron3D <: AbstractElementGeometry3D end
"""
$(TYPEDEF)
"""
abstract type Tetrahedron3D <: Polyhedron3D end
"""
$(TYPEDEF)
"""
abstract type Hexahedron3D <: Polyhedron3D end
"""
$(TYPEDEF)
"""
abstract type Parallelepiped3D <: Hexahedron3D end
"""
$(TYPEDEF)
"""
abstract type RectangularCuboid3D <: Parallelepiped3D end
"""
$(TYPEDEF)
"""
abstract type Prism3D <: Polyhedron3D end
"""
$(TYPEDEF)
"""
abstract type TrianglePrism3D <: Prism3D end
"""
$(TYPEDEF)
"""
abstract type Sphere3D <: AbstractElementGeometry3D end

"""
$(TYPEDEF)
"""
abstract type Polychoron4D <: AbstractElementGeometry4D end
"""
$(TYPEDEF)
"""
abstract type HyperCube4D <: AbstractElementGeometry4D end

"""
$(TYPEDSIGNATURES)
"""
dim_element(::Type{<:AbstractElementGeometry0D}) = 0
"""
$(TYPEDSIGNATURES)
"""
dim_element(::Type{<:AbstractElementGeometry1D}) = 1
"""
$(TYPEDSIGNATURES)
"""
dim_element(::Type{<:AbstractElementGeometry2D}) = 2
"""
$(TYPEDSIGNATURES)
"""
dim_element(::Type{<:AbstractElementGeometry3D}) = 3
"""
$(TYPEDSIGNATURES)
"""
dim_element(::Type{<:AbstractElementGeometry4D}) = 4


const allgeometrytypes = vcat(
    allsubtypes(AbstractElementGeometry0D),
    allsubtypes(AbstractElementGeometry1D),
    allsubtypes(AbstractElementGeometry2D),
    allsubtypes(AbstractElementGeometry3D)
)

const ElementGeometries = Union{[Type{t} for t in allgeometrytypes]...}
