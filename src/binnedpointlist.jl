"""
$(TYPEDEF)

Binned point list structure allowing for fast check for already
existing points.

This provides better performance for identifying already inserted
points than the naive linear search.

# Algorithm

All inserted points are kept in `points`. In addition, a cuboid
*binning region* (given by `binning_region_min`/`binning_region_max`)
is subdivided into a `number_of_directional_bins`-per-dimension grid
of `bins`, each holding the indices of the points falling into it.
Looking up or inserting a point then only has to search the (small)
bin the point falls into, instead of the whole point list.

Points that fall outside of the current binning region (or are
inserted before any region has been established) are kept in the
separate `unbinned` list, which is searched linearly. Once too many
points accumulate there (as governed by `num_allowed_unbinned_points`
and `max_unbinned_ratio`), the binning region is enlarged to cover
them and *all* points are re-distributed into freshly allocated bins,
see [`_rebin_all_points!`](@ref). This amortizes the cost of handling
points outside the initial region over many insertions.

OTOH the implementation is still quite naive - it dynamically
maintains a cuboid binning region with a fixed number of bins.

Probably tree based adaptive methods (a la octree) will be more
efficient, however they will be harder to implement.

In an ideal world, we would maintain a dynamic Delaunay triangulation,
which at once could be the starting point of mesh generation which
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
    are collapsed to the first inserted. This is an
    absolute, not a relative, tolerance.
    """
    tol::T

    """
    The union of all bins is the binning region -
    a cuboid given by two of its corners. It is calculated
    dynamically depending on the inserted points.
    Until the first call to [`_rebin_all_points!`](@ref) actually
    performs a rebinning, this is the (degenerate, empty) cuboid
    `binning_region_min = fill(floatmax(T), dim)`,
    `binning_region_max = fill(-floatmax(T), dim)`.
    """
    binning_region_min::Vector{T}
    binning_region_max::Vector{T}

    """
    Increase factor of binning region (with respect to
    the cuboid defined by the coordinates of the binned points).
    Keeps points which lie exactly on the boundary of the region
    spanned by the current point set (and future points close to it)
    safely inside the binning region instead of the `unbinned` list.
    """
    binning_region_increase_factor::T

    """
    The actual point list, as a `dim × npoints` matrix.
    """
    points::ElasticArray{T, 2}

    """
    The bins are vectors of indices of points in the point list.
    We store them in a dim-dimensional array of size
    `number_of_directional_bins` along each dimension, i.e. with
    `number_of_directional_bins^dim` entries in total.
    Before the first rebinning, this array has size zero in each
    dimension (no bins have been allocated yet).
    """
    bins::Array{Vector{Int32}}

    """
    Number of bins in each space dimension
    """
    number_of_directional_bins::Int32

    """
    Some points will fall outside of the binning region, e.g. because
    they were inserted before the region was ever calculated, or
    because they lie outside of the region as it was last enlarged.
    We collect them in a vector of unbinned point indices, which is
    searched linearly.
    """
    unbinned::Vector{Int32}

    """
    Number of unbinned points tolerated without triggering a rebinning
    via [`_rebin_all_points!`](@ref).
    """
    num_allowed_unbinned_points::Int32

    """
    Maximum ratio of unbinned points in the point list tolerated
    without triggering a rebinning via [`_rebin_all_points!`](@ref).
    Rebinning is triggered once the number of unbinned points exceeds
    `max(num_allowed_unbinned_points, max_unbinned_ratio * npoints)`.
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

    bpl.points = ElasticArray{T}(undef, dim, 0)

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

Find point `p` by linear search among the points listed in `index`
(typically one bin, or the `unbinned` list).
Return its index in `binnedpointlist.points`, or zero if not found.
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

Calculate the bin of the point. Result is stored in `bpl.current_bin`.

For each space dimension, `bpl.current_bin[idim]` is set to a value in
`1:bpl.number_of_directional_bins` if `p[idim]` lies within the binning
region for that dimension, and to `0` if it lies outside (this includes
the case where the binning region has not been set up yet, or is still
degenerate in that dimension). Consumers must check
`reduce(*, bpl.current_bin) > 0` before indexing into `bpl.bins` with
`bpl.current_bin`, since a `0` entry is not a valid array index.
"""
function _bin_of_point!(bpl, p)
    for idim in 1:(bpl.dim)
        width = bpl.binning_region_max[idim] - bpl.binning_region_min[idim]
        if width <= 0
            # Binning region is degenerate (not yet initialized, or
            # zero-width in this dimension). Avoid dividing by zero/
            # negative width; only an exact match can be "inside".
            bpl.current_bin[idim] = p[idim] == bpl.binning_region_min[idim] ? 1 : 0
            continue
        end
        # scaled value for particular dimension, in [0,1] if inside the region
        s = (p[idim] - bpl.binning_region_min[idim]) / width
        if s > 1 || s < 0
            # point lies outside of binning area
            bpl.current_bin[idim] = 0
        else
            # calculate bin in particular dimension.
            # clamp is needed since s == 0 would otherwise yield bin index 0,
            # which is out of the valid 1:number_of_directional_bins range.
            bpl.current_bin[idim] = clamp(ceil(Int32, bpl.number_of_directional_bins * s), 1, bpl.number_of_directional_bins)
        end
    end
    return
