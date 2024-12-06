"""
````
function simplexgrid(coord::Array{Tc,2},
                     cellnodes::Array{Ti,2},
                     cellregions=ones(Ti, size(coord,2)),
                     bfacenodes=zeros(Ti,size(coord,1),0),
                     bfaceregions=zeros(Ti,length(bfacenodes))
                     ) where {Tc,Ti}
````

Create  d-dimensional simplex grid from five arrays.

-        coord: d ``\\times`` n_points matrix of coordinates
-    cellnodes: d+1 ``\\times`` n_tri matrix of triangle - point incidence
-  cellregions: (optional) n_tri vector of cell region markers 
-   bfacenodes: (optional) d ``\\times`` n_bf matrix of boundary facet - point incidences
- bfaceregions: (optional) n_bf vector of boundary facet  region markers

Coordinate type `Tc` index type `Ti` are detected from the first two parameters.
`cellregions`, `bfaceregions`, `bfacenodes` are converted to have the same element type as `cellnodes`.
"""
function simplexgrid(
        coord::AbstractArray{Tc, 2},
        cellnodes::AbstractArray{Ti, 2},
        cellregions = ones(Ti, size(cellnodes, 2)),
        bfacenodes = zeros(Ti, size(coord, 1), 0),
        bfaceregions = zeros(Ti, length(bfacenodes))
    ) where {Tc, Ti}
    @assert size(coord, 2) > 0
    dim = size(coord, 1)
    if dim == 1
        eltype = Edge1D
        btype = Vertex0D
        csys = Cartesian1D
    elseif dim == 2
        eltype = Triangle2D
        btype = Edge1D
        csys = Cartesian2D
    elseif dim == 3
        eltype = Tetrahedron3D
        btype = Triangle2D
        csys = Cartesian3D
    end

    grid = ExtendableGrid{Tc, Ti}()
    grid[Coordinates] = convert(Matrix{Tc}, coord)
    grid[CellNodes] = convert(Matrix{Ti}, cellnodes)
    grid[CellRegions] = convert(Vector{Ti}, cellregions)
    grid[CellGeometries] = VectorOfConstants{ElementGeometries, Int}(eltype, length(cellregions))
    grid[BFaceNodes] = convert(Matrix{Ti}, bfacenodes)
    grid[BFaceRegions] = convert(Vector{Ti}, bfaceregions)
    grid[BFaceGeometries] = VectorOfConstants{ElementGeometries, Int}(btype, length(bfaceregions))
    grid[CoordinateSystem] = csys
    return grid
end


"""
````
function simplexgrid(coord::Array{Tc,2},
                     cellnodes::Array{Ti,2},
                     cellregions,
                     bfacenodes,
                     bfaceregions,
                     bedgenodes,
                     bedgeregions
                     ) where {Tc,Ti}
````

Create simplex grid from coordinates, cell-nodes-adjancency, cell-region-numbers,
boundary-face-nodes adjacency, boundary-face-region-numbers, boundary-edge-nodes, and
boundary-edge-region-numbers arrays.

The index type `Ti` is detected from `cellnodes`, all other arrays besides `coord`
are converted to this index type.
"""
function simplexgrid(
        coord::Array{Tc, 2},
        cellnodes::Array{Ti, 2},
        cellregions,
        bfacenodes,
        bfaceregions,
        bedgenodes,
        bedgeregions
    ) where {Tc, Ti}
    grid = simplexgrid(coord, cellnodes, cellregions, bfacenodes, bfaceregions)
    grid[BEdgeNodes] = convert(Matrix{Ti}, bedgenodes)
    grid[BEdgeRegions] = convert(Vector{Ti}, bedgeregions)
    return grid
end


##########################################################
abstract type XCoordinates <: AbstractGridFloatArray1D end
abstract type YCoordinates <: AbstractGridFloatArray1D end
abstract type ZCoordinates <: AbstractGridFloatArray1D end


