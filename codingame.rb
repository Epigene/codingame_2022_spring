class Decider
  attr_reader :world, :timeline

  def initialize(world:)
    @world = world
    @timeline = []
  end

  # Takes in all data known at daybreak.
  # Updates internal state and returns all moves we can reasonably make today.
  #
  # GROW cellIdx | SEED sourceIdx targetIdx | COMPLETE cellIdx | WAIT <message>
  #
  # @return [Array<String>]
  def moves_for_day(daybreak_data)
    # day:,
    # nutrients:,
    # sun:,
    # score:,
    # opp_sun:,
    # opp_score:,
    # opp_waiting:,
    # trees:,
    # actions:
    timeline << daybreak_data

    actions.
      select { |action| action.start_with?("COMPLETE") }.
      sort_by { |action| action.split(" ").last.to_i }
  end

  def current_day
    timeline.last
  end

  private

    def actions
      current_day[:actions]
    end
end

require "set"
require "benchmark"

STDOUT.sync = true # DO NOT REMOVE

def debug(message)
  STDERR.puts(message)
end

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

timeline = {}

loop do
  day = gets.to_i # the game lasts 24 days: 0-23
  nutrients = gets.to_i # the base score you gain from the next COMPLETE action
  # sun: your sun points
  # score: your current score
  sun, score = gets.split(" ").map(&:to_i)
  # opp_sun: opponent's sun points
  # opp_score: opponent's score
  # opp_is_waiting: whether your opponent is asleep until the next day
  opp_sun, opp_score, opp_waiting = gets.split(" ")
  opp_sun = opp_sun.to_i
  opp_score = opp_score.to_i
  opp_waiting = opp_waiting.to_i == 1

  number_of_trees = gets.to_i # the current amount of trees

  trees = {}
  number_of_trees.times do
    # cell_index: location of this tree
    # size: size of this tree: 0-3
    # is_mine: 1 if this is your tree
    # is_dormant: 1 if this tree is dormant
    cell_index, size, is_mine, is_dormant = gets.split(" ")
    cell_index = cell_index.to_i
    size = size.to_i
    is_mine = is_mine.to_i == 1
    is_dormant = is_dormant.to_i == 1
    trees[cell_index] = {size: size, mine: is_mine, dormant: is_dormant}
  end

  number_of_possible_actions = gets.to_i # all legal actions

  actions = Set.new
  number_of_possible_actions.times do
    actions << gets.chomp # try printing something from here to start with
  end

  debug("day: #{ day }")
  debug("nutrients: #{ nutrients }")
  debug("my sun and score: #{ [sun, score] }")
  debug("opp sun, score and waiting: #{ [opp_sun, opp_score, opp_waiting] }")
  debug("trees: #{ number_of_trees }")
  trees.each_pair do |index, data|
    debug("tree##{ index }: #{ data }")
  end
  debug("actions: #{ number_of_possible_actions }")
  actions.each do |action|
    debug(action)
  end

  day_params = {
    day: day, # the game lasts 24 days: 0-23
    nutrients: nutrients,
    sun: sun,
    score: score,
    opp_sun: opp_sun,
    opp_score: opp_score,
    opp_waiting: opp_waiting,
    trees: trees,
    actions: actions
  }

  decider.moves_for_day(day_params).each do |move|
    puts(move)
  end
end

