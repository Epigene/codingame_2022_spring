# Implements a directionless and weightless graph structure with named nodes
class Graph
  # Key data storage.
  # Each key is a node (key == name),
  # and the value set represents the neighbouring nodes.
  # private attr_reader :structure

  attr_reader :structure

  # @nodes [Array]
  def initialize(nodes=[])
    @structure =
      Hash.new do |hash, key|
        hash[key] = {outgoing: Set.new, incoming: Set.new}
      end

    nodes.each do |node|
      structure[node] = {outgoing: Set.new, incoming: Set.new}
    end
  end

  # A shorthand access to underlying has node structure
  def [](node)
    structure[node]
  end

  def []=(node, value)
    structure[node] = value
  end

  def nodes
    structure.keys
  end

  # adds a bi-directional connection between two nodes
  def connect_nodes_bidirectionally(node1, node2)
    structure[node1][:incoming] << node2
    structure[node1][:outgoing] << node2

    structure[node2][:incoming] << node1
    structure[node2][:outgoing] << node1

    nil
  end

  def ensure_bidirectional_connection!(node1, node2)
    d1 = structure[node1]
    d1[:incoming] << node2 unless d1[:incoming].include?(node2)
    d1[:outgoing] << node2 unless d1[:outgoing].include?(node2)

    d2 = structure[node2]
    d2[:incoming] << node1 unless d2[:incoming].include?(node1)
    d2[:outgoing] << node1 unless d2[:outgoing].include?(node1)

    nil
  end

  # Severs all connections to and from this node
  # @return [nil]
  def remove_node(node)
    structure[node][:incoming].each do |other_node|
      structure[other_node][:outgoing] -= [node]
    end

    structure.delete(node)

    nil
  end

  # @root/@destination [String] # "1, 4"
  #
  # @return [Array, nil] # will return an array of nodes from root to destination, or nil if no path exists
  def dijkstra_shortest_path(root, destination)
    # When we choose the arbitrary starting parent node we mark it as visited by changing its state in the 'visited' structure.
    visited = Set.new([root])

    parent_node_list = {root => nil}

    # Then, after changing its value from FALSE to TRUE in the "visited" hash, we’d enqueue it.
    queue = [root]

    # Next, when dequeing the vertex, we need to examine its neighboring nodes, and iterate (loop) through its adjacent linked list.
    loop do
      dequeued_node = queue.shift
      # debug "dequed '#{ dequeued_node }', remaining queue: '#{ queue }'"

      if dequeued_node.nil?
        return
        # raise("Queue is empty, but destination not reached!")
      end

      neighboring_nodes = structure[dequeued_node][:outgoing]
      # debug "neighboring_nodes for #{ dequeued_node }: '#{ neighboring_nodes }'"

      neighboring_nodes.each do |node|
        # If either of those neighboring nodes hasn’t been visited (doesn’t have a state of TRUE in the “visited” array),
        # we mark it as visited, and enqueue it.
        next if visited.include?(node)

        visited << node
        parent_node_list[node] = dequeued_node

        # debug "parents: #{ parent_node_list }"

        if node == destination
          # destination reached
          path = [node]

          loop do
            parent_node = parent_node_list[path[0]]

            return path if parent_node.nil?

            path.unshift(parent_node)
            # debug "path after update: #{ path }"
          end
        else
          queue << node
        end
      end
    end
  end

  private

    def initialize_copy(copy)
      dupped_structure =
        structure.each_with_object({}) do |(k, v), mem|
          mem[k] =
            v.each_with_object({}) do |(sk, sv), smem|
              smem[sk] = sv.dup
            end
        end

      copy.instance_variable_set("@structure", dupped_structure)

      super
    end
end

