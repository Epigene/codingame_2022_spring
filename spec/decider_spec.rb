# frozen_string_literal: true

# rspec spec/decider_spec.rb
RSpec.describe Decider, :tl do
  let(:decider) { described_class.new }

  describe "#call(step_info)" do
    subject(:call) { decider.call(step_info) }

    let(:step_info) do
      {
        health: 3, mana: 10, opp_health: 3, opp_mana: 10, lines: lines,
      }
    end

    context "when hero1 is in a position to :wind monster(s) out of lawn" do
      let(:lines) do
        [
          "0 1 3721 0 0 0", # hero1
          "1 1 3721 0 0 0", # hero2
          "2 1 3721 0 0 0", # hero3
          "7 0 3922 100 0 0 10 -337 0 1 1", # closest
        ]
      end

      before do
        stub_const("MAX_X", 10_000)
      end

      it "returns commands to wind towards opponent's base" do
        is_expected.to match(
          [
            "WIND 10000 9000",
            anything,
            anything,
          ],
        )
      end
    end

    context "when hero1 is not quite in a position to wind a monster out of lawn" do
      # not sure why Wind is used, the monster is not on lawn
      Standard Error Stream:
        3 1 13529 4899 0 0 -1 -1 -1 -1 -1
        4 1 13529 4899 0 0 -1 -1 -1 -1 -1
        5 1 13529 4899 0 0 -1 -1 -1 -1 -1
        36 0 11903 5521 0 0 13 -57 395 0 0
        40 0 14619 3205 0 0 14 164 364 0 1
      Standard Output Stream:
        MOVE 14619 3205
        MOVE 14619 3205
        MOVE 14619 3205

      Standard Error Stream:
        3 1 13961 4227 0 0 -1 -1 -1 -1 -1
        4 1 13961 4227 0 0 -1 -1 -1 -1 -1
        5 1 13961 4227 0 0 -1 -1 -1 -1 -1
        40 0 14783 3569 0 0 14 164 364 0 1
      Standard Output Stream:
        SPELL WIND 1 1
        MOVE 14783 3569
        MOVE 14783 3569

      it " " do
        expect(0).to eq(1)
      end
    end
  end

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
