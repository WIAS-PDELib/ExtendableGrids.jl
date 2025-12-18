# Changelog

## [1.15.0]
 - add and export `explode` function that produces a grid with all adjacencies removed

## [1.14.2] - 2025-11-25
- less allocations in gFindLocal

## [1.14.1] - 2025-11-14
- fix dangling nodes in full ringsector
- add `isconsistent` checks to CI tests
- somewhat extend `isconsistent` checks

## [1.14.0] - 2025-07-01

- add `trim!`/`trim` function to remove precomputed grid components for lightweight storage

## [1.13.2] - 2025-06-22
- Allow Triangulate v3

## [1.13] - 2025-05-05
- better documentation of adjacencies
- transposed adjacencies NodeCells, NodeFaces, NodeEdges can be stored in the grid
- EdgeNodes now also instantiates adjacencies in relation to its ParentGrid
  
## [1.12] - 2024-11-29
- Allow TetGen v1 and v2
- Code sustainability improvements: pre-commit, codespell

## [1.11] - 2024-11-16
-  Update show method. Have different methods for REPL and interpolation
- make it compatible with planned improvement of show method for VoronoiFVM.System

## [1.10.5] - 2024-11-14

### Changed

- `dim_space`, `num_nodes` and `num_cells` return now `0` if there is no grid key `Coordinates` or `CellNodes`, respectively

### Fixed

