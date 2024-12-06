### A Pluto.jl notebook ###
# v0.19.43

using Markdown
using InteractiveUtils

# ╔═╡ 784b4c3e-bb2a-4940-a83a-ed5e5898dfd4
begin
    import Pkg as _Pkg
    haskey(ENV, "PLUTO_PROJECT") && _Pkg.activate(ENV["PLUTO_PROJECT"])
    using Revise, Test
    import PlutoUI
    import Metis
    using ExtendableGrids: simplexgrid, partition, num_partitions, num_pcolors
    using ExtendableGrids: partition_cells, pcolor_partitions, pcolors
    using ExtendableGrids: PlainMetisPartitioning, RecursiveMetisPartitioning
    using ExtendableGrids: PColorPartitions, PartitionNodes, PartitionCells
    using ExtendableGrids: CellVolumes
    using GridVisualize: gridplot, default_plotter!
    import CairoMakie
    isdefined(Main, :PlutoRunner) && default_plotter!(CairoMakie)
end;

# ╔═╡ b2d3a356-c852-40f1-84ee-4b290a9a5cd3
PlutoUI.TableOfContents(; depth = 4)

# ╔═╡ 0c591473-6fd6-43e1-8127-cff52892f16c
md"""
## Partitioning example
"""

# ╔═╡ 30c05ba4-b349-43cf-b5a6-16a5a7e56ca7
md"""
Provide a glance on grid partitioning. This will be made more comprehensive over time.
"""

# ╔═╡ 175e0fa6-c6f7-4900-a4f8-271029aedc54
X = 0:0.25:10

# ╔═╡ 9cb3696f-7185-412e-b3e3-882bf31c0f5c
grid = simplexgrid(X, X)

# ╔═╡ 3abcfcbc-66ed-43cc-8e5a-758575fe0285
gridplot(grid; linewidth = 0.1)

# ╔═╡ 25b0ff94-da5e-4fbe-bba2-33e14c18e529
md"""
By default, the  grid is partitioned in a trivial way.
"""

# ╔═╡ de7b7fbc-ce0f-4455-8561-1a4598cedd85
md"""
The `partition` function returns a differently partitioned grid.
"""

# ╔═╡ 36938d24-1132-4b09-9a9d-a02333a2f2f1
@doc partition

# ╔═╡ b666b4d9-787c-4b38-96f1-3b3769976018
md"""
`partition` has different backends which can be triggered by `alg`.
"""

# ╔═╡ 827b0bbf-de32-49ae-97db-74c335cfa97f
md"""
## `PlainMetisPartitioning`
"""

# ╔═╡ 9bebe35c-53cc-4e0b-879d-0d3ca2502356
md"""
Partition grid  using PlainMetisPartitioning
"""

# ╔═╡ 3de51bb4-c552-4200-b213-2fd7082ad060
@doc PlainMetisPartitioning

# ╔═╡ 16be63f0-fcc8-4185-abed-dd42064e6624
pgrid1 = partition(grid, PlainMetisPartitioning(; npart = 10))

# ╔═╡ ad021f66-5d78-416c-94ed-50b46d60aae9
md"""
This results in the following partitioning of the grid cells:
"""

# ╔═╡ 23cbb662-50a7-49ba-b1f9-b700c038ddc5
gridplot(pgrid1; cellcoloring = :partitions, linewidth = 0.1)

# ╔═╡ ac233091-6101-4577-9556-1b5ea4aabbec
md"""
The neighborhood graph of the partitions gets colored in such a way that
adjacent partitions have different colors. As a result, e.g. FEM assembly threads can run in parallel on partitions with the same color. If we color cells by their partition color, we get the following plot:
"""

# ╔═╡ b2580aea-68d3-4860-a85b-20b02ab9f62a
gridplot(pgrid1; cellcoloring = :pcolors, linewidth = 0.1)

# ╔═╡ a1b818ae-de78-4b33-9614-153ffac49270
md"""
Partition data are stored in a number of fields:
"""

# ╔═╡ 95ec0bcb-3042-4c2c-b230-5902581364cc
md"""
### Accessing partitioning data
"""

# ╔═╡ c02d0c06-207f-415c-8289-2dad41149bbc
md"""
#### `PColorPartitions`
"""

