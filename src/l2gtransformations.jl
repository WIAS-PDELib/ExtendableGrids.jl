##################
# L2GTransformer #
##################
#
# maps points of reference geometries to global world
# and is e.g. used by FEBasisEvaluator or CellFinder
#
# needs call of update_trafo! on entry of a new cell (to update the trafo matrix and the determinant det)
#
# eval_trafo! maps local xref on cell to global x (e.g. for evaluation of data functions)
# mapderiv! gives the derivative of the mapping (for computation of derivatives of basis functions)

"""
    L2GTransformer

Transforms reference coordinates to global coordinates
"""
mutable struct L2GTransformer{Tv <: Real, Ti <: Integer, EG <: AbstractElementGeometry, CS <: AbstractCoordinateSystem}
    citem::Int
    nonlinear::Bool # so that users know if derivatives of map change in every quadrature point of cell or not
    Coords::Array{Tv, 2}
    Nodes::Adjacency{Ti}
    ItemVolumes::Array{Tv, 1}
    A::Matrix{Tv}
    b::Vector{Tv}
    C::Matrix{Tv} # cache for subcalculations that stay the same for each x (like adjugates)
    det::Tv
end

function L2GTransformer(EG::Type{<:AbstractElementGeometry}, grid::ExtendableGrid{Tv, Ti}, AT::Type{<:AssemblyType} = ON_CELLS) where {Tv, Ti}
    A = zeros(Tv, size(grid[Coordinates], 1), dim_element(EG))
    b = zeros(Tv, size(grid[Coordinates], 1))
    return L2GTransformer{Tv, Ti, EG, grid[CoordinateSystem]}(0, false, grid[Coordinates], grid[GridComponentNodes4AssemblyType(AT)], grid[GridComponentVolumes4AssemblyType(AT)], A, b, zeros(Tv, 0, 0), 0)
end

function L2GTransformer(EG::Union{Type{<:Tetrahedron3D}, Type{<:Parallelepiped3D}}, grid::ExtendableGrid{Tv, Ti}, AT::Type{<:AssemblyType} = ON_CELLS) where {Tv, Ti}
    A = zeros(Tv, size(grid[Coordinates], 1), dim_element(EG))
    b = zeros(Tv, size(grid[Coordinates], 1))
    return L2GTransformer{Tv, Ti, EG, grid[CoordinateSystem]}(0, false, grid[Coordinates], grid[GridComponentNodes4AssemblyType(AT)], grid[GridComponentVolumes4AssemblyType(AT)], A, b, zeros(Tv, 3, 3), 0)
end

function update_trafo!(T::L2GTransformer{<:Real, <:Integer, <:Vertex0D, Cartesian1D}, item::Int)
    T.b[1] = T.Coords[1, T.Nodes[1, item]]
    return nothing
end

function update_trafo!(T::L2GTransformer{<:Real, <:Integer, <:Edge1D, Cartesian1D}, item::Int)
    if T.citem != item
        T.citem = item
        T.b[1] = T.Coords[1, T.Nodes[1, item]]
        T.A[1, 1] = T.Coords[1, T.Nodes[2, item]] - T.b[1]
        T.det = T.ItemVolumes[item]
    end
    return nothing
end

function update_trafo!(T::L2GTransformer{<:Real, <:Integer, <:Edge1D, Cartesian2D}, item::Int)
    if T.citem != item
        T.citem = item
        T.b[1] = T.Coords[1, T.Nodes[1, item]]
        T.b[2] = T.Coords[2, T.Nodes[1, item]]
        T.A[1, 1] = T.Coords[1, T.Nodes[2, item]] - T.b[1]
        T.A[2, 1] = T.Coords[2, T.Nodes[2, item]] - T.b[2]
        T.det = T.ItemVolumes[item]
    end
    return nothing
end

function update_trafo!(T::L2GTransformer{<:Real, <:Integer, <:Edge1D, Cartesian3D}, item::Int)
    if T.citem != item
        T.citem = item
        T.b[1] = T.Coords[1, T.Nodes[1, item]]
        T.b[2] = T.Coords[2, T.Nodes[1, item]]
        T.b[3] = T.Coords[3, T.Nodes[1, item]]
        T.A[1, 1] = T.Coords[1, T.Nodes[2, item]] - T.b[1]
        T.A[2, 1] = T.Coords[2, T.Nodes[2, item]] - T.b[2]
        T.A[3, 1] = T.Coords[3, T.Nodes[2, item]] - T.b[3]
        T.det = T.ItemVolumes[item]
    end
    return nothing
end

