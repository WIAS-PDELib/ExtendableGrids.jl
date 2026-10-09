# Subgrid

Subgrids of an ExtendableGrid are again of the same type ExtendableGrid
and unse the typed Dict mechanism to store linkage to the parent grid.


```@example
using ExtendableGrids # hide
grid=simplexgrid([1,2,3], [4,5,6])
sub=subgrid(grid,[2],boundary=true, transform=(a,b) -> (a[1]=10*b[2]))
println(keys(sub))
println(sub[Coordinates])
```

Given a vector on the parent grid, one can create a
view of this vecotor on the subgrid:

```@example
using ExtendableGrids # hide
grid=simplexgrid([1,2,3], [4,5,6])
sub=subgrid(grid,[2],boundary=true, transform=(a,b) -> (a[1]=10*b[2]))
v=[i for i=1:num_nodes(grid)]
subv=view(v,sub)
println(subv)
```


## API
```@autodocs
Modules = [ExtendableGrids]
Pages = ["subgrid.jl"]
```

## Deprecated component names
```@docs
NodeInParent
```
