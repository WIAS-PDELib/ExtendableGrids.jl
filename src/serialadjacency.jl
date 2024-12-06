struct SerialVariableTargetAdjacency{T}
    """
    Start indices of respective column data in `colentries`
    """
    colstart::Vector{T}
end

"""
    $(SIGNATURES)
    
    Comparison of two adjacencies
"""
function Base.:(==)(a::SerialVariableTargetAdjacency{Ta}, b::SerialVariableTargetAdjacency{Tb}) where {Ta, Tb}
    return Ta == Tb && a.colstart == b.colstart
end

"""
$(TYPEDSIGNATURES)
Create an empty SerialVariableTargetAdjacency
"""
SerialVariableTargetAdjacency(t::Type{T}) where {T} = SerialVariableTargetAdjacency{T}([one(T)])

"""
$(TYPEDSIGNATURES)
Create an empty SerialVariableTargetAdjacency with default type
"""
SerialVariableTargetAdjacency() = SerialVariableTargetAdjacency(Int64)

"""
$(TYPEDSIGNATURES)
Show adjacency (in transposed form; preliminary)
"""
function Base.show(io::IO, adj::SerialVariableTargetAdjacency)
    for isource in 1:num_sources(adj)
        for itarget in 1:num_targets(adj, isource)
            print(adj[itarget, isource], " ")
        end
        println()
    end
    return
end

"""
$(TYPEDSIGNATURES)
Access adjacency as if it is a 2D Array
"""
Base.getindex(adj::SerialVariableTargetAdjacency, i, isource) = adj.colstart[isource] + i - 1
Base.getindex(adj::SerialVariableTargetAdjacency, ::Colon, isource) = adj.colstart[isource]:(adj.colstart[isource + 1] - 1)
Base.view(adj::SerialVariableTargetAdjacency{Ti}, ::Colon, isource) where {Ti} = adj.colstart[isource]:(adj.colstart[isource + 1] - 1)

"""
$(TYPEDSIGNATURES)
Number of targets for given source
"""
ExtendableGrids.num_targets(adj::SerialVariableTargetAdjacency, isource) = adj.colstart[isource + 1] - adj.colstart[isource]

"""
$(TYPEDSIGNATURES)
Number of sources in adjacency
"""
ExtendableGrids.num_sources(adj::SerialVariableTargetAdjacency) = length(adj.colstart) - 1

"""
$(TYPEDSIGNATURES)
Maximum number of targets per source
"""
ExtendableGrids.max_num_targets_per_source(adj::SerialVariableTargetAdjacency) = maximum(adj.colstart[2:end] .- adj.colstart[1:(end - 1)])


"""
$(TYPEDSIGNATURES)
Append a column to adjacency.
"""
function Base.append!(adj::SerialVariableTargetAdjacency, len)
    return push!(adj.colstart, adj.colstart[end] + len)
end
