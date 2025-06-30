using Test, Aqua
using ExampleJuggler

using ExtendableGrids, SHA
using ExtendableGrids: seal!

using AbstractTrees, StatsBase

@testset "Aqua" begin
    Aqua.test_ambiguities([ExtendableGrids, Base, Core], exclude = [view, ==, StatsBase.TestStat, copyto!])
    Aqua.test_unbound_args(ExtendableGrids)
    Aqua.test_undefined_exports(ExtendableGrids)
    Aqua.test_project_extras(ExtendableGrids)
    Aqua.test_stale_deps(ExtendableGrids, ignore = [:Requires, :Bijections])
    Aqua.test_deps_compat(ExtendableGrids)
    Aqua.test_piracies(ExtendableGrids, treat_as_own = [AbstractTrees.children])
    Aqua.test_persistent_tasks(ExtendableGrids)
end


@testset "Constructors" begin
    # test whether the show() function throws an error
    @test show(ExtendableGrid{Float64, Int32}()) === nothing
end

@testset "Geomspace" begin
    function test_geomspace()
        X1 = geomspace(2.0, 3.0, 0.2, 0.2)
        X2 = collect(2:0.2:3)
        @assert X1 ≈ X2
        X1 = geomspace(2.0, 3.0, 0.1, 0.2)
        X2 = geomspace(2.0, 3.0, 0.2, 0.1)

        X1 = geomspace(2.0, 3.0, 1.0e-5, 0.2)
        X2 = geomspace(2.0, 3.0, 0.2, 1.0e-5)
        (X1[2] - X1[1]) ≈ (X2[end] - X2[end - 1]) &&
            (X2[2] - X2[1]) ≈ (X1[end] - X1[end - 1])
    end

    function test_geomspace1(n, h0, h1)
        for i in 1:n
            X = geomspace(0, 1, h0 * rand(), h1 * rand())
        end
        true
    end

    @test test_geomspace()
    @test test_geomspace1(100, 0.01, 0.01)
    @test test_geomspace1(100, 0.01, 0.1)
    @test test_geomspace1(100, 0.1, 0.01)
    @test test_geomspace1(100, 0.001, 0.1)

    @test length(geomspace(0, 1, 0.01, 0.1)) == 27
    @test length(geomspace(0, 1, 0.001, 0.1)) == 47
    @test length(geomspace(0, 1, 0.0001, 0.1)) == 68
    @test length(geomspace(0, 1, 0.00001, 0.1)) == 90
end

@testset "Basic" begin
    nodes = [
        0.0 1;
        1 0;
        0 1;
        1 1
    ]'

    cells = [
        1 2 3;
        2 3 4
    ]'

    cellmat = [1, 1]
    bfaces = [
        1 2;
        1 3;
        2 4
    ]'

    bfacemat = [1, 1]

    grid = simplexgrid(nodes, cells, cellmat, bfaces, bfacemat)
    @test isconsistent(grid)

    grid = simplexgrid(nodes, cells, cellmat, bfaces)
    @test isconsistent(grid)
    seal!(grid)
    @test isconsistent(grid)

    grid = simplexgrid(nodes, cells, cellmat)
    @test isconsistent(grid)
    seal!(grid)
    @test isconsistent(grid)

    grid = simplexgrid(nodes, cells)
    @test isconsistent(grid)
    seal!(grid)
    @test isconsistent(grid)

    @test let
        nodes = [
            0.0 1;
            1 0;
            0 1;
            1 1;
            1 2;
            2 4
        ]'

        cells = [
            1 2 3;
            2 3 4
        ]'

        cellmat = [1, 1]
        bfaces = [
            1 2;
            1 3;
            2 4
        ]'

        bfacemat = [1, 1]

        grid = simplexgrid(nodes, cells, cellmat, bfaces, bfacemat)
        !isconsistent(grid; warnonly = true)
    end

    function test_prepare_edges()
        ## Compared with pdelib; have more of these
        nodes = [
            0.0 1;
            1 0;
            0 1;
            1 1
        ]'

        cells = [
            1 2 3;
            2 3 4
        ]'

        cellmat = [1, 1]
        bfaces = [
            1 2;
            1 3;
            2 4
        ]'

        bfacemat = [1, 1]

        grid = simplexgrid(nodes, cells, cellmat, bfaces, bfacemat)

        grid[CellEdges] == Int32[1 2; 2 4; 3 5] &&
            grid[FaceNodes] == Int32[1 2 3 3 4; 2 3 1 4 2] &&
            grid[EdgeCells] == Int32[1 1 1 2 2; 0 2 0 0 0]
    end
    @test test_prepare_edges()

    @test let
        g = simplexgrid(0:10)
        bfc = g[BFaceCells]
        bfc[1, 1] == 1 && bfc[1, 2] == 10
    end

    @test let
        g = simplexgrid(0:10)
        bfn = g[BFaceNormals]
        bfn == [-1.0 1.0]
    end

    @test let
        g = simplexgrid(0:2, 0:2)
        bfn = g[BFaceNormals]
        bfn == [
            0.0 -1.0;
            -1.0 0.0;
            0.0 -1.0;
            1.0 0.0;
            0.0 1.0;
            -1.0 0.0;
            1.0 0.0;
            0.0 1.0
        ]'
    end

    @test let
        g = simplexgrid(0:2, 0:2)
        bfc = g[BFaceCells]
        tryfix(bfc) == [1 2 3 3 6 6 7 8;]
    end

    @test let
        X = [0 0; 2 0; 1 2; 1 0.5]'
        C = [1 2 4; 2 3 4; 3 1 4]'
        CR = ones(Int, 3)
        F = [1 2; 2 3; 3 1]'
        FR = [1, 2, 3]
        g = simplexgrid(X, C, CR, F, FR)
        bfc = g[BFaceCells]
        tryfix(bfc) == [1 2 3;]
    end
