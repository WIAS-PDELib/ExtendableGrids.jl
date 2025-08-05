"""
    slice(grid::ExtendableGrid{Tc,Ti}, plane::Vector{Tc}) where {Tc,Ti} -> ExtendableGrid{Tc,Ti}

Compute the intersection of a 3D grid with a plane, returning a 2D grid of the intersection.

# Arguments
- `grid::ExtendableGrid{Tc,Ti}`: A 3D ExtendableGrid to be sliced
- `plane::Vector{Tc}`: A 4-element vector `[a,b,c,d]` defining the plane equation ax + by + cz + d = 0

# Returns
- `ExtendableGrid{Tc,Ti}`: A 2D grid representing the intersection of the input grid with the plane.
  The grid contains:
  - `Coordinates`: The 3D coordinates of intersection points
  - `EdgeNodes`: The connectivity of intersection points forming edges

# Details
The function identifies intersections between the plane and the grid's edges. Each tetrahedron
in the grid is processed to find its intersection with the plane, which can occur:
- At vertices (when the plane passes through a grid point)
- Along edges (when the plane intersects between grid points)

The resulting 2D grid maintains the full 3D coordinates of intersection points while
representing their connectivity as a set of edges.

# Example
```julia
grid = some_3d_grid()
plane = [1.0, 0.0, 0.0, 0.5]  # x = -0.5 plane
slice_grid = slice(grid, plane)
```
"""
function slice(grid::ExtendableGrid{Tc, Ti}, plane::Vector{Tc}) where {Tc, Ti}
    @assert dim_space(grid) == 3
    @assert length(plane) == 4 "Plane must be specified as [a,b,c,d] for equation ax + by + cz + d = 0"

    # Get grid components
    coordinates = grid[Coordinates]
    cell_nodes = grid[CellNodes]
    cell_edges = grid[CellEdges]
    edge_nodes = grid[EdgeNodes]

    # Initialize working arrays
    ixcoord = @MArrays zeros(Tc, 3, 10)  # Storage for intersection points (max 10 per tetrahedron)
    ixvalues = @MArrays zeros(Tc, 10)    # Not used but required by intersection function
    ixindices = @MArrays zeros(Ti, 10)   # Indices of valid intersection points

    # Track intersection points by edge/node index
    num_edges = size(edge_nodes, 2)
    num_nodes = size(coordinates, 2)
    intersection_coords = zeros(Tc, 3, num_edges + num_nodes)  # Store points for both edges and nodes
    intersection_used = zeros(Bool, num_edges + num_nodes)     # Track which indices were actually used

    # Calculate plane equation values for all nodes once
    plane_eq_values = zeros(Tc, num_nodes)
    for i in 1:num_nodes
        @views plane_eq_values[i] = plane[1:3]'coordinates[:, i] + plane[4]
    end

    # Process each cell
    ncells = num_cells(grid)
    intersection_edges = Vector{Vector{Ti}}()

    for icell in 1:ncells
        # Get nodes for this cell
        local_nodes = @view cell_nodes[:, icell]
        local_edges = @view cell_edges[:, icell]

        # Get plane equation values for these nodes
        local_plane_values = @view plane_eq_values[local_nodes]

        # Find intersections for this tetrahedron
        num_intersections = calculate_plane_tetrahedron_intersection!(
            ixcoord,
            ixvalues,
            ixindices,
            coordinates,
            local_nodes,
            local_plane_values,
            nothing  # function_values not needed
        )

        # Process valid intersections
        if num_intersections > 0
            cell_points = Vector{Ti}()
            for i in 1:num_intersections
                idx = ixindices[i]
                point = @view ixcoord[:, idx]

                # Find which edge this intersection belongs to
                edge_idx = local_edges[idx]

                # Store point in the global array at edge's position
                if !intersection_used[edge_idx]
                    intersection_coords[:, edge_idx] = point
                    intersection_used[edge_idx] = true
                end

                push!(cell_points, edge_idx)
            end

            # If we found enough points to make an edge
            if length(cell_points) >= 2
                # Add edges between points (assuming they form a polygon)
                n = length(cell_points)
                for i in 1:(n - 1)
                    push!(intersection_edges, [cell_points[i], cell_points[i + 1]])
                end
            end
        end
    end

    # Create the 2D grid from collected intersections
    result = ExtendableGrid{Tc, Ti}()

    # Compress points and create mapping
    used_indices = findall(intersection_used)
    old_to_new = zeros(Ti, length(intersection_used))
    for (new_idx, old_idx) in enumerate(used_indices)
        old_to_new[old_idx] = new_idx
    end

    # Create coordinate array with only used points
    npoints = length(used_indices)
    coords_2d = zeros(Tc, 3, npoints)
    for (new_idx, old_idx) in enumerate(used_indices)
        coords_2d[:, new_idx] = intersection_coords[:, old_idx]
    end
    result[Coordinates] = coords_2d

    # Remap and add edges
    nedges = length(intersection_edges)
    edges = zeros(Ti, 2, nedges)
    for i in 1:nedges
        edges[1, i] = old_to_new[intersection_edges[i][1]]
        edges[2, i] = old_to_new[intersection_edges[i][2]]
    end
    result[EdgeNodes] = edges

    return result
end
