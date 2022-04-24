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

    # if hero1 on lawn, there's no monsters, but an opponent hero is controllable - do it
    # if @commands[0].nil? && params[:mana] >= 10 && Cap.call(hero1).on_lawn? && Cap.call(hero1).moves.include?(:control) && ()

    # end

    # if hero1 on lawn, can cast :wind and there's monsters, - do it
    hero1_push_monsters_off_lawn? &&
      @commands[0] = "SPELL WIND #{Locator.opp_base[0]} #{Locator.opp_base[1]}"

    if threats.any?
      focus_on_closest_threat!
    else
      camp_at_mound!
    end

    @commands
  end

  def update_gamestate!(step_info)
    timeline << step_info
    @commands = Array.new(HEROES_PER_PLAYER)
    @monsters = {}
    @threats = []

    update_heroes!
    update_monsters!
  end

  private

  def hero1_push_monsters_off_lawn?
    @commands[0].nil? && params[:mana] >= 10 &&
      Cap.call(hero1).moves.include?(:wind) &&
      Locator.monsters_in_cast_range(caster: hero1, monsters: monsters, distance: WIND_CASTRANGE).any?
  end

  # @return [Array<String>]
  def focus_on_closest_threat!
    closest_threat_location = Locator.location(threats[0])

    HEROES_PER_PLAYER.times do |i|
      @commands[i] ||= "MOVE #{closest_threat_location[0]} #{closest_threat_location[1]}"
    end
  end

  # @return [Array<String>]
  def camp_at_mound!
    m = Locator.mound

    HEROES_PER_PLAYER.times do |i|
      @commands[i] ||= "MOVE #{m[0]} #{m[1]}"
    end
  end

  def params
    timeline.last
  end

  def lines
    params[:lines]
  end

  def update_heroes!
    lines.cycle(1) do |line|
      next if line.match?(MONSTER_LINE_REGEX)

      id, type, x, y, shield, charmed, _whatever = line.split.map(&:to_i)

      data = {
        id: id,
        x: x,
        y: y,
        shield: shield,
        charmed: charmed == 1,
      }

      if type == 1
        my_heroes[id] = data
      else
        opp_heroes[id] = data
      end
    end
  end

  def hero1
    @hero1_index ||= BASE_X.zero? ? 0 : 3
    my_heroes[@hero1_index]
  end

  def hero2
    @hero2_index ||= BASE_X.zero? ? 1 : 4
    my_heroes[@hero2_index]
  end

  def hero3
    @hero3_index ||= BASE_X.zero? ? 2 : 5
    my_heroes[@hero3_index]
  end

  MONSTER_LINE_REGEX = %r'^\d+ 0'.freeze

  def update_monsters!
    lines.cycle(1) do |line|
      next unless line.match?(MONSTER_LINE_REGEX)

      id, _type, x, y, shield, charmed, health, vx, vy, near_base, threat_for = line.split.map(&:to_i)

      data = {
        id: id,
        x: x,
        y: y,
        shield: shield,
        charmed: charmed,
        health: health,
        vx: vx,
        vy: vy,
        near_base: near_base,
        threat_for: threat_for,
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
