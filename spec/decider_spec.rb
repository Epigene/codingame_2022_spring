# frozen_string_literal: true

# rspec spec/decider_spec.rb
RSpec.describe Decider do
  let(:decider) { described_class.new(world: world) }

  describe "#move(params)" do
    subject(:move) { decider.move(params) }

    let(:world) { {} }

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
  end
end
