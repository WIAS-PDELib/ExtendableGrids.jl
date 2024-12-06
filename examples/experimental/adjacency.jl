using Test
using ExtendableGrids

##########################################
# Correctness test
function test_adj_correctness()

    println("A0: Adjacency transpose from matrix")
    A0 = [i + 3 * (j - 1) for i in 1:3, j in 1:3]

    A0t = atranspose(A0)
    println("A0:\n", A0)
    println("A0t:\n", A0t)

    @test A0t == VariableTargetAdjacency{Int64}([1, 1, 1, 2, 2, 2, 3, 3, 3], [1, 2, 3, 4, 5, 6, 7, 8, 9, 10])


    println("A1: Adjacency transpose from variable target adj")
    A1 = VariableTargetAdjacency()
    append!(A1, (1, 2, 3))
    append!(A1, (4, 5, 6, 7))
    append!(A1, (8, 9))
    A1t = atranspose(A1)

    println("A1:\n", A1)
    println("A1t:\n", A1t)


    @test A1t == VariableTargetAdjacency{Int64}([1, 1, 1, 2, 2, 2, 2, 3, 3], [1, 2, 3, 4, 5, 6, 7, 8, 9, 10])

    println("A2: Adjacency transpose from variable target adj")
    A2 = VariableTargetAdjacency()
    append!(A2, (1, 2, 3))
    append!(A2, (2, 3, 4))
    append!(A2, (3, 4, 5))

    A2t = atranspose(A2)
    println("A2:\n", A2)
    println("A2t:\n", A2t)
    return @test A2t == VariableTargetAdjacency{Int64}([1, 1, 2, 1, 2, 3, 2, 3, 3], [1, 2, 4, 7, 9, 10])
end


#############################################
# Performance test

# Function to be called with adjaceny for checking access
# performance
function sum_adj(a)
    sum = 0
    for irun in 1:100
        for isource::Int64 in 1:num_sources(a)
            for itarget in 1:num_targets(a, isource)
                sum += a[itarget, isource]
            end
        end
    end
    return sum
end


struct TestStruct{T}
    adj::Adjacency{T}
end

struct TestStructAny
    adj
end


function test_adj_performance(n = 100_000)
    m = 3
    matrix = [i * j for i in 1:m, j in 1:n]

    ########################################################
    # Access matrix sas FixedTargeAdjacency, should be fast
    print("Direct matrix access:")
    @time begin
        for irun in 1:100
            sum = 0
            for isource in 1:num_sources(matrix)
                for itarget in 1:num_targets(matrix, isource)
                    sum += matrix[itarget, isource]
                end
            end
        end
    end

    # Use this in call, should be fast, but
    # in fact it is slower
    print("    Call with matrix:")
    sum_adj(matrix)
    @time sum_adj(matrix)
    println()

    ########################################################
    # Reorganize adjacency as variable target adjacency
    vadj = VariableTargetAdjacency(matrix)

    # Direct access should be slower than matrix access
    print("  Direct vadj access:")
    @time begin
        for irun in 1:100
            sum = 0
            for isource in 1:num_sources(vadj)
                for itarget in 1:num_targets(vadj, isource)
                    sum += vadj[itarget, isource]
                end
            end
        end
    end


    # Direct access should be slower than matrix access
    print("      Call with vadj:")
    @time sum_adj(vadj)
    println()

    ############################################
    # Assign matrix to adj::Adjacency in struct
    # As Adjacency is a union, this could lead to performance problems,
    # but we have "UnionSplitting": https://julialang.org/blog/2018/08/union-splitting/
    tstruct = TestStruct(matrix)
    tadj = tstruct.adj

    # Here we see a slowdown compared to the matrix case as
    # there must be some dispatch in the Union
    print("  Direct tadj access:")
    @time begin
        for irun in 1:100
            sum = 0
            for isource in 1:num_sources(tadj)
                for itarget in 1:num_targets(tadj, isource)
                    sum += tadj[itarget, isource]
                end
            end
        end
    end

    # Here the dispatch due to Union splitting
    # allows for the same performance as for the matrix case
    print("      Call with tadj:")
    @time sum_adj(tadj)
    println()

    ############################################
    # Assign matrix to adj::Adjacency in struct
    # As Adjacency is a union, this could lead to performance problems,
    # but we have "UnionSplitting": https://julialang.org/blog/2018/08/union-splitting/
    tstruct_v = TestStruct(vadj)
    tvadj = tstruct.adj

    # Here we see a slowdown compared to the matrix case as
    # there must be some dispatch in the Union
    print("  Direct tvadj access:")
    @time begin
        for irun in 1:100
            sum = 0
            for isource in 1:num_sources(tvadj)
                for itarget in 1:num_targets(tvadj, isource)
                    sum += tvadj[itarget, isource]
                end
            end
        end
    end

    # Here the dispatch due to Union splitting
    # allows for the same performance as for the matrix case
    print("      Call with tvadj:")
    @time sum_adj(tvadj)
    println()

    ############################################
    # Assign matrix to adj::Any in struct

    tstruct_a = TestStructAny(matrix)
    aadj = tstruct_a.adj

    # Here we have unboxing with every access so this is
    # really expensive
    print("  Direct aadj access:")
    @time begin
        for irun in 1:100
            sum = 0
            for isource in 1:num_sources(aadj)
                for itarget in 1:num_targets(aadj, isource)
                    sum += aadj[itarget, isource]
                end
            end
        end
    end

    # After "unboxing" when passing the data, specialized
    # code for matrix is called
    print("      Call with aadj:")
    @time sum_adj(aadj)
    """
    Summary: if we want to have a flexible structure, we could either use
    only VariableTargetAdjacency or Union{Matrix,VariableTargetAdjacency}
    """
    return nothing
end
