# typed: strict
# frozen_string_literal: true

# Use a deterministic simulator so we can test.
class FirstPicker
  extend T::Sig
  include Playoffs::Simulator

  sig { override.params(series: Playoffs::Series).returns(Playoffs::Team) }
  def pick(series)
    T.must(series.teams.first)
  end
end

