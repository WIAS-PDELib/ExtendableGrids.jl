# Here goes all the stuff that connects this code to ExtendableGrids like
# - definition of additional adjacency types and their instantiation
# - connections between CellGeometries and FaceGeometries of their faces
# - formulas to compute Volumes and Normal Vectors etc.
# (some of this might become native in the ExtendableGrids module itself at some point)


# additional ElementGeometryTypes with parent information
#abstract type Vertex0DWithParent{Parent <: AbstractElementGeometry} <: Vertex0D end
#abstract type Vertex0DWithParents{Parent1 <: AbstractElementGeometry, Parent2 <: AbstractElementGeometry} <: Vertex0D end
#export Vertex0DWithParent, Vertex0DWithParents

#function AddParent(FEG::Type{<:Vertex0D}, CEG::Type{<:AbstractElementGeometry})
#    return Vertex0DWithParent{CEG}
#end

#abstract type Edge1DWithParent{Parent <: AbstractElementGeometry} <: Edge1D end
#abstract type Edge1DWithParents{Parent1 <: AbstractElementGeometry, Parent2 <: AbstractElementGeometry} <: Edge1D end
#export Edge1DWithParent, Edge1DWithParents

#function AddParent(FEG::Type{<:Edge1D}, CEG::Type{<:AbstractElementGeometry})
#    return Edge1DWithParent{CEG}
#end

const GridEGTypes = Vector{ElementGeometries}
const GridRegionTypes{Ti} = Union{VectorOfConstants{Ti}, Array{Ti, 1}}


# additional ExtendableGrids adjacency types
abstract type CellEdges <: AbstractGridAdjacency end
abstract type CellFaces <: AbstractGridAdjacency end
abstract type CellFaceSigns <: AbstractGridAdjacency end
abstract type CellFaceOrientations <: AbstractGridAdjacency end
abstract type CellEdgeSigns <: AbstractGridAdjacency end
abstract type CellVolumes <: AbstractGridFloatArray1D end
abstract type UniqueCellGeometries <: AbstractElementGeometries end
abstract type CellAssemblyGroups <: AbstractGridAdjacency end

abstract type FaceNodes <: AbstractGridAdjacency end
abstract type FaceVolumes <: AbstractGridFloatArray1D end
abstract type FaceCells <: AbstractGridAdjacency end
abstract type FaceEdges <: AbstractGridAdjacency end
abstract type FaceEdgeSigns <: AbstractGridAdjacency end
abstract type FaceNormals <: AbstractGridFloatArray2D end
abstract type FaceGeometries <: AbstractElementGeometries end
abstract type FaceRegions <: AbstractElementRegions end
abstract type UniqueFaceGeometries <: AbstractElementGeometries end
abstract type FaceAssemblyGroups <: AbstractGridAdjacency end

abstract type BFaceFaces <: AbstractGridIntegerArray1D end
abstract type BFaceCellPos <: AbstractGridIntegerArray1D end # position of bface in adjacent cell
abstract type BFaceVolumes <: AbstractGridFloatArray1D end
abstract type UniqueBFaceGeometries <: AbstractElementGeometries end
abstract type BFaceAssemblyGroups <: AbstractGridAdjacency end

abstract type EdgeNodes <: AbstractGridAdjacency end
abstract type EdgeVolumes <: AbstractGridFloatArray1D end
abstract type EdgeCells <: AbstractGridAdjacency end
abstract type EdgeTangents <: AbstractGridFloatArray2D end
abstract type EdgeRegions <: AbstractElementRegions end
abstract type EdgeGeometries <: AbstractElementGeometries end
abstract type UniqueEdgeGeometries <: AbstractElementGeometries end
abstract type EdgeAssemblyGroups <: AbstractGridAdjacency end

abstract type BEdgeNodes <: AbstractGridAdjacency end
abstract type BEdgeEdges <: AbstractGridIntegerArray1D end
#abstract type BEdgeCellPos <: AbstractGridIntegerArray1D end # position of bface in adjacent cell
abstract type BEdgeVolumes <: AbstractGridFloatArray1D end
abstract type BEdgeRegions <: AbstractElementRegions end
abstract type BEdgeGeometries <: AbstractElementGeometries end
abstract type UniqueBEdgeGeometries <: AbstractElementGeometries end
abstract type BEdgeAssemblyGroups <: AbstractGridAdjacency end

abstract type NodePatchGroups <: AbstractGridIntegerArray1D end


## grid item types to dispatch certain things to the correct GridComponents
abstract type ITEMTYPE_NODE end
abstract type ITEMTYPE_CELL end
abstract type ITEMTYPE_FACE end
abstract type ITEMTYPE_BFACE end
abstract type ITEMTYPE_EDGE end
abstract type ITEMTYPE_BEDGE end

abstract type PROPERTY_NODES end
abstract type PROPERTY_VOLUME end
abstract type PROPERTY_REGION end
abstract type PROPERTY_GEOMETRY end
abstract type PROPERTY_UNIQUEGEOMETRY end
abstract type PROPERTY_ASSEMBLYGROUP end

GridComponent4TypeProperty(::Type{ITEMTYPE_CELL}, ::Type{PROPERTY_NODES}) = CellNodes
GridComponent4TypeProperty(::Type{ITEMTYPE_CELL}, ::Type{PROPERTY_VOLUME}) = CellVolumes
GridComponent4TypeProperty(::Type{ITEMTYPE_CELL}, ::Type{PROPERTY_REGION}) = CellRegions
GridComponent4TypeProperty(::Type{ITEMTYPE_CELL}, ::Type{PROPERTY_GEOMETRY}) = CellGeometries
GridComponent4TypeProperty(::Type{ITEMTYPE_CELL}, ::Type{PROPERTY_UNIQUEGEOMETRY}) = UniqueCellGeometries
GridComponent4TypeProperty(::Type{ITEMTYPE_CELL}, ::Type{PROPERTY_ASSEMBLYGROUP}) = CellAssemblyGroups


GridComponent4TypeProperty(::Type{ITEMTYPE_FACE}, ::Type{PROPERTY_NODES}) = FaceNodes
GridComponent4TypeProperty(::Type{ITEMTYPE_FACE}, ::Type{PROPERTY_VOLUME}) = FaceVolumes
GridComponent4TypeProperty(::Type{ITEMTYPE_FACE}, ::Type{PROPERTY_REGION}) = FaceRegions
GridComponent4TypeProperty(::Type{ITEMTYPE_FACE}, ::Type{PROPERTY_GEOMETRY}) = FaceGeometries
GridComponent4TypeProperty(::Type{ITEMTYPE_FACE}, ::Type{PROPERTY_UNIQUEGEOMETRY}) = UniqueFaceGeometries
GridComponent4TypeProperty(::Type{ITEMTYPE_FACE}, ::Type{PROPERTY_ASSEMBLYGROUP}) = FaceAssemblyGroups

