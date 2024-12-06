"""
$(TYPEDSIGNATURES)

Edit region numbers of grid cells via rectangular mask.

Examples: [Rectangle-with-multiple-regions](@ref)
"""
function cellmask!(
        grid::ExtendableGrid,
        maskmin,
        maskmax,
        ireg::Int;
        tol = 1.0e-10
    )
    xmaskmin = maskmin .- tol
    xmaskmax = maskmax .+ tol
    ncells = num_cells(grid)
    cellnodes = grid[CellNodes]
    dim = dim_space(grid)
    cellregions = grid[CellRegions]
    coord = grid[Coordinates]
    for icell in 1:ncells
        in_region = true
        for inode in 1:num_targets(cellnodes, icell)
            ignode = cellnodes[inode, icell]
            for idim in 1:dim
                if coord[idim, ignode] < xmaskmin[idim]
                    in_region = false
                    break
                elseif coord[idim, ignode] > xmaskmax[idim]
                    in_region = false
                    break
                end
            end
        end
        if in_region
            cellregions[icell] = ireg
        end
    end
    grid[NumCellRegions] = max(num_cellregions(grid), ireg)
    return grid
end


"""
    bfacemask!(grid::ExtendableGrid,
                    maskmin,
                    maskmax,
                    ireg;
                    allow_new=true,
                    tol=1.0e-10)


Edit region numbers of grid  boundary facets  via rectangular mask.
If `allow_new` is true (default), new facets are added.

ireg may be an integer  or a function `ireg(current_region)`.

A zero region number removes boundary faces.

Examples: [Rectangle-with-multiple-regions](@ref)
"""
function bfacemask!(
        grid::ExtendableGrid,
        maskmin,
        maskmax,
        ireg;
        allow_new = true,
        tol = 1.0e-10
    )

    xmaskmin = maskmin .- tol
    xmaskmax = maskmax .+ tol


    bfacenodes = grid[BFaceNodes]
    nbfaces = size(bfacenodes, 2)

    Ti = eltype(bfacenodes)
    dim = dim_space(grid)
    bfaceregions = grid[BFaceRegions]
    coord = grid[Coordinates]

    xfacenodes = bfacenodes
    if allow_new
        new_bfacenodes = ElasticArray{Ti, 2}(bfacenodes)
        facenodes = grid[FaceNodes]
        bfacefaces = grid[BFaceFaces]
        nfaces = size(facenodes, 2)
        bmark = zeros(Int, nfaces)
        for ibface in 1:nbfaces
            bmark[bfacefaces[ibface]] = ibface
        end
        xfacenodes = facenodes
    end

    newregion(ireg::Int, current_region) = ireg

    newregion(ireg::T, current_region) where {T <: Function} = ireg(current_region)

    ndim = dim_space(grid)
    for ixface in 1:size(xfacenodes, 2)
        in_region = true
        for inode in 1:num_targets(xfacenodes, ixface)
            ignode = xfacenodes[inode, ixface]
            for idim in 1:ndim
                if coord[idim, ignode] < xmaskmin[idim]
                    in_region = false
                elseif coord[idim, ignode] > xmaskmax[idim]
                    in_region = false
                end
            end
            if !in_region
                break
            end
        end

        if in_region
            if allow_new
                ibface = bmark[ixface]
                if ibface > 0 # we are on an existing bface
                    reg = newregion(ireg, bfaceregions[ibface])
                    bfaceregions[ibface] = reg
                else # new bface
                    reg = newregion(ireg, 0)
                    if reg > 0
                        push!(bfaceregions, reg)
                        @views append!(new_bfacenodes, xfacenodes[:, ixface])
                    end
                end
            else # just updating bregion number
                reg = newregion(ireg, bfaceregions[ixface])
                bfaceregions[ixface] = reg
            end
        end
    end


    # This adjacency is not true anymore...
    delete!(grid, BFaceFaces)

    if allow_new
        grid[BFaceNodes] = Array{Ti, 2}(new_bfacenodes)
    end

    # Remove bfaces with zero region number.
    nzeros = sum(iszero, bfaceregions)
    if nzeros > 0
        bfacenodes = grid[BFaceNodes]
        newlength = length(bfaceregions) - nzeros
        new_bfaceregions = zeros(Ti, newlength)
        new_bfacenodes = zeros(Ti, size(bfacenodes, 1), newlength)
        ibfnew = 1
        for ibface in eachindex(bfaceregions)
            if bfaceregions[ibface] > 0
                new_bfaceregions[ibfnew] = bfaceregions[ibface]
                @views new_bfacenodes[:, ibfnew] .= bfacenodes[:, ibface]
                ibfnew += 1
            end
        end
        grid[BFaceNodes] = new_bfacenodes
        grid[BFaceRegions] = new_bfaceregions
    end

    # Update grid information
    btype = grid[BFaceGeometries][1]
    grid[BFaceGeometries] = VectorOfConstants{ElementGeometries, Int}(btype, length(grid[BFaceRegions]))
    grid[NumBFaceRegions] = maximum(grid[BFaceRegions])
    return grid
end


