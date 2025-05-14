using WriteVTK

# conversion from AbstractElementGeometry to WriteVTK.VTKCellTypes
WriteVTK.VTKCellType(::Type{<:AbstractElementGeometry1D}) = VTKCellTypes.VTK_LINE
WriteVTK.VTKCellType(::Type{<:Triangle2D}) = VTKCellTypes.VTK_TRIANGLE
WriteVTK.VTKCellType(::Type{<:Quadrilateral2D}) = VTKCellTypes.VTK_QUAD
WriteVTK.VTKCellType(::Type{<:Tetrahedron3D}) = VTKCellTypes.VTK_TETRA
WriteVTK.VTKCellType(::Type{<:Hexahedron3D}) = VTKCellTypes.VTK_HEXAHEDRON

"""
$(TYPEDSIGNATURES)

exports grid and optional provided data as a vtk file

- `filename`: filename of the exported file
- `grid`: grid

Each '(key, value)' pair adds another data entry to the vtk file via WriteVTK functionality.

For the arguments 'append' and 'compress', see documentation of vtk_grid of WriteVTK.
"""
function writeVTK(filename::String, grid::ExtendableGrid{Tc, Ti}; append = false, compress = false, kwargs...) where {Tc, Ti}
    ncells = num_cells(grid)   # get number of cells in grid
    coords = grid[Coordinates] # get coordinates
    cells = grid[CellNodes]   # get cell-node list
    geo_dim = size(coords, 1)

    cell_geo = grid[CellGeometries]

    vtk_cells = Array{MeshCell, 1}(undef, ncells)

    for icell in 1:ncells
        vtk_cells[icell] = MeshCell(VTKCellType(cell_geo[icell]), view(cells, :, icell))
    end

    return vtk_grid(filename, coords, vtk_cells, append = append, compress = compress) do vtk
        for (key, value) in kwargs
            vtk[String(key)] = value
        end
    end
end

"""
$(TYPEDSIGNATURES)
  
Write grid to file. 
Supported formats:
- "*.sg": pdelib sg format. See [`simplexgrid(::String;kwargs...)`](@ref)
        
"""
function Base.write(fname::String, g::ExtendableGrid; format = "", kwargs...)
    (fbase, fext) = splitext(fname)
    if format == ""
        format = fext[2:end]
    end
    return try
        writegrid(fname, g, Val{Symbol(format)}; kwargs...)
    catch e
        throw(ErrorException("Writing $(fext) files not supported"))
    end
end

function writegrid(filename::String, g::ExtendableGrid, ::Type{Val{:msh}}; kwargs...)
    return try
        simplexgrid_to_gmsh(g; filename)
    catch e
        throw(ErrorException("Missing Gmsh extension. Add Gmsh.jl to your environment and import it to write msh files."))
    end
end

function writegrid(fname::String, g::ExtendableGrid, ::Type{Val{:sg}}; version = v"2.2", kwargs...)
    dim_g = dim_grid(g)
    dim_s = dim_space(g)
    nn = num_nodes(g)
    nc = num_cells(g)
    nbf = num_bfaces(g)
    coord = g[Coordinates]
    cellnodes = g[CellNodes]
    bfacenodes = g[BFaceNodes]
    cellregions = g[CellRegions]
    bfaceregions = g[BFaceRegions]

    # TODO: replace @sprintf by something non-allocating
    open(fname, "w") do file
        write(file, @sprintf("SimplexGrid"))
        write(file, @sprintf(" "))
        write(file, @sprintf("%s\n", "$version"[1:(end - 2)]))
        write(file, @sprintf("#created by ExtendableGrids.jl (c) J.Fuhrmann et al\n"))
        write(file, @sprintf("#%s\n", Dates.format(Dates.now(), "yyyy-mm-ddTHH-mm-SS")))

        write(file, @sprintf("DIMENSION %d\n", dim_g))
        write(file, @sprintf("NODES %d %d\n", nn, dim_s))

        for inode in 1:nn
            for idim in 1:dim_s
                write(file, @sprintf("%.20e ", coord[idim, inode]))
                write(file, @sprintf("\n"))
            end
        end

        write(file, @sprintf("CELLS %d\n", nc))
        for icell in 1:nc
            for inode in 1:(dim_g + 1)
                write(file, @sprintf("%d ", cellnodes[inode, icell]))
            end
            write(file, @sprintf("%d\n", cellregions[icell]))
        end

        write(file, @sprintf("FACES %d\n", nbf))
        for ibface in 1:nbf
            for inode in 1:dim_g
                write(file, @sprintf("%d ", bfacenodes[inode, ibface]))
            end
            write(file, @sprintf("%d\n", bfaceregions[ibface]))
        end

        if version > v"2.1"
            function writeitems(key, label)
                data = g[key]
                write(file, "$(label) $(length(data))\n")
                for d in data
                    write(file, "$d\n")
                end
                return
            end
            writeitems(PColorPartitions, "PCOLORPARTITIONS")
            writeitems(PartitionCells, "PARTITIONCELLS")
            writeitems(PartitionBFaces, "PARTITIONBFACES")
            writeitems(PartitionNodes, "PARTITIONNODES")
        end
        write(file, @sprintf("END\n"))
        flush(file)
        flush(file)
    end
    return nothing
end

