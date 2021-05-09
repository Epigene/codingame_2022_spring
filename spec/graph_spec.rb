# frozen_string_literal: true

# rspec spec/graph_spec.rb
RSpec.describe Graph do
  let(:graph) { described_class.new }

  it "can be initialized without arguments" do
    expect(described_class.new).to be_a(described_class)
  end

  describe "#ensure_bidirectional_connection!(node1, node2)" do
    subject(:ensure_bidirectional_connection!) do
      graph.ensure_bidirectional_connection!(node1, node2)
    end

    let(:node1) { "a" }
    let(:node2) { "b" }

    it "makes at most one bidirectional connection per node pair" do
      # 1st call
      expect do
        graph.ensure_bidirectional_connection!(node1, node2)
      end.to(
        change{ graph[node1][:incoming].size }.from(0).to(1)
      )

      # repeat call
      expect do
        graph.ensure_bidirectional_connection!(node1, node2)
      end.to(
        not_change{ graph[node1][:incoming].size }
      )
    end
  end
end
