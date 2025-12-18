using ExtendableGrids
using Test

@testset "explode function tests" begin
    # create a grid
    grid = uniform_refine(grid_unitcube(Tetrahedron3D), 3)

    # Test explode function
    exploded_grid = explode(grid)

    # Verify results
    @test num_cells(exploded_grid) == num_cells(grid)
    @test num_nodes(exploded_grid) == 4 * num_cells(grid) # 4 tetrahedron corners for each cell

    # Verify coordinates are preserved
    original_coords = Set([Tuple(grid[Coordinates][:, i]) for i in 1:size(grid[Coordinates], 2)])
    exploded_coords = Set([Tuple(exploded_grid[Coordinates][:, i]) for i in 1:size(exploded_grid[Coordinates], 2)])
    @test original_coords == exploded_coords

    # Verify regions are preserved
    @test exploded_grid[CellRegions] == grid[CellRegions]

    # Verify parent relation
    @test exploded_grid[ParentGrid] === grid
end