# ╔═╡ 14dc5342-a9c6-40dc-a831-58d949a10499
@doc PColorPartitions

# ╔═╡ 75abfb08-0e6c-4a2c-b93f-317b437dcb45
pgrid1[PColorPartitions]

# ╔═╡ dec393e1-3110-49e2-8277-5300266b41cd
md"""
This means that partitions $(pcolor_partitions(pgrid1,1)) have color 1,
partitions $(pcolor_partitions(pgrid1,2)) have color 2 etc.
"""

# ╔═╡ bf0603a5-5c61-4555-bf08-3449938500b0
md"""
See also:
"""

# ╔═╡ 0814401d-e4ee-4db9-8ce8-dc7ed4572f87
@doc pcolor_partitions

# ╔═╡ 416308bc-628d-4345-9341-1fcd25c86ef7
md"""
#### `PartitionCells`
"""

# ╔═╡ 0e92a375-5a0d-436d-b3ba-55fb18f374ee
@doc PartitionCells

# ╔═╡ 7f94d44b-9629-48ae-bd25-e5bf0017b981
pgrid1[PartitionCells]

# ╔═╡ 2a3d7fbd-e7a7-4ba6-b58c-1b93a817671e
md"""
This means that cells $(partition_cells(pgrid1,1)) belong to partition 1,
cells $(partition_cells(pgrid1,2)) belong to partition 2 etc. See also:
"""

# ╔═╡ fe634974-16e6-4c17-ba66-70d4d6d1a212
@doc partition_cells

# ╔═╡ 72050a4c-5d48-458b-adff-e06c9a51021c
md"""
#### `PartitionNodes`
"""

# ╔═╡ 2549b034-0032-40b0-b9fe-8837452f08d6
@doc PartitionNodes

# ╔═╡ ca6ff578-f97a-4834-8958-2de3ea68596b
grid[PartitionNodes]

# ╔═╡ 39328a7b-1421-44a2-b9da-2647d1a8d903
md"""
Here, we see, that there is just one trivial node partition. If there is a need for a partition of the nodes, the `node` kwarg in `partition` needs to be set to true:
"""

# ╔═╡ e77cb4ff-a038-4488-a946-8774f64772d1
pgrid2 = partition(grid, PlainMetisPartitioning(; npart = 10); nodes = true)

# ╔═╡ de81358f-44ff-4314-806a-ea46b739caf7
pgrid2[PartitionNodes]

# ╔═╡ 054feb2d-fc05-46fa-8531-c072f771720e
md"""
After partitioning, the `PartitionNodes` entry has the information on node partition numbers.
"""

# ╔═╡ 8b38c213-96c7-461c-8c53-84fe3b585b77
md"""
### Assembly loops
"""

# ╔═╡ 6661564b-5699-4cad-8e32-8cb542419fea
md"""
Assembly loops can be run in parallel on for partitions of the same color.
"""

# ╔═╡ dea042ab-f115-4556-87d5-845ee2da0315
begin
    cvol = pgrid1[CellVolumes]
    pvol = zeros(num_partitions(pgrid1))
    for color in pcolors(pgrid1)
        Threads.@threads for part in pcolor_partitions(pgrid1, color)
            for cell in partition_cells(pgrid1, part)
                pvol[part] += cvol[cell]
            end
        end
        @info "Area of partitions of color $color: $(sum(pvol[pcolor_partitions(pgrid1, color)]))"
    end
end

# ╔═╡ 622185fe-02ec-4e3d-b77b-95b881cca9ac
@test sum(pvol) - sum(cvol) ≈ 0.0

# ╔═╡ 139872f0-5158-4f09-af6e-e8822048f41f
md"""
## `RecursiveMetisPartitioning`
"""

# ╔═╡ 3a933e57-207e-43ea-a188-237647332eb7
md"""
This is another partitioning algrorithm which recursively creates colored partitions.
"""

# ╔═╡ b9fb35bd-cf38-416b-8824-eaf0444b6b94
@doc RecursiveMetisPartitioning

# ╔═╡ 8e6343c4-7e62-421a-9884-c825a1e38a02
pgrid3 = partition(grid, RecursiveMetisPartitioning(; npart = 5))

