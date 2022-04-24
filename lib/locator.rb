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

  # @param caster [Hash] # a hero hash
  # @param distance [Integer] how far to look
  # @param monsters [Hash<Hash>] an id-keyed repo of monster data
  #
  # @return [Array<Hash>]
  def self.monsters_in_cast_range(caster:, monsters:, distance:)
    monsters.each_pair.with_object([]) do |(_k, monster), mem|
      mem << monster if distance_between(caster, monster) <= distance
    end
  end

  def self.distance_between(thing1, thing2)
    dist_x = (thing1[:x] - thing2[:x]).abs
    dist_y = (thing1[:y] - thing2[:y]).abs

    Math.sqrt((dist_x**2) + (dist_y**2)).round
  end

  # @return [Array<x, y>]
  def self.mound
    @mound ||=
      if BASE_X.zero?
        [4101, 4101]
      else
        [MAX_X - 4101, MAX_Y - 4101]
      end
  end

  # @return [Array<x, y>]
  def self.opp_base
    @opp_base ||=
      if BASE_X.zero?
        [MAX_X, MAX_Y]
      else
        [1, 1]
      end
  end
end
