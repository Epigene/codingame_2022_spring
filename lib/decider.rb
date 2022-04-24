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
    closest_threat_destination = Locator.location(threats[0])

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
