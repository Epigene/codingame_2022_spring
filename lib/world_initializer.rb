class WorldInitializer
  attr_reader :lines

  # @lines [Array<String>]
  def initialize(lines)
    @lines = lines
  end

  # @return [Graph]
  def call
    world_graph = Graph.new

    to_delete = []

    lines.each do |line|
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