# ╔═╡ 3607b22d-56e2-4aa6-aaf3-40704bc548a4
gridplot(pgrid3; cellcoloring = :partitions, linewidth = 0.1)

# ╔═╡ da3fe0bd-4f2a-473c-86ec-eb88ad13098f
gridplot(pgrid3; cellcoloring = :pcolors, linewidth = 0.1)


# ╔═╡ Cell order:
# ╠═784b4c3e-bb2a-4940-a83a-ed5e5898dfd4
# ╟─b2d3a356-c852-40f1-84ee-4b290a9a5cd3
# ╟─0c591473-6fd6-43e1-8127-cff52892f16c
# ╟─30c05ba4-b349-43cf-b5a6-16a5a7e56ca7
# ╠═175e0fa6-c6f7-4900-a4f8-271029aedc54
# ╠═9cb3696f-7185-412e-b3e3-882bf31c0f5c
# ╠═3abcfcbc-66ed-43cc-8e5a-758575fe0285
# ╟─25b0ff94-da5e-4fbe-bba2-33e14c18e529
# ╟─de7b7fbc-ce0f-4455-8561-1a4598cedd85
# ╟─36938d24-1132-4b09-9a9d-a02333a2f2f1
# ╟─b666b4d9-787c-4b38-96f1-3b3769976018
# ╟─827b0bbf-de32-49ae-97db-74c335cfa97f
# ╟─9bebe35c-53cc-4e0b-879d-0d3ca2502356
# ╟─3de51bb4-c552-4200-b213-2fd7082ad060
# ╠═16be63f0-fcc8-4185-abed-dd42064e6624
# ╟─ad021f66-5d78-416c-94ed-50b46d60aae9
# ╠═23cbb662-50a7-49ba-b1f9-b700c038ddc5
# ╟─ac233091-6101-4577-9556-1b5ea4aabbec
# ╠═b2580aea-68d3-4860-a85b-20b02ab9f62a
# ╟─a1b818ae-de78-4b33-9614-153ffac49270
# ╟─95ec0bcb-3042-4c2c-b230-5902581364cc
# ╟─c02d0c06-207f-415c-8289-2dad41149bbc
# ╟─14dc5342-a9c6-40dc-a831-58d949a10499
# ╠═75abfb08-0e6c-4a2c-b93f-317b437dcb45
# ╟─dec393e1-3110-49e2-8277-5300266b41cd
# ╟─bf0603a5-5c61-4555-bf08-3449938500b0
# ╟─0814401d-e4ee-4db9-8ce8-dc7ed4572f87
# ╟─416308bc-628d-4345-9341-1fcd25c86ef7
# ╟─0e92a375-5a0d-436d-b3ba-55fb18f374ee
# ╠═7f94d44b-9629-48ae-bd25-e5bf0017b981
# ╟─2a3d7fbd-e7a7-4ba6-b58c-1b93a817671e
# ╟─fe634974-16e6-4c17-ba66-70d4d6d1a212
# ╟─72050a4c-5d48-458b-adff-e06c9a51021c
# ╟─2549b034-0032-40b0-b9fe-8837452f08d6
# ╟─ca6ff578-f97a-4834-8958-2de3ea68596b
# ╟─39328a7b-1421-44a2-b9da-2647d1a8d903
# ╠═e77cb4ff-a038-4488-a946-8774f64772d1
# ╠═de81358f-44ff-4314-806a-ea46b739caf7
# ╟─054feb2d-fc05-46fa-8531-c072f771720e
# ╟─8b38c213-96c7-461c-8c53-84fe3b585b77
# ╟─6661564b-5699-4cad-8e32-8cb542419fea
# ╠═dea042ab-f115-4556-87d5-845ee2da0315
# ╠═622185fe-02ec-4e3d-b77b-95b881cca9ac
# ╟─139872f0-5158-4f09-af6e-e8822048f41f
# ╟─3a933e57-207e-43ea-a188-237647332eb7
# ╟─b9fb35bd-cf38-416b-8824-eaf0444b6b94
# ╠═8e6343c4-7e62-421a-9884-c825a1e38a02
# ╟─3607b22d-56e2-4aa6-aaf3-40704bc548a4
# ╟─da3fe0bd-4f2a-473c-86ec-eb88ad13098f
