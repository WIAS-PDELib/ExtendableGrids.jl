using ExtendableGrids

function grid3D_test(filename::String)
    X = collect(0:0.1:1)
    Y = collect(0:0.1:2)
    Z = collect(0:0.1:3)
    g = simplexgrid(X, Y, Z)

    point_data = map((x, y, z) -> (sinpi(2 * x) * sinpi(2 * y) * z), g)
    nc = num_cells(g)
    field_data = [1, 2, 3, 4, 5, 6]
    cell_data = rand(Float64, nc)

    writeVTK(
        filename, g, true; point_data = point_data,
        cell_data = cell_data,
        field_data = field_data
    )
    return nothing

end

function grid2D_test(filename::String)
    X = collect(0:0.1:1)
    Y = collect(0:0.1:2)
    g = simplexgrid(X, Y)

    point_data = map((x, y) -> (sinpi(2 * x) * sinpi(2 * y)), g)
    nc = num_cells(g)
    field_data = [1, 2, 3, 4, 5, 6]
    cell_data = rand(Float64, nc)

    writeVTK(
        "output.vtu", g, true; point_data = point_data,
        cell_data = cell_data,
        field_data = field_data
    )
    return nothing
end

function grid1D_test(filename::String)
    X = collect(0:0.01:1)

    g = simplexgrid(X)

    point_data = map((x) -> (sinpi(2 * x)), g)
    nc = num_cells(g)
    field_data = [1, 2, 3, 4, 5, 6]
    cell_data = rand(Float64, nc)

    writeVTK(
        filename::String, g, true; point_data = point_data,
        cell_data = cell_data,
        field_data = field_data
    )
    return nothing
end
