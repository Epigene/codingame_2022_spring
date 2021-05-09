# rspec spec/world_initializer_spec.rb
RSpec.describe WorldInitializer do
  let(:initializer) { described_class.new(lines) }

  describe "#call" do
    subject(:call) { initializer.call }

    context "when initialized with dead hexes" do
      let(:lines) do
        [

        ]
      end

      it "returns a Graph with those hex nodes removed" do
        expect(call[2]).to be_nil
        expect(call[5]).to be_nil
        expect(call[0]).to be_present
      end
    end
  end
end
