using StatsBase: countmap

"""
````
function encode(x::Vector, nn::Integer)
````

Encode th vector `x` into an Int `y`.
The en/-decoding is similar to using the base-`nn` number system.
Example:
`` [x₁, x₂, x₃] → (x₁-1) + (x₂-1)*nn + (x₃-1)*nn²````
"""
function encode(x::Vector, nn::Integer)
    y = 0 * nn
    for i in 1:length(x)
        y += (x[i] - 1) * nn^(i - 1)
    end
    return y
end

"""
````
function faces_of_ndim_simplex(x::Vector, dim::Integer, nn::Integer)
````

Return all faces of a n-dim simplex.
The orientation is not guaranteed to be right.
`x` contains the nodes of the simplex.
`nn` is the total number of nodes.
The faces (=the nodes contained in the face), are encoded to Integers (of `nn`'s type).


"""
function faces_of_ndim_simplex(x::Vector, dim::Integer, nn::Integer)
    # for a given array x with n entries. for n=4: x1, x2, x3, x4
    # i want all subsets with length n-1 (and distinct entries)
    if dim == 3 # =faces_of_tetrahedron
        y = [
            encode(sort([x[1], x[2], x[3]]), nn),
            encode(sort([x[1], x[2], x[4]]), nn),
            encode(sort([x[1], x[3], x[4]]), nn),
            encode(sort([x[2], x[3], x[4]]), nn),
        ]
    elseif dim == 2
        y = [
            encode(sort([x[1], x[2]]), nn),
            encode(sort([x[1], x[3]]), nn),
            encode(sort([x[2], x[3]]), nn),
        ]
    end
    return y

end

"""
````
function faces_of_ndim_simplex(x::Vector, dim::Integer, nn::Integer)
````

Return all faces of a n-dim simplex.
The orientation is not guaranteed to be right.
`x` contains the nodes of the simplex.
`nn` is the total number of nodes.
The faces (=the nodes contained in the face), are not encoded to Integers.
"""
function faces_of_ndim_simplex_direct(x::Vector)
    # for a given array x with n entries. for n=4: x1, x2, x3, x4
    # i want all subsets with length n-1 (and distinct entries)
    if length(x) == 4 # =faces_of_tetrahedron
        y = [
            sort([x[1], x[2], x[3]]),
            sort([x[1], x[2], x[4]]),
            sort([x[1], x[3], x[4]]),
            sort([x[2], x[3], x[4]]),
        ]
    elseif length(x) == 3
        y = [
            sort([x[1], x[2]]),
            sort([x[1], x[3]]),
            sort([x[2], x[3]]),
        ]
    end
    return y
end

"""
````
function decode(y::Integer, nn::Integer, dim::Integer)
````

Decode `y` to the vector `x`.
`x` has the length `dim`.
The en/-decoding is similar to using the base-`nn` number system.
For details of the encoding, see the documentation of the function `encode`.

"""
function decode(y::Integer, nn::Integer, dim::Integer)
    x = zeros(typeof(y), dim)
    x[1] = y % nn + 1
    x[2] = typeof(y).((y ÷ nn) % nn) + 1
    if dim == 3
        x[3] = typeof(y).(y ÷ nn^2) + 1
    end
    return x
end

"""
````
function assemble_bfaces(simplices, dim, nn, Ti)
````

Assemble the BoundaryFaces corresponding to the simplices passed.
In this function, the faces are encoded for performance reasons. If a large grid with many nodes is used, `Ti` has to be chosen accordingly (e.g. `Int128`), or `encode=false` has to be passed to `seal!`.
`simplices` is a ``(dim+1) x 'number cells'`` matrix and `nn` is the total number of nodes.
We can not guarantee, that the orientation of the BoundaryFaces is correct.  
"""
function assemble_bfaces(simplices, dim, nn, Ti)
    m = size(simplices, 2)
    poss_faces = zeros(Ti, (dim + 1) * m)
    for i in 1:m
        poss_faces[((dim + 1) * i - dim):((dim + 1) * i)] =
            faces_of_ndim_simplex(simplices[:, i], dim, nn)
    end
    dict = countmap(poss_faces)

    k = 0
    for d in dict
        (a, b) = d
        if b == 1
            k += 1
            #push!(unicats, a)
        end
    end

    bfaces = zeros(Ti, (dim, k))
    k = 1
    for d in dict
        (a, b) = d
        if b == 1
            bfaces[:, k] = decode(a, nn, dim)
            k += 1
        end
    end

    if dim == 3
        @warn "bfaces may not be oriented correctly"
    end

    return bfaces
