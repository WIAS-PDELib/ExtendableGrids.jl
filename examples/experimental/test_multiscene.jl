######################################################
#
# Example testing all features of multiscene
#=
 Features are  up to now
 - Arrangement of several subscenes with  in a given scene grid
 - ',' key switches between gallery view and focus view showing one  subscene
 - space key can block/unblock main task
 - handle interactive variables associated with  hotkeys via keyboard interaction,
   separately for each subscene. Rationale: sliders would eat up too much screen real estate
 - Store context dict in the attributes of LScene
=#

import Pkg
Pkg.activate(mktempdir())
Pkg.add(["ExtendableGrids", "GLMakie"])

using ExtendableGrids.MultiScene
using GLMakie

setmakie!(GLMakie)

# Scene with two internal variables, shown only once
function subscene1!(ax)
    N = 10
    s = 1.0
    makedata(s, N) = s * rand(N)
    makestatus(s, N) = "s=$(round(s, digits = 2)) N=$(N)"
    data = Node(makedata(s, N))
    status = Node(makestatus(s, N))

    scene = lines(lift(a -> a, data), color = :red, linewidth = 4)

    scene_interaction(scene, [:n, :s]) do delta, key
        # key: which key  is "switched on" (of those passed in the array)
        # delta: increment/decrement value
        if key == :n
            N = max(2, N + delta)
        elseif key == :s
            s = max(0.1, s + 0.01 * Float64(delta))
        end
        data[] = makedata(s, N)
        status[] = makestatus(s, N)
        update!(scene)
    end
    return add_scene!(ax, scene, title = "lines", status = status)
end

# Scene with two internal variables, shown multiple times
# as a consequence, data and nodes are stored in a context dict
# which is stored in ax.attributes. Not sure if this is a good idea...
function subscene2!(ax, k, l)
    ctx = subscenecontext(ax)

    N = 100
    makedata(k, l) = [sinpi(2 * k * i / N) * sinpi(2 * l * j / N) for i in 1:N, j in 1:N]
    makestatus(k, l) = "k=$(round(k, digits = 2)) l=$(round(k, digits = 2))"


    return if isempty(ctx)
        data = Node(makedata(k, l))
        status = Node(makestatus(k, l))
        scene = heatmap(lift(a -> a, data))
        ctx[:data] = data
        ctx[:status] = status
        ctx[:k] = k
        ctx[:l] = l

        scene_interaction(scene, [:k, :l]) do delta, key
            ctx[key] = max(0.1, ctx[key] + 0.1 * delta)
            status[] = makestatus(ctx[:k], ctx[:l])
            data[] = makedata(ctx[:k], ctx[:l])
        end
        add_scene!(ax, scene, title = "heatmap2d", status = status)
        ctx
    else
        ctx[:k] = k
        ctx[:l] = l
        ctx[:status][] = makestatus(ctx[:k], ctx[:l])
        ctx[:data][] = makedata(ctx[:k], ctx[:l])
        yieldwait()
        ctx
    end
end

# simple subscene with one interior variable
# so no need to care about switching
function subscene3!(ax)
    N = 50
    data = Node(rand(N, 3))
    status = Node("N=$(N)")
    scene = scatter(lift(a -> a, data), color = rand(RGBf0))
    scene_interaction(scene) do delta, key
        N = max(4, N + delta)
        status[] = "N=$(N)"
        data[] = rand(N, 3)
    end
    return add_scene!(ax, scene, title = "scatter3d", status = status)
end

# simple subscene with one interior variable
function subscene4!(ax)
    iso = 1.7

    r = LinRange(-1, 1, 100)
    cube = [(x .^ 2 + y .^ 2 + z .^ 2) for x in r, y in r, z in r]
    cubedata = cube .* (cube .> 1.4)
    data = Node(iso)
    status = Node("iso=$(round(iso, digits = 2))")
    scene = volume(cubedata, algorithm = :iso, isorange = 0.05, isovalue = lift(a -> a, data))

    scene_interaction(scene) do delta, key
        iso = min(2.5, max(1.5, iso + 0.05 * delta))
        data[] = iso
        status[] = "iso=$(round(iso, digits = 2))"
    end
    return add_scene!(ax, scene, title = "cube3d", status = status)
end


function test_multiscene()

    parent, subscenes = multiscene(layout = (2, 2))

    subscene1!(subscenes[1, 1])
    subscene2!(subscenes[1, 2], 1.9, 3.5)
    subscene3!(subscenes[2, 1])
    subscene4!(subscenes[2, 2])

    display(parent)

    # this loop runs "forever" and can be temporarily
    # stopped by the space key
    k = 2.0
    l = 2.0
    dir = 1.0
    while true
        for i in 1:1000
            k += dir * 0.01
            l += dir * 0.01
            subscene2!(subscenes[1, 2], k, l)
        end
        dir = -dir
    end
    return
end
