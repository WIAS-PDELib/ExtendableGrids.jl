function bulk_mark(xgrid::ExtendableGrid{Tv, Ti}, refinement_indicators::AbstractVector{T}, theta = 0.5; indicator_AT = ON_CELLS) where {T, Tv, Ti}

    xFaceCells = xgrid[FaceCells]
    xFaceNodes = xgrid[FaceNodes]
    nfaces = num_sources(xFaceNodes)

    # redistribute refinement_indicators to face indicators (if necessary)
    if indicator_AT == ON_CELLS
        refind4face::Array{T, 1} = zeros(T, nfaces)
        cell::Int = 0
        for face in 1:nfaces
            for k in 1:2
                cell = xFaceCells[k, face]
                if cell > 0
                    refind4face[face] += refinement_indicators[cell]
                end
            end
            if cell > 0
                refind4face[face] /= 2
            end
        end
    elseif indicator_AT == ON_FACES
        refind4face = refinement_indicators
    end

    # mark largest indicators until theta*total is reached
    p = Base.sortperm(refind4face[:], rev = true)
    totalsum = sum(refind4face)
    csum = 0
    j = 0
    facemarker = zeros(Bool, nfaces)
    while csum <= theta * totalsum
        j += 1
        csum += refind4face[p[j]]
        facemarker[p[j]] = true
    end

    return facemarker
end


# adaptive refinement rules fo TRIANGLE2D
# first k nodes are the CellNodes
# next m nodes are the CellFaces midpoints
# next node is the CellMidpoint (if needed)
const _no_refinement_Triangle2D = reshape([1 2 3], 3, 1)
const _red_refinement_Triangle2D = [1 4 6; 4 2 5; 6 5 3; 5 6 4]'
const _blueR_refinement_Triangle2D = [3 1 4; 4 2 5; 3 4 5]'
const _blueL_refinement_Triangle2D = [1 4 6; 2 3 4; 4 3 6]'
const _gree_refinement_Triangle2D = [3 1 4; 2 3 4]'

function RGB_refinement_rule(::Type{<:Triangle2D}, marked_faces::Array{Bool, 1})
    if any(marked_faces) == true
        @assert marked_faces[1] = true # closure should always mark reference face
        if marked_faces[2] == true && marked_faces[3] == true
            return _red_refinement_Triangle2D
        elseif marked_faces[2] == true && marked_faces[3] == false
            return _blueR_refinement_Triangle2D
        elseif marked_faces[2] == false && marked_faces[3] == true
            return _blueL_refinement_Triangle2D
        elseif marked_faces[2] == false && marked_faces[3] == false
            return _gree_refinement_Triangle2D
        end
    else
        return _no_refinement_Triangle2D
    end
end


