```@meta
CollapsedDocStrings = true
```
# Adjacency
    
This handles adjacency matrices between entities of polyhedral complexes, e.g.
nodes, cells, edges etc.

An adjacency is described by an Adjacency matrix, which is a sparse matrix
whose entries a 0 or 1. While such a matrix always can be stored
as a SparseMatrixCSC, in general this would be a waste of storage.

For the general case, it is sufficient to only store the column start
indieces and the column entries (row numbers), and to implicitly assume
that nonzero entries are 1. This kind of storage is realised in a
VariableTargetAdjacency.
    
In many cases, this can be compressed even more, if each column has the
same length. In that case, a Matrix is sufficient to store the data.
This is the usual base for implementing FEM/FVM assembly, and the interface
for the general case should be similar.

From these ideas we develop the following interface for an adjacency a.
        
In order to avoid name confusion, we introduce the following notation which 
should be consistent with the use in assembly loops.
    
    source:  source of adjacency link
    target:  target of adjacency link

E.g. the cell-node adjacency for FEM assembly links  a number of
cells with a collection of nodes.  The cells are the sources,
and the targets are the nodes. 
    
    getindex(a,i,isource) aka a[i,isource]: return i-th target of  source j
    num_sources(a): overall number of sources, e.g. number of cells
    num_targets(a): overall number of targets
    num_targets(a,isource): number of targets for source given by isource
    num_links(a): number of links aka nonzero entries of adjacency matrix
    show(a): print stuff

Further API ideas:
- Convert between Matrix and Variable target stuff using 0 entries as "padding"

## API

```@autodocs
Modules = [ExtendableGrids]
Pages = ["adjacency.jl","serialadjacency.jl"]
```
