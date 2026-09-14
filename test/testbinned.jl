function testbinning(a)
    dim = size(a, 1)
    n = size(a, 2)
    idx = rand(1:n, n ÷ 4)
    a1 = a[:, idx]

    bpl = BinnedPointList(dim)
    for i in 1:size(a, 2)
        insert!(bpl, a[:, i])
    end

    for i in 1:size(a1, 2)
        ix = insert!(bpl, a1[:, i])
        if ix != idx[i]
            return false
        end
    end
    return true
end

@test testbinning(rand(1, 10))
@test testbinning(rand(1, 10000))
@test testbinning(rand(2, 10))
@test testbinning(rand(2, 10000))
@test testbinning(rand(3, 10))
@test testbinning(rand(3, 10000))


using SimplexGridFactory, TetGen

function issue136(h1)
    builder = SimplexGridBuilder(; Generator = TetGen)

    r1 = 100
    r2 = 1000

    p00 = point!(builder, -r2, -r2, h1)
    p10 = point!(builder, r2, -r2, h1)
    p01 = point!(builder, -r2, r2, h1)
    p11 = point!(builder, r2, r2, h1)

    q00 = point!(builder, -r1, -r1, h1)
    q10 = point!(builder, r1, -r1, h1)
    q01 = point!(builder, -r1, r1, h1)
    q11 = point!(builder, r1, r1, h1)
    return isa(builder, SimplexGridBuilder)
end

@test issue136(-52645.0)
@test issue136(0.0)
