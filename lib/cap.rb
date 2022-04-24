# Knows everything about what moves make sense given a hero's location.
# :move is always available and implicit.
# There are two dimensions - distance from base, and distance to opponent base.
# Ranges for :wind
#   [0-3721] :wind is OK since any monsters in range are by definition on lawn
#   [3722-6279] :wind is possible, but monsters must be checked for range and being on lawn (4999)
#   [6280) no :wind
#
# Ranged for :control
#   [7200) can :control freely

class Cap
  def self.call(hero)
    @cache ||= {}

    return @cache[hero] if @cache[hero]

    instance = new(hero)

    @cache[hero] = instance
  end

  # @return [Set] :control_opp, :control, :wind, :shield
  def moves
    return @moves if defined?(@moves)

    @moves = [:shield].to_set

    distance_to_base = Locator.distance_to_base(@hero)
    # distance_to_opp_base = TODO

    @moves << :wind if (0..6279).include?(distance_to_base)
    @moves << :control_opp if (0..4000).include?(distance_to_base)
    @moves << :control if (7200..).include?(distance_to_base)

    @moves
  end

  private

  def initialize(hero)
    @hero = hero
  end
end