"""
    simplexgrid(X; bregions=[1,2],cellregion=1)

Constructor for 1D grid.

Construct 1D grid from an array of node coordinates.
It creates two boundary regions with index 1 at the left end and
index 2 at the right end by default.

The keyword arguments allow to overwrite the default region numbers.

Primal grid holding unknowns: marked by `o`, dual
grid marking control volumes: marked by `|`.

```@raw html
 o-----o-----o-----o-----o-----o-----o-----o-----o
 |--|-----|-----|-----|-----|-----|-----|-----|--|
```
"""
function simplexgrid(_X::AbstractVector; bregions = [1, 2], cellregion = 1)
    X = convert(Vector, _X)
    #    is_monotone(X) || error("X not monotone")
    coord = reshape(X, 1, length(X))
    cellnodes = zeros(Cint, 2, length(X) - 1)
    cellregions = zeros(Cint, length(X) - 1)
    for i in 1:(length(X) - 1)
        cellnodes[1, i] = i
        cellnodes[2, i] = i + 1
        cellregions[i] = 1
    end
    bfacenodes = Array{Cint}(undef, 1, 2)
    bfaceregions = zeros(Cint, 2)
    bfacenodes[1, 1] = 1
    bfacenodes[1, 2] = length(X)
    bfaceregions[1] = bregions[1]
    bfaceregions[2] = bregions[2]
    grid = simplexgrid(
        coord,
        cellnodes,
        cellregions,
        bfacenodes,
        bfaceregions
    )
    grid[XCoordinates] = X
    return grid
end


