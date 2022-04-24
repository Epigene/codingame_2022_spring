# Data that game has the bot read once. Stub whatever is given here in specs.

# base_x: The corner of the map representing your base
BASE_X, BASE_Y = gets.split.map(&:to_i)
HEROES_PER_PLAYER = gets.to_i # Always 3

decider = Decider.new
