# typed: strict
# frozen_string_literal: true

module Playoffs
  # Represents a group of series that can be played at the same time.
  class Round
    extend T::Sig

    sig { returns(T::Array[Series]) }
    attr_reader :series

    sig { params(series: T::Array[Series]).void }
    def initialize(series)
      @series = series
    end

    sig { returns(String) }
    def to_s
      series.map(&:to_s).join("\n")
    end

    sig { returns(T.nilable(Series)) }
    def up_next
      not_over.first
    end

    sig { returns(T::Boolean) }
    def over?
      not_over.empty?
    end

    sig { returns(T::Boolean) }
    def not_over?
      !over?
    end

    sig { returns(T::Array[Series]) }
    def not_over
      series.reject(&:over?).sort_by(&:games_played)
    end
  end
end
