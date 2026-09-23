"""
    $(TYPEDEF)

CellFinder supports finding cells in grids.
"""
struct CellFinder{Tv, Ti}
    xgrid::ExtendableGrid{Tv, Ti}
    xCellFaces::Adjacency{Ti}
    xFaceCells::Adjacency{Ti}
    xCellGeometries::GridEGTypes
    facetogo::Array{Array{Ti, 1}, 1}
    previous_cells::Array{Ti, 1}
    EG::Array{Type{<:AbstractElementGeometry}, 1}
    L2G4EG::Vector{L2GTransformer{Tv, Ti, EG, CS} where {EG <: AbstractElementGeometry, CS <: AbstractCoordinateSystem}} # each Geometry has its own L2GTransformer
    invA::Matrix{Tv}
    xreftest::Array{Tv, 1}
    cx::Vector{Tv}
end

## postprocessing function that calculate conditions to decide over which face to go next
function postprocess_xreftest!(xreftest::AbstractArray{Tv}, ::Type{<:Edge1D}) where {Tv}
    xreftest[2] = 1 - xreftest[1]
    return nothing
end
function postprocess_xreftest!(xreftest::AbstractArray{Tv}, ::Type{<:Triangle2D}) where {Tv}
    xreftest[3] = 1 - xreftest[1] - xreftest[2]
    return nothing
end
function postprocess_xreftest!(xreftest::AbstractArray{Tv}, ::Type{<:Tetrahedron3D}) where {Tv}
    xreftest[4] = 1 - xreftest[1] - xreftest[2] - xreftest[3]
    return nothing
end
function postprocess_xreftest!(xreftest::AbstractArray{Tv}, ::Type{<:Parallelogram2D}) where {Tv}
    xreftest[3] = 1 - xreftest[1]
    xreftest[4] = 1 - xreftest[2]
    return nothing
end

function postprocess_xreftest!(xreftest::AbstractArray{Tv}, ::Type{<:Parallelepiped3D}) where {Tv}
    xreftest[4] = 1 - xreftest[1]
    xreftest[5] = 1 - xreftest[2]
    xreftest[6] = 1 - xreftest[3]
    return nothing
end

## shape function values (in local node order) of a point with local coordinates `xref`
## (as returned by [`gFindLocal!`](@ref)) for the cell geometries supported by CellFinder:
## - simplices: `xref[k]` (k=1..dim) is the barycentric weight of node k+1,
##   `xref[dim+1]` the barycentric weight of node 1
## - Parallelogram2D: `xref = (ξ, η, 1-ξ)` with ξ along the reference edge (1,2), η along (1,4)
## - Parallelepiped3D: `xref = (ξ, η, ζ, 1-ξ)` with ξ,η,ζ along the reference edges (1,2),(1,4),(1,5)
function shapevalues!(w, xref, ::Type{<:Edge1D})
    w[1] = xref[2]
    w[2] = xref[1]
    return nothing
end
function shapevalues!(w, xref, ::Type{<:Triangle2D})
    w[1] = xref[3]
    w[2] = xref[1]
    w[3] = xref[2]
    return nothing
end
function shapevalues!(w, xref, ::Type{<:Tetrahedron3D})
    w[1] = xref[4]
    w[2] = xref[1]
    w[3] = xref[2]
    w[4] = xref[3]
    return nothing
end
function shapevalues!(w, xref, ::Type{<:Parallelogram2D})
    xi = xref[1]
    eta = xref[2]
    w[1] = (1 - xi) * (1 - eta)
    w[2] = xi * (1 - eta)
    w[3] = xi * eta
    w[4] = (1 - xi) * eta
    return nothing
end
function shapevalues!(w, xref, ::Type{<:Parallelepiped3D})
    xi = xref[1]
    eta = xref[2]
    zeta = xref[3]
    w[1] = (1 - xi) * (1 - eta) * (1 - zeta)
    w[2] = xi * (1 - eta) * (1 - zeta)
    w[3] = xi * eta * (1 - zeta)
    w[4] = (1 - xi) * eta * (1 - zeta)
    w[5] = (1 - xi) * (1 - eta) * zeta
    w[6] = xi * (1 - eta) * zeta
    w[7] = xi * eta * zeta
    w[8] = (1 - xi) * eta * zeta
    return nothing
end