GridComponent4TypeProperty(::Type{ITEMTYPE_BFACE}, ::Type{PROPERTY_NODES}) = BFaceNodes
GridComponent4TypeProperty(::Type{ITEMTYPE_BFACE}, ::Type{PROPERTY_VOLUME}) = BFaceVolumes
GridComponent4TypeProperty(::Type{ITEMTYPE_BFACE}, ::Type{PROPERTY_REGION}) = BFaceRegions
GridComponent4TypeProperty(::Type{ITEMTYPE_BFACE}, ::Type{PROPERTY_GEOMETRY}) = BFaceGeometries
GridComponent4TypeProperty(::Type{ITEMTYPE_BFACE}, ::Type{PROPERTY_UNIQUEGEOMETRY}) = UniqueBFaceGeometries
GridComponent4TypeProperty(::Type{ITEMTYPE_BFACE}, ::Type{PROPERTY_ASSEMBLYGROUP}) = BFaceAssemblyGroups

GridComponent4TypeProperty(::Type{ITEMTYPE_EDGE}, ::Type{PROPERTY_NODES}) = EdgeNodes
GridComponent4TypeProperty(::Type{ITEMTYPE_EDGE}, ::Type{PROPERTY_VOLUME}) = EdgeVolumes
GridComponent4TypeProperty(::Type{ITEMTYPE_EDGE}, ::Type{PROPERTY_REGION}) = EdgeRegions
GridComponent4TypeProperty(::Type{ITEMTYPE_EDGE}, ::Type{PROPERTY_GEOMETRY}) = EdgeGeometries
GridComponent4TypeProperty(::Type{ITEMTYPE_EDGE}, ::Type{PROPERTY_UNIQUEGEOMETRY}) = UniqueEdgeGeometries
GridComponent4TypeProperty(::Type{ITEMTYPE_EDGE}, ::Type{PROPERTY_ASSEMBLYGROUP}) = EdgeAssemblyGroups

GridComponent4TypeProperty(::Type{ITEMTYPE_BEDGE}, ::Type{PROPERTY_NODES}) = BEdgeNodes
GridComponent4TypeProperty(::Type{ITEMTYPE_BEDGE}, ::Type{PROPERTY_VOLUME}) = BEdgeVolumes
GridComponent4TypeProperty(::Type{ITEMTYPE_BEDGE}, ::Type{PROPERTY_REGION}) = BEdgeRegions
GridComponent4TypeProperty(::Type{ITEMTYPE_BEDGE}, ::Type{PROPERTY_GEOMETRY}) = BEdgeGeometries
GridComponent4TypeProperty(::Type{ITEMTYPE_BEDGE}, ::Type{PROPERTY_UNIQUEGEOMETRY}) = UniqueBEdgeGeometries
GridComponent4TypeProperty(::Type{ITEMTYPE_BEDGE}, ::Type{PROPERTY_ASSEMBLYGROUP}) = BEdgeAssemblyGroups

# show function for ExtendableGrids and defined Components in its Dict
function showmore(io::IO, xgrid::ExtendableGrid{Tc, Ti}) where {Tc, Ti}

    dim = size(xgrid[Coordinates], 1)
    nnodes = num_sources(xgrid[Coordinates])
    ncells = num_sources(xgrid[CellNodes])

    println("ExtendableGrid information")
    println("==========================")
    println("dim: $(dim)")
    println("nnodes: $(nnodes)")
    println("ncells: $(ncells)")
    if haskey(xgrid.components, FaceNodes)
        nfaces = num_sources(xgrid[FaceNodes])
        println("nfaces: $(nfaces)")
    else
        println("nfaces: (FaceNodes not instantiated)")
    end
    if haskey(xgrid.components, EdgeNodes)
        nedges = num_sources(xgrid[EdgeNodes])
        println("nedges: $(nedges)")
    else
        println("nedges: (EdgeNodes not instantiated)")
    end
    println("")
    println("Components")
    println("==========")
    for tuple in xgrid.components
        println("> $(tuple[1])")
    end
    return
end


