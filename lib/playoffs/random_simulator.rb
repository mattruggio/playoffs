# typed: strict
# frozen_string_literal: true

require_relative 'simulator'

module Playoffs
  # Very simple example of how to select a winner for a series.
  class RandomSimulator
    extend T::Sig
    include Simulator

    sig { override.params(series: Series).returns(Team) }
    def pick(series)
      index = rand(0..1)

      T.must(series.teams[index])
    end
  end
end
