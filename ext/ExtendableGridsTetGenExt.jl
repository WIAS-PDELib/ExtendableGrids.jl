module ExtendableGridsTetGenExt

using TetGen
import ExtendableGrids: simplexgrid

function simplexgrid(tio::RawTetGenIO; flags = nothing)
    if !isnothing(flags)
        tetout = TetGen.tetrahedralize(tio, flags)
    else
        tetout = tio
    end

    pointlist = tetout.pointlist

    tetrahedronlist = tetout.tetrahedronlist

    if size(tetout.tetrahedronattributelist, 2) == 0
        cellregions = ones(Int32, size(tetrahedronlist, 2))
    else
        cellregions = Vector{Int32}(vec(tetout.tetrahedronattributelist))
    end

    segmentlist = tetout.trifacelist

    segmentmarkerlist = tetout.trifacemarkerlist

    return simplexgrid(pointlist, tetrahedronlist, cellregions, segmentlist, segmentmarkerlist)
end

end