end


"""
````
function assemble_bfaces_direct(simplices, dim, Ti)
````

Assemble the BoundaryFaces corresponding to the simplices passed.
In this function, the faces are not encoded. This may make sense for grids with many nodes.
For smaller grids it can lead to performance losses.
`simplices` is a ``(dim+1) x 'number cells'`` matrix and nn is the total number of nodes.
We can not guarantee, that the orientation of the BoundaryFaces is correct.  
"""
function assemble_bfaces_direct(simplices, dim, Ti)
    m = size(simplices, 2)
    poss_faces = fill(zeros(Ti, dim), (dim + 1) * m) #zeros(Int64, (dim, (dim + 1)*m))
    for i in 1:m
        poss_faces[((dim + 1) * i - dim):((dim + 1) * i)] = faces_of_ndim_simplex_direct(simplices[:, i])
    end
    dict = countmap(poss_faces)

    k = 0
    for d in dict
        (a, b) = d
        if b == 1
            k += 1
            #push!(unicats, a)
        end
    end

    bfaces = zeros(Ti, (dim, k))
    k = 1
    for d in dict
        (a, b) = d
        if b == 1
            bfaces[:, k] = a #decode(a, nn, dim)
            k += 1
        end
    end

    if dim == 3
        @warn "bfaces may not be oriented correctly"
    end

    return bfaces
end


"""
````
function seal!(grid::ExtendableGrid; bfaceregions=[], encode=true, Ti=Int64)
````

Take an (simplex-) ExtendableGrid and compute and add the BoundaryFaces.
A so called incomplete ExtendableGrid can e.g. be read from an msh file using the Gmsh.jl-extension of the ExtendableGrids package and the function ````simplexgrid_from_gmsh(filename::String; incomplete=true)````.
If a non empty vector is passed as bfaceregions, this vector is used for the 'BFaceRegions'.
If bfaceregions is empty, all BoundaryFaces get the region number 1.

For performance reasons, the faces (=the nodes contained in the face) can be encoded (see the function ````encode(x::Vector, nn::Integer)````) to Integers `encoding_type`. To do this, `encode=true` is used.
But for each `encoding_type` there is a limit on the number of nodes: \n
	- For Int64  and a 2d grid: 3*10^9 nodes
	- For Int64  and a 3d grid: 2*10^6 nodes
	- For Int128 and a 2d grid: 1.3*10^19 nodes
	- For Int128 and a 3d grid: 5.5*10^12 nodes
	
If `encode=false` is passed, there is no limit (besides the MaxValue of the Integer type used).

"""
function seal!(grid::ExtendableGrid; bfaceregions = [], encode = true, encoding_type = Int64)
    dim = size(grid[Coordinates])[1]
    Ti2 = typeof(grid[CellNodes][1, 1])
    if encode
        grid[BFaceNodes] = convert(Matrix{Ti2}, assemble_bfaces(grid[CellNodes], dim, size(grid[Coordinates])[2], encoding_type))
    else
        grid[BFaceNodes] = convert(Matrix{Ti2}, assemble_bfaces_direct(grid[CellNodes], dim, encoding_type))
    end

    if bfaceregions == []
        grid[BFaceRegions] = ones(Ti2, size(grid[BFaceNodes])[2])
    else
        grid[BFaceRegions] = bfaceregions #Int64.(collect(1:size(grid[BFaceNodes])[2]))
    end

    if dim == 2
        grid[BFaceGeometries] = VectorOfConstants{ElementGeometries, Ti2}(Edge1D, size(grid[BFaceNodes])[2])
    else
        grid[BFaceGeometries] = VectorOfConstants{ElementGeometries, Ti2}(Triangle2D, size(grid[BFaceNodes])[2])
    end

    return grid
end