"""
$(TYPEDSIGNATURES)

generates a new ExtendableGrid by red-green-blue mesh refinement of triangular meshes, see e.g.

Carstensen, C.
--An Adaptive Mesh-Refining Algorithm Allowing for an H^1 Stable L^2 Projection onto Courant Finite Element Spaces--
Constr Approx 20, 549–564 (2004). https://doi.org/10.1007/s00365-003-0550-5

The bool array facemarkers determines which faces should be bisected. Note, that a closuring is performed
such that the first face in every triangle with a marked face is also refined.
"""
function RGB_refine(source_grid::ExtendableGrid{T, K}, facemarkers::Array{Bool, 1}; store_parents = true) where {T, K}

    xgrid = ExtendableGrid{T, K}()
    xgrid[CoordinateSystem] = source_grid[CoordinateSystem]

    # unpack stuff from source grid
    oldCoordinates = source_grid[Coordinates]
    oldCellGeometries = source_grid[CellGeometries]
    oldCellRegions = source_grid[CellRegions]
    EG = Base.unique(oldCellGeometries)

    # get dimension of CellGeometries
    # currently it is assumed to be the same for all cells
    dim = dim_element(EG[1])

    xCellNodes = VariableTargetAdjacency(K)
    xCellGeometries = []
    xCellRegions = zeros(K, 0)
    oldCellNodes = source_grid[CellNodes]
    oldCellFaces = source_grid[CellFaces]
    oldFaceNodes = source_grid[FaceNodes]
    nfaces = num_sources(oldFaceNodes)
    ncells = num_sources(oldCellNodes)
    xCellParents::Array{K, 1} = zeros(K, 0)

    # closuring
    # @logmsg MoreInfo "RGB refinement with $(sum(facemarkers)) marked faces"
    is_refined = true
    closure_finished = false
    while closure_finished == false
        closure_finished = true
        for cell in 1:ncells
            is_refined = false
            for f in 1:3
                if facemarkers[oldCellFaces[f, cell]] == true
                    is_refined = true
                    break
                end
            end
            if is_refined && facemarkers[oldCellFaces[1, cell]] == false
                # mark also reference edge
                facemarkers[oldCellFaces[1, cell]] = true
                closure_finished = false
            end
        end
    end
    # @logmsg DeepInfo "marked faces after closure = $(sum(facemarkers))"


    # determine number of new vertices
    oldvertices = size(oldCoordinates, 2)
    newvertices = 0
    for face in 1:nfaces
        if facemarkers[face] == true
            newvertices += 1
        end
    end
    xCoordinates = zeros(T, size(oldCoordinates, 1), oldvertices + newvertices)
    @views xCoordinates[:, 1:oldvertices] = oldCoordinates

    # refine faces
    newvertex = zeros(T, size(xCoordinates, 1))
    newnodenr = oldvertices
    newnode4facemidpoint = zeros(Int, nfaces)
    nnodes4item = 0
    # add face midpoints to Coordinates
    for face in 1:nfaces
        if facemarkers[face] == true
            nnodes4item = num_targets(oldFaceNodes, face)
            fill!(newvertex, 0.0)
            for k in 1:nnodes4item, d in 1:size(xCoordinates, 1)
                newvertex[d] += xCoordinates[d, oldFaceNodes[k, face]]
            end
            newvertex ./= nnodes4item
            newnodenr += 1
            newnode4facemidpoint[face] = newnodenr
            for d in 1:size(xCoordinates, 1)
                xCoordinates[d, newnodenr] = newvertex[d]
            end
        end
    end

    # determine new cells
    nnodes4item = 3
    nfaces4item = 3
    ncells = 0
    subitemnodes = zeros(K, 3)
    m = 0
    localmarked_faces = zeros(Bool, 3)
    refine_rule = RGB_refinement_rule(Triangle2D, localmarked_faces)
    nnewcells::Int = 0
    for cell in 1:num_sources(oldCellNodes)
        for f in 1:3
            localmarked_faces[f] = facemarkers[oldCellFaces[f, cell]]
        end
        refine_rule = RGB_refinement_rule(Triangle2D, localmarked_faces)
        nnewcells = size(refine_rule, 2)
        for j in 1:nnewcells
            for k in 1:3
                m = refine_rule[k, j]
                if m <= nnodes4item
                    subitemnodes[k] = oldCellNodes[m, cell]
                elseif m <= nnodes4item + nfaces4item
                    subitemnodes[k] = newnode4facemidpoint[oldCellFaces[m - nnodes4item, cell]]
                end
            end
            append!(xCellNodes, view(subitemnodes, :))
            push!(xCellGeometries, Triangle2D)
            push!(xCellRegions, oldCellRegions[cell])
            if store_parents
                push!(xCellParents, cell)
            end
        end
        ncells += nnewcells
    end

    # assign new cells to grid
    xgrid[Coordinates] = xCoordinates
    if typeof(oldCellNodes) == Array{K, 2}
        nnodes4item = size(oldCellNodes, 1)
        xgrid[CellNodes] = reshape(xCellNodes.colentries, nnodes4item, num_sources(xCellNodes))
    else
        xgrid[CellNodes] = xCellNodes
    end
    if typeof(oldCellRegions) <: VectorOfConstants
        xgrid[CellRegions] = VectorOfConstants{K}(1, ncells)
    else
        xgrid[CellRegions] = xCellRegions
    end
    xgrid[CellGeometries] = VectorOfConstants{ElementGeometries, Int}(Triangle2D, ncells)


    # determine new boundary faces
    oldBFaceNodes = source_grid[BFaceNodes]
    oldBFaceFaces = source_grid[BFaceFaces]
    oldBFaceRegions = source_grid[BFaceRegions]

    xBFaceRegions = zeros(K, 0)
    nbfaces = num_sources(oldBFaceNodes)
    xBFaceNodes = zeros(K, 0)

    refine_rule = uniform_refine_rule(Edge1D)

    newbfaces = 0
    xBFaceParents::Array{K, 1} = zeros(K, 0)
    for bface in 1:nbfaces
        face = oldBFaceFaces[bface]
        if facemarkers[face] == true
            for j in 1:2
                for k in 1:2
                    m = refine_rule[j, k]
                    if dim == 2
                        if m <= 2
                            subitemnodes[k] = oldBFaceNodes[m, bface]
                        else
                            subitemnodes[k] = newnode4facemidpoint[face]
                        end
                    end
                end
                append!(xBFaceNodes, view(subitemnodes, 1:2))
                push!(xBFaceRegions, oldBFaceRegions[bface])
                if store_parents
                    push!(xBFaceParents, bface)
                end
            end
            newbfaces += 1
        else
            append!(xBFaceNodes, view(oldBFaceNodes, :, bface))
            push!(xBFaceRegions, oldBFaceRegions[bface])
            if store_parents
                push!(xBFaceParents, bface)
            end
        end
    end
    @debug "bisected bfaces = $newbfaces"

    xgrid[BFaceNodes] = reshape(xBFaceNodes, (2, nbfaces + newbfaces))
    xgrid[BFaceRegions] = xBFaceRegions
    xgrid[BFaceGeometries] = VectorOfConstants{ElementGeometries, Int}(Edge1D, nbfaces + newbfaces)
    xgrid[ParentGrid] = source_grid
    xgrid[ParentGridRelation] = RefinedGrid

    if store_parents
        xgrid[CellParents] = xCellParents
        xgrid[BFaceParents] = xBFaceParents
    end

    return xgrid
end