# FaceNodes = nodes for each face (implicitly defines the enumerations of faces)
function ExtendableGrids.instantiate(xgrid::ExtendableGrid{Tc, Ti}, ::Type{FaceNodes}) where {Tc, Ti}

    if haskey(xgrid, ParentGrid) && haskey(xgrid, ParentGridRelation)
        if xgrid[ParentGridRelation] <: SubGrid{ON_CELLS}
            ## get FaceNodes from ParentGrid to keep ordering and orientation
            pgrid = xgrid[ParentGrid]
            pnodes = xgrid[NodeParents]
            nscells = num_cells(xgrid)
            PFaceNodes = pgrid[FaceNodes]
            PCellFaces = deepcopy(pgrid[CellFaces])
            pcells = xgrid[CellParents]
            nfaces = size(PFaceNodes, 2)
            is_subface = false
            FNT = typeof(PFaceNodes)
            if FNT <: Matrix
                singleEG = true
            else
                singleEG = false
            end
            SFaceNodes::Union{VariableTargetAdjacency{Ti}, Matrix{Ti}} = singleEG ? zeros(Ti, size(PFaceNodes, 1), 0) : VariableTargetAdjacency(Ti)

            pnode2snode = zeros(Ti, num_nodes(pgrid))
            pnode2snode[pnodes] .= 1:length(pnodes)
            pfaces = Ti[]
            for face in 1:nfaces
                is_subface = true
                for k in 1:num_targets(PFaceNodes, face)
                    if !(PFaceNodes[k, face] in pnodes)
                        is_subface = false
                        break
                    end
                end
                if is_subface
                    push!(pfaces, face)
                end
            end
            pface2sface = zeros(Ti, nfaces)
            pface2sface[pfaces] = 1:length(pfaces)
            SFaceNodes = PFaceNodes[:, pfaces]
            for face in 1:length(pfaces)
                for k in 1:num_targets(SFaceNodes, face)
                    SFaceNodes[k, face] = pnode2snode[SFaceNodes[k, face]]
                end
            end
            xgrid[FaceNodes] = SFaceNodes
            if typeof(pgrid[FaceGeometries]) <: VectorOfConstants
                xgrid[FaceGeometries] = VectorOfConstants{ElementGeometries, Int}(pgrid[FaceGeometries][1], length(pfaces))
            else
                xgrid[FaceGeometries] = pgrid[FaceGeometries][pfaces]
            end
            xgrid[FaceRegions] = pgrid[FaceRegions][pfaces]

            npcells = num_cells(pgrid)
            for cell in 1:npcells
                is_subcell = true
                for k in 1:num_targets(PCellFaces, cell)
                    PCellFaces[k, cell] = pface2sface[PCellFaces[k, cell]]
                end
            end
            pcell2scell = zeros(Ti, npcells)
            pcell2scell[pcells] = 1:length(pcells)
            xgrid[CellFaces] = PCellFaces[:, pcells]
            xgrid[CellFaceSigns] = pgrid[CellFaceSigns][:, pcells]
            SFaceCells = pgrid[FaceCells][:, pfaces]
            for face in 1:1:length(pfaces)
                for k in 1:num_targets(SFaceCells, face)
                    if SFaceCells[k, face] > 0
                        SFaceCells[k, face] = pcell2scell[SFaceCells[k, face]]
                    else
                        SFaceCells[k, face] = 0
                    end
                end
                if SFaceCells[1, face] == 0 && SFaceCells[2, face] > 0
                    SFaceCells[1, face] = SFaceCells[2, face]
                    SFaceCells[2, face] = 0
                end
            end
            xgrid[FaceCells] = SFaceCells
            xgrid[FaceParents] = pfaces
            xgrid[CellParents] = pcells

            return SFaceNodes
        end
    end

    xCellNodes = xgrid[CellNodes]
    ncells = num_sources(xCellNodes)
    nnodes = num_sources(xgrid[Coordinates])
    xCellGeometries = xgrid[CellGeometries]

    # transpose CellNodes to get NodeCells
    xNodeCells = atranspose(xCellNodes)
    max_ncell4node::Ti = max_num_targets_per_source(xNodeCells)

    # instantiate new empty adjacency fields
    xFaceCells = zeros(Ti, 0) # cells are appended and at the end rewritten into 2,nfaces array


    # find unique face enumeration rules
    EG = unique(xCellGeometries)
    dim::Ti = dim_element(EG[1])
    face_rules = Array{Array{Ti, 2}, 1}(undef, length(EG))
    maxfacenodes::Ti = 0
    FEG = []
    for j in 1:length(EG)
        face_rules[j] = local_cellfacenodes(EG[j])
        maxfacenodes = max(size(face_rules[j], 2), maxfacenodes)
        for k in 1:num_faces(EG[j])
            append!(FEG, [facetype_of_cellface(EG[j], j)])
        end
    end
    unique!(FEG)

    # check if only one type of cell geometry is present in grid
    if length(EG) == 1
        singleEG = true
    else
        singleEG = false
    end
    # check if only one type of face geometry is present in grid
    if length(FEG) == 1
        singleFEG = true
    else
        singleFEG = false
    end

    if singleFEG
        xFaceNodes = zeros(Ti, 0)
    else
        xFaceNodes = VariableTargetAdjacency(Ti)
        xFaceGeometries::Array{ElementGeometries, 1} = []
    end
    xCellFaces::Union{VariableTargetAdjacency{Ti}, Matrix{Ti}} = singleEG * singleFEG ? zeros(Ti, num_faces(EG[1]), ncells) : VariableTargetAdjacency(Ti)
    xCellFaceSigns::Union{VariableTargetAdjacency{Ti}, Matrix{Ti}} = singleEG * singleFEG ? zeros(Ti, num_faces(EG[1]), ncells) : VariableTargetAdjacency(Ti)
    if singleEG == true && singleFEG == true
    else
        # pre-allocate xCellFaces
        cellEG = xCellGeometries[1]
        for cell in 1:ncells
            cellEG = xCellGeometries[cell]
            append!(xCellFaces, zeros(Ti, num_faces(cellEG)))
            append!(xCellFaceSigns, zeros(Ti, num_faces(cellEG)))
        end
    end

    # temporary variables
    # pre-initialised ready to work for singleEG and singleFEG
    node::Ti = 0
    face::Ti = 0
    cell::Ti = 0
    cell2::Ti = 0
    cellEG = EG[1]
    cell2EG = EG[1]
    faceEG = FEG[1]
    faceEG2 = FEG[1]
    face_rule::Array{Ti, 2} = face_rules[1]
    face_rule2::Array{Ti, 2} = face_rules[1]
    iEG::Ti = 1
    nneighbours::Ti = 0
    faces_per_cell::Ti = num_faces(cellEG)
    faces_per_cell2::Ti = num_faces(cellEG)
    nodes_per_cellface::Ti = num_nodes(faceEG)
    current_item::Array{Ti, 1} = zeros(Ti, maxfacenodes) # should be large enough to store largest nnodes per cellface
    flag4item::Array{Bool, 1} = zeros(Bool, nnodes)
    no_neighbours_found::Bool = true
    same_face::Bool = false

    # loop over cells
    for cell in 1:ncells
        # find EG index for geometry
        if !singleEG
            cellEG = xCellGeometries[cell]
            faces_per_cell = num_faces(cellEG)
            for j in 1:length(EG)
                if cellEG == EG[j]
                    iEG = j
                    break
                end
            end
            face_rule = face_rules[iEG]
        end

        # loop over cell faces
        for k in 1:faces_per_cell

            # check if face is already known to cell
            if xCellFaces[k, cell] > 0
                continue
            end

            # get face geometry
            if !singleFEG
                faceEG = facetype_of_cellface(cellEG, k)
                nodes_per_cellface = num_nodes(faceEG)
            end

            # flag face nodes and commons4cells
            for j in nodes_per_cellface:-1:1
                node = xCellNodes[face_rule[j, k], cell]
                current_item[j] = node
                flag4item[node] = true
            end

            # get neighbours for first node
            nneighbours = num_targets(xNodeCells, node)

            # loop over neighbours
            no_neighbours_found = true
            for n in 1:nneighbours
                cell2 = xNodeCells[n, node]

                # skip if cell2 is the same as cell
                if (cell == cell2)
                    continue
                end

                # find face enumeration rule
                if !singleEG
                    cell2EG = xCellGeometries[cell2]
                    faces_per_cell2 = num_faces(cell2EG)
                    for j in 1:length(EG)
                        if cell2EG == EG[j]
                            iEG = j
                            break
                        end
                    end
                    face_rule2 = face_rules[iEG]
                end

                # loop over faces face2 of adjacent cell2
                for f2 in 1:faces_per_cell2

                    # check if face f2 is already known to cell2
                    if xCellFaces[f2, cell2] != 0
                        continue
                    end

                    # check if face f2 has same geometry
                    if !singleFEG
                        faceEG2 = facetype_of_cellface(cell2EG, f2)
                        if faceEG != faceEG2
                            continue
                        end
                    end

                    # otherwise compare nodes of face and face2
                    same_face = true
                    for j in 1:nodes_per_cellface
                        if flag4item[xCellNodes[face_rule2[j, f2], cell2]] == false
                            same_face = false
                            break
                        end
                    end

                    # if all nodes are the same, register face
                    if (same_face)
                        no_neighbours_found = false
                        face += 1
                        push!(xFaceCells, cell)
                        push!(xFaceCells, cell2)
                        if singleEG == false
                            xCellFaces.colentries[xCellFaces.colstart[cell] + k - 1] = face
                            xCellFaces.colentries[xCellFaces.colstart[cell2] + f2 - 1] = face
                            xCellFaceSigns.colentries[xCellFaceSigns.colstart[cell] + k - 1] = 1
                            xCellFaceSigns.colentries[xCellFaceSigns.colstart[cell2] + f2 - 1] = -1
                            if singleFEG == false
                                push!(xFaceGeometries, faceEG)
                            end
                        else
                            xCellFaces[k, cell] = face
                            xCellFaces[f2, cell2] = face
                            xCellFaceSigns[k, cell] = 1
                            xCellFaceSigns[f2, cell2] = -1
                        end
                        append!(xFaceNodes, view(current_item, 1:nodes_per_cellface))
                        break
                    end
                end
            end

            # if no common neighbour cell is found, register face (boundary faces)
            if no_neighbours_found == true
                face += 1
                push!(xFaceCells, cell)
                push!(xFaceCells, 0)
                if singleEG == false
                    xCellFaces.colentries[xCellFaces.colstart[cell] + k - 1] = face
                    xCellFaceSigns.colentries[xCellFaceSigns.colstart[cell] + k - 1] = 1
                    if singleFEG == false
                        push!(xFaceGeometries, faceEG)
                    end
                else
                    xCellFaces[k, cell] = face
                    xCellFaceSigns[k, cell] = 1
                end
                append!(xFaceNodes, view(current_item, 1:nodes_per_cellface))
            end

            # reset flag4item
            for j in 1:nodes_per_cellface
                flag4item[current_item[j]] = false
            end
        end
    end

    if singleFEG
        xFaceNodes = reshape(xFaceNodes, (nodes_per_cellface, Ti(length(xFaceNodes) / nodes_per_cellface)))
        xgrid[FaceGeometries] = VectorOfConstants{ElementGeometries, Int}(facetype_of_cellface(EG[1], 1), face)
    else
        xgrid[FaceGeometries] = xFaceGeometries
    end
    xgrid[CellFaces] = xCellFaces
    xgrid[CellFaceSigns] = xCellFaceSigns
    xgrid[FaceCells] = reshape(xFaceCells, (2, face))
    return xFaceNodes
