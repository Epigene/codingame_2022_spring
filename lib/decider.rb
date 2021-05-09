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
