# frozen_string_literal: true

RSpec.describe Locator, :tl do
  describe ".distance_to_base(thing, base_x: BASE_X, base_y: BASE_Y)" do
    subject(:distance_to_base) { described_class.distance_to_base(thing) }

    let(:thing) do
      {
        x: 100,
        y: 500,
      }
    end

    context "when base is in the TL" do
      it { is_expected.to eq(510) }
    end

    context "when base is in the BR", :br do
      subject(:distance_to_base) do
        described_class.distance_to_base(thing, base_x: 17_630, base_y: 9000)
      end

      it { is_expected.to eq(19_482) } # about 19,794 - 510
    end
  end

  describe ".destination(threat)" do
    subject(:destination) { described_class.destination(threat) }

    let(:threat) do
      {
        x: 4452,
        y: 8656,
        vx: -121,
        vy: -381,
      }
    end

    it "returns the prospective destination of a threat" do
      expect(destination).to eq([4331, 8275])
    end
  end
end