function update_trafo!(T::L2GTransformer{<:Real, <:Integer, <:Triangle2D, Cartesian2D}, item::Int)
    if T.citem != item
        T.citem = item
        T.b[1] = T.Coords[1, T.Nodes[1, item]]
        T.b[2] = T.Coords[2, T.Nodes[1, item]]
        T.A[1, 1] = T.Coords[1, T.Nodes[2, item]] - T.b[1]
        T.A[1, 2] = T.Coords[1, T.Nodes[3, item]] - T.b[1]
        T.A[2, 1] = T.Coords[2, T.Nodes[2, item]] - T.b[2]
        T.A[2, 2] = T.Coords[2, T.Nodes[3, item]] - T.b[2]
        T.det = 2 * T.ItemVolumes[item]
    end
    return nothing
end

function update_trafo!(T::L2GTransformer{<:Real, <:Integer, <:Parallelogram2D, Cartesian2D}, item::Int)
    if T.citem != item
        T.citem = item
        T.b[1] = T.Coords[1, T.Nodes[1, item]]
        T.b[2] = T.Coords[2, T.Nodes[1, item]]
        T.A[1, 1] = T.Coords[1, T.Nodes[2, item]] - T.b[1]
        T.A[1, 2] = T.Coords[1, T.Nodes[4, item]] - T.b[1]
        T.A[2, 1] = T.Coords[2, T.Nodes[2, item]] - T.b[2]
        T.A[2, 2] = T.Coords[2, T.Nodes[4, item]] - T.b[2]
        T.det = T.ItemVolumes[item]
    end
    return nothing
end

function update_trafo!(T::L2GTransformer{<:Real, <:Integer, <:Triangle2D, Cartesian3D}, item::Int)
    if T.citem != item
        T.citem = item
        T.b[1] = T.Coords[1, T.Nodes[1, item]]
        T.b[2] = T.Coords[2, T.Nodes[1, item]]
        T.b[3] = T.Coords[3, T.Nodes[1, item]]
        T.A[1, 1] = T.Coords[1, T.Nodes[2, item]] - T.b[1]
        T.A[1, 2] = T.Coords[1, T.Nodes[3, item]] - T.b[1]
        T.A[2, 1] = T.Coords[2, T.Nodes[2, item]] - T.b[2]
        T.A[2, 2] = T.Coords[2, T.Nodes[3, item]] - T.b[2]
        T.A[3, 1] = T.Coords[3, T.Nodes[2, item]] - T.b[3]
        T.A[3, 2] = T.Coords[3, T.Nodes[3, item]] - T.b[3]
        T.det = 2 * T.ItemVolumes[item]
    end
    return nothing
end

function update_trafo!(T::L2GTransformer{<:Real, <:Integer, <:Parallelogram2D, Cartesian3D}, item::Int)
    if T.citem != item
        T.citem = item
        T.b[1] = T.Coords[1, T.Nodes[1, item]]
        T.b[2] = T.Coords[2, T.Nodes[1, item]]
        T.b[3] = T.Coords[3, T.Nodes[1, item]]
        T.A[1, 1] = T.Coords[1, T.Nodes[2, item]] - T.b[1]
        T.A[1, 2] = T.Coords[1, T.Nodes[4, item]] - T.b[1]
        T.A[2, 1] = T.Coords[2, T.Nodes[2, item]] - T.b[2]
        T.A[2, 2] = T.Coords[2, T.Nodes[4, item]] - T.b[2]
        T.A[3, 1] = T.Coords[3, T.Nodes[2, item]] - T.b[3]
        T.A[3, 2] = T.Coords[3, T.Nodes[4, item]] - T.b[3]
        T.det = T.ItemVolumes[item]
    end
    return nothing
end


function update_trafo!(T::L2GTransformer{<:Real, <:Integer, <:Tetrahedron3D, Cartesian3D}, item::Int)
    if T.citem != item
        T.citem = item
        T.b[1] = T.Coords[1, T.Nodes[1, item]]
        T.b[2] = T.Coords[2, T.Nodes[1, item]]
        T.b[3] = T.Coords[3, T.Nodes[1, item]]
        T.A[1, 1] = T.Coords[1, T.Nodes[2, item]] - T.b[1]
        T.A[1, 2] = T.Coords[1, T.Nodes[3, item]] - T.b[1]
        T.A[1, 3] = T.Coords[1, T.Nodes[4, item]] - T.b[1]
        T.A[2, 1] = T.Coords[2, T.Nodes[2, item]] - T.b[2]
        T.A[2, 2] = T.Coords[2, T.Nodes[3, item]] - T.b[2]
        T.A[2, 3] = T.Coords[2, T.Nodes[4, item]] - T.b[2]
        T.A[3, 1] = T.Coords[3, T.Nodes[2, item]] - T.b[3]
        T.A[3, 2] = T.Coords[3, T.Nodes[3, item]] - T.b[3]
        T.A[3, 3] = T.Coords[3, T.Nodes[4, item]] - T.b[3]
        T.det = 6 * T.ItemVolumes[item]
    end
    return nothing
