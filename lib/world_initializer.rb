class WorldInitializer
  attr_reader :lines

  def initialize(lines)
    @lines = lines
  end

  # @return [Graph]
  def call
    world_graph = Graph.new

    lines.each do |line|
      index, richness, neigh_0, neigh_1, neigh_2, neigh_3, neigh_4, neigh_5 = line.split(" ").map(&:to_i)
      neighbors = [neigh_0, neigh_1, neigh_2, neigh_3, neigh_4, neigh_5]

      neighbors.each do |neigh|
        world_graph.ensure_bidirectional_connection!(index, neigh)
        world_graph[i][:r] = richness
      end
    end

    world_graph
  end
end
