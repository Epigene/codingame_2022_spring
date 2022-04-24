# Created at 2022-04-24 14:39:53 +0300 
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
      structure[other_node][:incoming] -= [node]
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

# Implements 2d navigation helpers
module Locator
  # @params thing [Hash] # must have :x and :y keys
  def self.distance_to_base(thing, base_x: BASE_X, base_y: BASE_Y)
    dist_x = (thing[:x] - base_x).abs
    dist_y = (thing[:y] - base_y).abs

    Math.sqrt((dist_x**2) + (dist_y**2)).round
  end

  # @params threat [Hash] # must have
  def self.destination(threat)
    [threat[:x] + threat[:vx], threat[:y] + threat[:vy]]
  end
end

# The Decider
class Decider
  # @world [Graph]
  def initialize
  end

  # @param step_info [Hash]
  #  health: my_health, mana: my_mana, opp_health: opp_health, opp_mana: opp_mana, lines: lines
  # @return [Array<String>]
  def call(step_info)
    update_gamestate!(step_info)

    if threats.any?
      focus_on_closest_threat!
    else
      camp_at_mound!
    end
  end

  def update_gamestate!(step_info)
    timeline << step_info
    @monsters = {}
    @threats = []

    update_heroes!
    update_monsters!
  end

  private

  # @return [Array<String>]
  def focus_on_closest_threat!
    closest_threat_destination = Locator.destination(threats[0])

    HEROES_PER_PLAYER.times.with_object([]) do |_i, mem|
      mem << "MOVE #{closest_threat_destination[0]} #{closest_threat_destination[1]}"
    end
  end

  # @return [Array<String>]
  def camp_at_mound!
    HEROES_PER_PLAYER.times.with_object([]) do |_i, mem|
      mem << "MOVE #{mound[0]} #{mound[1]}"
    end
  end

  def params
    timeline.last
  end

  def lines
    params[:lines]
  end

  def update_heroes!
    # lines.each do |line|
    # end

    # id: Unique identifier
    # type: 0=monster, 1=your hero, 2=opponent hero
    # x: Position of this entity
    # shield_life: Ignore for this league; Count down until shield spell fades
    # is_controlled: Ignore for this league; Equals 1 when this entity is under a control spell
    # health: Remaining health of this monster
    # vx/y: Trajectory of this monster
    # near_base: 0=monster with no target yet, 1=monster targeting a base
    # threat_for: Given this monster's trajectory, is it a threat to 1=your base, 2=your opponent's base, 0=neither

    # id, type, x, y, shield_life, is_controlled, health, vx, vy, near_base, threat_for = line.split(" ").collect { |x| x.to_i }
  end

  MONSTER_LINE_REGEX = %r'^\d+ 0'.freeze

  def update_monsters!
    lines.cycle(1) do |line|
      next unless line.match?(MONSTER_LINE_REGEX)

      id, _type, x, y, shield, is_controlled, health, vx, vy, near_base, threat_for = line.split.map(&:to_i)

      data = {
        id: id,
        x: x,
        y: y,
        shield: shield,
        is_controlled: is_controlled,
        health: health,
        vx: vx,
        vy: vy,
        near_base: near_base,
        threat_for: threat_for
      }

      monsters[id] = data

      if threat_for == 1
        index =
          threats.bsearch_index do |middle_threat, _|
            Locator.distance_to_base(middle_threat) > Locator.distance_to_base(data)
          end

        index = -1 if index.nil?

        threats.insert(index, data)
      end
    end
  end

  def monsters
    @monsters ||= {}
  end

  # monsters who actually move towards the base, sorted ascending by distance from the base
  def threats
    @threats ||= []
  end

  # @return [Hash]
  def my_heroes
    @my_heroes ||= {}
  end

  # @return [Hash]
  def opp_heroes
    @opp_heroes ||= {}
  end

  def timeline
    @timeline ||= []
  end
end

class WorldInitializer
  # @lines [Array<String>]
  def initialize
  end

  # @return [Graph]
  def call
  end

  private


end

require "set"
require "benchmark"

STDOUT.sync = true # DO NOT REMOVE

def debug(message)
  STDERR.puts(message)
end

MAX_X = 17_630
MAX_Y = 9000

HERO_MOVESPEED = 800 # 566, 566 in a 45% angle
HERO_ATTACKRANGE = 800

MONSTER_MOVESPEED = 400 # half that of a hero

LAWN_RADIOUS = 5000
BASE_RADIUS = 300

def mound
  return @mound if defined?(@mound)

  if BASE_X.zero?
    [4101, 4101]
  else
    [MAX_X - 4101, MAX_Y - 4101]
  end
end

# Data that game has the bot read once. Stub whatever is given here in specs.

# base_x: The corner of the map representing your base
BASE_X, BASE_Y = gets.split.map(&:to_i)
HEROES_PER_PLAYER = gets.to_i # Always 3

decider = Decider.new

# game loop
loop do
  line = gets
  debug(line)
  # health: Your base health
  # mana: Ignore in the first league; Spend ten mana to cast a spell
  my_health, my_mana = line.split.map(&:to_i)

  line = gets
  debug(line)
  # health: Your base health
  # mana: Ignore in the first league; Spend ten mana to cast a spell
  opp_health, opp_mana = line.split.map(&:to_i)

  lines = []

  entity_count = gets.to_i # Amount of heros and monsters you can see

  entity_count.times do
    line = gets
    debug(line)
    lines << line
  end

  params = {
    health: my_health, mana: my_mana, opp_health: opp_health, opp_mana: opp_mana, lines: lines
  }

  decider.call(params).select { |command| puts(command) }
  #=> puts as many commands as I have heroes.
end

