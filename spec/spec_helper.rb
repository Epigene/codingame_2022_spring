require "bundler/setup"
require "codinbot"
require "pry"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before do
    stub_const("HEROES_PER_PLAYER", 3)
    stub_const("BASE_X", base_x)
    stub_const("BASE_Y", base_y)
  end

  RSpec::Matchers.define_negated_matcher(:not_change, :change)
end

RSpec.shared_context("BR", :br) do
  let(:base_x) { MAX_X }
  let(:base_y) { MAX_Y }
end

RSpec.shared_context("TL", :tl) do
  let(:base_x) { 0 }
  let(:base_y) { 0 }
end