##########################################################
"""
    simplexgrid(X,Y; bregions=[1,2,3,4],cellregion=1)


Constructor for 2D grid
from coordinate arrays. 



Boundary region numbers count counterclockwise:

| location  |  number |
| --------- | ------- |
| south     |       1 |
| east      |       2 |
| north     |       3 |
| west      |       4 |

The keyword arguments allow to overwrite the default region numbers.


"""
function simplexgrid(_X::AbstractVector, _Y::AbstractVector; bregions = [1, 2, 3, 4], cellregion = 1)
    is_monotone(_X) || error("X not monotone")
    is_monotone(_Y) || error("Y not monotone")

    Tc = promote_type(eltype(_X), eltype(_Y))

    X = convert(Vector{Tc}, _X)
    Y = convert(Vector{Tc}, _Y)


    function leq(x, x1, x2)
        if (x > x1)
            return false
        end
        if (x > x2)
            return false
        end
        return true
    end

    function geq(x, x1, x2)
        if (x < x1)
            return false
        end
        if (x < x2)
            return false
        end
        return true
    end

    nx = length(X)
    ny = length(Y)

    hmin = X[2] - X[1]
    for i in 1:(nx - 1)
        h = X[i + 1] - X[i]
        if h < hmin
            hmin = h
        end
    end
    for i in 1:(ny - 1)
        h = Y[i + 1] - Y[i]
        if h < hmin
            hmin = h
        end
    end

    @assert(hmin > 0.0)
    eps = 1.0e-5 * hmin

    x1 = X[1] + eps
    xn = X[nx] - eps
    y1 = Y[1] + eps
    yn = Y[ny] - eps


    function check_insert_bface(ibface, coord, n1, n2)
        if (geq(x1, coord[1, n1], coord[1, n2]))
            ibface = ibface + 1
            bfacenodes[1, ibface] = n1
            bfacenodes[2, ibface] = n2
            bfaceregions[ibface] = bregions[4]
        elseif (leq(xn, coord[1, n1], coord[1, n2]))
            ibface = ibface + 1
            bfacenodes[1, ibface] = n1
            bfacenodes[2, ibface] = n2
            bfaceregions[ibface] = bregions[2]
        elseif (geq(y1, coord[2, n1], coord[2, n2]))
            ibface = ibface + 1
            bfacenodes[1, ibface] = n1
            bfacenodes[2, ibface] = n2
            bfaceregions[ibface] = bregions[1]
        elseif (leq(yn, coord[2, n1], coord[2, n2]))
            ibface = ibface + 1
            bfacenodes[1, ibface] = n1
            bfacenodes[2, ibface] = n2
            bfaceregions[ibface] = bregions[3]
        end
        return ibface
    end


    num_nodes = nx * ny
    num_cells = 2 * (nx - 1) * (ny - 1)
    num_bfacenodes = 2 * (nx - 1) + 2 * (ny - 1)

    coord = zeros(Tc, 2, num_nodes)
    cellnodes = zeros(Cint, 3, num_cells)
    cellregions = zeros(Cint, num_cells)
    bfacenodes = Array{Cint}(undef, 2, num_bfacenodes)
    bfaceregions = zeros(Cint, num_bfacenodes)

    ipoint = 0
    for iy in 1:ny
        for ix in 1:nx
            ipoint = ipoint + 1
            coord[1, ipoint] = X[ix]
            coord[2, ipoint] = Y[iy]
        end
    end
    @assert(ipoint == num_nodes)

    icell = 0
    for iy in 1:(ny - 1)
        for ix in 1:(nx - 1)
            ip = ix + (iy - 1) * nx
            p00 = ip
            p10 = ip + 1
            p01 = ip + nx
            p11 = ip + 1 + nx

            icell = icell + 1
            cellnodes[1, icell] = p00
            cellnodes[2, icell] = p10
            cellnodes[3, icell] = p11
            cellregions[icell] = cellregion


            icell = icell + 1
            cellnodes[1, icell] = p11
            cellnodes[2, icell] = p01
            cellnodes[3, icell] = p00
            cellregions[icell] = cellregion
        end
    end
    @assert(icell == num_cells)

    #lazy way to  create boundary grid

    ibface = 0
    for icell in 1:num_cells
        n1 = cellnodes[1, icell]
        n2 = cellnodes[2, icell]
        n3 = cellnodes[3, icell]
        ibface = check_insert_bface(ibface, coord, n1, n2)
        ibface = check_insert_bface(ibface, coord, n1, n3)
        ibface = check_insert_bface(ibface, coord, n2, n3)
    end
    @assert(ibface == num_bfacenodes)


    grid = simplexgrid(
        coord,
        cellnodes,
        cellregions,
        bfacenodes,
        bfaceregions
    )

    grid[XCoordinates] = X
    grid[YCoordinates] = Y
    return grid
end


