"""
$(TYPEDEF)


Binned  point  list structure  allowing  for  fast check  for  already
existing points.

This  provides better  performance for  indendifying already  inserted
points than the naive linear search.

OTOH  the  implementation  is  still  quite  naive  -  it  dynamically
maintains a cuboid binning region with a fixed number of bins.

Probably  tree based  adaptive  methods  (a la  octree)  will be  more
efficient, however they will be harder to implement.

In an ideal world, we would maintain a dynamic Delaunay triangulation,
which at  once could be  the starting  point of mesh  generation which
will follow here anyway.

$(TYPEDFIELDS)
"""
mutable struct BinnedPointList{T}

    """
     Space dimension
    """
    dim::Int32

    """
    Point distance tolerance. Points closer than tol
    (in Euclidean distance) will be identified, i.e.
    are collapsed to the first inserted.
    """
    tol::T

    """"
    The union of all bins is the binning region -
    a cuboid given by two of its corners. It is calculated
    dynamically depending on the inserted points.
    """
    binning_region_min::Vector{T}
    binning_region_max::Vector{T}

    """
    Increase factor of binning region (with respect to
    the cuboid defined by the coordinates of the binned points)
    """
    binning_region_increase_factor::T

    """
    The actual point list
    """
    points::ElasticArray{T, 2}

    """
    The bins are vectors of indices of points in the point list
    We store them in a dim-dimensional array  of length "number_of_directional_bins^dim"
    """
    bins::Array{Vector{Int32}}

    """
    Number of bins in each space dimension
    """
    number_of_directional_bins::Int32

    """
    Some points will fall outside of the binning region.
    We collect them in vector of ubinned point indices
    """
    unbinned::Vector{Int32}

    """
    Number of unbinned  points tolerated without rebinning
    """
    num_allowed_unbinned_points::Int32

    """
    Maximum ratio of unbinned  points  in point list
    """
    max_unbinned_ratio::T

    """
    Storage of current point bin
    """
    current_bin::Vector{Int32}

    BinnedPointList{T}(::Nothing) where {T} = new()
end

"""
     BinnedPointList(::Type{T}, dim;
                     tol = 1.0e-12,
                     number_of_directional_bins = 10,
                     binning_region_increase_factor = 0.01,
                     num_allowed_unbinned_points = 5,
                     max_unbinned_ratio = 0.05) where {T}

Create and initialize binned point list
"""
function BinnedPointList(
        ::Type{T}, dim;
        tol = 1.0e-12,
        number_of_directional_bins = 10,
        binning_region_increase_factor = 0.01,
        num_allowed_unbinned_points = 5,
        max_unbinned_ratio = 0.05
    ) where {T}
    bpl = BinnedPointList{T}(nothing)

    bpl.dim = dim
    bpl.tol = tol
    bpl.number_of_directional_bins = number_of_directional_bins
    bpl.binning_region_increase_factor = binning_region_increase_factor
    bpl.num_allowed_unbinned_points = num_allowed_unbinned_points
    bpl.max_unbinned_ratio = max_unbinned_ratio

    bpl.points = ElasticArray{Cdouble}(undef, dim, 0)

    bpl.binning_region_min = fill(floatmax(T), dim)
    bpl.binning_region_max = fill(-floatmax(T), dim)

    bpl.unbinned = Vector{Int32}(undef, 0)
    bpl.bins = Array{Vector{Int32}, dim}(undef, zeros(Int32, dim)...)

    bpl.current_bin = zeros(Int32, bpl.dim)
    return bpl
end

"""
    BinnedPointList(dim; kwargs...) 


Create and initialize binned point list
"""
BinnedPointList(dim; kwargs...) = BinnedPointList(Float64, dim; kwargs...)

"""
    _findpoint(binnedpointlist, index, p)

Find point in index list (by linear search)
Return its index, or zero if not found
"""
function _findpoint(bpl, index, p)
    for i in 1:length(index)
        @views if norm(bpl.points[:, index[i]] - p) < bpl.tol
            return index[i]
        end
    end
    return 0
end

"""
    _bin_of_point!(binnedpointlist, p)

Calculate the bin of the point. Result is stored
in bpl.current_bin
"""
function _bin_of_point!(bpl, p)
    for idim in 1:(bpl.dim)
        # scaled value for particular dimension
        s = (p[idim] - bpl.binning_region_min[idim]) / (bpl.binning_region_max[idim] - bpl.binning_region_min[idim])
        if s > 1 || s < 0
            # point lies outside of binning area
            bpl.current_bin[idim] = 0
        else
            # calculate bin in particular dimension
            bpl.current_bin[idim] = ceil(Int32, bpl.number_of_directional_bins * s)
        end
    end
    return
end

