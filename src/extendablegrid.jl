##################################################################
# Abstract types

"""
$(TYPEDEF)
Apex type for grid components.
"""
abstract type AbstractGridComponent <: AbstractExtendableGridApexType end

"""
$(TYPEDEF)

Grid type wrapping Dict
"""
mutable struct ExtendableGrid{Tc, Ti}
    components::Dict{Type{<:AbstractGridComponent}, Any}
    ExtendableGrid{Tc, Ti}() where {Tc, Ti} = new(Dict{Type{<:AbstractGridComponent}, Any}())
end

"""
````
Base.getindex(grid::ExtendableGrid,T::Type{<:AbstractGridComponent})
````

Generic method for obtaining grid component.

This method is mutating in the sense that non-existing grid components
are created on demand.

Due to the fact that components are stored as Any the return
value triggers type instability. To prevent this, specialized methods must be (and are) defined.
"""
Base.getindex(grid::ExtendableGrid, T::Type{<:AbstractGridComponent}) = get!(grid, T)

"""
````
const ElementInfo{T}=Union{Vector{T},VectorOfConstants{T}}
````

Union type for element information arrays. If all elements have
the same information, it can be stored in an economical form
as a [`VectorOfConstants`](@ref).
"""
const ElementInfo{T} = Union{Vector{T}, VectorOfConstants{T}}

"""
$(TYPEDEF)
1D Array of floating point data
"""
abstract type AbstractGridFloatArray1D <: AbstractGridComponent end

function Base.getindex(grid::ExtendableGrid{Tc, Ti}, T::Type{<:AbstractGridFloatArray1D})::Array{Tc, 1} where {Tc, Ti}
    return get!(grid, T)
end

"""
$(TYPEDEF)
2D Array of floating point data
"""
abstract type AbstractGridFloatArray2D <: AbstractGridComponent end

function Base.getindex(grid::ExtendableGrid{Tc, Ti}, T::Type{<:AbstractGridFloatArray2D})::Array{Tc, 2} where {Tc, Ti}
    return get!(grid, T)
end

"""
$(TYPEDEF)
1D Array of integer data
"""
abstract type AbstractGridIntegerArray1D <: AbstractGridComponent end

function Base.getindex(grid::ExtendableGrid{Tc, Ti}, T::Type{<:AbstractGridIntegerArray1D})::Array{Ti, 1} where {Tc, Ti}
    return get!(grid, T)
end

"""
$(TYPEDEF)
2D Array of integer data
"""
abstract type AbstractGridIntegerArray2D <: AbstractGridComponent end

function Base.getindex(grid::ExtendableGrid{Tc, Ti}, T::Type{<:AbstractGridIntegerArray2D})::Array{Ti, 1} where {Tc, Ti}
    return get!(grid, T)
end

"""
$(TYPEDEF)
Integer number
"""
abstract type AbstractGridIntegerConstant <: AbstractGridComponent end

function Base.getindex(grid::ExtendableGrid{Tc, Ti}, T::Type{<:AbstractGridIntegerConstant})::Ti where {Tc, Ti}
    return get!(grid, T)
end

"""
$(TYPEDEF)
Floating point number
"""
abstract type AbstractGridFloatConstant <: AbstractGridComponent end

function Base.getindex(grid::ExtendableGrid{Tc, Ti}, T::Type{<:AbstractGridFloatConstant})::Tc where {Tc, Ti}
    return get!(grid, T)
end

"""
$(TYPEDEF)

Any kind of adjacency between grid components
"""
abstract type AbstractGridAdjacency <: AbstractGridComponent end

function Base.getindex(grid::ExtendableGrid{Tc, Ti}, T::Type{<:AbstractGridAdjacency})::Adjacency{Ti} where {Tc, Ti}
    return get!(grid, T)
end

"""
$(TYPEDEF)

Array of element geometry information. 
"""
abstract type AbstractElementGeometries <: AbstractGridComponent end

function Base.getindex(
        grid::ExtendableGrid{Tc, Ti},
        T::Type{<:AbstractElementGeometries}
    )::ElementInfo{ElementGeometries} where {Tc, Ti}
    return get!(grid, T)