##########################################################
"""
    simplexgrid(X,Y,Z; bregions=[1,2,3,4,5,6],cellregion=1)


Constructor for 3D grid
from coordinate arrays. 
Boundary region numbers:

| location  |  number |
| --------- | ------- |
| south     |       1 |
| east      |       2 |
| north     |       3 |
| west      |       4 |
| bottom    |       5 |
| top       |       6 |


The keyword arguments allow to overwrite the default region numbers.
"""
function simplexgrid(_X::AbstractVector, _Y::AbstractVector, _Z::AbstractVector; bregions = [1, 2, 3, 4, 5, 6], cellregion = 1)
    is_monotone(_X) || error("X not monotone")
    is_monotone(_Y) || error("Y not monotone")
    is_monotone(_Z) || error("Z not monotone")

    Tc = promote_type(eltype(_X), eltype(_Y), eltype(_Z))

    X = convert(Vector{Tc}, _X)
    Y = convert(Vector{Tc}, _Y)
    Z = convert(Vector{Tc}, _Z)


    leq(x, x1, x2, x3) = x ≤ x1 && x ≤ x2 && x ≤ x3
    geq(x, x1, x2, x3) = x ≥ x1 && x ≥ x2 && x ≥ x3

    nx = length(X)
    ny = length(Y)
    nz = length(Z)

    hmin = X[2] - X[1]
    for i in 1:(nx - 1)
        h = X[i + 1] - X[i]
        if h < hmin
            hmin = h
        end
    end
    for i in 1:(ny - 1)
        h = Y[i + 1] - Y[i]
        if h < hmin
            hmin = h
        end
    end

    for i in 1:(nz - 1)
        h = Z[i + 1] - Z[i]
        if h < hmin
            hmin = h
        end
    end

    @assert(hmin > 0.0)
    eps = 1.0e-5 * hmin

    x1 = X[1] + eps
    xn = X[end] - eps

    y1 = Y[1] + eps
    yn = Y[end] - eps

    z1 = Z[1] + eps
    zn = Z[end] - eps


    function check_insert_bface(ibface, coord, bfacenodes, n1, n2, n3)
        if geq(x1, coord[1, n1], coord[1, n2], coord[1, n3])
            ibface = ibface + 1
            bfacenodes[1, ibface] = n1
            bfacenodes[2, ibface] = n2
            bfacenodes[3, ibface] = n3
            bfaceregions[ibface] = bregions[4]
        elseif leq(xn, coord[1, n1], coord[1, n2], coord[1, n3])
            ibface = ibface + 1
            bfacenodes[1, ibface] = n1
            bfacenodes[2, ibface] = n2
            bfacenodes[3, ibface] = n3
            bfaceregions[ibface] = bregions[2]
        elseif geq(y1, coord[2, n1], coord[2, n2], coord[2, n3])
            ibface = ibface + 1
            bfacenodes[1, ibface] = n1
            bfacenodes[2, ibface] = n2
            bfacenodes[3, ibface] = n3
            bfaceregions[ibface] = bregions[1]
        elseif leq(yn, coord[2, n1], coord[2, n2], coord[2, n3])
            ibface = ibface + 1
            bfacenodes[1, ibface] = n1
            bfacenodes[2, ibface] = n2
            bfacenodes[3, ibface] = n3
            bfaceregions[ibface] = bregions[3]
        elseif geq(z1, coord[3, n1], coord[3, n2], coord[3, n3])
            ibface = ibface + 1
            bfacenodes[1, ibface] = n1
            bfacenodes[2, ibface] = n2
            bfacenodes[3, ibface] = n3
            bfaceregions[ibface] = bregions[5]
        elseif leq(zn, coord[3, n1], coord[3, n2], coord[3, n3])
            ibface = ibface + 1
            bfacenodes[1, ibface] = n1
            bfacenodes[2, ibface] = n2
            bfacenodes[3, ibface] = n3
            bfaceregions[ibface] = bregions[6]
        end
        return ibface
    end

    num_nodes = nx * ny * nz
    num_cells = 6 * (nx - 1) * (ny - 1) * (nz - 1)
    num_bfacenodes = 4 * (nx - 1) * (ny - 1) + 4 * (nx - 1) * (nz - 1) + 4 * (ny - 1) * (nz - 1)

    Ti = Cint
    coord = zeros(Tc, 3, num_nodes)
    cellnodes = zeros(Ti, 4, num_cells)
    cellregions = fill(cellregion, num_cells)
    bfacenodes = zeros(Ti, 3, num_bfacenodes)
    bfaceregions = zeros(Ti, num_bfacenodes)

    ipoint = 0
    for iz in 1:nz
        for iy in 1:ny
            for ix in 1:nx
                ipoint = ipoint + 1
                coord[1, ipoint] = X[ix]
                coord[2, ipoint] = Y[iy]
                coord[3, ipoint] = Z[iz]
            end
        end
    end

    @assert(ipoint == num_nodes)

    icell = 0
    nxy = nx * ny
    for iz in 1:(nz - 1)
        for iy in 1:(ny - 1)
            for ix in 1:(nx - 1)

                ip = ix + (iy - 1) * nx + (iz - 1) * nxy

                p000 = ip
                p100 = ip + 1
                p010 = ip + nx
                p110 = ip + 1 + nx
                p001 = ip + nxy
                p101 = ip + 1 + nxy
                p011 = ip + nx + nxy
                p111 = ip + 1 + nx + nxy

                icell = icell + 1;  @. cellnodes[:, icell] = (p000, p100, p110, p111)
                icell = icell + 1;    @. cellnodes[:, icell] = (p000, p101, p100, p111)
                icell = icell + 1;    @. cellnodes[:, icell] = (p000, p010, p011, p111)
                icell = icell + 1;    @. cellnodes[:, icell] = (p000, p110, p010, p111)
                icell = icell + 1;    @. cellnodes[:, icell] = (p000, p001, p101, p111)
                icell = icell + 1;    @. cellnodes[:, icell] = (p000, p011, p001, p111)
            end
        end
    end
    @assert(icell == num_cells)
    #lazy way to  create boundary grid
    # lazy but easy... bad for partitioning !!!

    ibface = 0
    for icell in 1:num_cells
        n1 = cellnodes[1, icell]
        n2 = cellnodes[2, icell]
        n3 = cellnodes[3, icell]
        n4 = cellnodes[4, icell]
        ibface = check_insert_bface(ibface, coord, bfacenodes, n1, n2, n3)
        ibface = check_insert_bface(ibface, coord, bfacenodes, n1, n2, n4)
        ibface = check_insert_bface(ibface, coord, bfacenodes, n1, n3, n4)
        ibface = check_insert_bface(ibface, coord, bfacenodes, n2, n3, n4)
    end
    @assert(ibface == num_bfacenodes)


    grid = simplexgrid(
        coord,
        cellnodes,
        cellregions,
        bfacenodes,
        bfaceregions
    )

    grid[XCoordinates] = X
    grid[YCoordinates] = Y
    grid[ZCoordinates] = Z
    return grid
