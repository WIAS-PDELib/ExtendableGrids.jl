using Gmsh: gmsh
gmsh.initialize()

@testset "access gmsh" begin
    gmsh.option.setNumber("General.Terminal", 1)
    gmsh.model.add("t1")

    lc = 1e-2
    gmsh.model.geo.addPoint(0, 0, 0, lc, 1)
    gmsh.model.geo.addPoint(0.1, 0, 0, lc, 2)
    gmsh.model.geo.addPoint(0.1, 0.3, 0, lc, 3)

    p4 = gmsh.model.geo.addPoint(0, 0.3, 0, lc)

    gmsh.model.geo.addLine(1, 2, 1)
    gmsh.model.geo.addLine(3, 2, 2)
    gmsh.model.geo.addLine(3, p4, 3)
    gmsh.model.geo.addLine(4, 1, p4)

    gmsh.model.geo.addCurveLoop([4, 1, -2, 3], 1)
    gmsh.model.geo.addPlaneSurface([1], 1)

    gmsh.model.geo.synchronize()

    gmsh.model.addPhysicalGroup(0, [1, 2], 1)
    gmsh.model.addPhysicalGroup(1, [1, 2], 2)
    gmsh.model.addPhysicalGroup(2, [1], 6)

    gmsh.model.setPhysicalName(2, 6, "My surface")

    gmsh.model.mesh.generate(2)
    grid = ExtendableGrids.simplexgrid_from_gmsh(gmsh.model)

    @test num_nodes(grid) > 0 && num_cells(grid) > 0 && num_bfaces(grid) > 0

    #    @test testgrid(grid, (404, 726, 80)) gmsh generates differently on windows
    gmsh.clear()
end

@testset "Read/write simplex gmsh 2d / 3d" begin
    gmsh.option.setNumber("General.Terminal", 0)
    gmsh.option.setNumber("General.Verbosity", 0)

    path = ""

    X = collect(0:0.02:2)
    Y = collect(0:2:4)
    grid1 = simplexgrid(X, Y) #ExtendableGrids.simplexgrid_from_gmsh(path*"sto_2d.msh")
    ExtendableGrids.simplexgrid_to_gmsh(grid1; filename = path * "testfile.msh")
    grid2 = ExtendableGrids.simplexgrid_from_gmsh(path * "testfile.msh"; Tc = Float32, Ti = Int64)
    #gmsh.finalize()
    @test seemingly_equal(grid2, grid1; sort = true, confidence = :low)
    @test seemingly_equal(grid2, grid1; sort = true, confidence = :full)

    gmsh.clear()

    grid1 = ExtendableGrids.simplexgrid_from_gmsh(path * "sto_2d.msh"; Tc = Float64, Ti = Int64)
    gmsh.clear()
    ExtendableGrids.simplexgrid_to_gmsh(grid1; filename = path * "testfile.msh")
    grid2 = ExtendableGrids.simplexgrid_from_gmsh(path * "testfile.msh"; Tc = Float64, Ti = Int64)
    #gmsh.finalize()

    @test seemingly_equal(grid1, grid2; sort = true, confidence = :low)
    @test seemingly_equal(grid1, grid2; sort = true, confidence = :full)

    gmsh.clear()

    grid1 = ExtendableGrids.simplexgrid_from_gmsh(path * "sto_3d.msh"; Tc = Float32, Ti = Int64)
    gmsh.clear()
    ExtendableGrids.simplexgrid_to_gmsh(grid1; filename = path * "testfile.msh")
    grid2 = ExtendableGrids.simplexgrid_from_gmsh(path * "testfile.msh"; Tc = Float64, Ti = Int32)
    #gmsh.finalize()

    @test seemingly_equal(grid1, grid2; sort = true, confidence = :low)
    @test seemingly_equal(grid1, grid2; sort = true, confidence = :full)

    gmsh.clear()

    grid1 = ExtendableGrids.simplexgrid_from_gmsh(path * "sto_2d.msh")
    gmsh.clear()
    #grid2 = 
    #simplexgrid([0, 1, 2], [3, 4, 5]) 
    grid2 = ExtendableGrids.simplexgrid_from_gmsh(path * "sto_3d.msh"; Tc = Float32, Ti = Int32)
    #gmsh.finalize()

    @test !seemingly_equal(grid1, grid2; sort = true, confidence = :low)
    @test !seemingly_equal(grid1, grid2; sort = true, confidence = :full)

    gmsh.clear()

    grid1 = ExtendableGrids.simplexgrid_from_gmsh("testmesh.gmsh"; incomplete = true)
    ExtendableGrids.seal!(grid1; encode = false)
    gmsh.clear()
    ExtendableGrids.simplexgrid_to_gmsh(grid1; filename = "completed_testfile.msh")
    grid2 = ExtendableGrids.simplexgrid_from_gmsh("completed_testfile.msh")

    gmsh.clear()

    grid3 = ExtendableGrids.simplexgrid_from_gmsh("testmesh.gmsh"; incomplete = true)
    ExtendableGrids.seal!(grid3; encode = true)

    gmsh.clear()

    @test seemingly_equal(grid1, grid2; sort = true, confidence = :low)
    @test seemingly_equal(grid1, grid2; sort = true, confidence = :full)
    @test seemingly_equal(grid1, grid3; sort = true, confidence = :low)
    @test seemingly_equal(grid1, grid3; sort = true, confidence = :full)

    x = collect(LinRange(0, 1, 50))
    grid1 = simplexgrid(x, x)
    grid1[BFaceRegions] = ones(Int32, length(grid1[BFaceRegions])) #num_faces(grid1))
    grid2 = simplexgrid(x, x)
    grid3 = simplexgrid(x, x)
    ExtendableGrids.seal!(grid2)
    ExtendableGrids.seal!(grid3; encode = false)

    gmsh.finalize()

    @test seemingly_equal(grid2, grid1; sort = true, confidence = :low)
    @test seemingly_equal(grid2, grid1; sort = true, confidence = :full)
    @test seemingly_equal(grid3, grid1; sort = true, confidence = :low)
    @test seemingly_equal(grid3, grid1; sort = true, confidence = :full)
end

@testset "Read/write mixed gmsh 2d" begin
    gmsh.initialize()
    gmsh.option.setNumber("General.Terminal", 0)
    gmsh.option.setNumber("General.Verbosity", 0)

    path = ""
    grid1 = ExtendableGrids.mixedgrid_from_gmsh(path * "mixedgrid_2d.msh"; Tc = Float64, Ti = Int64)
    gmsh.clear()
    ExtendableGrids.mixedgrid_to_gmsh(grid1; filename = path * "testfile.msh")
    grid2 = ExtendableGrids.mixedgrid_from_gmsh(path * "testfile.msh"; Tc = Float32, Ti = UInt64)
    gmsh.finalize()

    @test seemingly_equal(grid1, grid2; sort = true, confidence = :low)
    @test seemingly_equal(grid1, grid2; sort = true, confidence = :full)
end
