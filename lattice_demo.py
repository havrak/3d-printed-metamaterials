import cadquery as cq
import math

# Parameters
count = 7         # Number of nodes in each direction (5x5x5)
spacing = 5.0     # Distance between nodes
bar_thick = .5    # Thickness of the grid bars
max_cube = 10.0     # Maximum size of the center cube
min_dist_limit = 0.5 # Prevents infinite size at center

# 1. Create the Bars (The Grid)
# We create long boxes that span the entire length of the lattice
limit = (count - 1) * spacing
grid_bars = cq.Workplane("XY")

for i in range(count):
    for j in range(count):
        # Bars along Z axis
        grid_bars = grid_bars.union(
            cq.Workplane("XY").rect(bar_thick, bar_thick).workplane().box(bar_thick, bar_thick, limit)
            .translate((i * spacing, j * spacing, limit / 2))
        )
        # Bars along Y axis
        grid_bars = grid_bars.union(
            cq.Workplane("XZ").rect(bar_thick, bar_thick).workplane().box(bar_thick, bar_thick, limit)
            .translate((i * spacing, limit / 2, j * spacing))
        )
        # Bars along X axis
        grid_bars = grid_bars.union(
            cq.Workplane("YZ").rect(bar_thick, bar_thick).workplane().box(bar_thick, bar_thick, limit)
            .translate((limit / 2, i * spacing, j * spacing))
        )

# 2. Create the Variable Cubes
center_offset = limit / 2
nodes = cq.Workplane("XY")

for i in range(count):
    for j in range(count):
        for k in range(count):
            x, y, z = i * spacing, j * spacing, k * spacing
            
            dist = math.sqrt((x - center_offset)**2 + (y - center_offset)**2 + (z - center_offset)**2)
            
          
            cube_size = max_cube / (dist/spacing+1)
            
            # Create and place the cube
            nodes = nodes.union(
                cq.Workplane("XY").box(cube_size, cube_size, cube_size)
                .translate((x, y, z))
            )

# 3. Combine everything
final_structure = grid_bars.union(nodes)