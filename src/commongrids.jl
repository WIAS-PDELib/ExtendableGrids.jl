#####################
# REFERENCE DOMAINS #
#####################

"""
````
    reference_domain(EG::Type{<:AbstractElementGeometry}, T::Type{<:Real} = Float64; scale = [1,1,1], shift = [0,0,0]) -> ExtendableGrid{T,Int32}
````

Generates an ExtendableGrid{T,Int32} for the reference domain of the specified Element Geometry. With scale and shift the coordinates can be manipulated.
"""
function reference_domain(EG::Type{<:AbstractElementGeometry}, T::Type{<:Real} = Float64; scale = [1, 1, 1], shift = [0, 0, 0])
    xgrid = ExtendableGrid{T, Int32}()
    xCoordinates = Array{T, 2}(refcoords_for_geometry(EG))
    for j in 1:size(xCoordinates, 1)
        xCoordinates[j, :] .+= shift[j]
        xCoordinates[j, :] .*= scale[j]
    end
    xgrid[Coordinates] = xCoordinates
    xCellNodes = zeros(Int32, num_nodes(EG), 1)
    xCellNodes[:] = 1:num_nodes(EG)
    xgrid[CellNodes] = xCellNodes
    xgrid[CellGeometries] = VectorOfConstants{ElementGeometries, Int}(EG, 1)
    xgrid[CellRegions] = ones(Int32, 1)
    xgrid[BFaceRegions] = Array{Int32, 1}(1:num_faces(EG))
    xgrid[BFaceNodes] = Array{Int32, 2}(local_cellfacenodes(EG))
    xgrid[BFaceGeometries] = VectorOfConstants{ElementGeometries, Int}(facetype_of_cellface(EG, 1), num_faces(EG))
    if dim_element(EG) == 0
        xgrid[CoordinateSystem] = Cartesian0D
    elseif dim_element(EG) == 1
        xgrid[CoordinateSystem] = Cartesian1D
    elseif dim_element(EG) == 2
        xgrid[CoordinateSystem] = Cartesian2D
    elseif dim_element(EG) == 3
        xgrid[CoordinateSystem] = Cartesian3D
    end
    return xgrid
end

"""
    grid_triangle(coords::AbstractArray{T,2}) where {T}

Generates a single triangle with the given coordinates, that should be a 2 x 3 array
with the coordinates of the three vertices, e.g. coords = [0.0 0.0; 1.0 0.0; 0.0 1.0]'.
"""
function grid_triangle(coords::AbstractArray{T, 2}) where {T}
    xgrid = reference_domain(Triangle2D)
    xgrid[Coordinates] = coords
    return xgrid
end

"""
    grid_unitcube(EG::Type{<:Hexahedron3D}; scale = [1,1,1], shift = [0,0,0])

Unit cube as one cell with six boundary regions (bottom, front, right, back, left, top)
"""
function grid_unitcube(EG::Type{<:Hexahedron3D}; scale = [1, 1, 1], shift = [0, 0, 0])
    return reference_domain(EG; scale = scale, shift = shift)
end