end

"""
$(TYPEDEF)

Array of element region number information. 
"""
abstract type AbstractElementRegions <: AbstractGridComponent end

function Base.getindex(grid::ExtendableGrid{Tc, Ti}, T::Type{<:AbstractElementRegions})::ElementInfo{Ti} where {Tc, Ti}
    return get!(grid, T)
end

"""
$(TYPEDEF)

Coordinate system
"""
abstract type CoordinateSystem <: AbstractGridComponent end

function Base.getindex(grid::ExtendableGrid{Tc, Ti}, T::Type{CoordinateSystem})::CoordinateSystems where {Tc, Ti}
    return get!(grid, T)
end

##################################################################
# Component key types: for these, access is  type stable

"""
$(TYPEDEF)

Node coordinates
"""
abstract type Coordinates <: AbstractGridFloatArray2D end

"""
$(TYPEDEF)

Adjacency describing nodes per grid cell
"""
abstract type CellNodes <: AbstractGridAdjacency end

"""
$(TYPEDEF)

Adjacency describing nodes per grid boundary face
"""
abstract type BFaceNodes <: AbstractGridAdjacency end

"""
$(TYPEDEF)

Description of cell geometries
"""
abstract type CellGeometries <: AbstractElementGeometries end

"""
Description of boundary face geometries

$(TYPEDEF)
"""
abstract type BFaceGeometries <: AbstractElementGeometries end

"""
$(TYPEDEF)

Cell region number per cell
"""
abstract type CellRegions <: AbstractElementRegions end

"""
$(TYPEDEF)

Boundary region number per boundary face
"""
abstract type BFaceRegions <: AbstractElementRegions end

"""
$(TYPEDEF)

Number of cell regions
"""
abstract type NumCellRegions <: AbstractGridIntegerConstant end

"""
$(TYPEDEF)

Number of boundary face regions 
"""
abstract type NumBFaceRegions <: AbstractGridIntegerConstant end

"""
$(TYPEDEF)

Boundary edge region number per boundary edge
"""
abstract type BEdgeRegions <: AbstractElementRegions end

"""
$(TYPEDEF)

Number of boundary edge regions 
"""
abstract type NumBEdgeRegions <: AbstractGridIntegerConstant end

############################################################
# Generic component methods

"""
$(TYPEDSIGNATURES)
Default veryform method.

"veryform"  means "verify and/or transform"  and is called to check
and possibly transform components to be added to the grid via `setindex!`.

The default method just passes data through.
"""
veryform(grid::ExtendableGrid, v, ::Type{<:AbstractGridComponent}) = v

"""
$(TYPEDSIGNATURES)

Set new grid component
"""
Base.setindex!(grid::ExtendableGrid, v, T::Type{<:AbstractGridComponent}) = grid.components[T] = veryform(grid, v, T)

"""
$(TYPEDSIGNATURES)

Remove grid component
"""
Base.delete!(grid::ExtendableGrid, T::Type{<:AbstractGridComponent}) = delete!(grid.components, T)

"""
$(TYPEDSIGNATURES)

Reinstantiate grid component (only if it exists)
"""
update!(grid::ExtendableGrid, T::Type{<:AbstractGridComponent}) = haskey(grid, T) ? instantiate(grid, T) : nothing

"""
$(TYPEDSIGNATURES)

To be called by getindex. This triggers lazy creation of 
non-existing gridcomponents
"""
Base.get!(grid::ExtendableGrid, T::Type{<:AbstractGridComponent}) = get!(
    () -> veryform(grid, instantiate(grid, T), T),
    grid.components, T
)

"""
$(TYPEDSIGNATURES)

"Hook" for methods instantiating lazy components. 
"""
function instantiate end

############################################################
# Verification of inserted data

"""
````
veryform(grid::ExtendableGrid{Tc,Ti},v,T::Type{<:AbstractGridAdjacency}) where{Tc,Ti}
````

Check proper type of adjacencies upon insertion
"""
veryform(grid::ExtendableGrid{Tc, Ti}, v, T::Type{<:AbstractGridAdjacency}) where {Tc, Ti} = typeof(v) <: Adjacency{Ti} ? v :
    throw("Type mismatch")

