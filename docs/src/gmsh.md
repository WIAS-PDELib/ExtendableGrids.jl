# Gmsh interoperability 
This functionality is in beta stage.
Breaking changes for this API are considered non-breaking for the package.
Therefore, these functions are not exported yet.

```@contents
Pages = ["gmsh.md"]
Depth = 2:4
```

## API
These methods become available via a package extension which is loaded together with 
[Gmsh.jl](https://github.com/JuliaFEM/Gmsh.jl).
See the general [gmsh documentation](https://gmsh.info/), the [Gmsh reference manual](https://gmsh.info/doc/texinfo/gmsh.html)
and the [Gmsh Julia API source code](https://gitlab.onelab.info/gmsh/gmsh/blob/master/api/gmsh.jl) for  information.


```@docs
ExtendableGrids.simplexgrid_from_gmsh
ExtendableGrids.simplexgrid_to_gmsh
ExtendableGrids.mixedgrid_from_gmsh
ExtendableGrids.mixedgrid_to_gmsh
ExtendableGrids.seal!
```



## Internals
### Gmsh extension
```@docs
ExtendableGridsGmshExt.gmshfile_to_mixedgrid
ExtendableGridsGmshExt.take_second
ExtendableGridsGmshExt.gmshfile_to_simplexgrid
ExtendableGridsGmshExt.test_gmsh_init
ExtendableGridsGmshExt.mixedgrid_to_gmshfile
ExtendableGridsGmshExt.multiply_indices
ExtendableGridsGmshExt.mod_to_mixedgrid
ExtendableGridsGmshExt.simplexgrid_to_gmshfile
ExtendableGridsGmshExt.simplexgrid_to_mod
ExtendableGridsGmshExt.mod_to_simplexgrid
ExtendableGridsGmshExt.incomplete_mod_to_simplexgrid
ExtendableGridsGmshExt.use_geoms
ExtendableGridsGmshExt.use_vta
```

### seal! method
```@docs
ExtendableGrids.faces_of_ndim_simplex
ExtendableGrids.assemble_bfaces_direct
ExtendableGrids.decode
ExtendableGrids.encode
ExtendableGrids.faces_of_ndim_simplex_direct
ExtendableGrids.assemble_bfaces
```
