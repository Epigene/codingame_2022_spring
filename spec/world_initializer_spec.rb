# rspec spec/world_initializer_spec.rb
RSpec.describe WorldInitializer do
  let(:initializer) { described_class.new(lines) }

  describe "#call" do
    subject(:call) { initializer.call }
  end
end