######################################################
"""
$(TYPEDSIGNATURES)
  
Read grid from file. 
Supported formats:
- "*.sg": pdelib sg files. Format versions:
  - `format=v"2.0"`:  long version with some unnecessary data
  - `format=v"2.1"`: shortened version only with cells, cellnodes, cellregions, bfacenodes, bfaceregions
  - `format=v"2.2"`: like 2.1, but additional info on cell and node partitioning. Edge partitioning is not
    stored in the file and may be re-established by [`induce_edge_partitioning!`](@ref).
- "*.geo": gmsh geometry description (requires `using Gmsh`)
- "*.msh": gmsh mesh (requires `using Gmsh`)
"""
function simplexgrid(file::String; format = "", kwargs...)
    (fbase, fext) = splitext(file)
    if format == ""
        format = fext[2:end]
    end
    return try
        simplexgrid(file, Val{Symbol(format)}; kwargs...)
    catch e
        throw(ErrorException("Reading $(fext) files not supported"))
    end
end

function simplexgrid(file::String, ::Type{Val{:msh}}; kwargs...)
    return try
        simplexgrid_from_gmsh(file)
    catch e
        throw(ErrorException("Missing Gmsh extension. Add Gmsh.jl to your environment and import it to read msh files."))
    end
end

function simplexgrid(file::String, ::Type{Val{:geo}}; kwargs...)
    return try
        simplexgrid_from_gmsh(file)
    catch e
        throw(ErrorException("Missing Gmsh extension. Add Gmsh.jl to your environment and import it to read geo files."))
    end
end

function simplexgrid(file::String, ::Type{Val{:sg}}; kwargs...)
    Ti = Cint
    tks = TokenStream(file)
    expecttoken(tks, "SimplexGrid")
    version = VersionNumber(gettoken(tks))

    if version < v"2.0" || version >= v"2.3"
        error("Read grid: wrong format version: $(version)")
    end

    dim::Ti = 0
    coord = Array{Float64, 2}(undef, 0, 0)
    cells = Array{Ti, 2}(undef, 0, 0)
    regions = Array{Ti, 1}(undef, 0)
    faces = Array{Ti, 2}(undef, 0, 0)
    bregions = Array{Ti, 1}(undef, 0)

    pcolorpartitions = Array{Ti, 1}(undef, 0)
    partitioncells = Array{Ti, 1}(undef, 0)
    partitionbfaces = Array{Ti, 1}(undef, 0)
    partitionnodes = Array{Ti, 1}(undef, 0)


    while (true)
        if (trytoken(tks, "DIMENSION"))
            dim = parse(Ti, gettoken(tks))
        elseif (trytoken(tks, "NODES"))
            nnodes = parse(Ti, gettoken(tks))
            embdim = parse(Ti, gettoken(tks))
            if (dim != embdim)
                error("Dimension error (DIMENSION $(dim)) in section NODES")
            end
            coord = Array{Float64, 2}(undef, dim, nnodes)
            for inode in 1:nnodes
                for idim in 1:embdim
                    coord[idim, inode] = parse(Float64, gettoken(tks))
                end
            end
        elseif (trytoken(tks, "CELLS"))
            ncells = parse(Ti, gettoken(tks))
            cells = Array{Ti, 2}(undef, dim + 1, ncells)
            regions = Array{Ti, 1}(undef, ncells)
            for icell in 1:ncells
                for inode in 1:(dim + 1)
                    cells[inode, icell] = parse(Ti, gettoken(tks))
                end
                regions[icell] = parse(Ti, gettoken(tks))
                if version == v"2.0"
                    for j in 1:(dim + 1)
                        gettoken(tks)  # skip file format garbage
                    end
                end
            end
        elseif (trytoken(tks, "FACES"))
            nfaces = parse(Ti, gettoken(tks))
            faces = Array{Ti, 2}(undef, dim, nfaces)
            bregions = Array{Ti, 1}(undef, nfaces)
            for iface in 1:nfaces
                for inode in 1:dim
                    faces[inode, iface] = parse(Ti, gettoken(tks))
                end
                bregions[iface] = parse(Ti, gettoken(tks))
                if version == v"2.0"
                    for j in 1:(dim + 2)
                        gettoken(tks) #skip file format garbage
                    end
                end
            end
        elseif trytoken(tks, "PCOLORPARTITIONS") && version > v"2.1"
            n = parse(Ti, gettoken(tks))
            pcolorpartitions = [parse(Ti, gettoken(tks)) for i in 1:n]
        elseif trytoken(tks, "PARTITIONCELLS") && version > v"2.1"
            n = parse(Ti, gettoken(tks))
            partitioncells = [parse(Ti, gettoken(tks)) for i in 1:n]
        elseif trytoken(tks, "PARTITIONBFACES") && version > v"2.1"
            n = parse(Ti, gettoken(tks))
            partitionbfaces = [parse(Ti, gettoken(tks)) for i in 1:n]
        elseif trytoken(tks, "PARTITIONNODES") && version > v"2.1"
            n = parse(Ti, gettoken(tks))
            partitionnodes = [parse(Ti, gettoken(tks)) for i in 1:n]
        else
            expecttoken(tks, "END")
            break
        end
    end
    g = simplexgrid(coord, cells, regions, faces, bregions)
    if version > v"2.1"
        g[PColorPartitions] = pcolorpartitions
        g[PartitionCells] = partitioncells
        g[PartitionBFaces] = partitionbfaces
        g[PartitionNodes] = partitionnodes
    end
    return g
end

function simplexgrid_from_gmsh end

function simplexgrid_to_gmsh end

function mixedgrid_from_gmsh end

function mixedgrid_to_gmsh end
