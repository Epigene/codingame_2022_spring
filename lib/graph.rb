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
