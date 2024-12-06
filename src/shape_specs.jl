# The following methods are uses in VoronoiFVM.
# Do we need a more systematic approach here ?
"""
$(SIGNATURES)

Number of edges in grid.
"""
num_edges(grid::ExtendableGrid) = haskey(grid, EdgeNodes) ? num_sources(grid[EdgeNodes]) : 0

#########################################
# VERTEX0D <: AbstractElementGeometry0D #       [1]
#########################################

const _refcoords_for_geometry_Vertex0D = reshape([0], 1, 1) |> Matrix
const _local_celledgenodes_Vertex0D = reshape([1], 1, 1) |> Matrix

"""
$(SIGNATURES)

Coordinates of reference geometry of 0D vertex
"""
refcoords_for_geometry(::Type{<:AbstractElementGeometry0D}) = _refcoords_for_geometry_Vertex0D

"""
$(SIGNATURES)

Number of nodes of 0D vertex
"""
num_nodes(::Type{<:AbstractElementGeometry0D}) = 1

"""
$(SIGNATURES)

Number of faces of 0D vertex
"""
num_faces(::Type{<:AbstractElementGeometry0D}) = 0

"""
$(SIGNATURES)

Number of edges of 0D vertex
"""
num_edges(::Type{<:AbstractElementGeometry0D}) = 0

"""
$(SIGNATURES)

Cell-edge node numbering for 1D edge
"""
local_celledgenodes(::Type{Vertex0D}) = _local_celledgenodes_Vertex0D


#######################################
# EDGE1D <: AbstractElementGeometry1D #     [1]-----[2]        [1] = 0, [2] = 1
#######################################