############################################################
# Instantiation methods

"""
$(TYPEDSIGNATURES)

Instantiate number of cell regions
"""
instantiate(grid, ::Type{NumCellRegions}) = maximum(grid[CellRegions])

"""
$(TYPEDSIGNATURES)

Instantiate number of bface regions
"""
instantiate(grid, ::Type{NumBFaceRegions}) = length(grid[BFaceRegions]) > 0 ? maximum(grid[BFaceRegions]) : 0

"""
$(TYPEDSIGNATURES)

Instantiate number of boundary edge regions
"""
instantiate(grid, ::Type{NumBEdgeRegions}) = maximum(grid[BEdgeRegions])

function prepare_bedgeregions!(grid::ExtendableGrid)
    bedges = grid[BEdgeNodes]
    bedgeregions = zeros(Int32, num_bedges(grid))
    return grid[BEdgeRegions] = bedgeregions
end

instantiate(grid, ::Type{BEdgeRegions}) = prepare_bedgeregions!(grid)

#############################################################
# General methods
"""
$(TYPEDSIGNATURES)

Print the hierarchy of grid component key types (subtypes of [`AbstractGridComponent`](@ref). 
This includes additionally user defined subptypes.
"""
gridcomponents() = AbstractTrees.print_tree(AbstractGridComponent)

"""
$(TYPEDSIGNATURES)

Keys in grid
"""
Base.keys(g::ExtendableGrid) = Base.keys(g.components)

"""
$(TYPEDSIGNATURES)

Check if key is in grid
"""
Base.haskey(g::ExtendableGrid, k) = Base.haskey(g.components, k)

"""
$(SIGNATURES)

Space dimension of grid
"""
dim_space(grid::ExtendableGrid) = haskey(grid, Coordinates) ? size(grid[Coordinates], 1) : 0

"""
$(SIGNATURES)

Grid dimension dimension of grid (larges element dimension)
"""
dim_grid(grid::ExtendableGrid) = dim_element(grid[CellGeometries][1])

"""
$(SIGNATURES)

Number of nodes in grid
"""
num_nodes(grid::ExtendableGrid)::Int = haskey(grid, Coordinates) ? size(grid[Coordinates], 2) : 0

"""
$(TYPEDSIGNATURES)

Number of cells in grid
"""
num_cells(grid::ExtendableGrid) = haskey(grid, CellNodes) ? num_sources(grid[CellNodes]) : 0

"""
$(TYPEDSIGNATURES)

Number of boundary faces in grid.
"""
num_bfaces(grid::ExtendableGrid) = haskey(grid, BFaceNodes) ? num_sources(grid[BFaceNodes]) : 0

"""
$(TYPEDSIGNATURES)

Number of boundary edges in grid.
"""
num_bedges(grid::ExtendableGrid) = haskey(grid, BEdgeNodes) ? num_sources(grid[BEdgeNodes]) : 0

"""
$(TYPEDSIGNATURES)

Maximum  cell  region number
"""
num_cellregions(grid::ExtendableGrid) = grid[NumCellRegions]

"""
$(TYPEDSIGNATURES)

Maximum  boundary face region numbers
"""
num_bfaceregions(grid::ExtendableGrid) = grid[NumBFaceRegions]

"""
$(TYPEDSIGNATURES)

Maximum boundary edge region numbers
"""
num_bedgeregions(grid::ExtendableGrid) = grid[NumBEdgeRegions]

"""
$(SIGNATURES)
Type of coordinates in grid
"""
coord_type(grid::ExtendableGrid{Tc, Ti}) where {Tc, Ti} = Tc

"""
$(SIGNATURES)

Type of indices
"""
index_type(grid::ExtendableGrid{Tc, Ti}) where {Tc, Ti} = Ti

function dangling_nodes(grid)
    coord = grid[Coordinates]
    nnodes = size(coord, 2)
    nodemark = zeros(Bool, nnodes)
    cn = grid[CellNodes]
    ncells = num_cells(grid)
    for icell in 1:ncells
        for inode in 1:num_targets(cn, icell)
            nodemark[cn[inode, icell]] = true
        end
    end
    if all(nodemark)
        return nothing
    else
        return coord[:, findall(!, nodemark)]
    end