end

function update_trafo!(T::L2GTransformer{<:Real, <:Integer, <:Parallelepiped3D, Cartesian3D}, item::Int)
    if T.citem != item
        T.citem = item
        T.b[1] = T.Coords[1, T.Nodes[1, item]]
        T.b[2] = T.Coords[2, T.Nodes[1, item]]
        T.b[3] = T.Coords[3, T.Nodes[1, item]]
        T.A[1, 1] = T.Coords[1, T.Nodes[2, item]] - T.b[1]
        T.A[1, 2] = T.Coords[1, T.Nodes[4, item]] - T.b[1]
        T.A[1, 3] = T.Coords[1, T.Nodes[5, item]] - T.b[1]
        T.A[2, 1] = T.Coords[2, T.Nodes[2, item]] - T.b[2]
        T.A[2, 2] = T.Coords[2, T.Nodes[4, item]] - T.b[2]
        T.A[2, 3] = T.Coords[2, T.Nodes[5, item]] - T.b[2]
        T.A[3, 1] = T.Coords[3, T.Nodes[2, item]] - T.b[3]
        T.A[3, 2] = T.Coords[3, T.Nodes[4, item]] - T.b[3]
        T.A[3, 3] = T.Coords[3, T.Nodes[5, item]] - T.b[3]
        T.det = T.ItemVolumes[item]
    end
    return nothing
end

function eval_trafo!(x::AbstractArray, T::L2GTransformer{<:Real, <:Integer, <:Vertex0D, Cartesian1D}, xref)
    x[1] = T.b[1]
    return nothing
end

function eval_trafo!(x::AbstractArray, T::L2GTransformer{<:Real, <:Integer, <:Union{Triangle2D, Parallelogram2D}, Cartesian2D}, xref)
    x[1] = T.A[1, 1] * xref[1] + T.A[1, 2] * xref[2] + T.b[1]
    x[2] = T.A[2, 1] * xref[1] + T.A[2, 2] * xref[2] + T.b[2]
    return nothing
end


function eval_trafo!(x::AbstractArray, T::L2GTransformer{<:Real, <:Integer, <:Union{Triangle2D, Parallelogram2D}, Cartesian3D}, xref)
    x[1] = T.A[1, 1] * xref[1] + T.A[1, 2] * xref[2] + T.b[1]
    x[2] = T.A[2, 1] * xref[1] + T.A[2, 2] * xref[2] + T.b[2]
    x[3] = T.A[3, 1] * xref[1] + T.A[3, 2] * xref[2] + T.b[3]
    return nothing
end


function eval_trafo!(x::AbstractArray, T::L2GTransformer{<:Real, <:Integer, <:Union{Tetrahedron3D, Parallelepiped3D}, Cartesian3D}, xref)
    x[1] = T.A[1, 1] * xref[1] + T.A[1, 2] * xref[2] + T.A[1, 3] * xref[3] + T.b[1]
    x[2] = T.A[2, 1] * xref[1] + T.A[2, 2] * xref[2] + T.A[2, 3] * xref[3] + T.b[2]
    x[3] = T.A[3, 1] * xref[1] + T.A[3, 2] * xref[2] + T.A[3, 3] * xref[3] + T.b[3]
    return nothing
end


function eval_trafo!(x::AbstractArray, T::L2GTransformer{<:Real, <:Integer, <:Edge1D, Cartesian1D}, xref)
    x[1] = T.A[1, 1] * xref[1] + T.b[1]
    return nothing
end

function eval_trafo!(x::AbstractArray, T::L2GTransformer{<:Real, <:Integer, <:Edge1D, Cartesian2D}, xref)
    x[1] = T.A[1, 1] * xref[1] + T.b[1]
    x[2] = T.A[2, 1] * xref[1] + T.b[2]
    return nothing
end

function eval_trafo!(x::AbstractArray, T::L2GTransformer{<:Real, <:Integer, <:Edge1D, Cartesian3D}, xref)
    x[1] = T.A[1, 1] * xref[1] + T.b[1]
    x[2] = T.A[2, 1] * xref[1] + T.b[2]
    x[3] = T.A[3, 1] * xref[1] + T.b[3]
    return nothing
end

# EDGE1D/CARTESIAN1D map derivative
# x = a*xref + b
# Dxref/dx = a^{-1} = |E|^{-1}
function mapderiv!(M::Matrix, T::L2GTransformer{<:Real, <:Integer, <:Edge1D, Cartesian1D}, xref)
    # transposed inverse of A
    M[1, 1] = 1.0 / T.det
    return nothing
