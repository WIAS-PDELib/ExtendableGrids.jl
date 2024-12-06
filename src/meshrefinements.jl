# functions that tell how to split one ElementGeometry into another
const _split_rule_Triangle2D = reshape([1, 2, 3], 3, 1)
const _split_rule_Tetrahedron3D = reshape([1, 2, 3, 4], 4, 1)
const _split_rule_Quadrilateral2D_Triangle2D = [1 2 3;1 3 4]'
const _split_rule_Hexahedron3D_Tetrahedron3D = [1 2 4 8; 2 3 4 8; 2 7 3 8; 6 8 7 2; 6 5 8 2; 8 5 1 2]'

split_refine_rule(::Type{Triangle2D}, ::Type{Triangle2D}) = _split_rule_Triangle2D
split_refine_rule(::Type{Tetrahedron3D}, ::Type{Tetrahedron3D}) = _split_rule_Tetrahedron3D
split_refine_rule(::Type{<:Quadrilateral2D}, ::Type{Triangle2D}) = _split_rule_Quadrilateral2D_Triangle2D
split_refine_rule(::Type{<:Hexahedron3D}, ::Type{Tetrahedron3D}) = _split_rule_Hexahedron3D_Tetrahedron3D
#[1 2 3 7; 1 3 4 7; 1 5 6 7; 1 8 5 7; 1 6 2 7; 1 4 8 7]