end


function ExtendableGrids.instantiate(xgrid::ExtendableGrid{Tc, Ti}, ::Type{NodePatchGroups}) where {Tc, Ti}
    xCellNodes::Adjacency = xgrid[CellNodes]
    xNodeCells = atranspose(xCellNodes)
    nnodes = size(xgrid[Coordinates], 2)
    ncells = num_sources(xCellNodes)
    ncells4node::Ti = 0
    group4node = zeros(Ti, nnodes)
    cgroup::Ti = 0
    cell_in_group = zeros(Bool, ncells)
    take_into = false
    cgroup = 0
    while minimum(group4node) == 0
        cell_in_group .= false
        cgroup += 1
        for node in 1:nnodes
            if group4node[node] == 0
                ncells4node = num_targets(xNodeCells, node)
                take_into = true
                for c in 1:ncells4node
                    if cell_in_group[xNodeCells[c, node]] == true
                        take_into = false
                        break
                    end
                end
                if take_into
                    group4node[node] = cgroup
                    for c in 1:ncells4node
                        cell_in_group[xNodeCells[c, node]] = true
                    end
                end
            end
        end
    end
    return group4node
end


# FaceNodes = nodes for each face (implicitly defines the enumerations of faces)
function ExtendableGrids.instantiate(xgrid::ExtendableGrid{Tc, Ti}, ::Type{EdgeNodes}) where {Tc, Ti}

    xCellNodes = xgrid[CellNodes]
    ncells::Ti = num_sources(xCellNodes)
    nnodes::Ti = num_sources(xgrid[Coordinates])
    xCellGeometries = xgrid[CellGeometries]
    dim::Ti = dim_element(xCellGeometries[1])

    # in 1D edges = cells
    if dim == 1
        xgrid[EdgeNodes] = xgrid[CellNodes]
        xgrid[EdgeGeometries] = xgrid[CellGeometries]
        xgrid[CellEdges] = reshape(collect(Ti, 1:size(xCellNodes, 2)), (1, size(xCellNodes, 2)))
        xgrid[EdgeCells] = xgrid[CellEdges]
        return xgrid[EdgeNodes]
    end

    # in 2D edges = faces
    if dim == 2
        xgrid[CellEdges] = xgrid[CellFaces]
        xgrid[EdgeCells] = xgrid[FaceCells]
        xgrid[EdgeNodes] = xgrid[FaceNodes]
        xgrid[EdgeGeometries] = xgrid[FaceGeometries]
        return xgrid[EdgeNodes]
        #        return  prepare_edges!(xgrid) # keep compatible to VoronoiFVM
    end


    # transpose CellNodes to get NodeCells
    xNodeCells = atranspose(xCellNodes)
    max_ncell4node::Ti = max_num_targets_per_source(xNodeCells)

    # init EdgeCells
    xEdgeCells = VariableTargetAdjacency(Ti)

    # find unique edge enumeration rules for each cell geometry
    EG::Array{ElementGeometries, 1} = unique(xCellGeometries)
    edge_rules::Array{Array{Ti, 2}, 1} = Array{Array{Ti, 2}, 1}(undef, length(EG))
    maxedgenodes::Ti = 0
    for j in 1:length(EG)
        edge_rules[j] = local_celledgenodes(EG[j])
        maxedgenodes = max(size(edge_rules[j], 1), maxedgenodes)
    end

    # pre-allocate xCellEdges and xCellEdgeSigns
    if length(EG) == 1
        singleEG = true
        xCellEdges = zeros(Ti, num_edges(EG[1]), ncells)
        xCellEdgeSigns = zeros(Ti, num_edges(EG[1]), ncells)
    else
        singleEG = false
        xCellEdges = VariableTargetAdjacency(Ti)
        cellEG = xCellGeometries[1]
        for cell in 1:ncells
            cellEG = xCellGeometries[cell]
            append!(xCellEdges, zeros(Ti, num_edges(cellEG)))
        end
        xCellEdgeSigns = deepcopy(xCellEdges)
    end

    # init xEdgeNodes
    xEdgeNodes::Array{Ti, 1} = zeros(Ti, 0)

    edge_rule::Array{Ti, 2} = edge_rules[1]
    edge_rule2::Array{Ti, 2} = edge_rules[1]
    current_item::Array{Ti, 1} = zeros(Ti, 2)
    flag4item::Array{Bool, 1} = zeros(Bool, nnodes)
    cellEG = EG[1]
    node::Ti = 0
    cell2::Ti = 0
    nneighbours::Ti = 0
    edges_per_cell::Ti = num_edges(EG[1])
    edges_per_cell2::Ti = num_edges(EG[1])
    common_nodes::Ti = 0
    cells_with_common_edge::Array{Ti, 1} = zeros(Ti, max_ncell4node)
    pos_in_cells_with_common_edge::Array{Ti, 1} = zeros(Ti, max_ncell4node)
    sign_in_cells_with_common_edge::Array{Ti, 1} = zeros(Ti, max_ncell4node)
    ncells_with_common_edge::Ti = 0
    edge::Ti = 0
    iEG::Ti = 0

    # loop over cells
    for cell in 1:ncells

        # find EG index for geometry
        if singleEG == false
            cellEG = xCellGeometries[cell]
            edges_per_cell = num_edges(cellEG)
            for j in 1:length(EG)
                if cellEG == EG[j]
                    iEG = j
                    break
                end
            end
            edge_rule = edge_rules[iEG]
        end

        # loop over cell edges
        for k in 1:edges_per_cell

            # check if edge is already known to cell
            if xCellEdges[k, cell] > 0
                continue
            end
            ncells_with_common_edge = 1
            cells_with_common_edge[1] = cell
            pos_in_cells_with_common_edge[1] = k
            sign_in_cells_with_common_edge[1] = 1

            # flag edge nodes and commons4cells
            for j in 2:- 1:1
                node = xCellNodes[edge_rule[j, k], cell]
                current_item[j] = node
                flag4item[node] = true
            end

            # get first node and its neighbours
            nneighbours = num_targets(xNodeCells, node)

            # loop over neighbours
            for n in 1:nneighbours
                cell2 = xNodeCells[n, node]

                # skip if cell2 is the same as cell
                if (cell == cell2)
                    continue
                end

                # loop over edges of cell2
                if singleEG == false
                    cellEG = xCellGeometries[cell2]
                    edges_per_cell2 = num_edges(cellEG)

                    # find edge enumeration rule
                    for j in 1:length(EG)
                        if cellEG == EG[j]
                            iEG = j
                            break
                        end
                    end
                    edge_rule2 = edge_rules[iEG]
                end

                for f2 in 1:edges_per_cell2
                    # compare nodes of edge and edge2
                    common_nodes = 0
                    for j in 1:2
                        if flag4item[xCellNodes[edge_rule2[j, f2], cell2]]
                            common_nodes += 1
                        else
                            continue
                        end
                    end

                    # if all nodes are the same, register edge
                    if (common_nodes == 2)
                        ncells_with_common_edge += 1
                        cells_with_common_edge[ncells_with_common_edge] = cell2
                        pos_in_cells_with_common_edge[ncells_with_common_edge] = f2
                        if xCellNodes[edge_rule2[1, f2], cell2] == current_item[1]
                            sign_in_cells_with_common_edge[ncells_with_common_edge] = 1
                        else
                            sign_in_cells_with_common_edge[ncells_with_common_edge] = -1
                        end
                    end
                end
            end

            # register edge
            edge += 1
            for c in 1:ncells_with_common_edge
                xCellEdges[pos_in_cells_with_common_edge[c], cells_with_common_edge[c]] = edge
                xCellEdgeSigns[pos_in_cells_with_common_edge[c], cells_with_common_edge[c]] = sign_in_cells_with_common_edge[c]
            end
            append!(xEdgeCells, view(cells_with_common_edge, 1:ncells_with_common_edge))
            append!(xEdgeNodes, current_item)

            #reset flag4item
            for j in 1:2
                flag4item[current_item[j]] = false
            end
        end
    end
    xgrid[CellEdges] = xCellEdges
    xgrid[EdgeCells] = xEdgeCells
    xgrid[CellEdgeSigns] = xCellEdgeSigns
    xgrid[EdgeGeometries] = VectorOfConstants{ElementGeometries, Int}(Edge1D, edge)
    return reshape(xEdgeNodes, (2, edge))