end


"""
    isconsistent(grid; warnonly=false)

Check consistency of grid: a grid is consistent if
- Grid has no dangling nodes
- ... more to be added

If grid is consistent, return true, otherwise throw an error, 
or, if `warnoly==true`, return false.
"""
function isconsistent(grid; warnonly = false)
    consistent = true
    dnodes = dangling_nodes(grid)
    if !isnothing(dnodes)
        @warn "Found dangling nodes: $(dnodes)"
        consistent = false
    end
    if !consistent && ! warnonly
        error("Consistency error(s) found in grid")
    end
    return consistent
end

"""
    map(f,grid)
Map function `f` returning a number onto node coordinates of grid.
Returns a vector of length corresponding to the number of nodes of the grid.
The function can take either a vector or a numbers as arguments.
E.g. for a two-dimensional grid `g`, both

```
 map(X->X[1]+X[2], g)
```
and
```
 map((x,y)->x+y, g)
```

are possible.
"""
function Base.map(f::Function, grid::ExtendableGrid{Tc, Ti}) where {Tc, Ti}
    coord = grid[Coordinates]
    c1 = coord[:, 1]
    dim = dim_space(grid)

    ## Check if f can be called with number args like f(x,y)
    function checknumargs(f, args...)
        if !hasmethod(f, Tuple(typeof.(args)))
            return false
        end
        try
            y = f(args...)
        catch e
            if isa(e, MethodError)
                return false
            end
            if isa(e, BoundsError)
                return false
            end
            rethrow(e)
        end
        return true
    end

    ## Check if f can be called with vector args like f(X::Vector) and returns a number
    function checkvecargs(f, v)
        if !hasmethod(f, Tuple{Vector})
            return false
        end
        try
            y = f(v)
        catch e
            if isa(e, MethodError)
                return false
            end
            rethrow(e)
        end
        return true
    end

    use_numargs = checknumargs(f, c1...)
    use_vecargs = checkvecargs(f, c1)

    return if use_numargs
        if dim == 1
            @views Base.map(f, coord[1, :])
        elseif dim == 2
            @views Base.map(f, coord[1, :], coord[2, :])
        else
            @views Base.map(f, coord[1, :], coord[2, :], coord[3, :])
        end
    elseif use_vecargs
        Base.map(f, reinterpret(reshape, SVector{dim, Tc}, coord))
    else
        error("Cannot map function $f on grid. Check for consistency of function args and grid dimension.")
    end
end

#
# Define two show methods, one extended for printing the repl, one
# compact for e.g. interpolating into a string
# See https://discourse.julialang.org/t/show-and-showcompact-on-custom-types/8493/6
#
function Base.show(io::IO, ::MIME"text/plain", grid::ExtendableGrid)
    str = @sprintf(
        "%s\n      dim = %7d\n   nnodes = %7d\n   ncells = %7d\n  nbfaces = %7d",
        typeof(grid),
        dim_space(grid), num_nodes(grid), num_cells(grid), num_bfaces(grid)
    )
    if num_edges(grid) > 0
        str *= @sprintf("\n   nedges = %7d", num_edges(grid))
    end
    if num_partitions(grid) > 1
        str *= "\n  npartitions/color = $(num_partitions_per_color(grid))"
    end
    print(io, str)
    return nothing
end

function Base.show(io::IO, grid::ExtendableGrid)
    str = @sprintf(
        "%s(dim=%d, nnodes=%d, ncells=%d, nbfaces=%d",
        typeof(grid),
        dim_space(grid), num_nodes(grid), num_cells(grid), num_bfaces(grid)
    )
    if num_edges(grid) > 0
        str *= @sprintf(", nedges=%d", num_edges(grid))
    end
    if num_partitions(grid) > 1
        str *= ", npart/color=$(num_partitions_per_color(grid))"
    end
    str *= ")"
    print(io, str)
    return nothing
end

### Tests for the gmsh extension:

