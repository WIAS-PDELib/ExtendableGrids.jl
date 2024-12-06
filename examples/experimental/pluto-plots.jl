### A Pluto.jl notebook ###
# v0.12.18

using Markdown
using InteractiveUtils

# ╔═╡ 60941eaa-1aea-11eb-1277-97b991548781
using Revise, PlutoUI, ExtendableGrids

# ╔═╡ df8aefc0-5273-11eb-1a67-3552732deae0
using Plots

# ╔═╡ 08fa72d6-5274-11eb-03bd-ef885fdd216d
P = Plots

# ╔═╡ e5cec5c8-5273-11eb-0e0b-03960befcc71
X = collect(0:0.5:10)

# ╔═╡ f088d080-5273-11eb-2085-e5d4734512ff
g1 = simplexgrid(X)

# ╔═╡ ff091d22-5273-11eb-2645-89630b592fa0
gridplot(g1, Plotter = P, resolution = (500, 100))

# ╔═╡ 2dd685fe-5274-11eb-173c-6f2ccaf41aae
gridplot(g1, map(x -> sin(x), g1), Plotter = P)

# ╔═╡ 8d1857ae-5274-11eb-265d-09604d9dba94
g2 = simplexgrid(X, X)

# ╔═╡ 9526886c-5274-11eb-33a6-d95a16547472
gridplot(g2, Plotter = P)

# ╔═╡ ae81ae16-5274-11eb-36e6-a1dd77e51abb
gridplot(g2, map((x, y) -> (sin(x) * exp(-(y - 5)^2)), g2), Plotter = P, colormap = :hot)

# ╔═╡ eb380f5a-5274-11eb-2a7a-87c75706a2ae
p = GridPlotContext(Plotter = P, layout = (1, 2), fignum = 2, resolution = (800, 400))

# ╔═╡ 0114cb24-5275-11eb-3013-0f3b170f25de
begin
    gridplot!(p[1, 1], g1, map(x -> sin(x), g1), title = "1D")
    gridplot!(p[1, 2], g2, map((x, y) -> (sin(x) * exp(-(y - 5)^2)), g2), colormap = :hot, title = "2D")
    reveal(p)
end

# ╔═╡ Cell order:
# ╠═60941eaa-1aea-11eb-1277-97b991548781
# ╠═df8aefc0-5273-11eb-1a67-3552732deae0
# ╠═08fa72d6-5274-11eb-03bd-ef885fdd216d
# ╠═e5cec5c8-5273-11eb-0e0b-03960befcc71
# ╠═f088d080-5273-11eb-2085-e5d4734512ff
# ╠═ff091d22-5273-11eb-2645-89630b592fa0
# ╠═2dd685fe-5274-11eb-173c-6f2ccaf41aae
# ╠═8d1857ae-5274-11eb-265d-09604d9dba94
# ╠═9526886c-5274-11eb-33a6-d95a16547472
# ╠═ae81ae16-5274-11eb-36e6-a1dd77e51abb
# ╠═eb380f5a-5274-11eb-2a7a-87c75706a2ae
# ╠═0114cb24-5275-11eb-3013-0f3b170f25de