end


function ExtendableGrids.instantiate(xgrid::ExtendableGrid{Tc, Ti}, ::Type{CellFaceOrientations}) where {Tc, Ti}
    xCellFaceSigns = xgrid[CellFaceSigns]
    xCellGeometries = xgrid[CellGeometries]
    xCellFaces = xgrid[CellFaces]
    xFaceNodes = xgrid[FaceNodes]
    xCellNodes = xgrid[CellNodes]
    ncells = num_sources(xCellNodes)

    EG = unique(xCellGeometries)
    face_rules = Array{Array{Ti, 2}, 1}(undef, length(EG))
    maxfacenodes = 0
    for j in 1:length(EG)
        face_rules[j] = local_cellfacenodes(EG[j])
        maxfacenodes = max(size(face_rules[j], 2), maxfacenodes)
    end
    singleEG = false
    if typeof(xCellFaceSigns) <: VariableTargetAdjacency
        xCellFaceOrientations = deepcopy(xCellFaceSigns)
    else
        singleEG = true
        xCellFaceOrientations = zeros(Ti, size(xCellFaceSigns, 1), size(xCellFaceSigns, 2))
    end

    cellEG = EG[1]
    face_rule = face_rules[1]
    ncellfaces::Ti = 0
    nfacenodes::Ti = 0
    face::Ti = 0
    facenodes = zeros(Ti, maxfacenodes)
    found_configuration::Bool = false
    n::Ti = 0
    iEG::Ti = 0
    for cell in 1:ncells
        cellEG = xCellGeometries[cell]

        # find EG index for geometry
        for j in 1:length(EG)
            if cellEG == EG[j]
                iEG = j
                break
            end
        end
        face_rule = face_rules[iEG] # determines local enumeration of faces

        # determine orientation
        ncellfaces = num_targets(xCellFaces, cell)
        for j in 1:ncellfaces
            face = xCellFaces[j, cell]
            nfacenodes = num_targets(xFaceNodes, face)
            if xCellFaceSigns[j, cell] == 1
                if singleEG == false
                    xCellFaceOrientations.colentries[xCellFaceOrientations.colstart[cell] + j - 1] = 1
                else
                    xCellFaceOrientations[j, cell] = 1
                end
            else
                for k in 1:nfacenodes
                    facenodes[nfacenodes + 1 - k] = xFaceNodes[k, face]
                end
                found_configuration = false
                n = 0
                while !found_configuration
                    n += 1
                    if facenodes[n] == xCellNodes[face_rule[1, j], cell]
                        found_configuration = true
                    end
                end
                n = mod(n - 1, 3) + 1
                if singleEG == false
                    xCellFaceOrientations.colentries[xCellFaceOrientations.colstart[cell] + j - 1] = 1 + n
                else
                    xCellFaceOrientations[j, cell] = 1 + n
                end
            end
        end

    end
    return xCellFaceOrientations
end

# FaceEdges = Edges for each face (in 3D)
function ExtendableGrids.instantiate(xgrid::ExtendableGrid{Tc, Ti}, ::Type{FaceEdges}) where {Tc, Ti}
    xFaceNodes = xgrid[FaceNodes]
    xFaceCells = xgrid[FaceCells]
    xEdgeNodes = xgrid[EdgeNodes]
    xCellEdges = xgrid[CellEdges]
    xFaceEdges = VariableTargetAdjacency(Ti)
    xFaceGeometries = xgrid[FaceGeometries]
    nfaces::Ti = num_sources(xFaceNodes)
    nnodes::Ti = size(xgrid[Coordinates], 2)

    # find unique edge enumeration rules
    EG = unique(xFaceGeometries)
    edge_rules = Array{Array{Ti, 2}, 1}(undef, length(EG))
    maxedgenodes = 0
    for j in 1:length(EG)
        edge_rules[j] = local_cellfacenodes(EG[j]) # face edges are faces of the face
        maxedgenodes = max(size(edge_rules[j], 2), maxedgenodes)
    end
    edge_rule::Array{Ti, 2} = edge_rules[1]
    if length(EG) == 1
        singleEG = true
        xFaceEdges = zeros(Ti, num_edges(EG[1]), nfaces)
        xFaceEdgeSigns = zeros(Ti, num_edges(EG[1]), nfaces)
    else
        singleEG = false
        faceEG = xFaceGeometries[1]
        xFaceEdgeSigns = VariableTargetAdjacency(Ti)
        for face in 1:nfaces
            faceEG = xFaceGeometries[face]
            append!(xFaceEdges, zeros(Ti, num_edges(faceEG)))
            append!(xFaceEdgeSigns, zeros(Ti, num_edges(faceEG)))
        end
    end

    nfacenodes::Ti = num_targets(xFaceNodes, 1)
    ncelledges::Ti = 0
    nedgenodes::Ti = 0
    nfaceedges::Ti = num_edges(EG[1])
    node::Ti = 0
    cell::Ti = 0
    edge::Ti = 0
    faceedge::Ti = 0
    edge_is_in_face::Bool = false
    found_pos::Bool = false
    flag4face = zeros(Bool, nnodes)
    flag4edge = zeros(Bool, nnodes)
    faceEG = EG[1]
    iEG::Ti = 1
    pos::Ti = 0
    for face in 1:nfaces

        if singleEG == false
            faceEG = xFaceGeometries[face]
            nfaceedges = num_edges(faceEG)
            # find EG index for geometry
            for j in 1:length(EG)
                if faceEG == EG[j]
                    iEG = j
                    break
                end
            end
            edge_rule = edge_rules[iEG] # determines local enumeration of face edges
            nfacenodes = num_targets(xFaceNodes, face)
        end

        # mark nodes of face
        for j in 1:nfacenodes
            node = xFaceNodes[j, face]
            flag4face[node] = true
        end


        # find edges in first adjacent cell
        cell = xFaceCells[1, face]
        ncelledges = num_targets(xCellEdges, cell)
        faceedge = 0
        for cedge in 1:ncelledges
            edge = xCellEdges[cedge, cell]
            nedgenodes = num_targets(xEdgeNodes, edge)
            edge_is_in_face = true
            for j in 1:nedgenodes
                if flag4face[xEdgeNodes[j, edge]] == false
                    edge_is_in_face = false
                    break
                end
            end

            if edge_is_in_face

                # register edge
                # it is important obey same local ordering as in edge_rule
                # to ensure correct dof handling (e.g. for P2-FEM on boundary)

                # mark nodes of edge
                for j in 1:nedgenodes
                    node = xEdgeNodes[j, edge]
                    flag4edge[node] = true
                end

                pos = 0
                found_pos = false
                while found_pos == false
                    pos += 1
                    found_pos = true
                    for k in 1:nedgenodes
                        if flag4edge[xFaceNodes[edge_rule[k, pos], face]] == false
                            found_pos = false
                            break
                        end
                    end
                end
                if singleEG
                    xFaceEdges[pos, face] = edge
                    xFaceEdgeSigns[pos, face] = xEdgeNodes[1, edge] == xFaceNodes[edge_rule[1, pos], face] ? 1 : -1
                else
                    xFaceEdges.colentries[xFaceEdges.colstart[face] + pos - 1] = edge
                    xFaceEdgeSigns.colentries[xFaceEdgeSigns.colstart[face] + pos - 1] = xEdgeNodes[1, edge] == xFaceNodes[edge_rule[1, pos], face] ? 1 : -1
                end

                # reset flag4edge
                for j in 1:nedgenodes
                    node = xEdgeNodes[j, edge]
                    flag4edge[node] = false
                end

                faceedge += 1
                if faceedge == nfaceedges
                    break
                end
            end
        end

        #reset flag4face
        for j in 1:nfacenodes
            node = xFaceNodes[j, face]
            flag4face[node] = false
        end

    end

    xgrid[FaceEdgeSigns] = xFaceEdgeSigns
    return xFaceEdges