"""
    CellFinder(grid)

Create a cell finder on grid.
"""
function CellFinder(xgrid::ExtendableGrid{Tv, Ti}) where {Tv, Ti}
    CS = xgrid[CoordinateSystem]
    EG = xgrid[UniqueCellGeometries]
    L2G4EG = Vector{L2GTransformer{Tv, Ti, EG, CS} where {EG <: AbstractElementGeometry, CS <: AbstractCoordinateSystem}}(undef, length(EG))
    facetogo = Array{Array{Ti, 1}, 1}(undef, length(EG))
    xreftestlength::Int = 0
    for j in 1:length(EG)
        L2G4EG[j] = L2GTransformer(EG[j], xgrid, ON_CELLS)
        if EG[j] <: AbstractElementGeometry1D
            facetogo[j] = [1, 2]
            xreftestlength = max(xreftestlength, 2)
        elseif EG[j] <: Triangle2D
            facetogo[j] = [3, 1, 2]
            xreftestlength = max(xreftestlength, 3)
        elseif EG[j] <: Tetrahedron3D
            facetogo[j] = [4, 2, 1, 3]
            xreftestlength = max(xreftestlength, 4)
        elseif EG[j] <: Parallelogram2D
            facetogo[j] = [4, 1, 2, 3]
            xreftestlength = max(xreftestlength, 4)
        elseif EG[j] <: Parallelepiped3D
            facetogo[j] = [5, 2, 1, 3, 4, 6]
            xreftestlength = max(xreftestlength, 6)
        else
            @error "ElementGeometry not supported by CellFinder"
        end
    end

    edim = dim_element(EG[1])
    A = zeros(Tv, edim, edim)
    xreftest = zeros(Tv, xreftestlength)
    return CellFinder{Tv, Ti}(xgrid, xgrid[CellFaces], xgrid[FaceCells], xgrid[CellGeometries], facetogo, zeros(Ti, 3), EG, L2G4EG, A, xreftest, zeros(Tv, edim))
end


"""
    icellfound=GFindLocal!(xref,cellfinder,p; icellstart=1,eps=1.0e-14, trybrute=true)

Find cell containing point `p`  starting with cell number `icellstart`.

Returns cell number if found, zero otherwise. If `trybrute==true` try [`gFindBruteForce!`](@ref) before giving up.
Upon return, `xref` contains the local (barycentric) coordinates of the point:
`xref[1]:xref[dim]` are the coordinates along the reference edges from node 1 to
nodes 2..dim+1 (i.e., the barycentric weights of nodes 2..dim+1) and `xref[dim+1]`
is the barycentric weight of node 1. On Parallelogram2D cells `xref = (ξ, η, 1-ξ)`
and on Parallelepiped3D cells `xref = (ξ, η, ζ, 1-ξ)`, where (ξ,η[,ζ]) are the
coordinates in the reference cell.

!!! note
    Supported cell geometries: Edge1D, Triangle2D, Tetrahedron3D, Parallelogram2D,
    and Parallelepiped3D (also in mixed grids).
"""
function gFindLocal!(
        xref,
        CF::CellFinder{Tv, Ti},
        x;
        icellstart = Ti(1),
        stay_in_cell = false,
        trybrute = true,
        eps = 1.0e-14
    )::Ti where {Tv, Ti}
    # works for convex domains and simplices only !
    xCellFaces::Adjacency{Ti} = CF.xCellFaces
    xFaceCells::Adjacency{Ti} = CF.xFaceCells
    xCellGeometries::GridEGTypes = CF.xCellGeometries
    EG = CF.EG
    cx::Vector{Tv} = CF.cx
    cEG::Int = 0
    facetogo::Array{Array{Ti, 1}, 1} = CF.facetogo
    icell::Ti = icellstart
    previous_cells::Array{Ti, 1} = CF.previous_cells
    fill!(previous_cells, 0)
    xreftest::Array{Tv, 1} = CF.xreftest
    L2G::L2GTransformer{Tv, Ti} = CF.L2G4EG[1]
    L2Gb::Vector{Tv} = L2G.b

    invA::Matrix{Tv} = CF.invA
    imin::Int = 0

    while (true)
        # find current cell geometry index
        cEG = 1
        while xCellGeometries[icell] != EG[cEG]
            cEG += 1
        end

        # update local 2 global map
        L2G = CF.L2G4EG[cEG]
        update_trafo!(L2G, icell) # 1 allocation
        L2Gb = L2G.b

        # compute barycentric coordinates of node
        for j in 1:length(cx)
            cx[j] = x[j] - L2Gb[j]
        end
        mapderiv!(invA, L2G, xref)

        if stay_in_cell
            return icell
        end

        fill!(xreftest, 0)
        for j in 1:length(cx), k in 1:length(cx)
            xreftest[k] += invA[j, k] * cx[j]
        end
        postprocess_xreftest!(xreftest, xCellGeometries[icell])

        # find minimal barycentric coordinate with
        imin = 1
        for i in 2:length(facetogo[cEG])
            if xreftest[imin] >= xreftest[i]
                imin = i
            end
        end

        # if all barycentric coordinates are within [0,1] the including cell is found
        if xreftest[imin] >= -eps
            xref .= view(xreftest, 1:length(xref))
            return icell
        end

        # otherwise: go into direction of minimal barycentric coordinates
        for j in 1:(length(previous_cells) - 1)
            previous_cells[j] = previous_cells[j + 1]
        end
        previous_cells[end] = icell
        icell = xFaceCells[1, xCellFaces[facetogo[cEG][imin], icell]]
        if icell == previous_cells[end]
            icell = xFaceCells[2, xCellFaces[facetogo[cEG][imin], icell]]
            if icell == 0
                !trybrute
                if trybrute
                    return gFindBruteForce!(xref, CF, x; eps)
                else
                    @debug  "could not find point in any cell and ended up at boundary of domain (maybe x lies outside of the domain ?)"
                    return 0
                end
            end
        end

        if icell == previous_cells[end - 1] && !trybrute
            if trybrute
                return gFindBruteForce!(xref, CF, x; eps)
            else
                @debug  "could not find point in any cell and ended up at boundary of domain (maybe x lies outside of the domain ?)"
                return 0
            end
        end
    end

    return 0