"""
$(TYPEDSIGNATURES)

generates a new ExtendableGrid by splitting each cell into subcells of the specified targetgeometry

split rules exist for
- Quadrilateral2D into Triangle2D
- Hexahedron3D into Tetrahedron3D
"""
function split_grid_into(source_grid::ExtendableGrid{T, K}, targetgeometry::Type{<:AbstractElementGeometry}; store_parents = true) where {T, K}
    xgrid = ExtendableGrid{T, K}()
    xgrid[Coordinates] = source_grid[Coordinates]
    oldCellGeometries = source_grid[CellGeometries]
    oldCellRegions = source_grid[CellRegions]
    EG = Base.unique(oldCellGeometries)

    split_rules = Array{Array{Int, 2}, 1}(undef, length(EG))
    for j in 1:length(EG)
        split_rules[j] = split_refine_rule(EG[j], targetgeometry)
    end
    singleEG::Bool = false
    if length(EG) == 1
        singleEG = true
    end
    xCellNodes = zeros(K, 0)
    xCellRegions = zeros(K, 0)
    oldCellNodes = source_grid[CellNodes]
    nnodes4item::Int = num_targets(oldCellNodes, 1)
    ncells::Int = 0
    itemEG = EG[1]
    iEG::Int = 1
    split_rule::Array{Int, 2} = split_rules[iEG]
    xCellParents::Array{K, 1} = zeros(K, 0)
    for cell in 1:num_sources(oldCellNodes)
        if !singleEG
            nnodes4item = num_targets(oldCellNodes, cell)
            itemEG = oldCellGeometries[cell]
            iEG = findfirst(isequal(itemEG), EG)
            split_rule = split_rules[iEG]
        end
        for j in 1:size(split_rule, 2), k in 1:size(split_rule, 1)
            append!(xCellNodes, oldCellNodes[split_rule[k, j], cell])
        end
        for j in 1:size(split_rule, 2)
            push!(xCellRegions, oldCellRegions[cell])
            if store_parents
                push!(xCellParents, cell)
            end
        end
        ncells += size(split_rule, 2)
    end
    xCellNodes = reshape(xCellNodes, num_nodes(targetgeometry), ncells)
    xgrid[CellNodes] = xCellNodes
    xgrid[CellGeometries] = VectorOfConstants{ElementGeometries, Int}(targetgeometry, ncells)
    xgrid[CoordinateSystem] = source_grid[CoordinateSystem]
    if typeof(oldCellRegions) <: VectorOfConstants
        xgrid[CellRegions] = VectorOfConstants{ElementGeometries, Int}(K, ncells)
    else
        xgrid[CellRegions] = xCellRegions
    end

    # find new boundary faces (easy in 2D, not so easy in 3D)
    xBFaceParents::Array{K, 1} = zeros(K, 0)
    if dim_element(targetgeometry) == 2 # BFaces are Edge1D which stay the same
        xgrid[BFaceNodes] = source_grid[BFaceNodes]
        xgrid[BFaceRegions] = source_grid[BFaceRegions]
        xgrid[BFaceGeometries] = VectorOfConstants{ElementGeometries, Int}(facetype_of_cellface(targetgeometry, 1), num_sources(xgrid[BFaceNodes]))
        if store_parents
            xBFaceParents = Array{K, 1}(1:num_bfaces(source_grid))
        end
    elseif dim_element(targetgeometry) == 3
        # BFaces may be split into different shapes, e.g. from Quadrilateral2D to two Triangle2D
        # and it is hard to predict how they are split
        # so we do something lazy here and search for new faces that lie in old bfaces
        oldBFaceNodes = source_grid[BFaceNodes]
        oldBFaceRegions = source_grid[BFaceRegions]
        newFaceNodes = xgrid[FaceNodes]
        nfaces = num_sources(newFaceNodes)
        nbfaces = num_sources(oldBFaceNodes)

        newBFaceNodes = zeros(K, 0)
        newBFaceRegions = zeros(K, 0)
        newnbfaces = 0
        nnodes = size(xgrid[Coordinates], 2)
        flag4item = zeros(Bool, nnodes)
        nodes_per_bface::Int = 0
        nodes_per_face::Int = 0
        common_nodes::Int = 0
        for bface in 1:nbfaces
            # flag nodes of old bface
            nodes_per_bface = num_targets(oldBFaceNodes, bface)
            for j in 1:nodes_per_bface
                flag4item[oldBFaceNodes[j, bface]] = true
            end

            # find matching faces
            for face in 1:nfaces
                nodes_per_face = num_targets(newFaceNodes, face)
                common_nodes = 0
                for k in 1:nodes_per_face
                    if flag4item[newFaceNodes[k, face]] == true
                        common_nodes += 1
                    else
                        break
                    end
                end
                if common_nodes == nodes_per_face
                    append!(newBFaceNodes, newFaceNodes[:, face])
                    push!(newBFaceRegions, oldBFaceRegions[bface])
                    newnbfaces += 1
                    if store_parents
                        push!(xBFaceParents, bface)
                    end
                end
            end

            # reset flags
            for j in 1:nodes_per_bface
                flag4item[oldBFaceNodes[j, bface]] = false
            end
        end

        newBFaceNodes = reshape(newBFaceNodes, num_nodes(facetype_of_cellface(targetgeometry, 1)), newnbfaces)
        xgrid[BFaceNodes] = newBFaceNodes
        xgrid[BFaceRegions] = newBFaceRegions
        xgrid[BFaceGeometries] = VectorOfConstants{ElementGeometries, Int}(facetype_of_cellface(targetgeometry, 1), newnbfaces)
    end

    xgrid[ParentGrid] = source_grid
    xgrid[ParentGridRelation] = RefinedGrid
    if store_parents
        xgrid[CellParents] = xCellParents
        xgrid[BFaceParents] = xBFaceParents
    end

    return xgrid
end


uniform_refine_needfacemidpoints(::Type{<:AbstractElementGeometry}) = true
uniform_refine_needcellmidpoints(::Type{<:AbstractElementGeometry}) = false

# uniform refinement rules in 1D
# first k nodes are the CellNodes
# next node is the CellMidpoint
const _uniform_rule_Edge1D = [1 3; 3 2]'
const _uniform_rule_Triangle2D = [1 4 6; 4 2 5; 6 5 3; 5 6 4]'
const _uniform_rule_Quadrilateral2D = [1 5 9 8; 2 6 9 5; 3 7 9 6; 4 8 9 7]'
const _uniform_rule_Tetrahedron3D = [
    1 5 6 7;
    2 5 9 8;
    3 10 6 8;
    4 10 9 7;
    10 5 8 9;
    5 10 7 9;
    5 10 8 6;
    10 5 7 6
]'
const _uniform_rule_Hexahedron3D = [
    1   9  21  12  13  22  27  25;
    9   2  10  21  22  14  23  27;
    12  21  11   4  25  27  24  16;
    21  10   3  11  27  23  15  24;
    13  22  27  25   5  17  26  20;
    22  14  23  27  17   6  18  26;
    25  27  24  16  20  26  19   8;
    27  23  15  24  26  18   7  19
]'

