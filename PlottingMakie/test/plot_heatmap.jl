#=
Heat Map Tutorial

Reference
- http://juliaplots.org/MakieReferenceImages/gallery//tutorial_heatmap/index.html
---------
=#

data = rand(50, 50)
scene = heatmap(data)


# Save
save("output/heatmap.svg",scene)
