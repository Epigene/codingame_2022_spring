class Decider
  attr_reader :world, :timeline

  def initialize(world:)
    @world = world
    @timeline = []
  end

  # Takes in all data known at daybreak.
  # Updates internal state and returns all moves we can reasonably make today.
  #
  # GROW cellIdx | SEED sourceIdx targetIdx | COMPLETE cellIdx | WAIT <message>
  #
  # @return [Array<String>]
  def moves_for_day(daybreak_data)
    # day:,
    # nutrients:,
    # sun:,
    # score:,
    # opp_sun:,
    # opp_score:,
    # opp_waiting:,
    # trees:,
    # actions:
    timeline << daybreak_data

    actions.
      select { |action| action.start_with?("COMPLETE") }.
      sort_by { |action| action.split(" ").last.to_i }
  end

  def current_day
    timeline.last
  end

  private

    def actions
      current_day[:actions]
    end
end
