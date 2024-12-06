using Test
using ExtendableGrids

# This is the way how we can extend the grid type: define a new
# type, and either add the corresponding value or allow for
# lazy creation using the instantiate method

# Introduce an abstract type denoting the component
abstract type NodeCells <: AbstractGridAdjacency end

# Write an instantiate method which constructs the component if it is not available
ExtendableGrids.instantiate(grid, ::Type{NodeCells}) = atranspose(grid[CellNodes])

function test_create_circle(; nref = 5)
    nrad = 10 * 2^nref
    return grid = generate(
        points = reduce(hcat, [ [cos(2 * pi * i / nrad), sin(2 * pi * i / nrad)] for i in 1:nrad]),
        bfaces = reduce(hcat, vcat([ [i, i + 1] for i in 1:(nrad - 1)], [[nrad, 1]])),
        bfaceregions = ones(nrad),
        regionpoints = [0.0 0.0;],
        regionnumbers = [1],
        regionvolumes = [0.1 * 2.0^(-2 * nref)]
    )
end


function test_create_square(; nref = 3)
    points = [
        [-2.0 -2];
        [2 -2];
        [2 2];
        [-2 2];
        [-1 -1];
        [1 -1];
        [1 1];
        [-1 1]
    ]

    bfaces = [
        [0 1];
        [1 2];
        [2 3];
        [3 0];

        [4 5];
        [5 6];
        [6 7];
        [7 4]
    ] .+ 1


    bfaceregions = [1, 2, 3, 4, 5, 5, 5, 5]

    regionpoints = [
        [-1.5 -1.5];
        [0.0 0.0]
    ]
    regionnumbers = [1, 2]
    regionvolumes = [1.0 * 2.0^(-nref), 1.0 * 2.0^(-nref)]


    return grid = generate(
        points = points,
        bfaces = bfaces,
        bfaceregions = bfaceregions,
        regionpoints = regionpoints,
        regionnumbers = regionnumbers,
        regionvolumes = regionvolumes,
        flags = "pqaAD"
    )
end

function test_lazy(grid)
    return nodecells = grid[NodeCells]
end


function sum_adj(a, n)
    sum = 0
    for isource in 1:num_sources(a)
        for itarget in 1:num_targets(a, isource)
            sum += a[itarget, isource]
        end
    end
    return sum
end

function test_performance(grid)
    cellnodes = grid[CellNodes]
    n = num_sources(cellnodes)
    @time begin
        sum = 0
        for isource in 1:num_sources(cellnodes)
            for itarget in 1:num_targets(cellnodes, isource)
                sum += cellnodes[itarget, isource]
            end
        end
    end
    @time sum_adj(cellnodes, n)
    vadj = VariableTargetAdjacency(cellnodes)
    @time sum_adj(vadj, n)
    matrix = Matrix(cellnodes)
    @time sum_adj(matrix, n)
    return nothing
end


function test_performance2(grid)
    sum = 0
    @time begin
        sum = 0
        for isource in 1:num_sources(grid[CellNodes])
            for itarget in 1:num_targets(grid[CellNodes], isource)
                sum += grid[CellNodes][itarget, isource]
            end
        end
    end
    @show sum
    cellnodes = grid[CellNodes]
    @time begin
        sum = 0
        for isource in 1:num_sources(cellnodes)
            for itarget in 1:num_targets(cellnodes, isource)
                sum += cellnodes[itarget, isource]
            end
        end
    end
    @show sum
    return nothing
end