end


# CellFaces = faces for each cell
function ExtendableGrids.instantiate(xgrid::ExtendableGrid{Tc, Ti}, ::Type{CellFaces}) where {Tc, Ti}
    ExtendableGrids.instantiate(xgrid, FaceNodes)
    return xgrid[CellFaces]
end

function ExtendableGrids.instantiate(xgrid::ExtendableGrid{Tc, Ti}, ::Type{FaceGeometries}) where {Tc, Ti}
    ExtendableGrids.instantiate(xgrid, FaceNodes)
    return xgrid[FaceGeometries]
end

# CellEdges = edges for each cell
function ExtendableGrids.instantiate(xgrid::ExtendableGrid{Tc, Ti}, ::Type{CellEdges}) where {Tc, Ti}
    ExtendableGrids.instantiate(xgrid, EdgeNodes)
    return xgrid[CellEdges]
end

function ExtendableGrids.instantiate(xgrid::ExtendableGrid{Tc, Ti}, ::Type{EdgeCells}) where {Tc, Ti}
    ExtendableGrids.instantiate(xgrid, EdgeNodes)
    return xgrid[EdgeCells]
end


function ExtendableGrids.instantiate(xgrid::ExtendableGrid{Tc, Ti}, ::Type{CellEdgeSigns}) where {Tc, Ti}
    ExtendableGrids.instantiate(xgrid, EdgeNodes)
    return xgrid[CellEdgeSigns]
end


function ExtendableGrids.instantiate(xgrid::ExtendableGrid{Tc, Ti}, ::Type{FaceEdgeSigns}) where {Tc, Ti}
    ExtendableGrids.instantiate(xgrid, FaceEdges)
    return xgrid[FaceEdgeSigns]
end

function ExtendableGrids.instantiate(xgrid::ExtendableGrid{Tc, Ti}, ::Type{CellFaceSigns}) where {Tc, Ti}
    ExtendableGrids.instantiate(xgrid, FaceNodes)
    return xgrid[CellFaceSigns]
end

function collectVolumes4Geometries(xgrid::ExtendableGrid{Tc, Ti}, ItemType) where {Tc, Ti}
    # get links to other stuff
    xCoordinates = xgrid[Coordinates]
    xCoordinateSystem = xgrid[CoordinateSystem]
    xItemNodes = xgrid[GridComponent4TypeProperty(ItemType, PROPERTY_NODES)]
    xGeometries = xgrid[GridComponent4TypeProperty(ItemType, PROPERTY_GEOMETRY)]
    nitems = num_sources(xItemNodes)

    # keep existing volume array if possible
    if haskey(xgrid.components, GridComponent4TypeProperty(ItemType, PROPERTY_VOLUME))
        xVolumes = xgrid[GridComponent4TypeProperty(ItemType, PROPERTY_VOLUME)]
    else
        xVolumes = zeros(Tc, nitems)
    end

    # Introduce a function barrier: this will be compiled for each different type
    # of coordinate systems.
    function barrier!(xVolumes, xCoordinateSystem)
        for item in 1:nitems
            xVolumes[item] = volume(xCoordinates, xItemNodes, item, xGeometries[item], xCoordinateSystem)
        end
        return
    end
    nalloc = @allocated barrier!(xVolumes, xCoordinateSystem)
    nalloc > 0 && @warn " $nalloc allocations during $ItemType volume calculation"
    return xVolumes
end


function ExtendableGrids.instantiate(xgrid::ExtendableGrid{Tc, Ti}, ::Type{CellVolumes}) where {Tc, Ti}
    return collectVolumes4Geometries(xgrid, ITEMTYPE_CELL)
end

function ExtendableGrids.instantiate(xgrid::ExtendableGrid{Tc, Ti}, ::Type{FaceVolumes}) where {Tc, Ti}
    return collectVolumes4Geometries(xgrid, ITEMTYPE_FACE)
end

function ExtendableGrids.instantiate(xgrid::ExtendableGrid{Tc, Ti}, ::Type{BFaceVolumes}) where {Tc, Ti}
    return collectVolumes4Geometries(xgrid, ITEMTYPE_BFACE)
end

function ExtendableGrids.instantiate(xgrid::ExtendableGrid{Tc, Ti}, ::Type{EdgeVolumes}) where {Tc, Ti}
    return collectVolumes4Geometries(xgrid, ITEMTYPE_EDGE)
end

function ExtendableGrids.instantiate(xgrid::ExtendableGrid{Tc, Ti}, ::Type{BEdgeVolumes}) where {Tc, Ti}
    return collectVolumes4Geometries(xgrid, ITEMTYPE_BEDGE)
end