end

"""
    _rebin_all_points!(bpl)

Re-calculate binning if there are too many unbinned points, i.e. if
`length(bpl.unbinned) > max(bpl.num_allowed_unbinned_points, bpl.max_unbinned_ratio * size(bpl.points, 2))`.
This amounts to two steps:
- Enlarge the binning region in order to include all (previously unbinned) points,
  plus some tolerance-dependent slack given by `binning_region_increase_factor`
  so that points exactly on the boundary are unambiguously inside.
- Re-allocate `bpl.bins` and re-calculate the bin of *every* point (not
  just the previously unbinned ones), since the enlarged region shifts
  the boundaries of all bins.

This is a full O(npoints) operation; it is only called when the
above threshold is exceeded, so its cost is amortized over the
insertions/lookups performed since the last rebinning.
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

            reltol = bpl.tol * (abs(bpl.binning_region_max[i]) + abs(bpl.binning_region_min[i])) / 2
            if reltol == 0.0
                reltol = bpl.tol
            end
            # Slightly increase binning region further in order to
            # include all existing points with tolerance
            delta = max(bpl.binning_region_max[i] - bpl.binning_region_min[i], reltol)
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

        # Register all points in their respective bins.
        # By construction of the enlarged binning region above, every point
        # should now map to a valid bin; the `reduce(*, ...) > 0` check is
        # kept as a defensive fallback so a degenerate corner case cannot
        # crash on an invalid bin index but instead re-populates `unbinned`.
        new_unbinned = zeros(Int32, 0)
        for i in 1:size(bpl.points, 2)
            @views _bin_of_point!(bpl, bpl.points[:, i])
            if reduce(*, bpl.current_bin) > 0
                push!(bpl.bins[bpl.current_bin...], i)
            else
                push!(new_unbinned, i)
            end
        end
        bpl.unbinned = new_unbinned
    end
    return
end


"""
    findpoint(binnedpointlist, p)

Find point `p` in binned point list. Return its index in the point list if found,
otherwise return 0. `p` may be a vector or a tuple.

This first triggers a rebinning if too many points have accumulated
in the `unbinned` list (see [`_rebin_all_points!`](@ref)), then looks
up the bin `p` falls into (or the `unbinned` list, if `p` falls
outside of the current binning region) and searches it linearly.
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

If another point with distance less than `tol` from `p` is
already in the point list, return its index. Otherwise, insert `p`
into the point list and return the index of the newly inserted point.
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
    naiveinsert!(binnedpointlist, p)

Insert via linear search, without any binning.
Just for being able to check if all of the above was worth the effort...
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