uniform_refine_rule(::Type{<:Edge1D}) = _uniform_rule_Edge1D
uniform_refine_needcellmidpoints(::Type{<:Edge1D}) = true

# uniform refinement rules in 2D
# first k nodes are the CellNodes
# next m nodes are the CellFaces midpoints
# next node is the CellMidpoint (if needed)
uniform_refine_rule(::Type{<:Triangle2D}) = _uniform_rule_Triangle2D
uniform_refine_rule(::Type{<:Quadrilateral2D}) = _uniform_rule_Quadrilateral2D
uniform_refine_needcellmidpoints(::Type{<:Quadrilateral2D}) = true

# uniform refinement rules in 3D
# first k nodes are the CellNodes
# next m nodes are the CellEdges midpoints
# next n nodes are the CellFaces midpoints
# next node is the CellMidpoint (if needed)
uniform_refine_rule(::Type{<:Tetrahedron3D}) = _uniform_rule_Tetrahedron3D
uniform_refine_needfacemidpoints(::Type{<:Tetrahedron3D}) = false
uniform_refine_rule(::Type{<:Hexahedron3D}) = _uniform_rule_Hexahedron3D
uniform_refine_needcellmidpoints(::Type{<:Hexahedron3D}) = true


"""
$(TYPEDSIGNATURES)

generates a new ExtendableGrid by uniform refinement of each cell in the given grid

uniform refinement rules are available for these AbstractElementGeometries:
- Line1D (bisection into two subsegments)
- Triangle2D (red refinement into four subtriangles)
- Quadrilateral2D (into four subquadrilaterals)
- Tetrahedron (into eight subtetrahedrons)
- Hexahedron (into eight subhexahedrons)

if multiple geometries are in the mesh uniform refinement will only work
if all refinement rules refine faces and edges (in 3D) equally
(so no hanging nodes are created)
"""
function uniform_refine(source_grid::ExtendableGrid{T, K}; store_parents = true) where {T, K}
    # @logmsg MoreInfo "Uniform refinement of $(num_sources(source_grid[CellNodes])) cells"

    xgrid = ExtendableGrid{T, K}()
    xgrid[CoordinateSystem] = source_grid[CoordinateSystem]

    # unpack stuff from source grid
    oldCoordinates = source_grid[Coordinates]
    oldCellGeometries = source_grid[CellGeometries]
    oldCellRegions = source_grid[CellRegions]
    EG = Base.unique(oldCellGeometries)

    singleEG = false
    if length(EG) == 1
        singleEG = true
    end

    # get dimension of CellGeometries
    # currently it is assumed to be the same for all cells
    dim::Int = dim_element(EG[1])

    refine_rules::Array{Array{Int, 2}, 1} = Array{Array{Int, 2}, 1}(undef, length(EG))
    need_facemidpoints = uniform_refine_needfacemidpoints(EG[1])
    for j in 1:length(EG)
        refine_rules[j] = uniform_refine_rule(EG[j])
        @assert uniform_refine_needfacemidpoints(EG[j]) == need_facemidpoints
    end

    xCellNodes = VariableTargetAdjacency(K)
    xCellGeometries = Array{ElementGeometries, 1}(undef, 0)
    xCellRegions = zeros(K, 0)
    oldCellNodes::Adjacency{K} = source_grid[CellNodes]
    oldCellFaces::Adjacency{K} = source_grid[CellFaces]
    nfaces::Int = 0
    if dim > 1
        oldFaceNodes = source_grid[FaceNodes]
        nfaces = num_sources(oldFaceNodes)
    end
    nedges::Int = 0
    if dim > 2
        oldEdgeNodes::Adjacency{K} = source_grid[EdgeNodes]
        nedges = num_sources(oldEdgeNodes)
        oldCellEdges::Adjacency{K} = source_grid[CellEdges]
    end


    # determine number of new vertices
    itemEG = Triangle2D
    newvertices::Int = 0 # in 1D no additional vertices on the faces are needed
    if dim == 2 # in 2D each face is halved
        newvertices = nfaces
    elseif dim == 3 # in 2D each face and edge is halved
        newvertices = nedges
        if need_facemidpoints
            newvertices += nfaces
        end
    end
    oldvertices::Int = size(oldCoordinates, 2)
    newnode::Int = oldvertices + newvertices
    # additionally cell midpoints are needed for some refinements
    for cell in 1:num_sources(oldCellNodes)
        itemEG = oldCellGeometries[cell]
        if uniform_refine_needcellmidpoints(itemEG) == true
            newvertices += 1
        end
    end
    xCoordinates::Array{T, 2} = zeros(T, size(oldCoordinates, 1), oldvertices + newvertices)
    @views xCoordinates[:, 1:oldvertices] = oldCoordinates


    newvertex::Array{T, 1} = zeros(T, size(xCoordinates, 1))
    nnodes4item::Int = 0
    if dim > 2 # add edge midpoints to Coordinates
        for edge in 1:nedges
            nnodes4item = num_targets(oldEdgeNodes, edge)
            fill!(newvertex, 0.0)
            for k in 1:nnodes4item, d in 1:size(xCoordinates, 1)
                newvertex[d] += xCoordinates[d, oldEdgeNodes[k, edge]]
            end
            newvertex ./= nnodes4item
            for d in 1:size(xCoordinates, 1)
                xCoordinates[d, oldvertices + edge] = newvertex[d]
            end
        end
    end
    if dim > 1 && need_facemidpoints
        # add face midpoints to Coordinates
        for face in 1:nfaces
            nnodes4item = num_targets(oldFaceNodes, face)
            fill!(newvertex, 0.0)
            for k in 1:nnodes4item, d in 1:size(xCoordinates, 1)
                newvertex[d] += xCoordinates[d, oldFaceNodes[k, face]]
            end
            newvertex ./= nnodes4item
            for d in 1:size(xCoordinates, 1)
                xCoordinates[d, oldvertices + nedges + face] = newvertex[d]
            end
        end
    end

    # determine new cells
    nnodes4item = num_nodes(itemEG)
    nfaces4item::Int = num_faces(itemEG)
    nedges4item::Int = num_edges(itemEG)
    ncells::Int = 0
    iEG::Int = 1
    subitemnodes::Array{K, 1} = zeros(K, max_num_targets_per_source(oldCellNodes) + max_num_targets_per_source(oldCellFaces) + 1)
    m::Int = 0
    xCellParents::Array{K, 1} = zeros(K, 0)
    refine_rule::Array{Int, 2} = refine_rules[iEG]
    for cell in 1:num_sources(oldCellNodes)
        if !singleEG
            itemEG = oldCellGeometries[cell]
            nnodes4item = num_nodes(itemEG)
            nfaces4item = num_faces(itemEG)
            nedges4item = num_edges(itemEG)
            iEG = findfirst(isequal(itemEG), EG)
            refine_rule = refine_rules[iEG]
        end
        if uniform_refine_needcellmidpoints(itemEG) == true
            # add cell midpoint to Coordinates
            newnode += 1
            fill!(newvertex, 0.0)
            for k in 1:nnodes4item, d in 1:size(xCoordinates, 1)
                newvertex[d] += xCoordinates[d, oldCellNodes[k, cell]]
            end
            newvertex ./= nnodes4item
            for d in 1:size(xCoordinates, 1)
                xCoordinates[d, newnode] = newvertex[d]
            end
        end
        for j in 1:size(refine_rule, 2)
            for k in 1:size(refine_rule, 1)
                m = refine_rule[k, j]
                if dim == 1
                    if m <= nnodes4item
                        subitemnodes[k] = oldCellNodes[m, cell]
                    else
                        subitemnodes[k] = newnode
                    end
                elseif dim == 2
                    if m <= nnodes4item
                        subitemnodes[k] = oldCellNodes[m, cell]
                    elseif m <= nnodes4item + nfaces4item
                        subitemnodes[k] = oldvertices + oldCellFaces[m - nnodes4item, cell]
                    else
                        subitemnodes[k] = newnode
                    end
                elseif dim == 3
                    if m <= nnodes4item
                        subitemnodes[k] = oldCellNodes[m, cell]
                    elseif m <= nnodes4item + nedges4item
                        subitemnodes[k] = oldvertices + oldCellEdges[m - nnodes4item, cell]
                    elseif m <= nnodes4item + nedges4item + nfaces4item
                        subitemnodes[k] = oldvertices + nedges + oldCellFaces[m - nnodes4item - nedges4item, cell]
                    else
                        subitemnodes[k] = newnode
                    end
                end
            end
            append!(xCellNodes, view(subitemnodes, 1:size(refine_rule, 1)))
            push!(xCellRegions, oldCellRegions[cell])
            if !singleEG
                push!(xCellGeometries, itemEG)
            end
            if store_parents
                push!(xCellParents, cell)
            end
        end
        ncells += size(refine_rule, 2)
    end

    # assign new cells to grid
    xgrid[Coordinates] = xCoordinates

    if singleEG
        nnodes4item = size(oldCellNodes, 1)
        xgrid[CellNodes] = reshape(xCellNodes.colentries, nnodes4item, num_sources(xCellNodes))
        xgrid[CellGeometries] = VectorOfConstants{ElementGeometries, Int}(EG[1], ncells)
    else
        xgrid[CellNodes] = xCellNodes
        xgrid[CellGeometries] = xCellGeometries
    end
    if typeof(oldCellRegions) <: VectorOfConstants
        xgrid[CellRegions] = VectorOfConstants{K}(1, ncells)
    else
        xgrid[CellRegions] = xCellRegions
    end


    # determine new boundary faces
    oldBFaceNodes::Adjacency{K} = source_grid[BFaceNodes]
    oldBFaceFaces::Array{K, 1} = source_grid[BFaceFaces]
    oldBFaceRegions = source_grid[BFaceRegions]
    oldBFaceGeometries = source_grid[BFaceGeometries]
    xBFaceParents::Array{K, 1} = zeros(K, 0)

    if dim == 1
        xgrid[BFaceNodes] = oldBFaceNodes
        xgrid[BFaceRegions] = oldBFaceRegions
        xgrid[BFaceGeometries] = oldBFaceGeometries
        if store_parents
            xBFaceParents = Array{K, 1}(1:num_bfaces(source_grid))
        end
    else
        xBFaceRegions = zeros(K, 0)
        BFEG = Base.unique(oldBFaceGeometries)
        singleEG = length(BFEG) == 1
        if singleEG == false
            xBFaceGeometries = Array{ElementGeometries, 1}(undef, 0)
        end
        nbfaces = num_sources(oldBFaceNodes)
        if dim == 2 || typeof(oldBFaceNodes) == Array{K, 2}
            xBFaceNodes = zeros(K, 0)
        else
            xBFaceNodes = VariableTargetAdjacency(K)
        end
        if dim == 3
            xCellEdges = source_grid[CellEdges]
            xNodeEdges::Adjacency{K} = atranspose(oldEdgeNodes)
        else
            xCellEdges = []
        end

        EG = Base.unique(oldBFaceGeometries)

        refine_rules = Array{Array{Int, 2}, 1}(undef, length(EG))
        for j in 1:length(EG)
            refine_rules[j] = uniform_refine_rule(EG[j])
        end

        face::K = 0
        edge::Int = 0
        n1::Int = 0
        ne4n1::Int = 0
        n2::Int = 0
        ne4n2::Int = 0
        newnbfaces::Int = 0
        bface_enum_rule::Array{Int, 2} = local_cellfacenodes(EG[1])
        for bface in 1:nbfaces
            face = oldBFaceFaces[bface]
            itemEG = oldBFaceGeometries[bface]
            nnodes4item = num_nodes(itemEG)
            nfaces4item = num_faces(itemEG)
            nedges4item = num_edges(itemEG)
            iEG = findfirst(isequal(itemEG), EG)
            bface_enum_rule = local_cellfacenodes(itemEG)

            for j in 1:size(refine_rules[iEG], 2)
                for k in 1:size(refine_rules[iEG], 1)
                    m = refine_rules[iEG][k, j]
                    if dim == 2
                        if m <= nnodes4item
                            subitemnodes[k] = oldBFaceNodes[m, bface]
                        else
                            subitemnodes[k] = oldvertices + face
                        end
                    elseif dim == 3
                        if m <= nnodes4item
                            subitemnodes[k] = oldBFaceNodes[m, bface]
                        elseif m <= nnodes4item + nfaces4item
                            edge = m - nnodes4item # local number
                            # find global edge number
                            n1 = oldBFaceNodes[bface_enum_rule[1, edge], bface]
                            n2 = oldBFaceNodes[bface_enum_rule[2, edge], bface]
                            ne4n1 = num_targets(xNodeEdges, n1)
                            ne4n2 = num_targets(xNodeEdges, n2)
                            for ge in 1:ne4n1, gf in 1:ne4n2
                                if xNodeEdges[ge, n1] == xNodeEdges[gf, n2]
                                    edge = xNodeEdges[gf, n2]
                                    break
                                end
                            end
                            #   edge = intersect(xNodeEdges[:,oldBFaceNodes[bface_enum_rule[1,edge],bface]],xNodeEdges[:,oldBFaceNodes[bface_enum_rule[2,edge],bface]])[1]
                            subitemnodes[k] = oldvertices + edge
                        else
                            subitemnodes[k] = oldvertices + nedges + face
                        end
                    end
                end
                append!(xBFaceNodes, view(subitemnodes, 1:size(refine_rules[iEG], 1)))
                if !singleEG
                    push!(xBFaceGeometries, itemEG)
                end
                push!(xBFaceRegions, oldBFaceRegions[bface])
                if store_parents
                    push!(xBFaceParents, bface)
                end
                newnbfaces += 1
            end
        end
        if dim == 2 || typeof(oldBFaceNodes) == Array{K, 2}
            xgrid[BFaceNodes] = reshape(xBFaceNodes, (size(oldBFaceNodes, 1), newnbfaces))
        else
            xgrid[BFaceNodes] = xBFaceNodes
        end
        xgrid[BFaceRegions] = xBFaceRegions
        if singleEG
            xgrid[BFaceGeometries] = VectorOfConstants{ElementGeometries, Int}(BFEG[1], newnbfaces)
        else
            xgrid[BFaceGeometries] = xBFaceGeometries
        end
    end

    if store_parents
        xgrid[CellParents] = xCellParents
        xgrid[BFaceParents] = xBFaceParents
    end

    xgrid[ParentGrid] = source_grid
    xgrid[ParentGridRelation] = RefinedGrid

    return xgrid