const _refcoords_for_geometry_Edge1D = reshape([0; 1]', 1, 2) |> Matrix
const _local_cellfacenodes_Edge1D = reshape([1; 2], 1, 2) |> Matrix
const _local_celledgenodes_Edge1D = reshape([1; 2], 2, 1) |> Matrix

"""
$(SIGNATURES)

Coordinates of reference geometry of 1D edge
"""
refcoords_for_geometry(::Type{<:AbstractElementGeometry1D}) = _refcoords_for_geometry_Edge1D

"""
$(SIGNATURES)

Number of nodes for 1D edge
"""
num_nodes(::Type{<:AbstractElementGeometry1D}) = 2

"""
$(SIGNATURES)

Number of faces for 1D edge
"""
num_faces(::Type{<:AbstractElementGeometry1D}) = 2

"""
$(SIGNATURES)

Number of edges for 1D edge
"""
num_edges(::Type{<:AbstractElementGeometry1D}) = 0

"""
$(SIGNATURES)

Cell-face node numbering for 1D edge
"""
local_cellfacenodes(::Type{<:AbstractElementGeometry1D}) = _local_cellfacenodes_Edge1D

"""
$(SIGNATURES)

Cell-edge node numbering for 1D edge
"""
local_celledgenodes(::Type{<:AbstractElementGeometry1D}) = _local_celledgenodes_Edge1D

"""
$(SIGNATURES)

Number of edges of 1D edge
"""
num_edges(::Type{Edge1D}) = 1

"""
$(SIGNATURES)

Geometries of faces of 1D edge
"""
facetype_of_cellface(::Type{<:AbstractElementGeometry1D}, k) = Vertex0D


xrefFACE2xrefCELL(::Type{<:AbstractElementGeometry1D}) = [
    [(xref4FACE) -> [1]],
    [(xref4FACE) -> [1]],
]

xrefFACE2xrefOFACE(::Type{<:AbstractElementGeometry1D}) = [(xref4FACE) -> xref4FACE, (xref4FACE) -> 1 .- xref4FACE]


#                   [3]
#                    | \
##############       |   \                    [1] = (0,0)
# Triangle2D #       |     \                  [2] = (1,0)
##############       |       \                [3] = (0,1)
#                    |         \
#                   [1]--------[2]


const _refcoords_for_geometry_Triangle2D = [0 0; 1 0; 0 1]' |> Matrix
const _local_cellfacenodes_Triangle2D = [1 2; 2 3; 3 1]' |> Matrix # local edgenodes are the same

"""
$(SIGNATURES)

Coordinates of reference geometry of 2D triangle
"""
refcoords_for_geometry(::Type{<:Triangle2D}) = _refcoords_for_geometry_Triangle2D

"""
$(SIGNATURES)

Number of nodes in 2D triangle
"""
num_nodes(::Type{<:Triangle2D}) = 3

"""
$(SIGNATURES)

Number of faces in 2D triangle
"""
num_faces(::Type{<:Triangle2D}) = 3

"""
$(SIGNATURES)

Number of edges in 2D triangle
"""
num_edges(::Type{<:Triangle2D}) = 3

"""
$(SIGNATURES)

Cell-face node numbering for 2D triangle
"""
local_cellfacenodes(::Type{<:Triangle2D}) = _local_cellfacenodes_Triangle2D

"""
$(SIGNATURES)

Cell-edge node numbering for 2D triangle
"""
local_celledgenodes(::Type{<:Triangle2D}) = _local_cellfacenodes_Triangle2D

"""
$(SIGNATURES)

Geometries of faces of 2D triangle
"""
facetype_of_cellface(::Type{<:Triangle2D}, k) = Edge1D

# maps of reference coords on cell face to reference coords in cell
xrefFACE2xrefCELL(::Type{<:Triangle2D}) = [
    (xref4FACE) -> [xref4FACE[1], 0],
    (xref4FACE) -> [1 - xref4FACE[1], xref4FACE[1]],
    (xref4FACE) -> [0, 1 - xref4FACE[1]],
]

# maps of reference coords on face to reference coords in face with other orientation
xrefFACE2xrefOFACE(::Type{<:Triangle2D}) = [
    (xref4FACE) -> xref4FACE,                                    # orientation 1 = [1,2,3]
    (xref4FACE) -> [xref4FACE[1], 1 - xref4FACE[1] - xref4FACE[2]],   # orientation 2 = [1,3,2]
    (xref4FACE) -> [1 - xref4FACE[1] - xref4FACE[2], xref4FACE[2]],   # orientation 3 = [3,2,1]
    (xref4FACE) -> [xref4FACE[2], xref4FACE[1]],                   # orientation 4 = [2,1,3]
]


#                        [4]--------[3]
#                         |          |             [1] = (0,0)
###################       |          |             [2] = (1,0)
# Quadrilateral2D #       |          |             [3] = (1,1)
###################       |          |             [4] = (0,1)
#                        [1]--------[2]


const _refcoords_for_geometry_Quadrilateral2D = [0 0; 1 0; 1 1; 0 1]' |> Matrix
const _local_cellfacenodes_Quadrilateral2D = [1 2; 2 3; 3 4; 4 1]' |> Matrix # local edgenodes are the same

"""
$(SIGNATURES)

Coordinates of reference geometry of 2D quadrilateral
"""
refcoords_for_geometry(::Type{<:Quadrilateral2D}) = _refcoords_for_geometry_Quadrilateral2D

"""
$(SIGNATURES)

Number of nodes in 2D quadrilateral
"""
num_nodes(::Type{<:Quadrilateral2D}) = 4

"""
$(SIGNATURES)

Number of faces in 2D quadrilateral
"""
num_faces(::Type{<:Quadrilateral2D}) = 4

"""
$(SIGNATURES)

Number of edges in 2D quadrilateral
"""
num_edges(::Type{<:Quadrilateral2D}) = 4

"""
$(SIGNATURES)

Cell-face node numbering for 2D quadrilateral
"""
local_cellfacenodes(::Type{<:Quadrilateral2D}) = _local_cellfacenodes_Quadrilateral2D

"""
$(SIGNATURES)

Cell-edge node numbering for 2D quadrilateral
"""
local_celledgenodes(::Type{<:Quadrilateral2D}) = _local_cellfacenodes_Quadrilateral2D

"""
$(SIGNATURES)

Geometries of faces of 2D quadrilateral
"""
facetype_of_cellface(::Type{<:Quadrilateral2D}, k) = Edge1D

# maps of reference coords on cell face to reference coords in cell
xrefFACE2xrefCELL(::Type{<:Quadrilateral2D}) = [
    (xref4FACE) -> [xref4FACE[1], 0],
    (xref4FACE) -> [1, xref4FACE[1]],
    (xref4FACE) -> [1 - xref4FACE[1], 1],
    (xref4FACE) -> [0, 1 - xref4FACE[1]],
]


#                      [4]
#                       |\\
#################       | \ \                    [1] = (0,0,0)
# Tetrahedron3D #       |  \  \                  [2] = (1,0,0)
#################       |   \   \                [3] = (0,1,0)
#                       | _-[3]-_ \              [4] = (0,0,1)
#                      [1]--------[2]


const _refcoords_for_geometry_Tetrahedron3D = [0 0 0; 1 0 0; 0 1 0; 0 0 1]' |> Matrix
const _local_cellfacenodes_Tetrahedron3D = [1 3 2; 1 2 4; 2 3 4; 1 4 3]' |> Matrix
const _local_celledgenodes_Tetrahedron3D = [1 2; 1 3; 1 4; 2 3; 2 4; 3 4]' |> Matrix

"""
$(SIGNATURES)

Coordinates of reference geometry of 3D tetrahedron
"""
refcoords_for_geometry(::Type{<:Tetrahedron3D}) = _refcoords_for_geometry_Tetrahedron3D

"""
$(SIGNATURES)

Number of nodes in 3D tetrahedron
"""
num_nodes(::Type{<:Tetrahedron3D}) = 4

"""
$(SIGNATURES)

Number of faces in 3D tetrahedron
"""
num_faces(::Type{<:Tetrahedron3D}) = 4

"""
$(SIGNATURES)

Number of edges in 3D tetrahedron
"""
num_edges(::Type{<:Tetrahedron3D}) = 6


"""
$(SIGNATURES)

Cell-face node numbering for 3D tetrahedron
"""
local_cellfacenodes(::Type{<:Tetrahedron3D}) = _local_cellfacenodes_Tetrahedron3D

"""
$(SIGNATURES)

Geometries of faces of 3D tetrahedron
"""
facetype_of_cellface(::Type{<:Tetrahedron3D}, k) = Triangle2D

"""
$(SIGNATURES)

Cell-edge node numbering for 3D tetrahedron
"""
local_celledgenodes(::Type{<:Tetrahedron3D}) = _local_celledgenodes_Tetrahedron3D

# maps of reference coords on cell face to reference coords in cell
xrefFACE2xrefCELL(::Type{<:Tetrahedron3D}) = [
    (xref4FACE) -> [xref4FACE[2], xref4FACE[1], 0],
    (xref4FACE) -> [xref4FACE[1], 0, xref4FACE[2]],
    (xref4FACE) -> [1 - xref4FACE[1] - xref4FACE[2], xref4FACE[1], xref4FACE[2]],
    (xref4FACE) -> [0, xref4FACE[2], xref4FACE[1]],
]


#
#                         [8]--------[7]
#                        / |        / |          [1] = (0,0,0)
#                     [5]--------[6]  |          [2] = (1,0,0)
################       |   |      |   |          [3] = (1,1,0)
# Hexahedron3D #       |   |      |   |          [4] = (0,1,0)
################       |   |      |   |          [5] = (0,0,1)
#                      |  [4]-----|--[3]         [6] = (1,0,1)
#                      | /        | /            [7] = (1,1,1)
#                     [1]--------[2]             [8] = (0,1,1)


const _refcoords_for_geometry_Hexahedron3D = [0 0 0; 1 0 0; 1 1 0; 0 1 0; 0 0 1; 1 0 1; 1 1 1; 0 1 1]' |> Matrix
const _local_cellfacenodes_Hexahedron3D = [4 3 2 1; 1 2 6 5; 2 3 7 6; 3 4 8 7; 4 1 5 8; 5 6 7 8]' |> Matrix
const _local_celledgenodes_Hexahedron3D = [1 2; 2 3; 3 4; 4 1; 1 5; 2 6; 3 7; 4 8; 5 6; 6 7; 7 8; 8 5]' |> Matrix

"""
$(SIGNATURES)

Coordinates of reference geometry of 3D hexahedron
"""
refcoords_for_geometry(::Type{<:Hexahedron3D}) = _refcoords_for_geometry_Hexahedron3D

"""
$(SIGNATURES)

Number of nodes in 3D hexahedron
"""
num_nodes(::Type{<:Hexahedron3D}) = 8
num_faces(::Type{<:Hexahedron3D}) = 6
num_edges(::Type{<:Hexahedron3D}) = 12


"""
$(SIGNATURES)

Cell-face node numbering for 3D hexahedron
"""
local_cellfacenodes(::Type{<:Hexahedron3D}) = _local_cellfacenodes_Hexahedron3D

"""
$(SIGNATURES)

Geometries of faces of 3D hexahedron
"""
facetype_of_cellface(::Type{<:Hexahedron3D}, k) = Quadrilateral2D

"""
$(SIGNATURES)

Geometries of faces of 3D parallelepiped
"""
facetype_of_cellface(::Type{<:Parallelepiped3D}, k) = Parallelogram2D

"""
$(SIGNATURES)

Cell-edge node numbering for 3D hexahedron
"""
local_celledgenodes(::Type{<:Hexahedron3D}) = _local_celledgenodes_Hexahedron3D


###############
### VOLUMES ###
###############

function volume(Coords, Nodes, item, ::Type{<:Vertex0D}, ::Type{<:ExtendableGrids.AbstractCoordinateSystem})
    return 1
end

function volume(Coords, Nodes, item, ::Type{<:Edge1D}, ::Type{Cartesian1D})
    return abs(Coords[1, Nodes[2, item]] - Coords[1, Nodes[1, item]])
end


function volume(Coords, Nodes, item, ::Type{<:Edge1D}, ::Type{Cartesian2D})
    return sqrt((Coords[1, Nodes[2, item]] - Coords[1, Nodes[1, item]]) .^ 2 + (Coords[2, Nodes[2, item]] - Coords[2, Nodes[1, item]]) .^ 2)
end

function volume(Coords, Nodes, item, ::Type{<:Edge1D}, ::Type{Cartesian3D})
    return sqrt((Coords[1, Nodes[2, item]] - Coords[1, Nodes[1, item]]) .^ 2 + (Coords[2, Nodes[2, item]] - Coords[2, Nodes[1, item]]) .^ 2 + (Coords[3, Nodes[2, item]] - Coords[3, Nodes[1, item]]) .^ 2)
end


function volume(Coords, Nodes, item, ::Type{Triangle2D}, ::Type{Cartesian2D})
    return 1 // 2 * (
        Coords[1, Nodes[1, item]] * (Coords[2, Nodes[2, item]] - Coords[2, Nodes[3, item]])
            + Coords[1, Nodes[2, item]] * (Coords[2, Nodes[3, item]] - Coords[2, Nodes[1, item]])
            + Coords[1, Nodes[3, item]] * (Coords[2, Nodes[1, item]] - Coords[2, Nodes[2, item]])
    )
