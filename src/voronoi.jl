##################################################################
"""
$(SIGNATURES)

Find the circumcenter of a triangle.                 
									 
Derived from C source of Jonathan R Shewchuk <jrs@cs.cmu.edu>

Modified to return absolute coordinates.
"""
function tricircumcenter!(circumcenter, a, b, c)

    # Use coordinates relative to point `a' of the triangle.
    xba = b[1] - a[1]
    yba = b[2] - a[2]
    xca = c[1] - a[1]
    yca = c[2] - a[2]

    # Squares of lengths of the edges incident to `a'.
    balength = xba * xba + yba * yba
    calength = xca * xca + yca * yca

    # Calculate the denominator of the formulae.
    # if EXACT
    #    Use orient2d() from http://www.cs.cmu.edu/~quake/robust.html
    #    to ensure a correctly signed (and reasonably accurate) result,
    #    avoiding any possibility of division by zero.
    #  denominator = 0.5 / orient2d((double*) b, (double*) c, (double*) a)


    # Take your chances with floating-point roundoff
    denominator = 0.5 / (xba * yca - yba * xca)

    # Calculate offset (from `a') of circumcenter.
    xcirca = (yca * balength - yba * calength) * denominator
    ycirca = (xba * calength - xca * balength) * denominator


    # The result is returned both in terms of x-y coordinates and xi-eta
    # coordinates, relative to the triangle's point `a' (that is, `a' is
    # the origin of both coordinate systems).	 Hence, the x-y coordinates
    # returned are NOT absolute; one must add the coordinates of `a' to
    # find the absolute coordinates of the circumcircle.  However, this means
    # that the result is frequently more accurate than would be possible if
    # absolute coordinates were returned, due to limited floating-point
    # precision.  In general, the circumradius can be computed much more
    # accurately.


    circumcenter[1] = xcirca + a[1]
    circumcenter[2] = ycirca + a[2]

    return circumcenter
end


"""
$(TYPEDEF)

Centers of voronoi cell facets (currently 1D, 2D).
"""
abstract type VoronoiFaceCenters <: AbstractGridFloatArray2D  end


function instantiate(grid::ExtendableGrid{Tc, Ti}, ::Type{VoronoiFaceCenters}) where {Tc, Ti}
    coord = grid[Coordinates]
    en = grid[EdgeNodes]
    nedges = size(en, 2)
    dim = size(coord, 1)
    xsigma = zeros(Tc, dim, nedges)

    if dim == 1
        for iedge in 1:nedges
            en1 = en[1, iedge]
            en2 = en[2, iedge]
            xsigma[1, iedge] = 0.5 * (coord[1, en1] + coord[1, en2])
        end
    elseif dim == 2
        cn = grid[CellNodes]
        ec = grid[EdgeCells]
        cc1 = zeros(2)
        cc2 = zeros(2)
        for iedge in 1:nedges
            icell1 = ec[1, iedge]
            icell2 = ec[2, iedge]

            # calculate voronoi face ends: either  cellcenter -- cellcenter or cellcenter --edgecenter
            @views tricircumcenter!(
                cc1,
                coord[:, cn[1, icell1]],
                coord[:, cn[2, icell1]],
                coord[:, cn[3, icell1]]
            )
            if icell2 > 0
                @views tricircumcenter!(
                    cc2,
                    coord[:, cn[1, icell2]],
                    coord[:, cn[2, icell2]],
                    coord[:, cn[3, icell2]]
                )

                @views xsigma[:, iedge] .= 0.5 * (cc1 + cc2)
            else
                inode1 = en[1, iedge]
                inode2 = en[2, iedge]
                @views cc2 .= 0.5 * (coord[:, inode1] + coord[:, inode2])
                @views xsigma[:, iedge] .= cc2
            end
            # We observe artifacts at domain corners if we use
            # this expression which would be consistent to the formal approach.
            # @views xsigma[:,iedge].=0.5*(cc1+cc2)
        end
    else
        error("3D Voronoi Face Centers not implemented yet")
    end
    return xsigma
end
