# typed: strict
# frozen_string_literal: true

module Playoffs
  class Tournament
    # Understands how to take a top-level series
    module Roundable
      extend T::Helpers
      extend T::Sig

      abstract!

      sig { abstract.returns(T::Array[Round]) }
      def rounds; end

      sig { returns(T.nilable(Round)) }
      def current_round
        rounds.find(&:not_over?)
      end

      sig { returns(String) }
      def print_rounds
        rounds.map { |round, _number| [round.to_s, ''] }.join("\n")
      end

      private

      sig { params(series: Series).returns(T::Array[Round]) }
      def rounds_from_series(series)
        group_by_round(series).values.reverse.map { |s| Round.new(s) }
      end

      sig do
        params(
          series: Series,
          depth: Integer,
          series_by_depth: T::Hash[Integer, T::Array[Series]]
        ).returns(T::Hash[Integer, T::Array[Series]])
      end
      def group_by_round(series, depth = 0, series_by_depth = {})
        series_by_depth[depth] ||= []

        T.must(series_by_depth[depth]) << series

        series.contestants.each do |contestant|
          group_by_round(contestant, depth + 1, series_by_depth) if contestant.is_a?(Series)
        end

        series_by_depth
      end
    end
  end
end
