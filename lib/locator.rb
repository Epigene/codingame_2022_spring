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

  # @params threat [Hash] # must have
  def self.location(threat)
    [threat[:x], threat[:y]]
  end
end