end

@testset "Base.map" begin
    X = 0:0.1:1
    fx(x) = x
    fxy(x, y) = x + y
    fxyz(x, y, z) = x + y + z
    fv(v) = sum(v)
    gx = simplexgrid(X)
    gxy = simplexgrid(X, X)
    gxyz = simplexgrid(X, X, X)
    @test map(fx, gx) == map(fv, gx)
    @test map(fxy, gxy) == map(fv, gxy)
    @test map(fxyz, gxyz) == map(fv, gxyz)

    vfx(x) = [x]
    vfxy(x, y) = [x, y]
    vfxyz(x, y, z) = [x, y, z]
    vfv(v) = v
    @test map(vfx, gx) == map(x -> [vfv(x)], gx)
    @test map(vfxy, gxy) == map(vfv, gxy)
    @test map(vfxyz, gxyz) == map(vfv, gxyz)
end

function testrw(grid, format; confidence = :full, kwargs...)
    #@warn format
    ftmp = tempname() * "." * format
    write(ftmp, grid; kwargs...)
    grid1 = simplexgrid(ftmp)
    return seemingly_equal(grid1, grid; confidence = confidence)
end

@testset "Read/Write sg" begin
    X = collect(0:0.05:1)
    for version in [v"2.1", v"2.2"]
        @test testrw(simplexgrid(X), "sg"; version)
        @test testrw(simplexgrid(X, X), "sg"; version)
        @test testrw(simplexgrid(X, X, X), "sg"; version)
    end
end

@testset "rectnd" begin
    function rect1d()
        X = collect(0:0.1:1)
        g = simplexgrid(X)
        rect!(g, [0.3], [0.6]; region = 2, bregions = [3, 4])
    end

    function rect2d()
        X = collect(0:0.1:1)
        g = simplexgrid(X, X)
        rect!(g, [0.3, 0.3], [0.6, 0.6]; region = 2, bregions = [3, 4, 5, 6])
    end

    function rect3d()
        X = collect(0:0.1:1)
        g = simplexgrid(X, X, X)
        rect!(g, [0.3, 0.3, 0.4], [0.6, 0.6, 0.7]; region = 2, bregion = 8)
        g
    end

    @test numbers_match(rect1d(), 11, 10, 4)
    @test numbers_match(rect2d(), 121, 200, 52)
    @test numbers_match(rect3d(), 1331, 6000, 1308)
end

@testset "subgrid+extrusion" begin
    function subgen(; region = 1, h = 0.2)
        X = collect(-1:h:2)
        Y = collect(0:h:1)
        Z = collect(0:h:2)
        g = simplexgrid(X, Y, Z)
        # Mark all boundaries as region 1
        bfacemask!(g, [-1, 0, 0], [2, 1, 2], 1; allow_new = false)

        # Default cell region is 1
        # Mark cut-out regions as 2
        cellmask!(g, [-1, 0, 0], [0, 1, 1], 2)
        cellmask!(g, [1, 0, 0], [2, 1, 1], 2)
        # Mark interior region 3 with region 2
        cellmask!(g, [-0.75, 0.25, 0.25], [-0.25, 0.75, 0.75], 3)

        # add new interface elements
        bfacemask!(g, [-1, 0, 1], [2, 1, 1], 3; allow_new = true)
        bfacemask!(g, [0, 0, 0], [0, 1, 1], 3; allow_new = true)
        bfacemask!(g, [1, 0, 0], [1, 1, 1], 3; allow_new = true)

        # return subgrid of region 1
        subgrid(g, [region])
    end
    sub2 = subgen(; region = 3)

    @test numbers_match(subgen(), 756, 3000, 950)

    X = collect(0:0.25:1)
    gxy = simplexgrid(X, X)
    gxyz = simplexgrid(gxy, X)
    g = simplexgrid(X, X, X)
    @test numbers_match(gxyz, 125, 384, 192)
    @test g[Coordinates] ≈ gxyz[Coordinates]
