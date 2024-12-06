"""
$(TYPEDSIGNATURES)

Define children for types.
"""
AbstractTrees.children(T::Type) = InteractiveUtils.subtypes(T)

"""
$(TYPEDEF)

Apex type of all abstract types in this hierarchy.
"""
abstract type AbstractExtendableGridApexType end


"""
$(TYPEDSIGNATURES)

Print complete type hierarchy for ExtendableGrids
"""
typehierarchy() = AbstractTrees.print_tree(AbstractExtendableGridApexType)


function leaftypes(TApex)
    function leaftypes!(leafs, t)
        st = subtypes(t)
        if length(st) == 0
            push!(leafs, t)
        else
            for tsub in st
                leaftypes!(leafs, tsub)
            end
        end
        return leafs
    end
    return leaftypes!(Type[], TApex)
end

function allsubtypes(TApex)
    function allsubtypes!(st, t)
        for tsub in subtypes(t)
            push!(st, tsub)
            allsubtypes!(st, tsub)
        end
        return st
    end
    return allsubtypes!(Type[], TApex)
end
