module ExtendableGridsMetisExt

import Metis
import ExtendableGrids: dopartition, partgraph, reorder_cells
using ExtendableGrids, Graphs


function dopartition(grid::ExtendableGrid{Tc, Ti}, alg::PlainMetisPartitioning) where {Tc, Ti}
    nn = num_nodes(grid)
    ncells = num_cells(grid)
    cn = asparse(grid[CellNodes])
    nc = asparse(atranspose(grid[CellNodes]))
    cellcelladj = nc * cn
    mg = Metis.graph(cellcelladj)
    cellpartitions = Metis.partition(mg, alg.npart)
    uniquecellpartitions = unique(cellpartitions)
    ncellpartitions = length(uniquecellpartitions)
    gr = partgraph(cellpartitions, ncellpartitions, cellcelladj)
    col = Graphs.degree_greedy_color(gr)

    # Reorder partitions such that all partitions with the same color
    # are numbered contiguously
    partperm = similar(uniquecellpartitions)
    colctr = zeros(Int, col.num_colors + 1)
    colctr[1] = 1
    for i in 1:(length(colctr) - 1)
        colctr[i + 1] = colctr[i] + sum(x -> x == i, col.colors)
    end
    colpart = copy(colctr)
    for ip in 1:ncellpartitions
        color = col.colors[ip]
        partperm[ip] = colctr[color]
        colctr[color] += 1
    end

    # Renumber cell partition according to new order
    for i in 1:ncells
        cellpartitions[i] = partperm[cellpartitions[i]]
    end

    pgrid = reorder_cells(grid, cellpartitions, ncellpartitions, colpart)
    return pgrid, cn, nc
end


function coloredpartition(cc; npart = 4, depth = 0, maxdepth = 4, separatorwidth = 2)
    mg = Metis.graph(cc)
    Metis.options[Int(Metis.METIS_OPTION_CCORDER) + 1] = 1

    # primary partition
    primarypartition = Metis.partition(mg, npart)
    npp = maximum(primarypartition)
    ncells = length(primarypartition)
    sepamark = zeros(Bool, ncells)

    # Calculate separator: all cells with neighbours of a different partition
    # go into the separator
    nx = 0
    for icell in 1:ncells
        ipart = primarypartition[icell]
        for k in cc.colptr[icell]:(cc.colptr[icell + 1] - 1)
            jcell = cc.rowval[k]
            jpart = primarypartition[jcell]
            if ipart != jpart
                sepamark[icell] = 1
                if separatorwidth > 2
                    for l in cc.colptr[jcell]:(cc.colptr[jcell + 1] - 1)
                        kcell = cc.rowval[l]
                        sepamark[kcell] = 1
                    end
                end
                break
            end
        end
    end
    # Color separator cells with new color
    # and collect their indices
    sepaparent = zeros(Int, sum(sepamark))
    iparent = 1
    for icell in 1:ncells
        if sepamark[icell] > 0
            primarypartition[icell] = npp + 1
            sepaparent[iparent] = icell
            iparent = iparent + 1
        end
    end

    # get adjacency matrix for separator
    sepacc = cc[sepaparent, sepaparent]

    if depth > 0
        # Check if separator consists of several connected components
        # If yes, make each component a partition, give them a common
        # color and return.
        sepacomp = connected_components(SimpleGraph(sepacc))
        nsepacomp = length(sepacomp)
        if nsepacomp > 1
            for icomp in 1:nsepacomp
                for icell in sepacomp[icomp]
                    primarypartition[sepaparent[icell]] = npp + icomp
                end
            end
            return primarypartition, [1, npp + 1, npp + nsepacomp + 1]
        elseif depth == maxdepth && size(sepacc, 2) > 0
            # all separator is one partition
            for icell in size(sepacc, 2)
                primarypartition[sepaparent[icell]] = npp + 1
            end
            return primarypartition, [1, npp + 1, npp + 2]
        else # size(sepacc, 2)==0
            # separator is empty
            return primarypartition, [1, npp + 1]
        end
    end

    # if just one connected component,
    # partition separator
    if depth < maxdepth && size(sepacc, 1) > 0
        p1, c1 = coloredpartition(sepacc; npart, depth = depth + 1, maxdepth, separatorwidth)
        for icell in 1:length(p1)
            primarypartition[sepaparent[icell]] = npp + p1[icell]
        end
        return primarypartition, vcat([1], c1 .+ (npp))
    elseif size(sepacc, 1) > 0
        for icell in size(sepacc, 2)
            primarypartition[sepaparent[icell]] = npp + 1
        end
        return primarypartition, [1, npp + 1, npp + 2]
    else
        return primarypartition, [1, npp + 1]
    end

end

function dopartition(grid::ExtendableGrid{Tc, Ti}, alg::RecursiveMetisPartitioning) where {Tc, Ti}
    cn = asparse(grid[CellNodes])
    nc = asparse(atranspose(grid[CellNodes]))
    cc = nc * cn
    cellpartitions, colpart = coloredpartition(cc; npart = alg.npart, maxdepth = alg.maxdepth, separatorwidth = alg.separatorwidth)
    ncellpartitions = maximum(cellpartitions)
    pgrid = reorder_cells(grid, cellpartitions, ncellpartitions, colpart)
    return pgrid, cn, nc
end


end
