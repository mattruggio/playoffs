# typed: strict
# frozen_string_literal: true

require_relative 'tournament/bracketable'
require_relative 'tournament/roundable'

module Playoffs
  # Models the construction and lifecycle of a set of series in the configured order
  # leading to completion.
  class Tournament
    extend T::Sig
    include Bracketable
    include Roundable

    sig { override.returns(Series) }
    attr_reader :championship

    sig { override.returns(T::Array[Round]) }
    attr_reader :rounds

    sig { params(championship: Series).void }
    def initialize(championship)
      @championship = T.let(championship, Series)
      @rounds = T.let(rounds_from_series(championship), T::Array[Round])
    end

    sig { returns(String) }
    def to_s
      [
        print_bracket,
        '',
        print_rounds
      ].join("\n")
    end

    sig { returns(T.nilable(Series)) }
    def up_next
      current_round&.up_next
    end

    sig { returns(T::Boolean) }
    def over?
      !not_over?
    end

    sig { returns(T::Boolean) }
    def not_over?
      !up_next.nil?
    end

    sig { returns(T::Array[Round]) }
    def not_over
      rounds.select(&:not_over?)
    end

    sig { returns(T.nilable(Team)) }
    def winner
      championship.winner
    end
  end
end