"""
    $(TYPEDSIGNATURES)

Edit region numbers of grid  boundary edges via line mask.
This only works for 3D grids.
"""
function bedgemask!(
        grid::ExtendableGrid,
        xa,
        xb,
        ireg::Int;
        tol = 1.0e-10
    )
    # Masking of boundary edges makes only sense in 3D
    @assert (dim_space(grid) > 2)

    masked = false

    nbedges = num_bedges(grid)
    bedgenodes = grid[BEdgeNodes]
    Ti = eltype(bedgenodes)
    dim = dim_space(grid)
    bedgeregions = grid[BEdgeRegions]
    new_bedgenodes = ElasticArray{Ti, 2}(bedgenodes)
    coord = grid[Coordinates]
    Tv = eltype(coord)

    # length of boundary edge region
    distsq = sqrt((xa[1] - xb[1])^2 + (xa[2] - xb[2])^2 + (xa[3] - xb[3])^2)

    bedgenodes = grid[BEdgeNodes]
    # loop over boundary edges
    for ibedge in 1:size(bedgenodes, 2)
        in_region = true

        #loop over nodes of boundary edge
        for inode in 1:num_targets(bedgenodes, ibedge)
            ignode = bedgenodes[inode, ibedge]

            # we compute the distance of the boundary edge node to the endpoints
            # if the sum of the distances is larger (with tolerance) than the length
            # of the boundary region, the point does not lie on the edge
            distxa = sqrt(
                (xa[1] - coord[1, ignode])^2
                    + (xa[2] - coord[2, ignode])^2
                    + (xa[3] - coord[3, ignode])^2
            )
            distxb = sqrt(
                (coord[1, ignode] - xb[1])^2
                    + (coord[2, ignode] - xb[2])^2
                    + (coord[3, ignode] - xb[3])^2
            )
            diff = distxa + distxb - distsq
            if (diff > tol)
                in_region = false
                continue
            end
        end

        if in_region
            masked = true
            bedgeregions[ibedge] = ireg
        end
    end
    if !masked
        @warn "Couldn't mask any boundary edges for region $(ireg)"
    end

    grid[NumBEdgeRegions] = max(num_bedgeregions(grid), ireg)
    return grid
end

"""
    rect!(grid,maskmin,maskmax; 
          region=1, 
          bregion=1, 
          bregions=nothing, 
          tol=1.0e-10)

Place a rectangle into a rectangular grid. It places a cellmask according to `maskmin` and `maskmax`,
and introduces boundary faces via `bfacesmask! at all sides of the mask area. It is checked that the coordinate
values in the mask match (with tolerance) corresponding directional coordinates of the grid.

If `bregions` is given it is assumed to be a vector corresponding to the number of sides,
im the sequence `w,e` in 1D. `s,e,n,w` in 2D and `s,e,n,w,b,t` in 3D.

`bregion` or elements of `bregions` can be numbers or functions `ireg(current_region)`.

Examples: [Subgrid-from-rectangle](@ref), [Rect2d-with-bregion-function](@ref),  [Cross3d](@ref)
"""
function rect!(grid, maskmin, maskmax; region = 1, bregion = 1, bregions = nothing, tol = 1.0e-10)
    function findval(X, x)
        for i in eachindex(X)
            if abs(X[i] - x) < tol
                return true
            end
        end
        return false
    end

    dim = dim_space(grid)
    if dim >= 1
        nfaces = 2
        X = grid[XCoordinates]
        @assert findval(X, maskmin[1])
        @assert findval(X, maskmax[1])
    end
    if dim >= 2
        nfaces = 4
        Y = grid[YCoordinates]
        @assert findval(Y, maskmin[2])
        @assert findval(Y, maskmax[2])
    end
    if dim >= 3
        nfaces = 6
        Z = grid[ZCoordinates]
        @assert findval(Z, maskmin[3])
        @assert findval(Z, maskmax[3])
    end
    if bregions == nothing
        bregions = fill(bregion, nfaces)
    end
    @assert length(bregions) == nfaces
    cellmask!(grid, maskmin, maskmax, region; tol)

    if dim == 1
        bfacemask!(grid, maskmin, maskmin, bregions[1]; allow_new = true, tol)
        bfacemask!(grid, maskmax, maskmax, bregions[2]; allow_new = true, tol)
    end

    if dim == 2
        bfacemask!(grid, [maskmin[1], maskmin[2]], [maskmax[1], maskmin[2]], bregions[1]; allow_new = true, tol)
        bfacemask!(grid, [maskmax[1], maskmin[2]], [maskmax[1], maskmax[2]], bregions[2]; allow_new = true, tol)
        bfacemask!(grid, [maskmin[1], maskmax[2]], [maskmax[1], maskmax[2]], bregions[3]; allow_new = true, tol)
        bfacemask!(grid, [maskmin[1], maskmin[2]], [maskmin[1], maskmax[2]], bregions[4]; allow_new = true, tol)
    end

    if dim == 3
        bfacemask!(grid, [maskmin[1], maskmin[2], maskmin[3]], [maskmax[1], maskmin[2], maskmax[3]], bregions[1]; allow_new = true, tol) #south
        bfacemask!(grid, [maskmax[1], maskmin[2], maskmin[3]], [maskmax[1], maskmax[2], maskmax[3]], bregions[2]; allow_new = true, tol) #east
        bfacemask!(grid, [maskmin[1], maskmax[2], maskmin[3]], [maskmax[1], maskmax[2], maskmax[3]], bregions[3]; allow_new = true, tol) #north
        bfacemask!(grid, [maskmin[1], maskmin[2], maskmin[3]], [maskmin[1], maskmax[2], maskmax[3]], bregions[4]; allow_new = true, tol) #west
        bfacemask!(grid, [maskmin[1], maskmin[2], maskmin[3]], [maskmax[1], maskmax[2], maskmin[3]], bregions[5]; allow_new = true, tol) #bottom
        bfacemask!(grid, [maskmin[1], maskmin[2], maskmax[3]], [maskmax[1], maskmax[2], maskmax[3]], bregions[5]; allow_new = true, tol) #top
    end
    return grid
end