end


function volume(Coords, Nodes, item, ::Type{<:Quadrilateral2D}, ::Type{Cartesian2D})
    return 1 // 2 * (
        (Coords[1, Nodes[1, item]] - Coords[1, Nodes[3, item]]) * (Coords[2, Nodes[2, item]] - Coords[2, Nodes[4, item]])
            + (Coords[1, Nodes[4, item]] - Coords[1, Nodes[2, item]]) * (Coords[2, Nodes[1, item]] - Coords[2, Nodes[3, item]])
    )
end

function volume(Coords, Nodes, item, ::Type{<:Triangle2D}, ::Type{Cartesian3D})
    @views d12 = SVector{3}(Coords[:, Nodes[1, item]]) - SVector{3}(Coords[:, Nodes[2, item]])
    @views d14 = SVector{3}(Coords[:, Nodes[1, item]]) - SVector{3}(Coords[:, Nodes[3, item]])
    return sqrt((d12[2] * d14[3] - d12[3] * d14[2])^2 + (d12[3] * d14[1] - d12[1] * d14[3])^2 + (d12[1] * d14[2] - d12[2] * d14[1])^2) / 2
end


function volume(Coords::Array{Tc, 2}, Nodes, item, ::Type{<:Parallelogram2D}, ::Type{Cartesian3D}) where {Tc}
    @views d12 = SVector{3}(Coords[:, Nodes[1, item]]) - SVector{3}(Coords[:, Nodes[2, item]])
    @views d14 = SVector{3}(Coords[:, Nodes[1, item]]) - SVector{3}(Coords[:, Nodes[3, item]])
    return sqrt((d12[2] * d14[3] - d12[3] * d14[2])^2 + (d12[3] * d14[1] - d12[1] * d14[3])^2 + (d12[1] * d14[2] - d12[2] * d14[1])^2)
