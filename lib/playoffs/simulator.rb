# typed: strict
# frozen_string_literal: true

module Playoffs
  # Describes what functionality a Simulator should implement.
  module Simulator
    extend T::Sig
    extend T::Helpers
    interface!

    sig { abstract.params(series: Series).returns(Team) }
    def pick(series); end
  end
end
