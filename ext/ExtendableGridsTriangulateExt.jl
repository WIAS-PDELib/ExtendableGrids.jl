module ExtendableGridsTriangulateExt

using Triangulate

import ExtendableGrids: simplexgrid

function simplexgrid(tio::TriangulateIO; flags = nothing)
    if !isnothing(flags)
        triout, vorout = Triangulate.triangulate(tio, flags)
    else
        triout = tio
    end

    pointlist = triout.pointlist

    trianglelist = triout.trianglelist

    if size(triout.triangleattributelist, 2) == 0
        # Add default for cellregions if that was not created
        cellregions = ones(Int32, size(trianglelist, 2))
    else
        cellregions = Vector{Int32}(vec(triout.triangleattributelist))
    end

    segmentlist = triout.segmentlist

    segmentmarkerlist = triout.segmentmarkerlist

    if size(pointlist, 2) == 0
        error("Empty list of generated points. May be the geometry description is not watertight ?") |> throw
    end

    if size(trianglelist, 2) == 0
        error("Empty list of generated triangles. May be the geometry description is not watertight ?") |> throw
    end

    return simplexgrid(pointlist, trianglelist, cellregions, segmentlist, segmentmarkerlist)
end

end