end


@testset "ParentGridRelation-SubGrid" begin
    ## generate a subgrid
    grid = grid_unitsquare(Triangle2D)
    grid[CellRegions] = Int32[1, 2, 2, 1]
    sgrid = subgrid(grid, [1])
    @test sgrid[ParentGridRelation] == SubGrid{ON_CELLS}

    ## check if CellParents are assigned correctly
    @test sgrid[CellParents] == [1, 4]

    ## check if FaceNodes couple correctly with FaceNodes in parent grid
    facenodes = sgrid[FaceNodes]
    bfacenodes = sgrid[BFaceNodes]
    parentnodes = sgrid[NodeInParent]
    parentfaces = sgrid[FaceParents]
    parentbfaces = sgrid[BFaceParents]
    @test all(parentnodes[facenodes] .== grid[FaceNodes][:, parentfaces])
    @test all(parentnodes[bfacenodes] .== grid[BFaceNodes][:, parentbfaces])
end

@testset "ParentGridRelation-RefinedGrid" begin
    ## generate a refined
    grid = grid_unitsquare(Triangle2D)

    ## check uniform refinement
    rgrid = uniform_refine(grid)
    @test rgrid[ParentGridRelation] == RefinedGrid

    ## check if CellParents and BFaceParents are set
    @test length(rgrid[CellParents]) == 4 * num_cells(grid)
    @test length(rgrid[BFaceParents]) == 2 * num_bfaces(grid)

    ## check barycentric refinement
    rgrid = barycentric_refine(grid)
    @test rgrid[ParentGridRelation] == RefinedGrid

    ## check if CellParents and BFaceParents are set
    @test length(rgrid[CellParents]) == 3 * num_cells(grid)
    @test length(rgrid[BFaceParents]) == num_bfaces(grid)


end


@testset "        BinnedPointList" begin
    include("testbinned.jl")
end

function tglue(; dim = 2, breg = 0)
    X1 = linspace(0, 1, 5)
    Y1 = linspace(0, 1, 5)
    Z1 = linspace(0, 1, 5)

    X2 = linspace(1, 2, 5)
    Y2 = linspace(0, 0.5, 3)
    Z2 = linspace(0, 0.5, 3)

    if dim == 1
        g1 = simplexgrid(X1)
        g2 = simplexgrid(X2)
    end

    if dim == 2
        g1 = simplexgrid(X1, Y1)
        g2 = simplexgrid(X2, Y2)
    end

    if dim == 3
        g1 = simplexgrid(X1, Y1, Z1)
        g2 = simplexgrid(X2, Y2, Z2)
    end

    return glue(g1, g2; interface = breg)
end

@testset "Glue" begin
    @test numbers_match(tglue(; dim = 1, breg = 0), 9, 8, 2)
    @test numbers_match(tglue(; dim = 1, breg = 1), 9, 8, 3)
    @test numbers_match(tglue(; dim = 2, breg = 0), 37, 48, 24)
    @test numbers_match(tglue(; dim = 2, breg = 1), 37, 48, 26)
    @test numbers_match(tglue(; dim = 3, breg = 0), 161, 480, 256)
    @test numbers_match(tglue(; dim = 3, breg = 1), 161, 480, 264)
end

include("tritet.jl")

include("gmsh.jl")

include("partitioning.jl")

ExampleJuggler.verbose!(true)

@testset "Examples" begin
    @testscripts(joinpath(@__DIR__, "..", "examples"), ["examples1d.jl", "examples2d.jl", "examples3d.jl", "gmsh.jl"])
end

function voronoitest()
    g = simplexgrid(0:0.1:1)
    @test g[VoronoiFaceCenters] ≈ [0.05 0.15 0.25 0.35 0.45 0.55 0.65 0.75 0.85 0.95]
    g = simplexgrid(0:0.5:1, 0:0.5:1)
    return @test g[VoronoiFaceCenters] ≈ [
        0.25 0.5 0.25 0.25 0.0 0.75 1.0 0.75 0.75 0.5 0.25 0.25 0.0 1.0 0.75 0.75;
        0.0 0.25 0.25 0.5 0.25 0.0 0.25 0.25 0.5 0.75 0.75 1.0 0.75 0.75 0.75 1.0
    ]
end

@testset "Voronoi" begin
    voronoitest()
end

@testset "Grid Stuff" begin
    include("test_gridstuff.jl")
    run_grid_tests()
end