end

"""
    icellfound=gFindBruteForce!(xref,cellfinder,p; icellstart=1,eps=1.0e-14)

Find cell containing point `p`  starting with cell number `icellstart`.

Returns cell number if found, zero otherwise.
Upon return, `xref` contains the local (barycentric) coordinates of the point:
`xref[1]:xref[dim]` are the coordinates along the reference edges from node 1 to
nodes 2..dim+1 (i.e., the barycentric weights of nodes 2..dim+1) and `xref[dim+1]`
is the barycentric weight of node 1. On Parallelogram2D cells `xref = (ξ, η, 1-ξ)`
and on Parallelepiped3D cells `xref = (ξ, η, ζ, 1-ξ)`, where (ξ,η[,ζ]) are the
coordinates in the reference cell.

!!! note
    Supported cell geometries: Edge1D, Triangle2D, Tetrahedron3D, Parallelogram2D,
    and Parallelepiped3D (also in mixed grids).

"""
function gFindBruteForce!(xref, CF::CellFinder{Tv, Ti}, x; eps = 1.0e-14)::Ti where {Tv, Ti}

    cx::Vector{Tv} = CF.cx
    cEG::Int = 0
    EG::GridEGTypes = CF.EG
    xreftest::Array{Tv, 1} = CF.xreftest
    xCellGeometries::GridEGTypes = CF.xCellGeometries
    facetogo::Array{Array{Ti, 1}, 1} = CF.facetogo
    L2Gb::Vector{Tv} = CF.L2G4EG[1].b
    invA::Matrix{Tv} = CF.invA
    imin::Int = 0

    for icell::Ti in 1:num_sources(CF.xgrid[CellNodes])

        # find current cell geometry index
        cEG = 1
        while xCellGeometries[icell] != EG[cEG]
            cEG += 1
        end

        # update local 2 global map
        L2G = CF.L2G4EG[cEG]
        update_trafo!(L2G, icell)
        L2Gb = L2G.b

        # compute barycentric coordinates of node
        for j in 1:length(x)
            cx[j] = x[j] - L2Gb[j]
        end
        mapderiv!(invA, L2G, xref)
        fill!(xreftest, 0)
        for j in 1:length(x), k in 1:length(x)
            xreftest[k] += invA[j, k] * cx[j]
        end
        postprocess_xreftest!(xreftest, xCellGeometries[icell])

        # find minimal barycentric coordinate with
        imin = 1
        for i in 2:length(facetogo[cEG])
            if xreftest[imin] >= xreftest[i]
                imin = i
            end
        end

        # if all barycentric coordinates are within [0,1] the including cell is found
        if xreftest[imin] >= -eps
            xref .= view(xreftest, 1:length(xref))
            return icell
        end
    end

    @debug "gFindBruteForce did not find any cell that contains x = $x (make sure that x is inside the domain, or try reducing $eps)"

    return 0