end


function uniform_refine(source_grid::ExtendableGrid{T, K}, nrefinements::Int; store_parents = false) where {T, K}
    xgrid = source_grid
    parents = 1:num_sources(xgrid[CellNodes])
    for j in 1:nrefinements
        xgrid = uniform_refine(xgrid; store_parents = store_parents)
        if store_parents
            parents = parents[xgrid[CellParents]]
        end
    end
    if store_parents
        xgrid[CellParents] = parents
        xgrid[ParentGrid] = source_grid
        xgrid[ParentGridRelation] = RefinedGrid
    end
    return xgrid
end


# barycentric refinement rules
# first k nodes are the CellNodes, k+1-th  node is cell midpoint
const _barycentric_rule_Triangle2D = [1 2 4; 2 3 4; 3 1 4]'
barycentric_refine_rule(::Type{<:Triangle2D}) = _barycentric_rule_Triangle2D
const _barycentric_rule_Tetrahedron3D = [1 3 5 2; 1 2 5 4; 2 3 5 4; 3 1 5 4]'
barycentric_refine_rule(::Type{<:Tetrahedron3D}) = _barycentric_rule_Tetrahedron3D


"""
$(TYPEDSIGNATURES)

generates a new ExtendableGrid by barycentric refinement of each cell in the source grid

barycentric refinement is available for these ElementGeometries
- Quadrilateral2D (first split into Triangle2D)
- Triangle2D
"""
function barycentric_refine(source_grid::ExtendableGrid{T, K}; store_parents = true) where {T, K}
    # @logmsg MoreInfo "Barycentric refinement of $(num_sources(source_grid[CellNodes])) cells"

    # split first into triangles
    oldCellGeometries = source_grid[CellGeometries]
    dim = dim_element(oldCellGeometries[1])
    itemEG = dim == 2 ? Triangle2D : Tetrahedron3D
    source_grid = split_grid_into(source_grid, itemEG)

    xgrid = ExtendableGrid{T, K}()
    oldCoordinates = source_grid[Coordinates]
    oldCellGeometries = source_grid[CellGeometries]
    oldCellRegions = source_grid[CellRegions]
    EG = Base.unique(oldCellGeometries)

    refine_rules = Array{Array{Int, 2}, 1}(undef, length(EG))
    for j in 1:length(EG)
        refine_rules[j] = barycentric_refine_rule(EG[j])
    end

    xCellNodes::Adjacency = VariableTargetAdjacency(K)
    xCellGeometries = Array{ElementGeometries, 1}(undef, 0)
    xCellRegions = zeros(K, 0)

    oldCellNodes = source_grid[CellNodes]
    oldCellFaces = source_grid[CellFaces]

    # determine number of new vertices
    newvertices = num_sources(oldCellNodes)
    oldvertices = size(oldCoordinates, 2)
    xCoordinates = zeros(T, size(oldCoordinates, 1), oldvertices + newvertices)
    @views xCoordinates[:, 1:oldvertices] = oldCoordinates

    # determine new cells
    nnodes4item::Int = num_targets(oldCellNodes, 1)
    ncells::Int = 0
    iEG::Int = 1
    subitemnodes::Array{K, 1} = zeros(K, max_num_targets_per_source(oldCellNodes) + max_num_targets_per_source(oldCellFaces) + 1)
    newnode::Int = oldvertices
    m::Int = 0
    newvertex::Array{T, 1} = zeros(T, size(xCoordinates, 1))
    refine_rule::Array{Int, 2} = refine_rules[iEG]
    xCellParents::Array{K, 1} = zeros(K, 0)
    for cell in 1:num_sources(oldCellNodes)

        # add cell midpoint to Coordinates
        newnode += 1
        fill!(newvertex, 0.0)
        for k in 1:nnodes4item, d in 1:size(xCoordinates, 1)
            newvertex[d] += xCoordinates[d, oldCellNodes[k, cell]]
        end
        newvertex ./= nnodes4item
        for d in 1:size(xCoordinates, 1)
            xCoordinates[d, newnode] = newvertex[d]
        end

        for j in 1:size(refine_rule, 2)
            for k in 1:size(refine_rule, 1)
                m = refine_rules[iEG][k, j]
                if m <= nnodes4item
                    subitemnodes[k] = oldCellNodes[m, cell]
                else
                    subitemnodes[k] = newnode
                end
            end
            append!(xCellNodes, view(subitemnodes, 1:size(refine_rule, 1)))
            push!(xCellRegions, oldCellRegions[cell])
            if store_parents
                push!(xCellParents, cell)
            end
        end
        ncells += size(refine_rule, 2)
    end

    xgrid[Coordinates] = xCoordinates
    nnodes4item = size(oldCellNodes, 1)
    xgrid[CellNodes] = reshape(xCellNodes.colentries, nnodes4item, num_sources(xCellNodes))
    xgrid[CellGeometries] = VectorOfConstants{ElementGeometries, Int}(EG[1], num_sources(xCellNodes))
    if typeof(oldCellRegions) <: VectorOfConstants
        xgrid[CellRegions] = VectorOfConstants{K}(1, num_sources(xCellNodes))
    else
        xgrid[CellRegions] = xCellRegions
    end
    xgrid[BFaceNodes] = source_grid[BFaceNodes]
    xgrid[BFaceRegions] = source_grid[BFaceRegions]
    xgrid[BFaceGeometries] = source_grid[BFaceGeometries]
    xgrid[CoordinateSystem] = source_grid[CoordinateSystem]
    xgrid[ParentGrid] = source_grid
    xgrid[ParentGridRelation] = RefinedGrid
    if store_parents
        xgrid[CellParents] = xCellParents
        xgrid[BFaceParents] = Array{K, 1}(1:num_bfaces(source_grid))
    end
    return xgrid
end