class Decider
  attr_reader :world, :timeline

  LAST_DAY = 23

  # @world [Graph]
  def initialize(world:)
    @world = world
    @timeline = []
  end

  # Takes in all data known at daybreak.
  # Updates internal state and returns all moves we can reasonably make today.
  #
  # GROW cellIdx | SEED sourceIdx targetIdx | COMPLETE cellIdx | WAIT <message>
  # Growing:
  #  - size1 -> 2: costs 3 + size 2 trees already owned.
  #  - size2 -> 3: costs 7 + size 3 trees already owned.
  #  - size3 -> harvest: 4 points
  #
  # @return [Array<String>]
  def move(params)
    # day:,
    # nutrients:,
    # sun:,
    # score:,
    # opp_sun:,
    # opp_score:,
    # opp_waiting:,
    # trees:,
    # actions:
    params.each_pair do |k, v|
      debug("#{ k }: #{ v },")
    end
    timeline << params

    if begin_harvest?
      actions.
        select { |action| action.start_with?("COMPLETE") }.
        min_by { |action| action.split(" ").last.to_i } ||
          "WAIT hump, nothing to harvest"
    elsif plant?
      # plant_moving_to_center

      binding.pry
    elsif grow?
      grow = nil

      if can_afford?(:two_to3) && my_harvestable_trees.size < 2
        inter = my_size2_trees.keys.sort.map { |i| "GROW #{ i }" }.to_set & actions

        grow = inter.sort_by { |a| a.split(" ").last.to_i }.first
      end

      if can_afford?(:one_to2) && my_size2_trees.size < 2
        inter = my_size1_trees.keys.sort.map { |i| "GROW #{ i }" }.to_set & actions

        grow = inter.sort_by { |a| a.split(" ").last.to_i }.first
      end

      grow || "WAIT"
    else
      "WAIT"
    end
  end

  def current_move
    timeline.last
  end

  private

    def begin_harvest?
      current_move[:day] >= LAST_DAY || my_harvestable_trees.size >= 2 && sun >= 8
    end

    def grow?
      my_harvestable_trees.size < 2 # && my_size2_trees.size < 2
    end

    def plant?
      # for first days do nothing but seed
      return true if current_move[:day] <= 18 && first_seed_action
      return false if current_move[:day] >= LAST_DAY - 3

      false # or true?
    end

    def can_afford?(mode) # :harvest
      case mode
      when :harvest
        sun >= 4
      when :two_to3
        sun >= (7 + my_harvestable_trees.size)
      when :one_to2
        sun >= (3 + my_size2_trees.size)
      when :plant
        sun >= my_seeds.size
      else
        raise("mode '#{ mode }' not supported")
      end
    end

    def sun
      current_move[:sun]
    end

    # @return [Hash] {1 => {:size=>1, :mine=>true, :dormant=>false}}
    def my_trees
      current_move[:trees].select { |i, t| t[:mine] }.to_h
    end

    # @return [Hash] {1 => {:size=>1, :mine=>true, :dormant=>false}}
    def my_harvestable_trees
      my_trees.select { |i, t| t[:size] >= 3 }.to_h
    end

    def my_size2_trees
      my_trees.select { |i, t| t[:size] == 2 }.to_h
    end

    def my_size1_trees
      my_trees.select { |i, t| t[:size] == 1 }.to_h
    end

    def my_seeds
      my_trees.select { |i, t| t[:size] == 0 }.to_h
    end

    # @return [Set]
    def actions
      current_move[:actions]
    end

    # @return [String, nil] # use presence as indicator that seeding can take place
    def first_seed_action
      actions.find { |a| a.start_with?("SEED") }
    end
end

class WorldInitializer
  attr_reader :lines

  # @lines [Array<String>]
  def initialize(lines)
    @lines = lines
  end

  # @return [Graph]
  def call
    world_graph = ::Graph.new

    to_delete = []

    lines.each do |line|
      debug("\"#{ line }\",")

      index, richness, neigh_0, neigh_1, neigh_2, neigh_3, neigh_4, neigh_5 = line.split(" ").map(&:to_i)
      neighbors = [neigh_0, neigh_1, neigh_2, neigh_3, neigh_4, neigh_5]

      to_delete << index if richness < 1

      neighbors.each do |neigh|
        next if neigh.negative?

        world_graph.ensure_bidirectional_connection!(index, neigh)
        world_graph[index][:r] = richness
      end
    end

    to_delete.each do |index|
      world_graph.remove_node(index)
      world_graph[index] = nil
    end

    world_graph
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

lines = []
number_of_cells.times do
  # index: 0 is the center cell, the next cells spiral outwards
  # richness: 0 if the cell is unusable, 1-3 for usable cells
  # neigh_0: the index of the neighbouring cell for each direction
  lines << gets.chomp
end

decider = Decider.new(world: WorldInitializer.new(lines).call)

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

  # debug("day: #{ day }")
  # debug("nutrients: #{ nutrients }")
  # debug("my sun and score: #{ [sun, score] }")
  # debug("opp sun, score and waiting: #{ [opp_sun, opp_score, opp_waiting] }")
  # debug("trees: #{ number_of_trees }")
  # trees.each_pair do |index, data|
  #   debug("tree##{ index }: #{ data }")
  # end
  # debug("actions: #{ number_of_possible_actions }")
  # actions.each do |action|
  #   debug(action)
  # end

  params = {
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

  puts decider.move(params)
end