end

# EDGE1D/CARTESIAN2D (tangential) map derivative
# x = A*xref + b
# Dxref/dx = A*tangent^{-1} = |E|^{-1}
function mapderiv!(M::Matrix, T::L2GTransformer{<:Real, <:Integer, <:Edge1D, Cartesian2D}, xref)
    # transposed inverse of A
    M[1, 1] = 1.0 / T.det
    return nothing
end
# TRIANGLE2D/CARTESIAN2D map derivative
# x = A*xref + b
# Dxref/dx = A^{-T}
function mapderiv!(M::AbstractMatrix, T::L2GTransformer{<:Real, <:Integer, <:Triangle2D, Cartesian2D}, xref)
    # transposed inverse of A
    M[2, 2] = T.A[1, 1] / T.det
    M[2, 1] = -T.A[1, 2] / T.det
    M[1, 2] = -T.A[2, 1] / T.det
    M[1, 1] = T.A[2, 2] / T.det
    return nothing
end
# similar for parallelogram
function mapderiv!(M::Matrix, T::L2GTransformer{<:Real, <:Integer, <:Parallelogram2D, Cartesian2D}, xref)
    # transposed inverse of A
    M[2, 2] = T.A[1, 1] / T.det
    M[2, 1] = -T.A[1, 2] / T.det
    M[1, 2] = -T.A[2, 1] / T.det
    M[1, 1] = T.A[2, 2] / T.det
    return nothing
end

function mapderiv!(M::Matrix, T::L2GTransformer{<:Real, <:Integer, <:Tetrahedron3D, Cartesian3D}, xref)
    # adjugate matrix = T.determinant of subblocks (for faster map_deriv!)
    T.C[1, 1] = T.A[2, 2] * T.A[3, 3] - T.A[2, 3] * T.A[3, 2]
    T.C[1, 2] = -(T.A[2, 1] * T.A[3, 3] - T.A[2, 3] * T.A[3, 1])
    T.C[1, 3] = T.A[2, 1] * T.A[3, 2] - T.A[2, 2] * T.A[3, 1]
    T.C[2, 1] = -(T.A[1, 2] * T.A[3, 3] - T.A[1, 3] * T.A[3, 2])
    T.C[2, 2] = T.A[1, 1] * T.A[3, 3] - T.A[1, 3] * T.A[3, 1]
    T.C[2, 3] = -(T.A[1, 1] * T.A[3, 2] - T.A[1, 2] * T.A[3, 1])
    T.C[3, 1] = T.A[1, 2] * T.A[2, 3] - T.A[1, 3] * T.A[2, 2]
    T.C[3, 2] = -(T.A[1, 1] * T.A[2, 3] - T.A[1, 3] * T.A[2, 1])
    T.C[3, 3] = T.A[1, 1] * T.A[2, 2] - T.A[1, 2] * T.A[2, 1]

    # transposed inverse of A
    for j in 1:3, k in 1:3
        M[j, k] = T.C[j, k] / T.det
    end
    return nothing
end

function mapderiv!(M::Matrix, T::L2GTransformer{<:Real, <:Integer, <:Parallelepiped3D, Cartesian3D}, xref)

    # adjugate matrix = T.determinant of subblocks (for faster map_deriv!)
    T.C[1, 1] = T.A[2, 2] * T.A[3, 3] - T.A[2, 3] * T.A[3, 2]
    T.C[1, 2] = -(T.A[2, 1] * T.A[3, 3] - T.A[2, 3] * T.A[3, 1])
    T.C[1, 3] = T.A[2, 1] * T.A[3, 2] - T.A[2, 2] * T.A[3, 1]
    T.C[2, 1] = -(T.A[1, 2] * T.A[3, 3] - T.A[1, 3] * T.A[3, 2])
    T.C[2, 2] = T.A[1, 1] * T.A[3, 3] - T.A[1, 3] * T.A[3, 1]
    T.C[2, 3] = -(T.A[1, 1] * T.A[3, 2] - T.A[1, 2] * T.A[3, 1])
    T.C[3, 1] = T.A[1, 2] * T.A[2, 3] - T.A[1, 3] * T.A[2, 2]
    T.C[3, 2] = -(T.A[1, 1] * T.A[2, 3] - T.A[1, 3] * T.A[2, 1])
    T.C[3, 3] = T.A[1, 1] * T.A[2, 2] - T.A[1, 2] * T.A[2, 1]

    # transposed inverse of A
    for j in 1:3, k in 1:3
        M[j, k] = T.C[j, k] / T.det
    end
    return nothing
end