"""
    grid_unitcube(::Type{Tetrahedron3D}; scale = [1,1,1], shift = [0,0,0])

Unit cube as six tets with six boundary regions (bottom, front, right, back, left, top)
"""
function grid_unitcube(::Type{Tetrahedron3D}; scale = [1, 1, 1], shift = [0, 0, 0])
    xgrid = ExtendableGrid{Float64, Int32}()
    xCoordinates = Array{Float64, 2}([0 0 0; 1 0 0; 1 1 0; 0 1 0; 0 0 1; 1 0 1; 1 1 1; 0 1 1]')
    for j in 1:size(xCoordinates, 1)
        xCoordinates[j, :] .+= shift[j]
        xCoordinates[j, :] .*= scale[j]
    end
    xgrid[Coordinates] = xCoordinates

    xCellNodes = Array{Int32, 2}([1 2 3 7; 1 3 4 7; 1 5 6 7; 1 8 5 7; 1 6 2 7;1 4 8 7]')
    xgrid[CellNodes] = xCellNodes
    xgrid[CellGeometries] = VectorOfConstants{ElementGeometries, Int}(Tetrahedron3D, 6)
    ncells = num_sources(xCellNodes)
    xgrid[CellRegions] = ones(Int32, ncells)
    xgrid[BFaceRegions] = Array{Int32, 1}([1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6])
    xBFaceNodes = Array{Int32, 2}([1 3 2; 1 4 3; 1 2 6;1 6 5;2 3 7;2 7 6;3 4 7;7 4 8;8 4 1;1 5 8; 5 6 7; 5 7 8]')
    xgrid[BFaceNodes] = xBFaceNodes
    nbfaces = num_sources(xBFaceNodes)
    xgrid[BFaceGeometries] = VectorOfConstants{ElementGeometries, Int}(Triangle2D, nbfaces)
    xgrid[CoordinateSystem] = Cartesian3D
    return xgrid
end

"""
    grid_unitsquare(EG::Type{<:Quadrilateral2D}; scale = [1,1], shift = [0,0])
Unit square as one cell with four boundary regions (bottom, right, top, left)
"""
function grid_unitsquare(EG::Type{<:Quadrilateral2D}; scale = [1, 1], shift = [0, 0])
    return reference_domain(EG; scale = scale, shift = shift)
end

"""
    grid_unitsquare(::Type{<:Triangle2D}; scale = [1,1], shift = [0,0])
Unit square as two triangles with four boundary regions (bottom, right, top, left)
"""
function grid_unitsquare(::Type{<:Triangle2D}; scale = [1, 1], shift = [0, 0])
    xgrid = ExtendableGrid{Float64, Int32}()
    xCoordinates = Array{Float64, 2}([0 0; 1 0; 1 1; 0 1; 0.5 0.5]')
    for j in 1:size(xCoordinates, 1)
        xCoordinates[j, :] .+= shift[j]
        xCoordinates[j, :] .*= scale[j]
    end
    xgrid[Coordinates] = xCoordinates
    xgrid[CellNodes] = Array{Int32, 2}([1 2 5; 2 3 5; 3 4 5; 4 1 5]')
    xgrid[CellGeometries] = VectorOfConstants{ElementGeometries, Int}(Triangle2D, 4)
    xgrid[CellRegions] = ones(Int32, 4)
    xgrid[BFaceRegions] = Array{Int32, 1}([1, 2, 3, 4])
    xgrid[BFaceNodes] = Array{Int32, 2}([1 2; 2 3; 3 4; 4 1]')
    xgrid[BFaceGeometries] = VectorOfConstants{ElementGeometries, Int}(Edge1D, 4)
    xgrid[CoordinateSystem] = Cartesian2D
    return xgrid
end


"""
    grid_lshape(::Type{<:Triangle2D}; scale = [1,1], shift = [0,0])
Lshape domain
"""
function grid_lshape(::Type{<:Triangle2D}; scale = [1, 1], shift = [0, 0])
    xgrid = ExtendableGrid{Float64, Int32}()
    xCoordinates = Array{Float64, 2}([0 0; 1 0; 1 1; 0 1; -1 1; -1 0; -1 -1; 0 -1]')
    for j in 1:size(xCoordinates, 1)
        xCoordinates[j, :] .+= shift[j]
        xCoordinates[j, :] .*= scale[j]
    end
    xgrid[Coordinates] = xCoordinates
    xgrid[CellNodes] = Array{Int32, 2}([4 2 3; 2 4 1; 6 4 5; 4 6 1; 6 8 1; 8 6 7]')
    xgrid[CellGeometries] = VectorOfConstants{ElementGeometries, Int}(Triangle2D, 6)
    xgrid[CellRegions] = Array{Int32, 1}([1, 1, 1, 1, 1, 1])
    xgrid[BFaceRegions] = Array{Int32, 1}([1, 2, 3, 4, 5, 6, 7, 8])
    xgrid[BFaceNodes] = Array{Int32, 2}([1 2; 2 3; 3 4; 4 5; 5 6; 6 7; 7 8; 8 1]')
    xgrid[BFaceGeometries] = VectorOfConstants{ElementGeometries, Int}(Edge1D, 8)
    xgrid[CoordinateSystem] = Cartesian2D
    return xgrid
end

"""
    grid_unitsquare_mixedgeometries()

Unit suqare as mixed triangles and squares with four boundary regions (bottom, right, top, left)
"""
function grid_unitsquare_mixedgeometries()

    xgrid = ExtendableGrid{Float64, Int32}()
    xgrid[Coordinates] = Array{Float64, 2}([0 0; 4 // 10 0; 1 0; 0 6 // 10; 4 // 10 6 // 10; 1 6 // 10;0 1; 4 // 10 1; 1 1]')
    xCellNodes = VariableTargetAdjacency(Int32)
    xCellGeometries = ElementGeometries[Triangle2D, Triangle2D, Parallelogram2D, Parallelogram2D, Triangle2D, Triangle2D]

    append!(xCellNodes, [1, 5, 4])
    append!(xCellNodes, [1, 2, 5])
    append!(xCellNodes, [2, 3, 6, 5])
    append!(xCellNodes, [4, 5, 8, 7])
    append!(xCellNodes, [5, 6, 9])
    append!(xCellNodes, [8, 5, 9])

    xgrid[CellNodes] = xCellNodes
    xgrid[CellGeometries] = xCellGeometries
    ncells = num_sources(xCellNodes)
    xgrid[CellRegions] = ones(Int32, ncells)
    xgrid[BFaceRegions] = Array{Int32, 1}([1, 1, 2, 2, 3, 3, 4, 4])
    xBFaceNodes = Array{Int32, 2}([1 2; 2 3; 3 6; 6 9; 9 8; 8 7; 7 4; 4 1]')
    xgrid[BFaceNodes] = xBFaceNodes
    nbfaces = num_sources(xBFaceNodes)
    xgrid[BFaceGeometries] = VectorOfConstants{ElementGeometries, Int}(Edge1D, nbfaces)
    xgrid[CoordinateSystem] = Cartesian2D

    return xgrid
end


"""
    ringsector(rad,ang; eltype=Triangle2D)

Sector of ring or full ring (if  `ang[begin]-ang[end]≈2π`)
"""
function ringsector(rad, ang; eltype = Triangle2D)
    Tv = Float32
    Ti = Int32

    coord = ElasticArray{Tv, 2}(undef, 2, 0)
    cells = ElasticArray{Ti, 2}(undef, 3, 0)
    bfaces = ElasticArray{Ti, 2}(undef, 2, 0)
    bfaceregions = Vector{Ti}(undef, 0)
    cellregions = Vector{Ti}(undef, 0)

    nrad = length(rad)
    icell = 0
    ibface = 0

    fullcircle = ang[end] - ang[1] ≈ 2π

    narc = length(ang)

    for iarc in 1:narc
        ϕ = ang[iarc]
        x = cos(ϕ)
        y = sin(ϕ)
        for irad in 1:nrad
            append!(coord, (rad[irad] * x, rad[irad] * y))
            icoord = size(coord, 2)
            if irad < nrad
                if iarc < narc
                    i1 = icoord
                    i2 = i1 + 1
                    if fullcircle && iarc == narc - 1
                        i3 = irad
                        i4 = irad + 1
                    else
                        i3 = i1 + nrad
                        i4 = i2 + nrad
                    end
                    append!(cells, (i1, i2, i3))
                    push!(cellregions, 1)
                    append!(cells, (i3, i2, i4))
                    push!(cellregions, 1)
                end
            end
            if irad == 1 && iarc < narc
                if fullcircle && iarc == narc - 1
                    append!(bfaces, (icoord, 1))
                else
                    append!(bfaces, (icoord, icoord + nrad))
                end
                push!(bfaceregions, 1)
            end
            if irad == nrad && iarc < narc
                if fullcircle && iarc == narc - 1
                    append!(bfaces, (icoord, irad))
                else
                    append!(bfaces, (icoord, icoord + nrad))
                end
                push!(bfaceregions, 2)
            end

            if !fullcircle
                if iarc == 1 && irad < nrad
                    append!(bfaces, (icoord, icoord + 1))
                    push!(bfaceregions, 3)
                end

                if iarc == narc && irad < nrad
                    append!(bfaces, (icoord, icoord + 1))
                    push!(bfaceregions, 4)
                end
            end
        end
    end
    return simplexgrid(coord, cells, cellregions, bfaces, bfaceregions)
end
