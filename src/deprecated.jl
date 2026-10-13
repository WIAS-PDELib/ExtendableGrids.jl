## NodeInParent was renamed to NodeParents in v1.3
abstract type NodeInParent <: AbstractGridIntegerArray1D end
export NodeInParent

function instantiate(xgrid::ExtendableGrid, ::Type{NodeInParent})
    @warn "NodeInParents is deprecated, use NodeParents instead"
    return xgrid[NodeParents]
end
