# frozen_string_literal: true

# rspec spec/decider_spec.rb
RSpec.describe Decider do
  let(:decider) { described_class.new(world: world) }

  describe "#move(params)" do
    subject(:move) { decider.move(params) }

    let(:world) { WorldInitializer.new(lines).call }
    let(:lines) { [] }

    context "when its wood2 and we can harvest a bunch of trees" do
      let(:params) do
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

      it "returns harvesting actions sorted in order (inner hexes have greater richness)" do
        is_expected.to eq("COMPLETE 6")
      end
    end

    context "when its wood1, and we need to get growing" do
      let(:params) do
        {
          day: 0,
          nutrients: 20,
          sun: 4,
          score: 0,
          opp_sun: 4,
          opp_score: 0,
          opp_waiting: false,
          trees: {
            1=>{:size=>1, :mine=>true, :dormant=>false},
            4=>{:size=>1, :mine=>false, :dormant=>false},
            10=>{:size=>1, :mine=>false, :dormant=>false},
            16=>{:size=>1, :mine=>true, :dormant=>false},
            22=>{:size=>1, :mine=>false, :dormant=>false},
            27=>{:size=>1, :mine=>false, :dormant=>false},
            31=>{:size=>1, :mine=>true, :dormant=>false},
            36=>{:size=>1, :mine=>true, :dormant=>false}
          },
          actions: ["WAIT", "GROW 1", "GROW 31", "GROW 16", "GROW 36"].to_set
        }
      end

      it "prefers growing the tree on richest soil" do
        is_expected.to eq("GROW 1")
      end
    end

    context "when it's wood1, and we should grow the second 1->2" do
      let(:params) do
        {
          day: 1,
          nutrients: 20,
          sun: 6,
          score: 0,
          opp_sun: 6,
          opp_score: 0,
          opp_waiting: false,
          trees: {
            1=>{:size=>2, :mine=>true, :dormant=>false},
            4=>{:size=>1, :mine=>false, :dormant=>false},
            19=>{:size=>2, :mine=>false, :dormant=>false},
            21=>{:size=>1, :mine=>false, :dormant=>false},
            25=>{:size=>1, :mine=>true, :dormant=>false},
            28=>{:size=>1, :mine=>true, :dormant=>false},
            30=>{:size=>1, :mine=>true, :dormant=>false},
            34=>{:size=>1, :mine=>false, :dormant=>false}
          },
          actions: ["WAIT", "GROW 28", "GROW 25", "GROW 30"].to_set
        }
      end

      it "opts to grow the lowest-id size 1 tree" do
        is_expected.to eq("GROW 25")
      end
    end

    context "when it's wood1, and we should grow first 2->3 after having two 2s" do
      let(:params) do
        {
          day: 2,
          nutrients: 20,
          sun: 8,
          score: 0,
          opp_sun: 8,
          opp_score: 0,
          opp_waiting: false,
          trees: {
            7=>{:size=>2, :mine=>true, :dormant=>false},
            9=>{:size=>1, :mine=>false, :dormant=>false},
            13=>{:size=>2, :mine=>false, :dormant=>false},
            15=>{:size=>2, :mine=>true, :dormant=>false},
            24=>{:size=>2, :mine=>false, :dormant=>false},
            26=>{:size=>1, :mine=>true, :dormant=>false},
            33=>{:size=>1, :mine=>true, :dormant=>false},
            35=>{:size=>1, :mine=>false, :dormant=>false}
          },
          actions: ["WAIT", "GROW 7", "GROW 15", "GROW 26", "GROW 33"].to_set,
        }
      end

      it "opts to grow the lowest-id size 1 tree" do
        is_expected.to eq("GROW 7")
      end
    end

    context "when it's bronze and the best move is seed towards center, but no center hexes are possible" do
      let(:lines) do
        [
          "0 3 1 2 3 4 5 6",
          "1 3 7 8 2 0 6 18",
          "2 0 8 9 10 3 0 1",
          "3 3 2 10 11 12 4 0",
          "4 3 0 3 12 13 14 5",
          "5 0 6 0 4 14 15 16",
          "6 3 18 1 0 5 16 17",
          "7 2 19 20 8 1 18 36",
          "8 2 20 21 9 2 1 7",
          "9 2 21 22 23 10 2 8",
          "10 2 9 23 24 11 3 2",
          "11 2 10 24 25 26 12 3",
          "12 2 3 11 26 27 13 4",
          "13 2 4 12 27 28 29 14",
          "14 2 5 4 13 29 30 15",
          "15 2 16 5 14 30 31 32",
          "16 2 17 6 5 15 32 33",
          "17 2 35 18 6 16 33 34",
          "18 2 36 7 1 6 17 35",
          "19 1 -1 -1 20 7 36 -1",
          "20 1 -1 -1 21 8 7 19",
          "21 1 -1 -1 22 9 8 20",
          "22 1 -1 -1 -1 23 9 21",
          "23 1 22 -1 -1 24 10 9",
          "24 1 23 -1 -1 25 11 10",
          "25 1 24 -1 -1 -1 26 11",
          "26 1 11 25 -1 -1 27 12",
          "27 1 12 26 -1 -1 28 13",
          "28 1 13 27 -1 -1 -1 29",
          "29 1 14 13 28 -1 -1 30",
          "30 1 15 14 29 -1 -1 31",
          "31 1 32 15 30 -1 -1 -1",
          "32 1 33 16 15 31 -1 -1",
          "33 1 34 17 16 32 -1 -1",
          "34 1 -1 35 17 33 -1 -1",
          "35 1 -1 36 18 17 34 -1",
          "36 1 -1 19 7 18 35 -1"
        ]
      end

      let(:params) do
        {
          day: 0,
          nutrients: 20,
          sun: 2,
          score: 0,
          opp_sun: 2,
          opp_score: 0,
          opp_waiting: false,
          trees: {
            23=>{:size=>1, :mine=>false, :dormant=>false},
            26=>{:size=>1, :mine=>true, :dormant=>false},
            32=>{:size=>1, :mine=>true, :dormant=>false},
            35=>{:size=>1, :mine=>false, :dormant=>false}
          },
          actions: ["WAIT", "SEED 32 16", "SEED 26 12", "SEED 26 11", "SEED 26 27", "SEED 32 15", "SEED 26 25", "SEED 32 33", "SEED 32 31"].to_set,
        }
      end

      it "prefers seeeding such that two center hexes are adjacent to the seed" do
        is_expected.to eq("SEED 26 12")
      end
    end
  end
end
