using Printf, TetGen, Triangulate

function example_domain_regions(; minangle = 20)
    triin = Triangulate.TriangulateIO()
    triin.pointlist = Matrix{Cdouble}([0.0 0.0; 0.5 0.0; 1.0 0.0; 1.0 1.0; 0.6 0.6; 0.0 1.0]')
    triin.segmentlist = Matrix{Cint}([1 2; 2 3; 3 4; 4 5; 5 6; 6 1; 2 5]')
    triin.segmentmarkerlist = Vector{Int32}([1, 2, 3, 4, 5, 6, 7])
    triin.regionlist = Matrix{Cdouble}([0.2 0.8; 0.2 0.2; 1 2; 0.01 0.05])
    angle = @sprintf("%.15f", minangle)
    (triout, vorout) = triangulate("paAq$(angle)Q", triin)
    return simplexgrid(triout)
end


function example_domain_holes(; minangle = 20, maxarea = 0.001)
    triin = Triangulate.TriangulateIO()
    triin.pointlist = Matrix{Cdouble}(
        [
            0.0 0.0;
            1.0 0.0;
            1.0 1.0;
            0.0 1.0;
            0.2 0.2;
            0.3 0.2;
            0.3 0.3;
            0.2 0.3;
            0.6 0.6;
            0.7 0.6;
            0.7 0.7;
            0.6 0.7
        ]'
    )
    triin.segmentlist = Matrix{Cint}([1 2; 2 3; 3 4; 4 1; 5 6; 6 7; 7 8; 8 5; 9 10; 10 11; 11 12; 12 9]')
    triin.segmentmarkerlist = Vector{Int32}([1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3])
    triin.holelist = [0.25 0.25; 0.65 0.65]'
    area = @sprintf("%.15f", maxarea) # Don't use exponential format!
    angle = @sprintf("%.15f", minangle)
    (triout, vorout) = triangulate("pa$(area)q$(angle)Q", triin)
    return simplexgrid(triout)
end

@testset "Triangulate" begin
    @test isa(example_domain_regions(), ExtendableGrid)
    @test isa(example_domain_holes(), ExtendableGrid)
end

function prism(vol = 2)
    input = TetGen.RawTetGenIO{Cdouble}()
    input.pointlist = [
        0 0 0;
        1 0 0;
        0 1 0;
        0 0 1;
        1 0 1;
        0 1 1
    ]'

    TetGen.facetlist!(
        input, [
            [1, 2, 3],
            [4, 5, 6],
            [1, 2, 5, 4],
            [2, 3, 6, 5],
            [3, 1, 4, 6],
        ]
    )

    return simplexgrid(tetrahedralize(input, "pQa$(vol)"))
end


function material_prism(; vol1 = 0.01, vol2 = 0.1)
    input = TetGen.RawTetGenIO{Cdouble}()

    input.pointlist = [
        0 0 0;
        1 0 0;
        0 1 0;
        0 0 1;
        1 0 1;
        0 1 1;
        0 0 2;
        1 0 2;
        0 1 2
    ]'

    TetGen.facetlist!(
        input,
        [
            [1, 2, 3],
            [7, 8, 9],
            [1, 2, 5, 4],
            [2, 3, 6, 5],
            [3, 1, 4, 6],
            [1, 2, 5, 4] .+ 3,
            [2, 3, 6, 5] .+ 3,
            [3, 1, 4, 6] .+ 3,
        ]
    )

    input.facetmarkerlist = [1, 2, 3, 3, 3, 3, 3, 3]
    input.regionlist = [
        0.1 0.1 0.5 1 vol1;
        0.1 0.1 1.5 2 vol2
    ]'

    return simplexgrid(tetrahedralize(input, "paAqQ"))
end

@testset "TetGen" begin
    @test isa(prism(), ExtendableGrid)
    @test isa(material_prism(), ExtendableGrid)
end
