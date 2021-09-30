########################
# AbstractAssemblyType #
########################

# this type is used to steer where certain things live and assemble on
# mainly if it lives on CELLs, FACEs or BFACEs

abstract type AbstractAssemblyType end 

"""
$(TYPEDEF)

causes interpolation at vertices of the grid (only for H1-conforming interpolations)
"""
abstract type AT_NODES <: AbstractAssemblyType end  # at nodes (only available for H1 conforming interpolation)

"""
$(TYPEDEF)

causes assembly/interpolation on cells of the grid
"""
abstract type ON_CELLS <: AbstractAssemblyType end  # on all cells 

"""
$(TYPEDEF)

causes assembly/interpolation on faces of the grid
"""
abstract type ON_FACES <: AbstractAssemblyType end  # on all faces

"""
$(TYPEDEF)

causes assembly/interpolation on interior faces of the grid
"""
abstract type ON_IFACES <: ON_FACES end  # on interior faces

"""
$(TYPEDEF)

causes assembly/interpolation on boundary faces of the grid
"""
abstract type ON_BFACES <: AbstractAssemblyType end # on boundary faces

"""
$(TYPEDEF)

causes assembly/interpolation on edges of the grid (only in 3D)
"""
abstract type ON_EDGES <: AbstractAssemblyType end  # on all edges

"""
$(TYPEDEF)

causes assembly/interpolation on boundary edges of the grid (only in 3D)
"""
abstract type ON_BEDGES <: AbstractAssemblyType end # on boundary edges

function Base.show(io::Core.IO, ::Type{ON_CELLS})
    print(io,"ON_CELLS")
end
function Base.show(io::Core.IO, ::Type{ON_FACES})
    print(io,"ON_FACES")
end
function Base.show(io::Core.IO, ::Type{ON_BFACES})
    print(io,"ON_BFACES")
end
function Base.show(io::Core.IO, ::Type{ON_IFACES})
    print(io,"ON_IFACES")
end
function Base.show(io::Core.IO, ::Type{ON_EDGES})
    print(io,"ON_EDGES")
end
function Base.show(io::Core.IO, ::Type{ON_BEDGES})
    print(io,"ON_BEDGES")
end

ItemType4AssemblyType(::Type{ON_CELLS}) = ITEMTYPE_CELL
ItemType4AssemblyType(::Type{<:ON_FACES}) = ITEMTYPE_FACE
ItemType4AssemblyType(::Type{ON_BFACES}) = ITEMTYPE_BFACE
ItemType4AssemblyType(::Type{<:ON_EDGES}) = ITEMTYPE_EDGE
ItemType4AssemblyType(::Type{ON_BEDGES}) = ITEMTYPE_BEDGE

GridComponentNodes4AssemblyType(AT::Type{<:AbstractAssemblyType}) = GridComponent4TypeProperty(ItemType4AssemblyType(AT),PROPERTY_NODES)
GridComponentVolumes4AssemblyType(AT::Type{<:AbstractAssemblyType}) = GridComponent4TypeProperty(ItemType4AssemblyType(AT),PROPERTY_VOLUME)
GridComponentGeometries4AssemblyType(AT::Type{<:AbstractAssemblyType}) = GridComponent4TypeProperty(ItemType4AssemblyType(AT),PROPERTY_GEOMETRY)
GridComponentUniqueGeometries4AssemblyType(AT::Type{<:AbstractAssemblyType}) = GridComponent4TypeProperty(ItemType4AssemblyType(AT),PROPERTY_UNIQUEGEOMETRY)
GridComponentRegions4AssemblyType(AT::Type{<:AbstractAssemblyType}) = GridComponent4TypeProperty(ItemType4AssemblyType(AT),PROPERTY_REGION)