function multidimsort(A)
    i1 = sortperm(A[1, :])
    A1 = A[:, i1]
    for j in 2:size(A, 1)
        cm = countmap(A1[j - 1, :])
        for (key, val) in cm
            if val > 1 #if there only is one entry with this key, the reordering is not necessary
                inds = findall(z -> z == key, A1[j - 1, :]) #indices of that key in A1
                sorted_inds = sortperm(A1[j, inds])
                A1[:, inds] = A1[:, inds[sorted_inds]] #reorder
            end
        end
    end
    return A1
end

"""
    seemingly_equal(grid1, grid2; sort=false, confidence=:full

Recursively check seeming equality of two grids. Seemingly means 
that long arrays are only compared via random samples.

Keyword args:

- `sort`: if true, sort grid points
- `confidence`:  Confidence level: 
  - :low : Point numbers etc are the same
  - :full : all arrays are equal (besides the coordinate array, the arrays only have to be equal up to permutations)
"""
function seemingly_equal(grid1::ExtendableGrid, grid2::ExtendableGrid; sort = false, confidence = :full)
    if !sort
        for key in keys(grid1)
            if !haskey(grid2, key)
                return false
            end
            if !seemingly_equal(grid1[key], grid2[key])
                return false
            end
        end
        return true
    end

    if confidence == :full
        for key in keys(grid1)
            if !haskey(grid2, key)
                return false
            end
            if !isa(grid1[key], AbstractArray)
                !seemingly_equal(grid1[key], grid2[key]) && return false
                continue
            end

            s1 = size(grid1[key])
            s2 = size(grid2[key])

            if length(s1) == 0
                if length(s1) == 1
                    if eltype(grid1[key]) <: Number
                        ind1 = sortperm(grid1[key])
                        ind2 = sortperm(grid2[key])
                        sa1 = grid1[key][ind1]
                        sa2 = grid2[key][ind2]
                        !seemingly_equal(sa1, sa2) && return false
                    else
                        !seemingly_equal(grid1[key], grid2[key]) && return false
                    end
                else
                    if eltype(grid1[key]) <: Number && key != Coordinates
                        sa1 = multidimsort(sort(grid1[key]; dims = 1))
                        sa2 = multidimsort(sort(grid2[key]; dims = 1))
                        !seemingly_equal(sa1, sa2) && return false
                    else
                        !seemingly_equal(grid1[key], grid2[key]) && return false
                    end
                end
            end
        end
        return true
    elseif confidence == :low
        grid1_data = (num_nodes(grid1), num_cells(grid1), num_bfaces(grid1))
        grid2_data = (num_nodes(grid2), num_cells(grid2), num_bfaces(grid2))
        return grid1_data == grid2_data
    else
        error("Confidence level $(confidence) not implemented")
        return false
    end
end

"""
$(SIGNATURES)

Check for seeming equality of two arrays by random sample.
"""
function seemingly_equal(array1::AbstractArray, array2::AbstractArray)
    if size(array1) != size(array2)
        return false
    end
    l = length(array1)
    ntests = Float64(min(l, 50))
    p = min(0.5, ntests / l)
    for i in randsubseq(1:l, p)
        if !seemingly_equal(array1[i], array2[i])
            return false
        end
    end
    return true
end

function seemingly_equal(a1::VariableTargetAdjacency, a2::VariableTargetAdjacency)
    return seemingly_equal(a1.colentries, a2.colentries) && seemingly_equal(a1.colstart, a2.colstart)
end
seemingly_equal(x1::Type, x2::Type) = (x1 == x2)
seemingly_equal(x1::Number, x2::Number) = (x1 ≈ x2)
seemingly_equal(x1::Any, x2::Any) = (x1 == x2)

function numbers_match(grid, nn, nc, nb)
    return num_nodes(grid) == nn &&
        num_cells(grid) == nc &&
        num_bfaces(grid) == nb
end

Base.extrema(grid::ExtendableGrid) = Base.extrema(grid[Coordinates]; dims = 2)

function bbox(grid)
    e = extrema(grid)
    return map(a -> a[1], e), map(a -> a[2], e)
end
