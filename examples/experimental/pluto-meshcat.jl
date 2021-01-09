### A Pluto.jl notebook ###
# v0.12.18

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ 60941eaa-1aea-11eb-1277-97b991548781
using Revise,PlutoUI,ExtendableGrids

# ╔═╡ df8aefc0-5273-11eb-1a67-3552732deae0
using MeshCat

# ╔═╡ 08fa72d6-5274-11eb-03bd-ef885fdd216d
P=MeshCat

# ╔═╡ e5cec5c8-5273-11eb-0e0b-03960befcc71
X=collect(0:0.5:10)

# ╔═╡ f088d080-5273-11eb-2085-e5d4734512ff
g1=simplexgrid(X)

# ╔═╡ ff091d22-5273-11eb-2645-89630b592fa0
gridplot(g1,Plotter=P,resolution=(500,500))

# ╔═╡ 2dd685fe-5274-11eb-173c-6f2ccaf41aae
gridplot(g1,map(x->sin(x),g1),Plotter=P)

# ╔═╡ 8d1857ae-5274-11eb-265d-09604d9dba94
g2=simplexgrid(X,X)

# ╔═╡ 9526886c-5274-11eb-33a6-d95a16547472
gridplot(g2,Plotter=P)

# ╔═╡ ae81ae16-5274-11eb-36e6-a1dd77e51abb
gridplot(g2,map((x,y)->(sin(x)*exp(-(y-5)^2)),g2),Plotter=P,colormap=:hot)

# ╔═╡ 677d67f4-5275-11eb-17d6-1954c7cd0131
g3=simplexgrid(X,X,X)

# ╔═╡ 303339e0-527a-11eb-3d89-c9038f9009fc
gp3=GridPlotContext(Plotter=P)

# ╔═╡ aaab7994-5275-11eb-159b-fdd7f6bee8c6
@bind zplane Slider(0:0.51:10,default=4)

# ╔═╡ 6dbcc196-5275-11eb-0bd5-2941757247b3
gridplot!(gp3[1,1],g3,zplane=zplane,show=true)

# ╔═╡ 8d9d4d32-527a-11eb-1142-772022a0c4c4
gfp3=GridPlotContext(Plotter=P)

# ╔═╡ d6f7eb72-5275-11eb-2fa5-8b7b03a4743b
@bind flevel Slider(0:0.2:20,default=0.5)

# ╔═╡ 77e28b4c-5275-11eb-199f-253cae56c928
gridplot!(gfp3[1,1],g3,map((x,y,z)->(sin(x)*exp(0.1*y)*z),g3),Plotter=P,flevel=flevel,zplane=zplane,colormap=:brg,show=true)

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
# ╠═677d67f4-5275-11eb-17d6-1954c7cd0131
# ╠═303339e0-527a-11eb-3d89-c9038f9009fc
# ╠═6dbcc196-5275-11eb-0bd5-2941757247b3
# ╠═aaab7994-5275-11eb-159b-fdd7f6bee8c6
# ╠═8d9d4d32-527a-11eb-1142-772022a0c4c4
# ╠═77e28b4c-5275-11eb-199f-253cae56c928
# ╠═d6f7eb72-5275-11eb-2fa5-8b7b03a4743b
