# frozen_string_literal: true

# rspec spec/decider_spec.rb
RSpec.describe Decider do
  let(:decider) { described_class.new(world: world) }

  describe "#moves_for_day(daybreak_data)" do
    subject(:moves_for_day) { decider.moves_for_day(daybreak_data) }

    let(:world) { {} }

    let(:daybreak_data) do
      {
        day: 0,
        nutrients: 20,
        sun: 18,
        score: 0,
        opp_sun: 18,
        opp_score: 0,
        opp_waiting: false,
        trees: {
          6 => {:size=>3, :mine=>true, :dormant=>false},
          11 => {:size=>3, :mine=>true, :dormant=>false},
          21 => {:size=>3, :mine=>true, :dormant=>false},
        },
        actions: ["COMPLETE 11", "COMPLETE 21", "COMPLETE 6"].to_set
      }
    end

    context "when its wood2 and we can harvest a bunch of trees" do
      it "returns harvesting actions sorted in order (inner hexes have greater richness)" do
        is_expected.to eq(["COMPLETE 6", "COMPLETE 11", "COMPLETE 21"])
      end
    end
  end
end