@testset "Interpolations" begin
    X_from = collect(0:0.1:1)
    X_to = collect(0:0.02:1)

    grid_from = simplexgrid(X_from)
    grid_to = simplexgrid(X_to)
    u_from = map((x) -> x, grid_from)
    u_to_exact = map((x) -> x, grid_to)
    u_to = interpolate(grid_to, u_from, grid_from)
    @test u_to ≈ u_to_exact

    u_from = Matrix(hcat(u_from, u_from)')
    u_to_exact = Matrix(hcat(u_to_exact, u_to_exact)')
    u_to = interpolate(grid_to, u_from, grid_from)
    @test u_to ≈ u_to_exact

    grid_from = simplexgrid(X_from, X_from)
    grid_to = simplexgrid(X_to, X_to)
    u_from = map((x, y) -> x + y, grid_from)
    u_to_exact = map((x, y) -> x + y, grid_to)
    u_to = interpolate(grid_to, u_from, grid_from)
    @test u_to ≈ u_to_exact

    u_from = Matrix(hcat(u_from, u_from)')
    u_to_exact = Matrix(hcat(u_to_exact, u_to_exact)')
    u_to = interpolate(grid_to, u_from, grid_from)
    @test u_to ≈ u_to_exact

    grid_from = simplexgrid(X_from, X_from, X_from)
    grid_to = simplexgrid(X_to, X_to, X_to)
    u_from = map((x, y, z) -> x + y + z, grid_from)
    u_to_exact = map((x, y, z) -> x + y + z, grid_to)
    u_to = interpolate(grid_to, u_from, grid_from)
    @test u_to ≈ u_to_exact

    u_from = Matrix(hcat(u_from, u_from)')
    u_to_exact = Matrix(hcat(u_to_exact, u_to_exact)')
    u_to = interpolate(grid_to, u_from, grid_from)
    @test u_to ≈ u_to_exact
end

@testset "writeVTK" begin
    X = collect(-1:1.0:1)
    Y = collect(-1:1.0:1)
    Z = collect(-2:1.0:2)
    g = simplexgrid(X, Y, Z)

    nx = num_nodes(g)
    nc = num_cells(g)

    # ensure calculation of these data is free of roundoff errors
    point_data = map((x, y, z) -> (x + y + z), g)
    field_data = [1.0, 2, 3, 4, 5, 6]

    writeVTK(
        "testfile_writevtk.vtu", g;
        cellregions = g[CellRegions],
        point_data = point_data,
        field_data = field_data
    )

    sha_code = open("testfile_writevtk.vtu") do f
        sha256(f)
    end |> bytes2hex

    @test sha_code == "9596c59f6b0870dd4a42a7a48725c2257f260757e15cc5ac433e5e8e235659d9"
end


if VERSION < v"1.12.0-DEV.0"
    notebooks = ["pluto-partitioning.jl"]
    @testset "Notebooks" begin
        @testscripts(joinpath(@__DIR__, "..", "examples"), notebooks)
    end
end


@testset "trim!" begin

    grid = grid_unitcube(Tetrahedron3D)

    component_list = [
        BEdgeAssemblyGroups,
        BEdgeEdges,
        BEdgeGeometries,
        BEdgeNodes,
        BEdgeRegions,
        BEdgeVolumes,
        BFaceAssemblyGroups,
        BFaceCellPos,
        BFaceCells,
        BFaceEdges,
        BFaceFaces,
        BFaceNormals,
        BFaceVolumes,
        CellAssemblyGroups,
        CellEdges,
        CellEdgeSigns,
        CellFaceOrientations,
        CellFaces,
        CellFaceSigns,
        CellVolumes,
        EdgeAssemblyGroups,
        EdgeCells,
        EdgeGeometries,
        EdgeNodes,
        EdgeRegions,
        EdgeTangents,
        EdgeVolumes,
        FaceAssemblyGroups,
        FaceCells,
        FaceEdges,
        FaceEdgeSigns,
        FaceGeometries,
        FaceNodes,
        FaceNormals,
        FaceRegions,
        FaceVolumes,
        NodeCells,
        NodeEdges,
        NodeFaces,
        NodePatchGroups,
        NumBEdgeRegions,
        NumBFaceRegions,
        NumCellRegions,
        UniqueBEdgeGeometries,
        UniqueBFaceGeometries,
        UniqueCellGeometries,
        UniqueEdgeGeometries,
        UniqueFaceGeometries,
    ]

    # init components
    for c in component_list
        grid[c]
    end

    # trim all components, except a few
    grid = ExtendableGrids.trim(grid, keep = [BFaceNormals, NodeCells])

    @test haskey(grid, BFaceNormals)
    @test haskey(grid, NodeCells)

    # trim everything
    grid = ExtendableGrids.trim(grid)

    @test all([!haskey(grid, c) for c in component_list])
end