function ExtendableGrids.instantiate(xgrid::ExtendableGrid{Tc, Ti}, ::Type{BFaceFaces}) where {Tc, Ti}
    # get links to other stuff
    xCoordinates = xgrid[Coordinates]
    xFaceNodes = xgrid[FaceNodes]
    xBFaceNodes = xgrid[BFaceNodes]
    nnodes::Ti = num_sources(xCoordinates)
    nbfaces::Ti = num_sources(xBFaceNodes)

    # init BFaceFaces
    xBFaceFaces::Array{Ti, 1} = zeros(Ti, nbfaces)
    #xBFaceGeometries = xgrid[BFaceGeometries]
    #if typeof(xBFaceGeometries) == VectorOfConstants{ElementGeometries}
    #    EG = xBFaceGeometries[1]
    #    xBFaceGeometries = Array{ElementGeometries,1}(undef,nbfaces)
    #    for j = 1 : nbfaces
    #        xBFaceGeometries[j] = EG
    #    end
    #end

    # transpose FaceNodes to get NodeFaces
    xNodeFaces = atranspose(xFaceNodes)

    flag4item::Array{Bool, 1} = zeros(Bool, nnodes)
    nodes_per_bface::Ti = 0
    nodes_per_face::Ti = 0
    common_nodes::Ti = 0
    node::Ti = 0
    nneighbours::Ti = 0
    for bface in 1:nbfaces
        nodes_per_bface = num_targets(xBFaceNodes, bface)
        for j in 1:nodes_per_bface
            node = xBFaceNodes[j, bface]
            flag4item[node] = true
        end

        # get faces for last node of bface
        nneighbours = num_targets(xNodeFaces, node)

        # loop over faces and find the one that matches the bface
        for n in 1:nneighbours
            face = xNodeFaces[n, node]
            nodes_per_face = num_targets(xFaceNodes, face)
            common_nodes = 0
            for k in 1:nodes_per_face
                if flag4item[xFaceNodes[k, face]] == true
                    common_nodes += 1
                else
                    break
                end
            end
            if common_nodes == nodes_per_face
                xBFaceFaces[bface] = face
                break
            end
        end

        if xBFaceFaces[bface] == 0
            println("WARNING(BFaceFaces): found no matching face for bface $bface with nodes $(xBFaceNodes[:, bface])")
        end

        for j in 1:nodes_per_bface
            flag4item[xBFaceNodes[j, bface]] = false
        end
    end

    # enforce that BFaceNodes have same ordering as FaceNodes
    newBFaceNodes = deepcopy(xBFaceNodes)
    for bface in 1:nbfaces
        nodes_per_face = num_targets(xBFaceNodes, bface)
        for j in 1:nodes_per_bface
            if typeof(xBFaceNodes) <: VariableTargetAdjacency
                newBFaceNodes.colentries[newBFaceNodes.colstart[bface] + j - 1] = xFaceNodes[j, xBFaceFaces[bface]]
            else
                newBFaceNodes[j, bface] = xFaceNodes[j, xBFaceFaces[bface]]
            end
        end
    end
    xgrid[BFaceNodes] = newBFaceNodes

    # xgrid[BFaceGeometries] = xBFaceGeometries
    return xBFaceFaces
end


function instantiate(xgrid::ExtendableGrid{Tc, Ti}, ::Type{BEdgeNodes}) where {Tc, Ti}

    dim = size(xgrid[Coordinates], 1)
    if dim == 1
        xgrid[BEdgeEdges] = zeros(Ti, 0)
        xgrid[BEdgeNodes] = zeros(Ti, 0, 0)
        return xgrid[BEdgeNodes]
    end

    if dim == 2
        xgrid[BEdgeEdges] = xgrid[BFaceFaces]
        xgrid[BEdgeNodes] = xgrid[BFaceNodes]
        return xgrid[BEdgeNodes]
    end

    xBFaceFaces = xgrid[BFaceFaces]
    xEdgeNodes = xgrid[EdgeNodes]
    xFaceEdges = xgrid[FaceEdges]
    xBFaceGeometries = xgrid[BFaceGeometries]
    nbfaces = length(xBFaceFaces)
    xBEdgeEdges = zeros(Ti, 0)

    EG = Triangle2D
    edge::Ti = 0
    face::Ti = 0
    nfaceedges::Ti = 0

    for bface in 1:nbfaces
        EG = xBFaceGeometries[bface]
        nfaceedges = num_edges(EG)
        face = xBFaceFaces[bface]
        for k in 1:nfaceedges
            edge = xFaceEdges[k, face]
            if !(edge in xBEdgeEdges)
                push!(xBEdgeEdges, edge)
            end

        end
    end

    nbedges = length(xBEdgeEdges)
    xBEdgeNodes = zeros(Ti, 2, nbedges)
    for bedge in 1:nbedges, k in 1:2
        xBEdgeNodes[k, bedge] = xEdgeNodes[k, xBEdgeEdges[bedge]]
    end

    xgrid[BEdgeEdges] = xBEdgeEdges
    return xBEdgeNodes
end


function ExtendableGrids.instantiate(xgrid::ExtendableGrid{Tc, Ti}, ::Type{BEdgeEdges}) where {Tc, Ti}
    ExtendableGrids.instantiate(xgrid, BEdgeNodes)
    return xgrid[BEdgeEdges]
end


function ExtendableGrids.instantiate(xgrid::ExtendableGrid{Tc, Ti}, ::Type{FaceCells}) where {Tc, Ti}
    ExtendableGrids.instantiate(xgrid, FaceNodes)
    return xgrid[FaceCells]
end

function ExtendableGrids.instantiate(xgrid::ExtendableGrid{Tc, Ti}, ::Type{FaceRegions}) where {Tc, Ti}
    # interior faces get region number 0, boundary faces get their boundary region
    xBFaceFaces = xgrid[BFaceFaces]
    xBFaceRegions = xgrid[BFaceRegions]
    xFaceRegions = zeros(Ti, num_sources(xgrid[FaceNodes]))
    for j in 1:length(xBFaceFaces)
        xFaceRegions[xBFaceFaces[j]] = xBFaceRegions[j]
    end
    return xFaceRegions
end


### Not a good idea to have them as vectors of constants
function ExtendableGrids.instantiate(xgrid::ExtendableGrid{Tc, Ti}, ::Type{EdgeRegions}) where {Tc, Ti}
    return VectorOfConstants(Ti(0), num_sources(xgrid[EdgeNodes]))
end

function ExtendableGrids.instantiate(xgrid::ExtendableGrid{Tc, Ti}, ::Type{BEdgeRegions}) where {Tc, Ti}
    return Array{Int32, 1}(1:num_bedges(xgrid))
end

function ExtendableGrids.instantiate(xgrid::ExtendableGrid{Tc, Ti}, ::Type{EdgeGeometries}) where {Tc, Ti}
    return VectorOfConstants{ElementGeometries, Ti}(Edge1D, num_sources(xgrid[EdgeNodes]))
end

function ExtendableGrids.instantiate(xgrid::ExtendableGrid{Tc, Ti}, ::Type{BEdgeGeometries}) where {Tc, Ti}
    return VectorOfConstants{ElementGeometries, Ti}(Edge1D, num_sources(xgrid[BEdgeNodes]))
end


