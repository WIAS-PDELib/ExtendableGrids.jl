"""
$(TYPEDSIGNATURES)

Resurrect linspace despite https://github.com/JuliaLang/julia/pull/25896#issuecomment-363769368
"""
linspace(a, b, n) = collect(range(a, b, length = n))


"""
$(TYPEDSIGNATURES)

(Try to) create a subdivision of interval (a,b) stored in the 
returned array X such that 
  - `X[1]==a, X[end]==b`
  - `(X[2]-X[1])<=ha+tol*(b-a)`
  - `(X[end]-X[end-1])<=hb+tol*(b-a)`
  - There is a number q such that  `X[i+1]-X[i] == q*(X[i]-X[i-1])`
  - X is the array with the minimal possible number of points with the above property
  
Caveat: the algorithm behind this is  tested for many cases but unproven.

Returns an Array containing the points of the subdivision.
"""
function geomspace(a, b, ha, hb; tol = 1.0e-10, maxiterations = 100)
    a = Float64(a)
    b = Float64(b)
    ha = Float64(ha)
    hb = Float64(hb)

    function _geomspace0(l, h0, hl, tol = 1.0e-10)
        @assert (l > 0.0)
        @assert (h0 > 0.0)
        @assert (hl >= h0)
        @assert((hl + h0) < l)

        #  We need to  adjust two things:

        # The sum of the geometric progression must
        # match the length of the interval, so lmismatch
        # should be zero:
        function lmismatch(q, k)
            return l - h0 * (1 - q^k) / (1 - q)
        end

        # The claim from experimenral evidence (Wolfram)
        # is that, if written as a polynomial,
        # it has two real zeros: one and the value searched for which
        # is slightly larger than one. All other zeros are on one circle.

        # The size of the last interval should be close to
        # to hl, so hmismatch should be close to one and not larger than one
        function hmismatch(q, k)
            return h0 * q^(k - 1) / hl
        end

        # define initial number of intervals from
        # average of minimal and maximal h
        n = Int(ceil((2.0 * l / (h0 + hl))))


        if n == 1
            n = 2
        end

        # define initial q such that hmismatch is one.
        q = (hl / h0)^(1.0 / (n - 1.0))

        # Iteration until both mismatches are satisfactory
        # Outer loop runs until hmismatch is less than 1
        hmiss = 10.0 # some initial value >1 just to run the loop at least once
        if abs(q - 1.0) < tol
            hmiss = 1.0
        end

        while hmiss > 1.0
            # increase number of intervals until
            # lmismatch becomes less than zero
            while lmismatch(q, n) > tol
                n += 1
            end


            # find initial interval for q containing
            # value with zero lmismatch
            ns = 0

            while lmismatch(q, n) < tol &&  ns < maxiterations
                q *= 0.99
                ns += 1
            end
            ql = q * 0.9
            qr = q * 1.1
            @assert ns < maxiterations "Unable to determine geomspace data after $(maxiterations) iterations"

            # bisection to define q with zero lmismatch
            ns = 0
            qm = 0.5 * (ql + qr)
            while abs(qr - ql) > tol && ns < maxiterations
                ns += 1
                mmm = lmismatch(qm, n)
                if abs(mmm) < tol
                    break
                elseif lmismatch(ql, n) * mmm < 0
                    qr = qm
                else
                    ql = qm
                end
                qm = 0.5 * (ql + qr)
            end
            # increase q slightly to increase probability
            # for last interval to be <=hl
            q = qm * (1.0 + tol)

            @assert ns < maxiterations "Unable to determine geomspace data after $(maxiterations) iterations"
            hmiss = hmismatch(q, n)
            if hmiss > 1.0 + tol
                n = n + 1
            end
        end
        #  printf("%d %g %g %g\n",n,q,lmismatch(q,n),hmismatch(q,n))

        X = Array{Float64, 1}(undef, n + 1)
        X[1] = 0
        h = h0
        for i in 1:n
            X[i + 1] = X[i] + h
            h *= q
        end
        X[n + 1] = l


        # Fix last interval and remove "overshoots"
        if X[end] > l
            X[end] = l
        end

        while X[end - 1] + tol > X[end]
            pop!(X)
            X[end] = l
        end

        return X
    end

    @assert (ha > 0.0) "Start step size $(ha) should be positive"
    @assert (hb > 0.0) "End step size $(hb) should be positive"
    @assert (a < b)    "Interval ends $(a), $(b) should be increasing"
    @assert ((ha + hb) < b - a) "Sum of step sizes $(ha)+$(hb) should not exceed interval size $(b)-$(a)"


    # Map things to [0,b-a]
    tol = tol * (b - a)
    if ha < hb - tol
        X = _geomspace0(b - a, ha, hb, tol)
        X .+= a
    elseif ha > hb + tol
        X = -reverse(_geomspace0(b - a, hb, ha, tol))
        X .+= b
    else
        n = Int(ceil((b - a) / ha))
        X = collect(range(a, b, length = n + 1))
    end
    #    @show X[2]-X[1],ha, X[end]-X[end-1],hb


    @assert (X[2] - X[1]) <= ha + tol  "First interval turned out to be larger than $(ha)"
    @assert (X[2] - X[1]) > ha / 2  "First interval turned out to be less  than $(ha)/10"
    @assert (X[end] - X[end - 1]) <= hb + tol  "Last interval turned out to be larger than $(hb)"
    @assert (X[end] - X[end - 1]) >= hb / 2  "Last interval turned out to be less than $(hb)/10"
    @assert abs(X[1] - a) < tol  "Range start $(X[1]) differs from $(a)"
    @assert abs(X[end] - b) < tol "Range end $(X[end])  differs from $(b)"

    return X
end

is_monotone(X) = all(X[2:end] - X[1:(end - 1)] .> 0)

# See https://discourse.julialang.org/t/how-to-execute-code-depending-on-julia-version/75029/3
@static if VERSION < v"1.7"
    is_monotone(X::UnitRange) = all(collect(X[2:end]) - collect(X[1:(end - 1)]) .> 0)
end

"""
    c=glue(a,b)

Glue together two vectors `a` and b resulting in a vector c. They last element 
of `a` shall be equal (up to tol) to the first element of b.
The result fulfills `length(c)=length(a)+length(b)-1`
"""
function glue(_a::AbstractVector, _b::AbstractVector; tol = 1.0e-10)
    is_monotone(_a) || error("non-monotonous first argument of glue")
    is_monotone(_b) || error("non-monotonous second argument of glue")
    Tv = promote_type(eltype(_a), eltype(_b))

    a = convert(Vector{Tv}, _a)
    b = convert(Vector{Tv}, _b)

    na = length(a)
    nb = length(b)

    d = b[1] - a[na - 1]
    @assert(d > 0)
    d = b[1] - a[na]
    @assert(d > -tol)
    @assert(d < tol)

    c = Vector{Tv}(undef, na + nb - 1)
    ic = 0
    for ia in 1:na
        ic += 1
        c[ic] = a[ia]
    end
    for ib in 2:nb
        ic += 1
        c[ic] = b[ib]
    end
    return c
end