end


"""
    simplexgrid(grid2d::ExtendableGrid, coordZ; bot_offset=0,cell_offset=0,top_offset=0, bface_offset=0)

Create tensor product of 2D  grid and 1D coordinate array.

Cellregions and outer facet regions are taken over from 2D grid
and added to `cell_offset` and `bface_offset`, respectively.
Top an bottom facet regions are detected from the cell regions and
added to `bot_offset` resp. `top_offset`.
"""
function simplexgrid(grid2::ExtendableGrid, coordZ; bot_offset = 0, cell_offset = 0, top_offset = 0)
    coord2 = grid2[Coordinates]
    nnodes2 = size(coord2, 2)
    nnodesZ = length(coordZ)
    nnodes3 = nnodes2 * nnodesZ
    coord3 = zeros(3, nnodes3)


    cells2 = grid2[CellNodes]
    ncells2 = size(cells2, 2)
    ncells3 = ncells2 * 3 * (nnodesZ - 1)

    Ti = eltype(cells2)


    cells3 = zeros(Ti, 4, ncells3)


    cellregions2 = grid2[CellRegions]
    cellregions3 = zeros(Ti, ncells3)

    bfaces2 = grid2[BFaceNodes]
    nbfaces2 = size(bfaces2, 2)
    nbfaces3 = 2 * ncells2 + 2 * nbfaces2 * (nnodesZ - 1)
    bfaces3 = zeros(Ti, 3, nbfaces3)

    bfaceregions2 = grid2[BFaceRegions]
    bfaceregions3 = zeros(Ti, nbfaces3)


    # 3D coordinates
    i3 = 1
    for iZ in 1:nnodesZ
        for i2 in 1:nnodes2
            coord3[1, i3] = coord2[1, i2]
            coord3[2, i3] = coord2[2, i2]
            coord3[3, i3] = coordZ[iZ]
            i3 += 1
        end
    end


    # 3D cells
    i3 = 1
    ishift = 0
    for iZ in 1:(nnodesZ - 1)
        for i2 in 1:ncells2
            n1 = cells2[1, i2] + ishift
            n2 = cells2[2, i2] + ishift
            n3 = cells2[3, i2] + ishift

            n1 > n2 ? (n1, n2) = (n2, n1) : nothing
            n2 > n3 ? (n2, n3) = (n3, n2) : nothing
            n1 > n2 ? (n1, n2) = (n2, n1) : nothing

            cells3[:, i3] .= (n1, n2, n3, n3 + nnodes2)
            cells3[:, i3 + 1] .= (n1, n2, n2 + nnodes2, n3 + nnodes2)
            cells3[:, i3 + 2] .= (n1, n1 + nnodes2, n2 + nnodes2, n3 + nnodes2)


            cellregions3[i3] = cellregions2[i2] + cell_offset
            cellregions3[i3 + 1] = cellregions2[i2] + cell_offset
            cellregions3[i3 + 2] = cellregions2[i2] + cell_offset

            i3 += 3
        end
        ishift += nnodes2
    end


    #xy parallel  facets
    i3 = 1
    for iZ in [1, nnodesZ]
        ishift = (iZ - 1) * nnodes2
        for i2 in 1:ncells2
            @views bfaces3[:, i3] .= cells2[:, i2] .+ ishift
            bfaceregions3[i3] = iZ == 1 ? cellregions2[i2] + bot_offset : cellregions2[i2] + top_offset
            i3 += 1
        end
    end

    # facets vertical to the x-y plane
    ishift = 0
    for iZ in 1:(nnodesZ - 1)
        for i2 in 1:nbfaces2
            n1 = bfaces2[1, i2] + ishift
            n2 = bfaces2[2, i2] + ishift
            n1 > n2 ? (n1, n2) = (n2, n1) : nothing
            @views bfaces3[:, i3] .= (n1, n2, n2 + nnodes2)
            @views bfaces3[:, i3 + 1] .= (n1, n1 + nnodes2, n2 + nnodes2)
            bfaceregions3[i3] = bfaceregions2[i2]
            bfaceregions3[i3 + 1] = bfaceregions2[i2]
            i3 += 2
        end
        ishift += nnodes2
    end

    xgrid = simplexgrid(coord3, cells3, cellregions3, bfaces3, bfaceregions3)

    ## quick and dirty fix of local orderings to avoid negative CellVolumes
    ## and problems with CellFinder
    cellvolumes = xgrid[CellVolumes]
    cellnodes = xgrid[CellNodes]
    for cell in 1:num_cells(xgrid)
        if cellvolumes[cell] < 0
            ishift = cellnodes[1, cell]
            cellnodes[1, cell] = cellnodes[2, cell]
            cellnodes[2, cell] = ishift
            cellvolumes[cell] *= -1
        end
    end
    return xgrid