function ExtendableGrids.instantiate(xgrid::ExtendableGrid{Tc, Ti}, ::Type{BFaceCellPos}) where {Tc, Ti}
    # gets the local position of a bface in the CellFaces row of its adjacent cell

    # get links to other stuff
    xCellFaces = xgrid[CellFaces]
    xFaceCells = xgrid[FaceCells]
    xBFaceFaces::Array{Ti, 1} = xgrid[BFaceFaces]
    nbfaces = length(xBFaceFaces)

    # init BFaceFaces
    xBFaceCellPos = zeros(Ti, nbfaces)

    cface = 0
    cell = 0
    nfaces4cell = 0
    for bface in 1:nbfaces
        cface = xBFaceFaces[bface]
        cell = xFaceCells[1, cface]
        nfaces4cell = num_targets(xCellFaces, cell)
        for face in 1:nfaces4cell
            if cface == xCellFaces[face, cell]
                xBFaceCellPos[bface] = face
                break
            end
        end
    end

    return xBFaceCellPos
end


function ExtendableGrids.instantiate(xgrid::ExtendableGrid{Tc, Ti}, ::Type{FaceNormals}) where {Tc, Ti}
    dim::Int = size(xgrid[Coordinates], 1)
    xCoordinates::Array{Tc, 2} = xgrid[Coordinates]
    xFaceNodes::Adjacency{Ti} = xgrid[FaceNodes]
    nfaces::Int = num_sources(xFaceNodes)
    xFaceGeometries::GridEGTypes = xgrid[FaceGeometries]
    xCoordinateSystem::Type{<:AbstractCoordinateSystem} = xgrid[CoordinateSystem]

    xFaceNormals::Array{Tc, 2} = haskey(xgrid.components, FaceNormals) ? xgrid[FaceNormals] : zeros(Tc, dim, nfaces)

    normal::Array{Tc, 1} = zeros(Tc, dim)
    EG = xFaceGeometries[1]
    for face in 1:nfaces
        EG = xFaceGeometries[face]
        Normal4ElemType!(normal, xCoordinates, xFaceNodes, face, EG, xCoordinateSystem)
        for k in 1:dim
            xFaceNormals[k, face] = normal[k]
        end
    end
    return xFaceNormals
end


function ExtendableGrids.instantiate(xgrid::ExtendableGrid{Tc, Ti}, ::Type{EdgeTangents}) where {Tc, Ti}
    dim::Int = size(xgrid[Coordinates], 1)
    xCoordinates::Array{Tc, 2} = xgrid[Coordinates]
    xEdgeNodes::Adjacency{Ti} = xgrid[EdgeNodes]
    nedges::Int = num_sources(xEdgeNodes)
    xEdgeGeometries::GridEGTypes = xgrid[EdgeGeometries]
    xCoordinateSystem::Type{<:AbstractCoordinateSystem} = xgrid[CoordinateSystem]

    xEdgeTangents::Array{Tc, 2} = haskey(xgrid.components, EdgeTangents) ? xgrid[EdgeTangents] : zeros(Tc, dim, nedges)

    EG = xEdgeGeometries[1]
    tangent::Array{Tc, 1} = zeros(Tc, dim)
    for edge in 1:nedges
        EG = xEdgeGeometries[edge]
        Tangent4ElemType!(tangent, xCoordinates, xEdgeNodes, edge, EG, xCoordinateSystem)
        for k in 1:dim
            xEdgeTangents[k, edge] = tangent[k]
        end
    end
    return xEdgeTangents
end

function ExtendableGrids.instantiate(xgrid::ExtendableGrid{Tc, Ti}, ::Type{UniqueCellGeometries}) where {Tc, Ti}
    return xUniqueCellGeometries = ElementGeometries[unique(xgrid[CellGeometries])...]
end

function ExtendableGrids.instantiate(xgrid::ExtendableGrid{Tc, Ti}, ::Type{UniqueFaceGeometries}) where {Tc, Ti}
    return xUniqueFaceGeometries = ElementGeometries[unique(xgrid[FaceGeometries])...]
end

function ExtendableGrids.instantiate(xgrid::ExtendableGrid{Tc, Ti}, ::Type{UniqueBFaceGeometries}) where {Tc, Ti}
    return xUniqueBFaceGeometries = ElementGeometries[unique(xgrid[BFaceGeometries])...]
end

function ExtendableGrids.instantiate(xgrid::ExtendableGrid{Tc, Ti}, ::Type{UniqueEdgeGeometries}) where {Tc, Ti}
    return xUniqueEdgeGeometries = ElementGeometries[unique(xgrid[EdgeGeometries])...]
end

function ExtendableGrids.instantiate(xgrid::ExtendableGrid{Tc, Ti}, ::Type{UniqueBEdgeGeometries}) where {Tc, Ti}
    return xUniqueBEdgeGeometries = ElementGeometries[unique(xgrid[BEdgeGeometries])...]
end


function ExtendableGrids.instantiate(xgrid::ExtendableGrid{Tc, Ti}, ::Type{CellAssemblyGroups}) where {Tc, Ti}
    xGeometryGroups = VariableTargetAdjacency(Ti)
    xCellGeometries = xgrid[CellGeometries]
    xUniqueCellGeometries = xgrid[UniqueCellGeometries]
    for EG in xUniqueCellGeometries
        append!(xGeometryGroups, findall(==(EG), xCellGeometries))
    end
    return xGeometryGroups
end

function ExtendableGrids.instantiate(xgrid::ExtendableGrid{Tc, Ti}, ::Type{FaceAssemblyGroups}) where {Tc, Ti}
    xGeometryGroups = VariableTargetAdjacency(Ti)
    xFaceGeometries = xgrid[FaceGeometries]
    xUniqueFaceGeometries = xgrid[UniqueFaceGeometries]
    for EG in xUniqueFaceGeometries
        append!(xGeometryGroups, findall(==(EG), xFaceGeometries))
    end
    return xGeometryGroups
end

function ExtendableGrids.instantiate(xgrid::ExtendableGrid{Tc, Ti}, ::Type{BFaceAssemblyGroups}) where {Tc, Ti}
    xGeometryGroups = VariableTargetAdjacency(Ti)
    xBFaceGeometries = xgrid[BFaceGeometries]
    xUniqueBFaceGeometries = xgrid[UniqueBFaceGeometries]
    for EG in xUniqueBFaceGeometries
        append!(xGeometryGroups, findall(==(EG), xBFaceGeometries))
    end
    return xGeometryGroups
end


function ExtendableGrids.instantiate(xgrid::ExtendableGrid{Tc, Ti}, ::Type{EdgeAssemblyGroups}) where {Tc, Ti}
    xGeometryGroups = VariableTargetAdjacency(Ti)
    xEdgeGeometries = xgrid[EdgeGeometries]
    xUniqueEdgeGeometries = xgrid[UniqueEdgeGeometries]
    for EG in xUniqueEdgeGeometries
        append!(xGeometryGroups, findall(==(EG), xEdgeGeometries))
    end
    return xGeometryGroups
end

function ExtendableGrids.instantiate(xgrid::ExtendableGrid{Tc, Ti}, ::Type{BEdgeAssemblyGroups}) where {Tc, Ti}
    xGeometryGroups = VariableTargetAdjacency(Ti)
    xBEdgeGeometries = xgrid[BEdgeGeometries]
    xUniqueBEdgeGeometries = xgrid[UniqueBEdgeGeometries]
    for EG in xUniqueBEdgeGeometries
        append!(xGeometryGroups, findall(==(EG), xBEdgeGeometries))
    end
    return xGeometryGroups
end
