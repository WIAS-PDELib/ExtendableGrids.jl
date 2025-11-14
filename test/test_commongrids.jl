@test isconsistent(reference_domain(Edge1D))
@test isconsistent(reference_domain(Triangle2D))
@test isconsistent(reference_domain(Parallelogram2D))
@test isconsistent(reference_domain(Tetrahedron3D))
@test isconsistent(reference_domain(Hexahedron3D))

@test isconsistent(grid_unitcube(Parallelepiped3D))
@test isconsistent(grid_unitcube(Tetrahedron3D))
@test isconsistent(grid_unitsquare(Triangle2D))
@test isconsistent(grid_unitsquare(Parallelogram2D))
@test isconsistent(grid_lshape(Triangle2D))
@test isconsistent(grid_unitsquare_mixedgeometries())

@test isconsistent(
    ringsector(
        range(0, 1, length = 10),
        range(0, π / 2, length = 10)
    )
)

@test isconsistent(
    ringsector(
        range(0, 1, length = 10),
        range(0, 2π, length = 10)
    )
)