end


function volume(Coords, Nodes, item, ::Type{<:Parallelepiped3D}, ::Type{Cartesian3D})
    return (
        (Coords[1, Nodes[5, item]] - Coords[1, Nodes[1, item]]) * ((Coords[2, Nodes[2, item]] - Coords[2, Nodes[1, item]]) * (Coords[3, Nodes[4, item]] - Coords[3, Nodes[1, item]]) - (Coords[2, Nodes[4, item]] - Coords[2, Nodes[1, item]]) * (Coords[3, Nodes[2, item]] - Coords[3, Nodes[1, item]]))
            + (Coords[2, Nodes[5, item]] - Coords[2, Nodes[1, item]]) * ((Coords[3, Nodes[2, item]] - Coords[3, Nodes[1, item]]) * (Coords[1, Nodes[4, item]] - Coords[1, Nodes[1, item]]) - (Coords[1, Nodes[2, item]] - Coords[1, Nodes[1, item]]) * (Coords[3, Nodes[4, item]] - Coords[3, Nodes[1, item]]))
            + (Coords[3, Nodes[5, item]] - Coords[3, Nodes[1, item]]) * ((Coords[1, Nodes[2, item]] - Coords[1, Nodes[1, item]]) * (Coords[2, Nodes[4, item]] - Coords[2, Nodes[1, item]]) - (Coords[2, Nodes[2, item]] - Coords[2, Nodes[1, item]]) * (Coords[1, Nodes[4, item]] - Coords[1, Nodes[1, item]]))
    )
