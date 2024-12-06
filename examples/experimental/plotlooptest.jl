using ExtendableGrids
import Makie, PyPlot, Plots, VTKView


X = collect(0.0:0.05:1)

grid1d = simplexgrid(X)
grid2d = simplexgrid(X, X)

func1d = map(x -> sin(5 * x), grid1d)
func2d = map((x, y) -> sin(5 * x) * sin(5 * y), grid2d)


function gridloop(Plotter)
    ctx = PlotterContext(Plotter)
    return @time for i in 1:20
        X = collect(0.0:0.05:1)
        Y = collect(0.0:0.05:(1 + 0.01 * i))
        grid = simplexgrid(X, Y)
        plot!(ctx, grid)
    end
end

function gridloops()
    gridloop(PyPlot)
    gridloop(VTKView)
    #    gridloop(Plots)
    return gridloop(Makie)
end

function funcloop(Plotter)
    ctx = PlotterContext(Plotter)
    X = collect(0.0:0.05:1)
    grid = simplexgrid(X, X)
    return @time for i in 1:20
        func2d = map((x, y) -> sin(0.5 * i * x) * sin(0.5 * i * y), grid2d)
        plot!(ctx, grid, func2d)
    end
end

function funcloops()
    funcloop(PyPlot)
    funcloop(VTKView)
    funcloop(Plots)
    return funcloop(Makie)
end


twofigloop(Plotter) = twofigloop(plottertype(Plotter), Plotter)


function twofigloop(::Type{MakieType}, Makie)
    MakieLayout = Makie.AbstractPlotting.MakieLayout
    ## Layouting mit leeren scenen auch nicht
    ## tricontour mit linien ?
    scene, layout = MakieLayout.layoutscene(resolution = (600, 300))
    ax1 = layout[1, 1] = MakieLayout.LAxis(scene)
    ax2 = layout[1, 2] = MakieLayout.LAxis(scene)
    Makie.lines!(ax1, [0.0, 0.0001], [0.0, 0.0001], color = :white)
    Makie.lines!(ax2, [0.0, 0.0001], [0.0, 0.0001], color = :white)
    ctx1 = PlotterContext(Makie, scene = ax1)
    ctx2 = PlotterContext(Makie, scene = ax2)
    Makie.display(scene)

    X = collect(0.0:0.05:1)
    grid = simplexgrid(X, X)

    for i in 1:200
        func1 = map((x, y) -> sin(0.1 * i * x) * sin(0.1 * i * y), grid)
        func2 = map((x, y) -> exp(sin(0.1 * i * x) * sin(0.1 * i * y)), grid)
        plot!(ctx1, grid, func1, show = false)
        plot!(ctx2, grid, func2, show = false)
        Makie.update!(scene)
        Makie.sleep(1.0e-10)
    end
    return scene
end


#
# Works ok this way
#
function twofigloop(::Type{PyPlotType}, PyPlot)

    figure = PyPlot.figure(1, figsize = (6, 3))
    ctx1 = PlotterContext(PyPlot, figure = figure, clear = false, legend = false, subplot = 121)
    ctx2 = PlotterContext(PyPlot, figure = figure, clear = false, legend = false, subplot = 122)

    for i in 1:20
        X = collect(0.0:0.05:(1 - 0.01 * i))
        Y = collect(0.0:0.05:(1 + 0.01 * i))
        grid = simplexgrid(X, Y)
        PyPlot.clf()
        func2d = map((x, y) -> sin(0.5 * i * x) * sin(0.5 * i * y), grid)
        plot!(ctx1, grid)
        plot!(ctx2, grid, func2d)
    end
    return
end


function twowinloop()
    # in order to make this work we need to switch from
    # PyPlot.plot to ax.plot.
    ctx1 = PlotterContext(PyPlot, fignumber = 1, legend = false)
    ctx2 = PlotterContext(PyPlot, fignumber = 2, legend = false)


    for i in 1:20
        X = collect(0.0:0.05:(1 - 0.01 * i))
        Y = collect(0.0:0.05:(1 + 0.01 * i))
        grid = simplexgrid(X, Y)
        PyPlot.clf()
        func2d = map((x, y) -> sin(0.5 * i * x) * sin(0.5 * i * y), grid)
        plot!(ctx1, grid)
        plot!(ctx2, grid, func2d)
    end
    return
end


#
# Warnings from vtk when updating grid + functions
#
function twofigloop(::Type{VTKViewType}, VTKView)

    frame = VTKView.StaticFrame()
    VTKView.clear!(frame)
    VTKView.size!(frame, 600, 300)
    VTKView.layout!(frame, 2, 1)
    dataset = VTKView.DataSet()
    ctx1 = PlotterContext(VTKView, frame = frame, clear = false, dataset = dataset, framepos = 1, label = "func1")
    ctx2 = PlotterContext(VTKView, frame = frame, clear = false, dataset = dataset, framepos = 2, label = "func2")

    X = collect(0.0:0.05:1)
    grid = simplexgrid(X, X)
    for i in 1:200
        func1 = map((x, y) -> sin(0.1 * i * x) * sin(0.1 * i * y), grid)
        func2 = map((x, y) -> exp(sin(0.1 * i * x) * sin(0.1 * i * y)), grid)
        plot!(ctx1, grid, func1)
        plot!(ctx2, grid, func2)
    end
    return
end

#
# Works well this way, missing tricontourf and trigrid plotting...
#
function twofigloop(::Type{PlotsType}, Plots)

    ctx1 = PlotterContext(Plots, plot = Plots.plot(), show = false, clear = false)
    ctx2 = PlotterContext(Plots, plot = Plots.plot(), show = false, clear = false)
    p = Plots.plot(ctx1[:plot], ctx2[:plot])

    X = collect(0.0:0.05:1)
    Y = collect(0.0:0.05:1)
    grid = simplexgrid(X, Y)
    for i in 1:20
        func1 = map((x, y) -> sin(0.5 * i * x) * sin(0.5 * i * y), grid)
        func2 = map((x, y) -> exp(sin(0.5 * i * x) * sin(0.5 * i * y)), grid)
        plot!(ctx1, grid, func1)
        plot!(ctx2, grid, func2)

        Plots.gui(p)
    end
    return
end

function twofigloops()
    twofigloop(PyPlot)
    twofigloop(VTKView)
    twofigloop(Plots)
    return twofigloop(Makie)
end

function alltests()
    gridloops()
    funcloops()
    return twofigloops()
end
"""
Layout plan:

PlotterContext(layout=(2,3)) creates array of contexts
ctx[1,2]  contains subcontexts for plotting into

update!(ctx) updates at end of two figure loop


"""