- An `ExtendableGrid` given by the default constructor can be displayed by `show()` (#70)

## 2024-10-28
Moved repository from https://github.com/j-fu/ExtendableGrids.jl to https://github.com/WIAS-PDELib/ExtendableGrids.jl. [WIAS-PDELib](https://github.com/WIAS-PDELib/) is a github organization created to collectively manage the Julia packages developed under the lead of the [WIAS Numerical Mathematics and Scientific Computing](https://wias-berlin.de/research/rgs/fg3)  research group. According to the [github docs on repository transfer](https://docs.github.com/en/repositories/creating-and-managing-repositories/transferring-a-repository#whats-transferred-with-a-repository), all links to the previous repository location are automatically redirected to the new location, and all relationships with forks stay intact.

## [1.10.0]  - 2024-09-29
- Allow to map functions with vector arguments onto grid
  E.g. for `f(x)=sum(x)` one can now do `map(f,grid)`.
- Make parts of simplexgrid constructor optional. 
  E.g. it is possible now to do just `simplexgrid(coord, cellnodes)`. In that
  case, e.g. `grid[BFaceRegions]` will return a zero length vector.
  
## [1.9.0]  - 2024-07-07
- Add edge partitioning induced from cell partitioning
- Overhaul of partitioning API

## [1.8.0] - 2024-06-24
- Correct node partitioning
- extended sg file format v2.2 with partitioning info
- Recursive metis partitioning

## [1.7.0] - 2024-06-17
- Partitioning for multithreading
- Metis extension
- extended subgrid method (new argument 'support' can be `ON_CELLS`, `ON_BFACES`, `ON_FACES`)
- SubGrid type has now a parameter that knows the support relative to parent grid, removed BoundarySubGrid type
- removed `get_facegrid`, `get_bfacegrid`, `get_edgegrid` in `derived.jl` (that offer no new functionality compared to subgrid)
- fixed default behaviour for coordinatesystem and restricted 1D coordinate sorting to project = true

## [1.6.1] - 2024-06-07

- Drop support of Julia 1.6. Minimum Julia version is 1.9
- TetGen + Triangulate extensions
- png instead of svg in docs

## [1.5.1] - 2024-05-06
- Grid consistency check
- Gmsh 0.3

## [1.4.0] - 2024-03-21

###  Features

- Move binnedpointlist to ExtendableGrids

- New grid glueing  algorithm using BinnedPointList

- Fix docs, test

- Merge pull request #42 from j-fu/mvbinned

Move binned pointlist over here and use it for glueing
- Update! function to trigger reinstantioation of grid components; instantiate of Volumes components and FaceNormals and EdgeTangents keep existing arrays.

- Merge pull request #41 from chmerdon/master

Reinstantiation of CellVolumes, FaceNormals etc.

## [1.3.2] - 2024-03-08

###  Features

- Fix documentation, all docstrings in output

- Update ci for apple silicon

- Add docstrings for commongrids

- Add Aqua.jl tests

- SimplexGridFactory isn't differently licensed

- Bump patch version


## [1.3.1] - 2024-02-20

###  Features

- Fix subgrid coordinate system for boundary grids (#38)

* fix subgrid coordinate system for boundary grids

* use ExampleJuggler v2 (no Pluto dependency due to extensions)

## [1.3.0] - 2024-02-05

###  Features

- Merge branch 'master' of https://github.com/chmerdon/ExtendableGrids.jl

- New grid components ParentGridRelation, FaceParents, CellParents, BFaceParents,
some of them are now directly set during subgrid or refinement routines
(todo: set BFaceParents also in refinements)

- Small fix

- Small fix

- Added BFaceParents to all refinement routines and some tests

- Renamed NodeInParent to NodeParents, added a deprecated warning on this

- New grid components ParentGridRelation, FaceParents, CellParents, BFaceParents,
some of them are now directly set during subgrid or refinement routines
(todo: set BFaceParents also in refinements)

- Small fix

- Small fix

- Added BFaceParents to all refinement routines and some tests

- Renamed NodeInParent to NodeParents, added a deprecated warning on this

- Merge branch 'master' of github.com:j-fu/ExtendableGrids.jl


## [1.2.3] - 2024-01-19

###  Features

- Fix for subgrid in case there is empty boundary data in the parent grid (or probably also when the subgrid lies completely in the interior)

- Modified the subgrid+extrusion test a bit to test if a subgrid for a completely interior region works (and it only does with the previous modifications)

- Fix for subgrid in case there is empty boundary data  (#36)

* fix for subgrid in case there is empty boundary data in the parent grid (or probably also when the subgrid lies completely in the interior)

* modified the subgrid+extrusion test a bit to test if a subgrid for a completely interior region works (and it only does with the previous modifications)
- Bump patch version


## [1.2.2] - 2023-11-29

###  Features

- Add more gmsh stuff
* handle geo files
* allow for `simplexgrid("my.msh")` and `simplexgrid("my.geo")`
* allow for `write("my.msh",grid)
* file handling with gmsh initializes and finalizes

- Bump version


## [1.2.1] - 2023-11-28

###  Features

- Bugfixes for gmsh extension

* handle node tags properly
* add more examples from gmsh docs


## [1.2.0] - 2023-11-23

###  Features

- Gmsh extension3 (#34)

* Update ExtendableGridsGmshExt.jl

* Add the seal function

Computes the boundary faces of an incomplete simplexgrid and adds them to it

* simplexgrid  + mixedgrid functions for the gmsh extension are defined

* add tests with different types (of indices & coordinates) for gmsh Y ExtendableGrids

* add gmsh geometry description test

* Document the gmsh stuff
---------

Co-authored-by: Jürgen Fuhrmann <juergen-fuhrmann@web.de>
- Use ExampleJuggler (#35)

* moved tests to examplejuggler

* move documentation to examplejuggler
- Add gmsh example

- Small readme+docs update

- Add J. Taraz to author lists


## [1.1.0] - 2023-07-25

###  Features

- Update Project.toml

change Project.toml to incorporate the extension
- Create ExtendableGridsGmshExt.jl
- Update ExtendableGridsGmshExt.jl

upload the (gmsh-) extension code
- Update simplexgrid.jl

include function definitions with implementations in the gmsh extension
- Gmsh-files for tests
- (g)msh-files for the test of the extension
- Delete sto_2d.msh
- Delete sto_3d.msh
- Update runtests.jl

added the tests of the gmsh extension
- Update Project.toml

add dependencies for the gmsh extension
- Update Project.toml
- Update runtests.jl
- Merge pull request #32 from jotaraz/master

gmsh ext
- Add requires for 1.6

- Remove assignment to gms.model for Julia <1.9

- Remove dummy simplexgrid(module)

- Bump version

- Merge pull request #33 from j-fu/gmsh-extension2

add requires for 1.6

## [1.0.0] - 2023-07-22

###  Features

- GeometryGroups (#27)

* new type CellGeometryGroups that collect all cells of same CellGeometry as ordered in UniqueCellGeometries

* view for VariableTargetAdjacency, less allocation in FaceNodes for mixed geometries

---------

Co-authored-by: Christian Merdon <merdon@wias-berlin.de>
- Allow non-leaf types in ElementGeometries

- New type CellGeometryGroups that collect all cells of same CellGeometry as ordered in UniqueCellGeometries

- Added also FaceGeometryGroups etc. and assembly helpers

- Init BEdgeRegions with an array, so that test for bedgemask works again

- GeometryGroups > AssemblyGroups

- Some small corrections, view for VariableTargetAdjacency, less allocation in FaceNodes for mixed geometries

- Some small improvements

- Merge pull request #31 from j-fu/geometry_groups

some small changes
- Merge branch 'master' into quadmeshes

- Merge pull request #30 from j-fu/quadmeshes

Prepare for  quadrilateral and cuboidal elements
- Set cairomakie invisible in tests

- Set version to 1.0 for better semver


## [0.9.17] - 2023-02-10

###  Features

- Fix print_tree calls

- Sorting coordinates of 1D subgrids

- Use CairoMakie for plotting tests & docs

- Merge pull request #22 from j-fu/sort_1d_subgrids

Sort 1d subgrids

## [0.9.16] - 2022-11-30

###  Features

- Remove allocation regression in Julia 1.9 - return Matrices as local_celledgenodes etc. instead of adjoints


## [0.9.15] - 2022-10-22

###  Features

- Cleanup type handling for simplexgrid constructors, 0.9.15

* Fixes stackoverflow error when calling simplexgrid with arrays of different index types

* Detect index types from CellNode arrays

* replace collect_or_assign by convert

* add `bregions`, `cellregion` constructor to tensor grid constructor

* Version bump

- Fix CI for 1.6

- Fix CI for 1.6 - again


## [0.9.14] - 2022-10-19

###  Features

- BFaceRegions in grid after uniform_refine are still VectorOfConstants if BFaceRegions in source grid has been VectorOfConstants

- Introduce barrier in volume calculation (#19)


- Bump version


## [0.9.13] - 2022-09-13

###  Features

- Fix unit test for writevtk

- Create Invalidations.yml (#16)

* Create Invalidations.yml

This is based on https://github.com/julia-actions/julia-invalidations. Adding such checks came up in https://discourse.julialang.org/t/potential-performance-regressions-in-julia-1-8-for-special-un-precompiled-type-dispatches-and-how-to-fix-them/86359. I suggest to add this check here since this package is widely used as a dependency.

See also SciML/MuladdMacro.jl#26 and SciML/MuladdMacro.jl#29
- Missing bracket (#18)


- Bump version, allow AbstractTrees 0.4


## [0.9.12] - 2022-06-23

###  Features

- Piecewise linear interpolation between simplexgrids


## [0.9.11] - 2022-06-21

###  Features

- Speed up of hot loops in  bfacemask! and cellmask!


## [0.9.10] - 2022-06-16

###  Features

- Bregion numbers can now be functions of the current region, or zero to erase


## [0.9.9] - 2022-06-16

###  Features

- Bugfix for 3D rect!


## [0.9.8] - 2022-06-15

###  Features

- Bump to 0.9.8 - missed some commits


## [0.9.7] - 2022-06-15

###  Features

- Fix superfluous corner triangles in subgrid generation

- Added rect! to regionedit - place surface info into rectangular grid


## [0.9.6] - 2022-05-13

###  Features

- Added barycentric refinement for Tetrahedron3D and some tests for uniform and barycentric refinement


## [0.9.5] - 2022-03-27

###  Features

- Improve glue performance
* allow to restrict tested regions
* removed allocations in main loop


## [0.9.4] - 2022-03-24

###  Features

- Added FaceEdgeSigns, version bump


## [0.9.3] - 2022-03-23

###  Features

- Added function for writing grid structure to vtk_write (#12)

* Added function for writing grid structure to io.jl

The writing of the VTK files uses the WriteVTK.jl package.
Hence, it was added as dependency. In addition to the grid structure,
point, cell, or field data can be written to the file.

* julia1.6 now required, added test (needs SHA hash comparison to test Project.toml)

Co-authored-by: chmerdon <57663257+chmerdon@users.noreply.github.com>
- Update ci.yml

update to new minimum julia version dependency
- Update Project.toml

## [0.9.2] - 2022-03-22

###  Features

- Fix for node ordering in tensor grid constructor such that no negative cell volumes occur


## [0.9.1] - 2022-02-21

###  Features

- Some bugfixes for unionizing update, version bump


## [0.9.0] - 2022-02-18

###  Features

- Unionize abstract types (#13)

This relies on the built-in union split of Julia which seems to have no union size constraint anymore. This may remove some allocations...

* Use "ElementGeomtries" -- union of Geometry leaf types -- as eltype for CellGeometries,BFaceGeomtries
* Similar with CoordinateSystems.
* fixed UniqueBFaceGeometries etc, reduced allocations in ItemVolumes instantiations (dispatch on CoordinateSystem seems to cause remaining allocations)
* use SVector for storing intermediate vector data
* Added more typestable getindex methods.
* use length of cx  in cellfinder instead of x as length of x might not match)

Co-authored-by: Christian Merdon <merdon@localhost.localdomain>

- Version bump


## [0.8.11] - 2021-12-06

###  Features

- Glue and simplexgrid(xygrid, zcoord) now use Cint indices.


## [0.8.10] - 2021-11-13

###  Features

- Test against tol for lmismatch in geomspace


## [0.8.9] - 2021-11-10

###  Features

- Fix missing CoordinateSystem instantiation for subgrid


## [0.8.8] - 2021-11-03

###  Features

- Volume of Vertex0D set to 1

- Switch off plotting testset on windows system for now

- Version bump

## [0.8.7] - 2021-10-21

###  Features

- Added ringsector2d


## [0.8.6] - 2021-10-21

###  Features

- Modify 2D x Z tensorproduct API: make cell, bottom and top regions from
offsets of 2D cellregions

- Bfacemask! for 3D, introduce allow_new flag


## [0.8.5] - 2021-10-20

###  Features

- Tensor product grid2d x coordZ


## [0.8.4] - 2021-10-20

###  Features

- Docstring for VoronoiFaceCenters

- Add glue method for grids

- Removed Base.RefValues from L2GTransformer struct and made it mutable (immutability seems to give no benefit here)

- Merge branch 'master' of github.com:j-fu/ExtendableGrids.jl


## [0.8.3] - 2021-10-13

###  Features

- Add tests for geomspace, make assertion warnings more clear

- Don't use yet X[begin]

- Some more geomspace tweaks

- Calculate VoronoiFaceCenters, take in tricircumcenter!

- Add voronoi.jl


## [0.8.2] - 2021-10-07

###  Features

- Start to sort out documentation

- Remove plotting test

- Less allocations in instantiation of EdgeNodes

- Less allocations in instantiation of FaceNormals and EdgeTangents, converted some Float64 to Tc

- Some tweaks for geomspace

- Merge branch 'master' of github.com:j-fu/ExtendableGrids.jl

- Merge branch 'master' of https://github.com/j-fu/ExtendableGrids.jl

- Reduced allocations in all mesh refinements, last remnants of GridAdjacencyTypes erased and replaced by Adjacency


## [0.8.1] - 2021-10-06

###  Features

- Nnodes_for_geometry/nfaces_for_geometry/nedges_for_geometry erased/merged into num_nodes/num_faces/num_edges that are now residing in shape_specs.jl, edges are always Edge1D (adjusted instantiation of EdgeNodes in derived.jl accordingly), erased GridAdjacencyTypes, added enum consistency tests also for Parallelepiped3D

- Activated L2GTransfer, AssemblyTypes, CellFinder (moved from GradientRobustMultiPhysics) and respective tests; renamed BFaces to BFaceFaces and BEdges to BEdgeEdges

- Version 0.8.1

- Ch Merdon as author

- Set EdgeGeometries in instantiation of EdgesNodes in 1D and 2D

- Merge branch 'master' of https://github.com/j-fu/ExtendableGrids.jl

- Merge branch 'master' of github.com:j-fu/ExtendableGrids.jl


## [0.8.0] - 2021-10-05

###  Features

- Phase 1 Transfer of gridstuff from GradienRobustMultiPhysics (#11)

* Phase 1 Transfer of gridstuff from GradienRobustMultiPhysics

- Bump  version


## [0.7.9] - 2021-07-09

###  Features

- Added boundary edge regions (#10)

* Added boundary edge regions

* Extended constructor for simplexgrid

* Fixed missing assignment of boundary edge node adjacency

Co-authored-by: Matthias Liero <matthias.liero@wias-berlin.de>
- Bump version


## [0.7.8] - 2021-07-02

###  Features

- Bugfix for BFaceCells, relax parameter types in simplexgrid() constructor


## [0.7.7] - 2021-06-15

###  Features

- Type-annotated some methods

- Compute adjacency between boundary faces and edges. (#8)

* Compute adjacency between boundary faces and edges.

* Added missing methods

Co-authored-by: Matthias Liero <matthias.liero@wias-berlin.de>
- Merge branch 'master' of github.com:j-fu/ExtendableGrids.jl

- Bump patch version


## [0.7.6] - 2021-03-31

###  Features

- J fu bfnormals (#7)

Enable outflow bc in VoronoiFVM

* Create BFaceNodes, BFaceNormals
* sparsematrix <-> adjacency handling
* Remove ExtendableSparse as Dependency
* Relax some type constraints for simplexgrid
* bump version

- Oops: remove GridVisiualize from Project.toml


## [0.7.5] - 2021-03-30

###  Features

- Bump patch version, Allow for ExtendableSparse 0.4


## [0.7.4] - 2021-01-12

###  Features

- Factored out plotting


## [0.7.3] - 2021-01-10

###  Features

- Fix typo (colstaert)
change alpha default for surfaces.


## [0.7.2] - 2021-01-09

###  Features

- Reorganization: GridVisualize as submodule

- Renamed:
GridPlotContext -> GridVisualizer
gridplot -> visualize
SubPlotContext -> SubVis

- More renames for passing test

- Bump version


## [0.7.1] - 2021-01-09

###  Features

- Gridplot checks with VoronoiFVM

* Detailed checks for plotting with VoronoiFVM

* Pluto examples in experimental


## [0.7.0] - 2021-01-07

###  Features

- Renamed plot->gridplot,  use AbstractPlotting >0.15 (#5)

Renamed plot->gridplot,  use AbstractPlotting >0.15



## [0.6.3] - 2021-01-06

###  Features

- Fix use of extrema in bbox

- Color handling via Colors.jl and ColorSchemes.jl

- Added rosetta.jl to experimental test examples

- Save method for plot context

- Lower expectation to  coverage

- Fix codecov

- Fix codecov

- Last developments before switching to AbstratPlotting 0.15 (#4)

Color handling via Colors.jl and ColorSchemes.jl
In addition:

* fix use of extrema in bbox

* color handling via Colors.jl and ColorSchemes.jl

* added rosetta.jl to experimental test examples

* save method for plot context



## [0.6.2] - 2021-01-01

###  Features

- Pluto tests, MeshCat (#3)

* marching tets et al can directly write into GeometryBasics compatible arrays

* add experimental meshcat implementation (3D only)

* don't run plotting tests on apple

- Bump version


## [0.6.1] - 2020-12-31

###  Features

- Assert non-empty pointlist in simplexgrid

- 3D Makie plotting interaction via keyboard

* sliders would eat up screen real estate
* middle mouse probably not available everywere
* up/down for fine moving and pgup/pgdown for coarse seems to be ok
* added title and status to 3d scene

- New subplot handling working with PyPlot

- Makie now running with multiscene

- Fixed allocations in simplexgrid

- Implementations (sometimes initial) for grid and grid,func in 1D, 2D, 3D

* Support  Makie, PyPlot, VTKView (VTKView without grid 1D)
* At least temporarily drop support of Plots

- Subplot handling: examples, docs

- Remove dependency on Observables

- Added grid writing

* fixed initializaion bug in tokenstream
* try to increase codecov

- Don't use cleanup in tempname()

- Fix definition of extrema

- Try to increase coverage:
add PyPlot to test dependency, test pyplot plotting

- Add  project.toml for test

- Try to set env for runtestes

- Fix project.toml


## [0.6.0] - 2020-12-24

###  Features

- Trigger TagBot on issue_comment instead of cron: https://discourse.julialang.org/t/ann-required-updates-to-tagbot-yml/49249

- Add 3D tensorgrid creation

- Documentation overhaul, fixed simplexgrid bug


## [0.5.8] - 2020-12-20

###  Features

- Use codecov.yml instead of switching off codecov

- Bugfix in adjacency

- Add test for subgrid


## [0.5.7] - 2020-12-14

###  Features

- Lots of small fixes


## [0.5.6] - 2020-12-12

###  Features

- Use backlight for isosurfaces and planes.

Be sure to have https://github.com/JuliaPlots/GLMakie.jl/commit/05220480a3e79c254f538ba46a38d437598c874e
in GLMakie >=1.19

- Fix small glitches + version bump


## [0.5.5] - 2020-12-12

###  Features

- Figured out with how to have changing mesh and changing function at once, see
https://github.com/JuliaPlots/Makie.jl/issues/778#issuecomment-742397119

- First reasonable 3D function plotting


## [0.5.4] - 2020-12-09

###  Features

- Refactor plotting

- generic mesh visibility extraction  for grid plot moved from makie  to common
- one loop for all materials.

- First reasonable 3D Grid plots  with PyPlot

- Rotation kwargs (work only for pyplot)


## [0.5.3] - 2020-12-07

###  Features

- Rename ci

- Added DOCUMENTER_KEY to TagBot.yml

- Interactive Makie grid plot for 3D simplex grids

- Remove coverage test from workflow for the time being


## [0.5.2] - 2020-12-05

###  Features

- Thank you travis and bye bye

- Thank you travis and bye bye

- removed .travis.yml


## [0.5.1] - 2020-12-04

###  Features

- Firsts steps to makie grid plotting


## [0.5.0] - 2020-12-04

###  Features

- Change edge plotting default to true

- Relaxs type constraints for geomspace

- First step to 3D grid visualization

- Update readme & bump version


## [0.4.2] - 2020-10-24

###  Features

- Moved edge creation from VoronoiFVM

This currently creates a dependency on ExtendableSparse which
should be replaced some time.

- Don't print in show() methods!

- Handle boundaries when creating bulk subgrid

- Some fixes for pyplot in Pluto notebooks.

Don't call PyPlot.show() and PyPlot.pause(), as this
must be handled by the user.

- Bfacemask! now allows to add new boundary facets in 2D

- Fix show again

- Fixing docs

- V0.4.2

- Fix compat


## [0.4.1] - 2020-09-24

###  Features

- Documentation fix


## [0.4.0] - 2020-09-23

###  Features

- Plotting of GridFactory showing input and output (PyPlot)

* first steps of Makie plotting

- Rebuild of plotting architecture

* dispatching via plotter type

* PlotterContext holds state of plot, allowing reuse or update (e.g. for Makie),
  see examples/plotlooptest.jl

* First plots with  Makie & WGLMakie

- Introduce kwargs for plotting

- Plotloop stuff

- Fine tuned and commentes plotting stuff

* Help mechanism for flags
* Test for two figure arrangements in one plot  -> future layout stuff

- Fix travis

- Switch to travis-ci.com

- Moving GridFactory to SimplexGridFactory.SimplexGridBuilder
(mainly for licensing reasons)

- Removed dependency on Triangulate

- Added MIT License

- Mentioned accssibility of Triangle via SimplexGridFactory

- Version 0.4.0


## [0.3.0] - 2020-09-04

###  Features

- First working steps to GridFactory

- Improved GridFactory

Added Examples to docs

- Git-added missing files

- V0.3: added GridFactory, Examples


## [0.2.3] - 2020-07-17

###  Features

- Version 0.2.3 using Triangulate 0.5

- Fixed issue #1


## [0.2.2] - 2020-05-01

###  Features

- Add [XYZ]Coordinates to grid if they have been there.
This allows rectangular grid plotting (e.g. with Plots)

- Fixed some plotting, show(grid)

- Patch version bump


## [0.2.1] - 2020-04-28

###  Features

- Temporarily remove macos from travis due to stalled service

- Fix documentation

* work around TYPEDSIGNATURES bug
* add typehierarchy to  doc

- Add typehierarchy.md

- Patch version bump
* first version with working documentation on github


## [0.2.0] - 2020-04-28

###  Features

- Documentation overhaul

- VoronoiFVM examples now running after renaming to ExtendableGrids

- Base.show(grid) ceases to print arrays

- Keys -> Base.keys

- Updated compat

- Updated compat


## [0.1.0] - 2020-04-25

###  Features

- Initialize with README

- Added first files

- Fixed README

- First tests are working...

- More comments, introduce FixedTargetAdjacency

- First version of extendabele container idea

- Containers.md

- Fixed pyplot for boundary grid

- Fixed error in generation

- Improved formatting + comments

- Modified ntargets etc. to num_targets etc.
added DocStringExtensions

- Fixed getindex for CellTypes

- First steps to interaction with VoronoiFVM

- Working for 1D Examples in VoronoiFVM

- Fixes for 2D VoronoiFVM

- Sorted API

- Version bump

- Typos

- More stuff moved over from VoronoiFVM.Grid

- Version bump

- Started Documenter stuff

- Fixed vectorofconstants: unique

- Version 0.1.5

- Restarting as ExtendableGrids

- Typo

- Replaced all occurrences of XGrid

- Add travis, tagbot

- Modified README, badges

- Add Test in Project.toml

- Add Printf in Project.toml

- Fixed compat...