end


function volume(Coords, Nodes, item, ::Type{<:Tetrahedron3D}, ::Type{Cartesian3D})
    return 1 // 6 * (
        (Coords[1, Nodes[4, item]] - Coords[1, Nodes[1, item]]) * ((Coords[2, Nodes[2, item]] - Coords[2, Nodes[1, item]]) * (Coords[3, Nodes[3, item]] - Coords[3, Nodes[1, item]]) - (Coords[2, Nodes[3, item]] - Coords[2, Nodes[1, item]]) * (Coords[3, Nodes[2, item]] - Coords[3, Nodes[1, item]]))
            + (Coords[2, Nodes[4, item]] - Coords[2, Nodes[1, item]]) * ((Coords[3, Nodes[2, item]] - Coords[3, Nodes[1, item]]) * (Coords[1, Nodes[3, item]] - Coords[1, Nodes[1, item]]) - (Coords[1, Nodes[2, item]] - Coords[1, Nodes[1, item]]) * (Coords[3, Nodes[3, item]] - Coords[3, Nodes[1, item]]))
            + (Coords[3, Nodes[4, item]] - Coords[3, Nodes[1, item]]) * ((Coords[1, Nodes[2, item]] - Coords[1, Nodes[1, item]]) * (Coords[2, Nodes[3, item]] - Coords[2, Nodes[1, item]]) - (Coords[2, Nodes[2, item]] - Coords[2, Nodes[1, item]]) * (Coords[1, Nodes[3, item]] - Coords[1, Nodes[1, item]]))
    )
end


###############
### NORMALS ###
###############

function Normal4ElemType!(normal, Coords, Nodes, item, ::Type{<:Vertex0D}, ::Type{Cartesian2D})
    normal[1] = 0.0
    return normal[2] = 0.0
end

function Normal4ElemType!(normal, Coords, Nodes, item, ::Type{<:Vertex0D}, ::Type{Cartesian1D})
    return normal[1] = 1.0
end

function Normal4ElemType!(normal, Coords, Nodes, item, ::Type{<:Edge1D}, ::Type{Cartesian2D})
    # rotate tangent
    normal[1] = Coords[2, Nodes[2, item]] - Coords[2, Nodes[1, item]]
    normal[2] = Coords[1, Nodes[1, item]] - Coords[1, Nodes[2, item]]
    # divide by length
    return normal ./= sqrt(normal[1]^2 + normal[2]^2)
end

