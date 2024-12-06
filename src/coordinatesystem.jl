"""
$(TYPEDEF)
Apex type for coordinate systems
"""
abstract type AbstractCoordinateSystem <: AbstractExtendableGridApexType end


"""
$(TYPEDSIGNATURES)

List possible coordinate systems. These describe the meaning of the grid coordinates.
"""
coordinatesystems() = AbstractTrees.print_tree(AbstractCoordinateSystem)


"""
$(TYPEDEF)
1D cartesian coordinate system (unknown `x`)
"""
abstract type Cartesian1D <: AbstractCoordinateSystem end

"""
$(TYPEDEF)
2D cartesian coordinate system (unknowns `x,y`)
"""
abstract type Cartesian2D <: AbstractCoordinateSystem end

"""
$(TYPEDEF)
2D cartesian coordinate system (unknowns `x,y,z`)
"""
abstract type Cartesian3D <: AbstractCoordinateSystem end

"""
$(TYPEDEF)
3D cylindrical coordinate system (unknowns `r,ϕ,z`)
"""
abstract type Cylindrical3D <: AbstractCoordinateSystem end

"""
$(TYPEDEF)
2D cylindrical coordinate system (unknowns `r,z`)
"""
abstract type Cylindrical2D <: AbstractCoordinateSystem end

"""
$(TYPEDEF)
2D polar coordinate system (unknowns `r,ϕ`)
"""
abstract type Polar2D <: AbstractCoordinateSystem end

"""
$(TYPEDEF)
1D polar coordinate system (unknown `r`)
"""
abstract type Polar1D <: AbstractCoordinateSystem end

"""
$(TYPEDEF)
3D spheriacal coordinate system (unknowns `r,ϕ,θ`)
"""
abstract type Spherical3D <: AbstractCoordinateSystem end

"""
$(TYPEDEF)
1D spheriacal coordinate system (unknown `r`)
"""
abstract type Spherical1D <: AbstractCoordinateSystem end  #r (integral over ϕ,\theta)


const CoordinateSystems = Union{[Type{t} for t in leaftypes(AbstractCoordinateSystem)]...}


"""
    codim1_coordinatesystem(CoordinateSystem)

Return coordinate system for codimension 1 subgrid.
"""
codim1_coordinatesystem(::Type{T}) where {T <: AbstractCoordinateSystem} = nothing
codim1_coordinatesystem(::Type{Cartesian3D}) = Cartesian2D
codim1_coordinatesystem(::Type{Cartesian2D}) = Cartesian1D
