function testbinning(a)
    dim = size(a, 1)
    n = size(a, 2)
    idx = rand(1:n, n ÷ 4)
    a1 = a[:, idx]

    bpl = BinnedPointList(dim)
    for i in 1:size(a, 2)
        insert!(bpl, a[:, i])
    end

    for i in 1:size(a1, 2)
        ix = insert!(bpl, a1[:, i])
        if ix != idx[i]
            return false
        end
    end
    return true
end

@test testbinning(rand(1, 10))
@test testbinning(rand(1, 10000))
@test testbinning(rand(2, 10))
@test testbinning(rand(2, 10000))
@test testbinning(rand(3, 10))
@test testbinning(rand(3, 10000))

# Degenerate binning region: all points share the same coordinate in
# some dimension, so binning_region_min == binning_region_max there.
# With binning_region_increase_factor == 0, no tolerance-based slack
# is added, so a naive division by (max - min) would divide by zero
# and crash with InexactError trying to convert the resulting NaN to
# an Int32 bin index. This must not crash and must still deduplicate
# correctly.
function test_degenerate_region(dim; increase_factor = 0.0)
    bpl = BinnedPointList(dim; num_allowed_unbinned_points = 0, binning_region_increase_factor = increase_factor)
    n = 20
    pts = [collect(ntuple(k -> k == 1 ? Float64(i) : 0.0, dim)) for i in 1:n]
    for p in pts
        insert!(bpl, p)
    end
    for (i, p) in enumerate(pts)
        if insert!(bpl, p) != i
            return false
        end
    end
    return size(bpl.points, 2) == n
end

@test test_degenerate_region(1)
@test test_degenerate_region(2)
@test test_degenerate_region(3)

# A single repeatedly-inserted point is the most extreme degenerate
# case: the binning region is degenerate in *every* dimension.
function test_single_point_repeated(dim; increase_factor = 0.0)
    bpl = BinnedPointList(dim; num_allowed_unbinned_points = 0, binning_region_increase_factor = increase_factor)
    p = fill(1.0, dim)
    ix = [insert!(bpl, p) for i in 1:10]
    return all(==(1), ix) && size(bpl.points, 2) == 1
end

@test test_single_point_repeated(1)
@test test_single_point_repeated(2)
@test test_single_point_repeated(3)

# Points lying exactly on the boundary of the binning region (s == 0
# in some dimension) must map to a valid bin (bin index 1, not 0) so
# that they are found via the bin instead of incorrectly falling
# through to the (separately searched) unbinned list, which would
# break deduplication.
function test_boundary_point_dedup(dim)
    bpl = BinnedPointList(dim; num_allowed_unbinned_points = 0, binning_region_increase_factor = 0.0)
    n_unique = 7
    pts = [fill(Float64(i - 1), dim) for i in 1:n_unique]
    for p in pts, _ in 1:5
        insert!(bpl, p)
    end
    # With binning_region_increase_factor == 0, the binning region exactly
    # matches the data extrema, so the minimum coordinate value (0.0) now
    # sits exactly on the region boundary in every dimension.
    pmin = zeros(dim)
    ix1 = insert!(bpl, pmin)
    ix2 = insert!(bpl, pmin)
    return ix1 == ix2 && ix1 == 1 && size(bpl.points, 2) == n_unique
end

@test test_boundary_point_dedup(1)
@test test_boundary_point_dedup(2)
@test test_boundary_point_dedup(3)

# The element type of the internal point storage must match the
# type parameter T passed to BinnedPointList, not be silently
# promoted/hardcoded to Float64 (Cdouble).
function test_eltype_preserved(::Type{T}, dim) where {T}
    bpl = BinnedPointList(T, dim)
    insert!(bpl, fill(T(1), dim))
    return eltype(bpl.points) === T
end

@test test_eltype_preserved(Float32, 2)
@test test_eltype_preserved(Float64, 2)
@test test_eltype_preserved(BigFloat, 2)


using SimplexGridFactory, TetGen

function issue136(h1)
    builder = SimplexGridBuilder(; Generator = TetGen)

    r1 = 100
    r2 = 1000

    p00 = point!(builder, -r2, -r2, h1)
    p10 = point!(builder, r2, -r2, h1)
    p01 = point!(builder, -r2, r2, h1)
    p11 = point!(builder, r2, r2, h1)

    q00 = point!(builder, -r1, -r1, h1)
    q10 = point!(builder, r1, -r1, h1)
    q01 = point!(builder, -r1, r1, h1)
    q11 = point!(builder, r1, r1, h1)
    return isa(builder, SimplexGridBuilder)
end

@test issue136(-52645.0)
@test issue136(0.0)
