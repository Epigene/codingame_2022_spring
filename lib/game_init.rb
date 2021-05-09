number_of_cells = gets.to_i # 37

world = {}

lines = []
number_of_cells.times do
  # index: 0 is the center cell, the next cells spiral outwards
  # richness: 0 if the cell is unusable, 1-3 for usable cells
  # neigh_0: the index of the neighbouring cell for each direction
  lines << gets
end

decider = Decider.new(world: WorldInitializer.new(lines).call)
