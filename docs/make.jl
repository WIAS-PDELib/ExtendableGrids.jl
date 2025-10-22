using Documenter, ExtendableGrids, ExampleJuggler
import Gmsh
import CairoMakie, Pluto, PlutoStaticHTML
CairoMakie.activate!(; type = "png", visible = false)
ExampleJuggler.verbose!(true)
ExtendableGridsGmshExt = Base.get_extension(ExtendableGrids, :ExtendableGridsGmshExt)
function mkdocs()
    cleanexamples()
    exampledir = joinpath(@__DIR__, "..", "examples")

    generated_examples = @docscripts(
        exampledir,
        ["examples1d.jl", "examples2d.jl", "examples3d.jl", "gmsh.jl"],
        Plotter = CairoMakie
    )

    notebooks = ["Partitioning" => "pluto-partitioning.jl"]
    notebook_examples = @docplutonotebooks(exampledir, notebooks, iframe = false)
    size_threshold_ignore = last.(notebook_examples)

    generated_examples = vcat(generated_examples, notebook_examples)

    return makedocs(;
        sitename = "ExtendableGrids.jl",
        modules = [ExtendableGrids, ExtendableGridsGmshExt],
        clean = false,
        doctest = true,
        authors = "J. Fuhrmann, Ch. Merdon, J. Taraz",
        repo = "https://github.com/WIAS-PDELib/ExtendableGrids.jl",
        format = Documenter.HTML(;
            size_threshold_ignore,
            assets = String["assets/citations.css"],
            mathengine = MathJax3()
        ),
        pages = [
            "Home" => "index.md",
            "Changes" => "changes.md",
            "adjacency.md",
            "vectorofconstants.md",
            "typehierarchy.md",
            "tdict.md",
            "elementgeometry.md",
            "shape_specs.md",
            "coordinatesystem.md",
            "extendablegrid.md",
            "subgrid.md",
            "more.md",
            "voronoi.md",
            "assembly.md",
            "cellfinder.md",
            "arraytools.md",
            "gridconstructors.md",
            "output.md",
            "refinement.md",
            "partitioning.md",
            "regionedit.md",
            "tokenstream.md",
            "binnedpointlist.md",
            "gmsh.md",
            "allindex.md",
            "Examples" => generated_examples,
        ]
    )
end

mkdocs()

deploydocs(; repo = "github.com/WIAS-PDELib/ExtendableGrids.jl.git")
