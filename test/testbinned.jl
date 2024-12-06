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
