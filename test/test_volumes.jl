using ExtendableGrids: volume

# static dispatch wrapper so that @allocated measures a single concrete call
vol4test(Coords, Nodes, item, ::Type{GEOM}, ::Type{CS}) where {GEOM, CS} = volume(Coords, Nodes, item, GEOM, CS)

# every volume method reached by a check_volume call below is recorded here
tested_volume_methods = Set{Method}()

function check_volume(Coords, Nodes, item, ::Type{GEOM}, ::Type{CS}, expected) where {GEOM, CS}
    push!(tested_volume_methods, which(volume, Tuple{typeof(Coords), typeof(Nodes), Int, Type{GEOM}, Type{CS}}))
    # first call warms up compilation, second one is measured
    @test vol4test(Coords, Nodes, item, GEOM, CS) ≈ expected
    @test @allocated(vol4test(Coords, Nodes, item, GEOM, CS)) == 0
    return nothing
end

col(v) = reshape(v, length(v), 1)

# Vertex0D
let
    Coords = [0.0 1.0 2.0; 0.0 1.0 0.0]
    Nodes = [1 2 3]
    for CS in (Cartesian1D, Cartesian2D, Cartesian3D)
        for item in 1:3
            check_volume(Coords, Nodes, item, Vertex0D, CS, 1)
        end
    end
end

# Edge1D in Cartesian1D
let
    Coords = [0.0 0.5 1.5]
    Nodes = [1 2 3; 2 3 1]
    for (item, expected) in enumerate((0.5, 1.0, 1.5))
        check_volume(Coords, Nodes, item, Edge1D, Cartesian1D, expected)
    end
end

# Edge1D in Cartesian2D
let
    Coords = [0.0 3.0 0.0; 0.0 0.0 4.0]
    Nodes = [1 2 3; 2 3 1]
    for (item, expected) in enumerate((3.0, 5.0, 4.0))
        check_volume(Coords, Nodes, item, Edge1D, Cartesian2D, expected)
    end
end

# Edge1D in Cartesian3D
let
    Coords = [0.0 0.0 2.0; 0.0 0.0 0.0; 0.0 2.0 0.0]
    Nodes = [1 2 3; 2 3 1]
    for (item, expected) in enumerate((2.0, 2 * sqrt(2.0), 2.0))
        check_volume(Coords, Nodes, item, Edge1D, Cartesian3D, expected)
    end
end

# Triangle2D in Cartesian2D (signed area, orientation matters)
let
    Coords = [0.0 2.0 0.0; 0.0 0.0 3.0]
    check_volume(Coords, col([1, 2, 3]), 1, Triangle2D, Cartesian2D, 3.0)
    check_volume(Coords, col([1, 3, 2]), 1, Triangle2D, Cartesian2D, -3.0)
end

# Quadrilateral2D in Cartesian2D
let
    # unit square
    Coords = [0.0 1.0 1.0 0.0; 0.0 0.0 1.0 1.0]
    check_volume(Coords, col([1, 2, 3, 4]), 1, Quadrilateral2D, Cartesian2D, 1.0)
    # 2x1 rectangle
    Coords = [0.0 2.0 2.0 0.0; 0.0 0.0 1.0 1.0]
    check_volume(Coords, col([1, 2, 3, 4]), 1, Quadrilateral2D, Cartesian2D, 2.0)
end

# Triangle2D in Cartesian3D (surface area)
let
    # planar right triangle (1,2,3) + tilted unit axis triangle (4,5,6)
    Coords = [0.0 2.0 0.0 1.0 0.0 0.0; 0.0 0.0 3.0 0.0 1.0 0.0; 0.0 0.0 0.0 0.0 0.0 1.0]
    check_volume(Coords, col([1, 2, 3]), 1, Triangle2D, Cartesian3D, 3.0)
    check_volume(Coords, col([4, 5, 6]), 1, Triangle2D, Cartesian3D, sqrt(3.0) / 2)
end

# Parallelogram2D in Cartesian3D (surface area)
let
    Coords = [0.0 2.0 2.0 0.0; 0.0 0.0 3.0 3.0; 0.0 0.0 0.0 0.0]
    check_volume(Coords, col([1, 2, 3, 4]), 1, Parallelogram2D, Cartesian3D, 6.0)
end

# Parallelepiped3D in Cartesian3D (volume via nodes 1, 2, 4, 5)
let
    Coords = [
        0.0 2.0 2.0 0.0 0.0 2.0 2.0 0.0;
        0.0 0.0 3.0 3.0 0.0 0.0 3.0 3.0;
        0.0 0.0 0.0 0.0 4.0 4.0 4.0 4.0
    ]
    Nodes = col([1, 2, 3, 4, 5, 6, 7, 8])
    check_volume(Coords, Nodes, 1, Parallelepiped3D, Cartesian3D, 24.0)
end

# Tetrahedron3D in Cartesian3D
let
    Coords = [0.0 2.0 0.0 0.0; 0.0 0.0 3.0 0.0; 0.0 0.0 0.0 4.0]
    check_volume(Coords, col([1, 2, 3, 4]), 1, Tetrahedron3D, Cartesian3D, 4.0)
end

# ensure that every volume method defined in the package is covered by one of
# the test cases above; when adding a new volume method, add a test case for it
let
    untested = setdiff(collect(methods(volume)), tested_volume_methods)
    for m in untested
        println("untested volume method: ", m.sig)
    end
    @test isempty(untested)
end