"""
    _rebin_all_points!(bpl)

Re-calculate binning if there are too many unbinned points
This amounts to two steps:
- Enlarge binning area in order to include all points
- Re-calculate all point bins
"""
function _rebin_all_points!(bpl)
    if length(bpl.unbinned) > max(
            bpl.num_allowed_unbinned_points,
            bpl.max_unbinned_ratio * size(bpl.points, 2)
        )

        # Calculate extrema of unbinned points
        @views e = extrema(bpl.points[:, bpl.unbinned]; dims = 2)

        for i in 1:(bpl.dim)
            # Increase binning region according to unbinned extrema
            bpl.binning_region_min[i] = min(bpl.binning_region_min[i], e[i][1])
            bpl.binning_region_max[i] = max(bpl.binning_region_max[i], e[i][2])

            # Slightly increase binning region further in order to
            # include all existing points with tolerance
            delta = max(bpl.binning_region_max[i] - bpl.binning_region_min[i], bpl.tol)
            bpl.binning_region_min[i] -= bpl.binning_region_increase_factor * delta
            bpl.binning_region_max[i] += bpl.binning_region_increase_factor * delta
        end

        # Re-allocate all bins
        if bpl.dim == 1
            bpl.bins = [zeros(Int32, 0) for i in 1:(bpl.number_of_directional_bins)]
        elseif bpl.dim == 2
            bpl.bins = [
                zeros(Int32, 0)
                    for i in 1:(bpl.number_of_directional_bins),
                    j in 1:(bpl.number_of_directional_bins)
            ]
        elseif bpl.dim == 3
            bpl.bins = [
                zeros(Int32, 0)
                    for i in 1:(bpl.number_of_directional_bins),
                    j in 1:(bpl.number_of_directional_bins),
                    k in 1:(bpl.number_of_directional_bins)
            ]
        end

        # Register all points in their respctive bins
        for i in 1:size(bpl.points, 2)
            @views _bin_of_point!(bpl, bpl.points[:, i])
            push!(bpl.bins[bpl.current_bin...], i)
        end

        # Re-allocate unbinned index
        bpl.unbinned = zeros(Int32, 0)
    end
    return
end


"""
    findpoint(binnedpointlist, p)

Find point in binned point list. Return its index in the point list if found,
otherwise return 0.
"""
function findpoint(bpl::BinnedPointList{T}, p) where {T}
    _rebin_all_points!(bpl)
    _bin_of_point!(bpl, p)
    if reduce(*, bpl.current_bin) > 0
        return _findpoint(bpl, bpl.bins[bpl.current_bin...], p)
    else
        return _findpoint(bpl, bpl.unbinned, p)
    end
end

"""
     Base.insert!(binnedpointlist,p)

If another point with distance less the tol from p is
in pointlist, return its index. Otherwise, insert point into pointlist. 
`p` may be a vector or a tuple.
"""
function Base.insert!(bpl::BinnedPointList{T}, p) where {T}
    _rebin_all_points!(bpl)
    _bin_of_point!(bpl, p)
    if reduce(*, bpl.current_bin) > 0
        i = _findpoint(bpl, bpl.bins[bpl.current_bin...], p)
        if i > 0
            return i
        else
            append!(bpl.points, p)
            i = size(bpl.points, 2)
            push!(bpl.bins[bpl.current_bin...], i)
            return i
        end
    else
        i = _findpoint(bpl, bpl.unbinned, p)
        if i > 0
            return i
        else
            append!(bpl.points, p)
            i = size(bpl.points, 2)
            push!(bpl.unbinned, i)
            return i
        end
    end
    return
end

"""
     Base.insert!(binnedpointlist,x)
    
Insert 1D point via coordinate.
"""
Base.insert!(bpl::BinnedPointList{T}, x::Number) where {T} = insert!(bpl, (x))

"""
     Base.insert!(binnedpointlist,x,y)
    
Insert 2D point via coordinates.
"""

Base.insert!(bpl::BinnedPointList{T}, x::Number, y::Number) where {T} = insert!(bpl, (x, y))
"""
     Base.insert!(binnedpointlist,x,y,z)
    
Insert 3D point via coordinates.
"""
Base.insert!(bpl::BinnedPointList{T}, x::Number, y::Number, z::Number) where {T} = insert!(bpl, (x, y, z))


"""
    naiveinsert(binnedpointlist, p)

Insert via linear search, without any binning.
Just for being able to check of all of the above was worth the effort...
"""
function naiveinsert!(bpl::BinnedPointList{T}, p) where {T}
    for i in 1:size(bpl.points, 2)
        @views if norm(bpl.points[:, i] - p) < bpl.tol
            return i
        end
    end
    append!(bpl.points, p)
    return size(bpl.points, 2)
end