end

"""
    interpolate!(u_to,grid_to, u_from, grid_from;eps=1.0e-14,trybrute=true)

Mutating form of [`interpolate`](@ref)
"""
function interpolate!(u_to::AbstractArray, grid_to, u_from::AbstractArray, grid_from; eps = 1.0e-14, not_in_domain_value = nothing, check_if_not_in_domain = isnothing(not_in_domain_value), trybrute = true)
    update!(u_to::AbstractVector, inode_to, λ, u_from::AbstractVector, inode_from) = u_to[inode_to] += λ * u_from[inode_from]
    update!(u_to::AbstractMatrix, inode_to, λ, u_from::AbstractMatrix, inode_from) = @views u_to[:, inode_to] += λ * u_from[:, inode_from]

    coord = grid_to[Coordinates]
    dim = size(coord, 1)
    nnodes_to = size(coord, 2)
    nnodes_from = num_nodes(grid_from)
    if ndims(u_from) == 1
        @assert length(u_to) == nnodes_to
        @assert length(u_from) == nnodes_from
    elseif ndims(u_from) == 2
        @assert size(u_to, 2) == nnodes_to
        @assert size(u_from, 2) == nnodes_from
        @assert size(u_to, 1) == size(u_from, 1)
    else
        @assert ndims(u_from) < 3
    end

    xref = zeros(dim + 1)
    w = zeros(2^dim)                             # shape function values of the point (max. number of vertices of a cell)
    cn_from = grid_from[CellNodes]
    cellgeoms = grid_from[CellGeometries]
    cf = CellFinder(grid_from)
    icellstart = 1
    for inode_to in 1:nnodes_to
        @views icell_from = gFindLocal!(xref, cf, coord[:, inode_to]; icellstart, eps, trybrute)
        if icell_from <= 0 && !check_if_not_in_domain
            u_to[inode_to] = not_in_domain_value
        else
            @assert icell_from > 0 "could not find cell for node $inode_to with coordinate $(coord[:, inode_to])"
            ## evaluate the shape functions of the found cell at the point
            shapevalues!(w, xref, cellgeoms[icell_from])
            for i in 1:num_nodes(cellgeoms[icell_from])
                inode_from = cn_from[i, icell_from]
                update!(u_to, inode_to, w[i], u_from, inode_from)
            end
        end
        icellstart = max(icell_from, 1)
    end
    return u_to
end


"""
	u_to=interpolate(grid_to, u_from, grid_from;eps=1.0e-14,trybrute=true)

Piecewise polynomial interpolation of function `u_from` on grid `grid_from` to `grid_to`;
the value at each node of `grid_to` is reconstructed with the shape functions of the cell
of `grid_from` the node lies in (linear on simplices, bilinear on Parallelogram2D cells,
trilinear on Parallelepiped3D cells).
Works for matrices with second dimension corresponding to grid nodes and for vectors.
!!! warning
    May be slow on non-convex domains. If `trybrute==false` it may even fail.

!!! note
    Supported cell geometries: Edge1D, Triangle2D, Tetrahedron3D, Parallelogram2D,
    and Parallelepiped3D (also in mixed grids).
"""
function interpolate(grid_to, u_from::AbstractVector, grid_from; eps = 1.0e-14, trybrute = true)
    u_to = zeros(eltype(u_from), num_nodes(grid_to))
    return interpolate!(u_to, grid_to, u_from, grid_from; eps, trybrute)
end

function interpolate(grid_to, u_from::AbstractMatrix, grid_from; eps = 1.0e-14, trybrute = true)
    u_to = zeros(eltype(u_from), size(u_from, 1), num_nodes(grid_to))
    return interpolate!(u_to, grid_to, u_from, grid_from; eps, trybrute)
end
