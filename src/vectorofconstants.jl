"""
$(TYPEDEF)

Vector with constant value
"""
struct VectorOfConstants{T, Tl} <: AbstractVector{T}
    val::T
    len::Tl
end

Base.IndexStyle(::Type{<:VectorOfConstants}) = IndexLinear()


"""
$(TYPEDSIGNATURES)

Length
"""
Base.length(v::VectorOfConstants) = v.len

"""
$(TYPEDSIGNATURES)

Size
"""
Base.size(v::VectorOfConstants) = (v.len,)

"""
$(TYPEDSIGNATURES)

Access
"""
function Base.getindex(v::VectorOfConstants, i)
    if i > v.len
        throw(BoundsError(v, i))
    end
    return v.val
end

"""
$(TYPEDSIGNATURES)

Iterator
"""
Base.iterate(v::VectorOfConstants) = (v.val, 1)
"""
$(TYPEDSIGNATURES)

Iterator
"""
Base.iterate(v::VectorOfConstants, state) = state >= v.len ? nothing : (v.val, state + 1)

"""
$(TYPEDSIGNATURES)

Shortcut for unique
"""
Base.unique(v::VectorOfConstants) = [v.val]