function Normal4ElemType!(normal, Coords, Nodes, item, ::Type{<:Quadrilateral2D}, ::Type{Cartesian3D})
    # cross(p(1)-p(2), p(1)-p(4)) / length
    normal[1] = (Coords[2, Nodes[1, item]] - Coords[2, Nodes[2, item]]) * (Coords[3, Nodes[1, item]] - Coords[3, Nodes[4, item]])
    normal[1] -= (Coords[3, Nodes[1, item]] - Coords[3, Nodes[2, item]]) * (Coords[2, Nodes[1, item]] - Coords[2, Nodes[4, item]])
    normal[2] = (Coords[3, Nodes[1, item]] - Coords[3, Nodes[2, item]]) * (Coords[1, Nodes[1, item]] - Coords[1, Nodes[4, item]])
    normal[2] -= (Coords[1, Nodes[1, item]] - Coords[1, Nodes[2, item]]) * (Coords[3, Nodes[1, item]] - Coords[3, Nodes[4, item]])
    normal[3] = (Coords[1, Nodes[1, item]] - Coords[1, Nodes[2, item]]) * (Coords[2, Nodes[1, item]] - Coords[2, Nodes[4, item]])
    normal[3] -= (Coords[2, Nodes[1, item]] - Coords[2, Nodes[2, item]]) * (Coords[1, Nodes[1, item]] - Coords[1, Nodes[4, item]])
    # divide by length
    return normal ./= sqrt(normal[1]^2 + normal[2]^2 + normal[3]^2)

    ## old version
    #d12 = @views Coords[:, Nodes[1, item]] - Coords[:, Nodes[2, item]]
    #d14 = @views Coords[:, Nodes[1, item]] - Coords[:, Nodes[4, item]]
    #normal[1] = d12[2]*d14[3]-d12[3]*d14[2]
    #normal[2] = d12[3]*d14[1]-d12[1]*d14[3]
    #normal[3] = d12[1]*d14[2]-d12[2]*d14[1]
end

function Normal4ElemType!(normal, Coords, Nodes, item, ::Type{<:Triangle2D}, ::Type{Cartesian3D})
    # cross(p(1)-p(2), p(1)-p(3)) / length
    normal[1] = (Coords[2, Nodes[1, item]] - Coords[2, Nodes[2, item]]) * (Coords[3, Nodes[1, item]] - Coords[3, Nodes[3, item]])
    normal[1] -= (Coords[3, Nodes[1, item]] - Coords[3, Nodes[2, item]]) * (Coords[2, Nodes[1, item]] - Coords[2, Nodes[3, item]])
    normal[2] = (Coords[3, Nodes[1, item]] - Coords[3, Nodes[2, item]]) * (Coords[1, Nodes[1, item]] - Coords[1, Nodes[3, item]])
    normal[2] -= (Coords[1, Nodes[1, item]] - Coords[1, Nodes[2, item]]) * (Coords[3, Nodes[1, item]] - Coords[3, Nodes[3, item]])
    normal[3] = (Coords[1, Nodes[1, item]] - Coords[1, Nodes[2, item]]) * (Coords[2, Nodes[1, item]] - Coords[2, Nodes[3, item]])
    normal[3] -= (Coords[2, Nodes[1, item]] - Coords[2, Nodes[2, item]]) * (Coords[1, Nodes[1, item]] - Coords[1, Nodes[3, item]])
    # divide by length
    return normal ./= sqrt(normal[1]^2 + normal[2]^2 + normal[3]^2)
end


################
### TANGENTS ###
################

function Tangent4ElemType!(tangent, Coords, Nodes, item, ::Type{<:Edge1D}, ::Type{Cartesian2D})
    tangent[1] = Coords[1, Nodes[2, item]] - Coords[1, Nodes[1, item]]
    tangent[2] = Coords[2, Nodes[2, item]] - Coords[2, Nodes[1, item]]
    # divide by length
    return tangent ./= sqrt(tangent[1]^2 + tangent[2]^2)
end

function Tangent4ElemType!(tangent, Coords, Nodes, item, ::Type{<:Edge1D}, ::Type{Cartesian3D})
    tangent[1] = Coords[1, Nodes[2, item]] - Coords[1, Nodes[1, item]]
    tangent[2] = Coords[2, Nodes[2, item]] - Coords[2, Nodes[1, item]]
    tangent[3] = Coords[3, Nodes[2, item]] - Coords[3, Nodes[1, item]]
    # divide by length
    return tangent ./= sqrt(tangent[1]^2 + tangent[2]^2 + tangent[3]^2)
end
