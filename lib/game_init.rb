number_of_cells = gets.to_i # 37

world = {}

number_of_cells.times do
  # index: 0 is the center cell, the next cells spiral outwards
  # richness: 0 if the cell is unusable, 1-3 for usable cells
  # neigh_0: the index of the neighbouring cell for each direction
  line = gets
  debug(line)
  index, richness, neigh_0, neigh_1, neigh_2, neigh_3, neigh_4, neigh_5 = line.split(" ").map(&:to_i)

  world[index] = {
    r: richness
    # TODO, handle neighbours binding.pry
  }
end

decider = Decider.new(world: world)