end


"""
    glue(g1,g2;
         g1regions=1:num_bfaceregions(g1),
         g2regions=1:num_bfaceregions(g2),
         interface=0,
         warnonly = false,
         tol=1.0e-10,
         naive=false)

Merge two grids along their common boundary facets. 

- g1: First grid to be merged
- g2: Second grid to be merged
- g1regions: boundary regions to be used from grid1. Default: all.
- g2regions: boundary regions to be used from grid2. Default: all.
- interface: if nonzero, create interface region in new grid, otherwise, ignore
- strict: Assume all bfaces form specified regions shall be matched, throw error on failure
- tol:  Distance below which two points are seen as identical. Default: 1.0e-10
- naive: use naive quadratic complexity matching (for checking backward compatibility). Default: false

Deprecated:
- breg: old notation for interface
"""
function glue(
        g1::ExtendableGrid, g2::ExtendableGrid;
        g1regions = 1:num_bfaceregions(g1),
        g2regions = 1:num_bfaceregions(g2),
        breg = nothing,
        interface = 0,
        tol = 1.0e-10,
        strict = false,
        naive = false
    )
    Ti = eltype(g1[CellNodes])
    dim = dim_space(g1)

    if breg != nothing
        interface = breg
        @warn "glue: set interface=$(interface) from deprecated breg kwarg"
    end

    bfreg1 = g1[BFaceRegions]
    bfreg2 = g2[BFaceRegions]
    bfn1 = g1[BFaceNodes]
    bfn2 = g2[BFaceNodes]

    nbf1 = size(bfn1, 2)
    nbf2 = size(bfn2, 2)

    coord1 = g1[Coordinates]
    coord2 = g2[Coordinates]

    nn1 = size(coord1, 2)
    nn2 = size(coord2, 2)

    # numbers of faces in grid1 which match nodes in grid2
    matching_faces = zeros(Ti, nbf2)
    n_matching_faces = 0


    # numbers of nodes in grid1 which match nodes in grid2
    matching_nodes = zeros(Ti, nn2)
    n_matching_nodes = 0


    # Add matching pair to index of matching pairs
    function add_match!(match_list, nmatch, i1, i2)
        @assert match_list[i2] == 0 || match_list[i2] == i1
        if match_list[i2] == 0
            match_list[i2] = i1
            nmatch += 1
        end
        return nmatch
    end

    # Add two point indices to list of matching points
    add_matching_points(ip1, ip2) = n_matching_nodes = add_match!(matching_nodes, n_matching_nodes, ip1, ip2)

    # Add two face indices to list of matching faces
    add_matching_faces(if1, if2) = n_matching_faces = add_match!(matching_faces, n_matching_faces, if1, if2)

    ## Check if two points match (distance < tol)
    function points_match(ip1, ip2)
        nm = 0.0
        for i in 1:dim
            nm += (coord1[i, ip1] - coord2[i, ip2])^2
        end
        return nm < tol^2
    end

    # Check if points in faces match, if so, add them to point matching index
    # Check if faces match, if so, add them to face matching index
    function match_faces(if1, if2)
        nmatch = 0
        for ip1 in 1:dim
            for ip2 in 1:dim
                xip1 = bfn1[ip1, if1]
                xip2 = bfn2[ip2, if2]
                if points_match(xip1, xip2)
                    add_matching_points(xip1, xip2)
                    nmatch += 1
                end
            end
        end

        return if nmatch == dim
            add_matching_faces(if1, if2)
        end
    end

    function barycenter!(bc, bfnodes, coord, iface)
        for idim in 1:dim
            bc[idim] = 0.0
            for jdim in 1:dim
                bc[idim] += coord[idim, bfnodes[jdim, iface]]
            end
            bc[idim] /= 3.0
        end
        return bc
    end

    nbfreg1 = num_bfaceregions(g1)
    nbfreg2 = num_bfaceregions(g2)
    breg1used = zeros(Bool, nbfreg1)
    breg2used = zeros(Bool, nbfreg2)
    for reg in g1regions
        breg1used[reg] = true
    end
    for reg in g2regions
        breg2used[reg] = true
    end

    nbf1used = 0
    for ibf1 in 1:nbf1
        if breg1used[bfreg1[ibf1]]
            nbf1used += 1
        end
    end

    nbf2used = 0
    for ibf2 in 1:nbf2
        if breg2used[bfreg2[ibf2]]
            nbf2used += 1
        end
    end

    if nbf1used != nbf2used && strict
        error("glue: trying to match $nbf1used grid1 bfaces with $nbf2used grid2 bfaces.")
    end


    if naive
        # Run over all pairs of boundary faces and try to match them
        # This can scale catastrophically...
        for ibf1 in 1:nbf1
            if breg1used[bfreg1[ibf1]]
                for ibf2 in 1:nbf2
                    if breg2used[bfreg2[ibf2]]
                        match_faces(ibf1, ibf2)
                    end
                end
            end
        end
    else
        # Use a binned point list for speed up.
        # Facets are found through their barycenters.
        bcenter = zeros(dim)
        bpl = BinnedPointList(eltype(coord1), dim; tol)

        # marker for facet numbers
        bf1used = zeros(Int, nbf1used)

        # insert all barycenters of used bfaces from grid 1 into the binned pointlist
        for ibf1 in 1:nbf1
            if breg1used[bfreg1[ibf1]]
                i = insert!(bpl, barycenter!(bcenter, bfn1, coord1, ibf1))
                bf1used[i] = ibf1
            end
        end

        # loop over used grid2 bfaces and find if barycenters match with a point in
        # the binned pointlist
        for ibf2 in 1:nbf2
            if breg2used[bfreg2[ibf2]]
                i = findpoint(bpl, barycenter!(bcenter, bfn2, coord2, ibf2))
                # if a match has been found, identify facets
                if i > 0
                    ibf1 = bf1used[i]
                    # use "old" matching, double check at once
                    match_faces(ibf1, ibf2)
                end
            end
        end
    end

    if (n_matching_faces != nbf1used || n_matching_faces != nbf2used) && strict
        error("glue: bfaces to be matched: $nbf1used vs. $nbf2used, bfaces matched: $n_matching_faces.")
    else
        @info "glue: $(n_matching_faces) matching bfaces found"
    end

    creg1 = g1[CellRegions]
    creg2 = g2[CellRegions]

    breg1 = g1[BFaceRegions]
    breg2 = g2[BFaceRegions]

    cn1 = g1[CellNodes]
    cn2 = g2[CellNodes]

    nc1 = size(cn1, 2)
    nc2 = size(cn2, 2)


    # transposed list of matching faces
    mf1 = zeros(Ti, nbf1)
    for if2 in 1:nbf2
        if matching_faces[if2] != 0
            mf1[matching_faces[if2]] = if2
        end
    end

    mfac = interface == 0 ? 2 : 1

    coordx = zeros(dim, nn1 + nn2 - n_matching_nodes)
    cnx = zeros(Ti, dim + 1, nc1 + nc2)
    cregx = zeros(Ti, nc1 + nc2)
    bfnx = zeros(Ti, dim, nbf1 + nbf2 - mfac * n_matching_faces)
    bregx = zeros(Ti, nbf1 + nbf2 - mfac * n_matching_faces)


    #   copy all data from g1 into new fields
    for ix in 1:nn1
        @views coordx[:, ix] .= coord1[:, ix]
    end

    for ix in 1:nc1
        cregx[ix] = creg1[ix]
        @views cnx[:, ix] .= cn1[:, ix]
    end

    ibfx = 1
    for ibf1 in 1:nbf1
        if mf1[ibf1] != 0 && interface == 0
            continue
        end
        if mf1[ibf1] != 0
            bregx[ibfx] = interface
        else
            bregx[ibfx] = breg1[ibf1]
        end
        @views bfnx[:, ibfx] .= bfn1[:, ibf1]
        ibfx += 1
    end


    # re-calculate matching nodes with new global numbers
    # add missing coordinates
    ix = nn1 + 1
    for in2 in 1:nn2
        if matching_nodes[in2] != 0
            continue
        end
        matching_nodes[in2] = ix
        @views coordx[:, ix] .= coord2[:, in2]
        ix = ix + 1
    end


    # copy missing data from g2 into arrays.
    ix = nc1 + 1
    for ic2 in 1:nc2
        cregx[ix] = creg2[ic2]
        for id in 1:(dim + 1)
            cnx[id, ix] = matching_nodes[cn2[id, ic2]]
        end
        ix = ix + 1
    end

    for ibf2 in 1:nbf2
        if matching_faces[ibf2] != 0
            continue
        end
        bregx[ibfx] = breg2[ibf2]
        for id in 1:dim
            bfnx[id, ibfx] = matching_nodes[bfn2[id, ibf2]]
        end
        ibfx += 1
    end
    @assert ibfx == nbf1 + nbf2 - mfac * n_matching_faces + 1
    return simplexgrid(coordx, cnx, cregx, bfnx, bregx)
end
