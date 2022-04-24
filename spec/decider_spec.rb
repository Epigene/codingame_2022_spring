# frozen_string_literal: true

# rspec spec/decider_spec.rb
RSpec.describe Decider, :tl do
  let(:decider) { described_class.new }

  describe "#update_gamestate!(step_info)" do
    subject(:update_gamestate!) { decider.update_gamestate!(step_info) }

    context "when base is in TL there are five monsters, three of which are actual threats" do
      let(:step_info) do
        {
          lines: [
            "9 0 9438 1864 0 0 8 201 -345 0 0", # nonthreat
            "11 0 5793 5651 0 0 10 -279 -286 0 1", # middle
            "14 0 12455 2906 0 0 3 280 285 0 2", # threat to opp
            "7 0 3594 2281 0 0 10 -337 -214 1 1", # closest
            "17 0 14480 9847 0 0 11 -259 -304 0 1", # furthest
          ]
        }
      end

      it "modifies @threats to contain threats in descending order to base" do
        update_gamestate!

        expect(decider.__send__(:threats)).to match(
          [
            hash_including(id: 7),
            hash_including(id: 11),
            hash_including(id: 17),
          ]
        )
      end
    end

    context "when base is in BR there are five monsters, three of which are actual threats", :br do
      let(:step_info) do
        {
          lines: [
            "9 0 9438 1864 0 0 8 201 -345 0 0", # nonthreat
            "11 0 5793 5651 0 0 10 -279 -286 0 1", # middle
            "14 0 12455 2906 0 0 3 280 285 0 2", # threat to opp
            "7 0 3594 2281 0 0 10 -337 -214 1 1", # furthest
            "17 0 14480 9847 0 0 11 -259 -304 0 1", # closest
          ]
        }
      end

      it "modifies @threats to contain threats in descending order to base" do
        update_gamestate!

        expect(decider.__send__(:threats)).to match(
          [
            hash_including(id: 17),
            hash_including(id: 11),
            hash_including(id: 7),
          ]
        )
      end
    end
  end
end
